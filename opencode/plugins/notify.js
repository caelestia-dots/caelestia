import { homedir } from "node:os"
import { mkdir, writeFile } from "node:fs/promises"

const APP = "opencode"
const USE_APP_ICON = true
const SUPPRESS_WHEN_TERMINAL_FOCUSED = true
const TERMINAL_CLASSES = [
  "kitty",
  "alacritty",
  "foot",
  "footclient",
  "wezterm",
  "ghostty",
  "org.wezfurlong.wezterm",
  "com.mitchellh.ghostty",
  "st",
  "st-256color",
  "konsole",
  "xterm",
  "xterm-256color",
  "caelestia-term",
]

const ICON_SVG = `<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
<rect width="512" height="512" fill="#131010"/>
<path d="M320 224V352H192V224H320Z" fill="#5A5858"/>
<path fill-rule="evenodd" d="M384 416H128V96H384V416ZM320 160H192V352H320V160Z" fill="#FFFFFF"/>
</svg>`

const ICON_THEME_DIR = `${homedir()}/.local/share/icons/hicolor/scalable/apps`
const ICON_CACHE_DIR = `${homedir()}/.cache/opencode-caelestia-notify`

const debugLog = async ($, line) => {
  const file = process.env.OPENCODE_NOTIFY_DEBUG
  if (!file) return
  await $`sh -c ${`echo ${JSON.stringify(line)} >> ${file}`}`.quiet().catch(() => {})
}

const focusedTerminal = async ($) => {
  if (!SUPPRESS_WHEN_TERMINAL_FOCUSED) return false
  if (process.env.OPENCODE_NOTIFY_NO_SUPPRESS === "1") return false
  try {
    const win = await $`hyprctl -j activewindow`.json()
    return TERMINAL_CLASSES.some((c) => (win?.class || "").toLowerCase() === c.toLowerCase())
  } catch {
    return false
  }
}

const installIcon = async ($) => {
  if (!USE_APP_ICON) return null
  try {
    await mkdir(ICON_THEME_DIR, { recursive: true })
    await writeFile(`${ICON_THEME_DIR}/${APP}.svg`, ICON_SVG)
    await $`gtk-update-icon-cache -f -t ${homedir()}/.local/share/icons/hicolor`.quiet().catch(() => {})
    await mkdir(ICON_CACHE_DIR, { recursive: true })
    await writeFile(`${ICON_CACHE_DIR}/${APP}.svg`, ICON_SVG)
    return APP
  } catch {
    try {
      await mkdir(ICON_CACHE_DIR, { recursive: true })
      await writeFile(`${ICON_CACHE_DIR}/${APP}.svg`, ICON_SVG)
      return `${ICON_CACHE_DIR}/${APP}.svg`
    } catch {
      return null
    }
  }
}

export const NotifyPlugin = async ({ client, $, directory }) => {
  const seenPermissions = new Set()
  const recent = new Map()
  const DEDUPE_WINDOW_MS = 3000
  const appIcon = await installIcon($)
  if (!appIcon) await debugLog($, `${new Date().toISOString()} icon install failed, using symbolic fallback`)

  const isDuplicate = (key) => {
    if (!key) return false
    const now = Date.now()
    if (now - (recent.get(key) || 0) < DEDUPE_WINDOW_MS) return true
    recent.set(key, now)
    if (recent.size > 100) recent.delete(recent.keys().next().value)
    return false
  }

  const sessionTitle = async (sessionID) => {
    try {
      const res = await client.session.get({ path: { id: sessionID } })
      return res?.data?.title || res?.title || null
    } catch {
      return null
    }
  }

  const notify = async ({ key, title, body, urgency = "normal", icon = "dialog-information-symbolic" }) => {
    if (isDuplicate(key)) {
      await debugLog($, `${new Date().toISOString()} suppressed (duplicate) ${title} | ${body}`)
      return
    }
    const args = ["-u", urgency, "-a", APP]
    args.push("-i", appIcon || icon)
    args.push("-h", `string:x-canonical-private-synchronous:${APP}`, title, body)
    await $`notify-send ${args}`.quiet().catch(() => {})
    await debugLog($, `${new Date().toISOString()} [${urgency}] icon=${appIcon || icon} ${title} | ${body}`)
  }

  return {
    event: async ({ event }) => {
      const props = event.properties || {}
      const sessionID = props.sessionID

      switch (event.type) {
        case "session.idle": {
          if (await focusedTerminal($)) {
            await debugLog($, `${new Date().toISOString()} suppressed (terminal focused)`)
            break
          }
          const title = (await sessionTitle(sessionID)) || directory.split("/").pop() || "Task"
          await notify({
            key: `idle:${sessionID}`,
            title: `${APP}: ready`,
            body: title,
            icon: "dialog-information-symbolic",
          })
          break
        }

        case "session.error": {
          const err = props.error || {}
          const detail =
            err?.data?.message ||
            err?.message ||
            err?.name ||
            "Something went wrong"
          const title = (await sessionTitle(sessionID)) || directory.split("/").pop() || "Task"
          await notify({
            key: `error:${sessionID}`,
            title: `${APP}: error`,
            body: `${title}\n${detail}`,
            urgency: "critical",
            icon: "dialog-error-symbolic",
          })
          break
        }

        case "permission.asked":
        case "permission.updated": {
          const key = `${sessionID}:${props.permissionID || props.id || props.title || ""}`
          if (seenPermissions.has(key)) break
          seenPermissions.add(key)
          if (seenPermissions.size > 100) seenPermissions.delete(seenPermissions.keys().next().value)
          const what = props.title || props.type || "Permission needed"
          const title = (await sessionTitle(sessionID)) || directory.split("/").pop() || "Task"
          await notify({
            key: `perm:${key}`,
            title: `${APP}: waiting for you`,
            body: `${what}\n${title}`,
            urgency: "critical",
            icon: "dialog-password-symbolic",
          })
          break
        }

        case "question.asked": {
          const q = props.question?.question || props.question || "OpenCode has a question"
          const title = (await sessionTitle(sessionID)) || directory.split("/").pop() || "Task"
          await notify({
            key: `question:${sessionID}`,
            title: `${APP}: question for you`,
            body: `${String(q).slice(0, 200)}\n${title}`,
            urgency: "critical",
            icon: "dialog-question-symbolic",
          })
          break
        }
      }
    },
  }
}
