# caelestia

This is the main repo of the caelestia dots and contains user configs for
various apps.

> [!IMPORTANT]
> The legacy `install.fish` script in this repo has been deprecated in favour
> of the [CLI](https://github.com/caelestia-dots/cli)'s install command.
>
> If you have an existing installation with the legacy script, please update
> the CLI and run the install command to migrate.

> [!IMPORTANT]
> We have switched to using Lua for the Hyprland config!
> For everyone with a custom `~/.config/caelestia/hypr-user.conf`
> or `~/.config/caelestia/hypr-vars.conf`, please convert it to Lua
> either manually, or using one of the available converters online.
>
> Usage for `hypr-vars.lua`:
>
> ```lua
> return {
>   browser = "chromium",
> }
> ```

## Installation (Arch Linux)

Install the CLI from the AUR, then run `caelestia install`.

For example:

```sh
paru -S caelestia-cli
caelestia install
```

### Manual installation

Clone this repo, then go through [the manifest](/manifest.toml) and install all packages from the
components that you want to enable, then copy all the entries from those components.

e.g. for the hyprland component:

```sh
git clone https://github.com/caelestia-dots/caelestia.git
cd caelestia
sudo pacman -S --needed hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ttf-jetbrains-mono-nerd
mkdir -p $XDG_CONFIG_HOME/hypr
cp -r hypr/. $XDG_CONFIG_HOME/hypr/
```

## Updating

Use `caelestia update` to perform a full system update and update the dots.

## Usage

> [!NOTE]
> These dots do not contain a login manager (for now), so you must install a
> login manager yourself unless you want to log in from a TTY. I recommend
> [`greetd`](https://sr.ht/~kennylevinsen/greetd) with
> [`tuigreet`](https://github.com/apognu/tuigreet), however you can use
> any login manager you want.

There aren't really any usage instructions... these are a set of dotfiles.

## Default Keybinds

> [!TIP]
> All keybinds can be customized by overriding the corresponding `kb*` variables in `~/.config/caelestia/hypr-vars.lua` (excluding the shell restart/kill binds).
> Reference [`hypr/variables.lua`](hypr/variables.lua) for available options.

### Launcher

| Keybind                   | Action        |
| ------------------------- | ------------- |
| `Super` (press & release) | Open launcher |

---

### Workspaces

| Keybind                                                                                | Action                               |
| -------------------------------------------------------------------------------------- | ------------------------------------ |
| `Super + 1~9, 0`                                                                       | Go to workspace 1~10                 |
| `Super + Alt + 1~9, 0`                                                                 | Move window to workspace 1~10        |
| `Ctrl + Super + 1~9, 0`                                                                | Go to workspace group (×10)          |
| `Ctrl + Super + Alt + 1~9, 0`                                                          | Move window to workspace group       |
| `Super + Alt + S`, `Ctrl + Super + Shift + Up`                                         | Move window to special workspace     |
| `Ctrl + Super + Shift + Down`                                                          | Move window out of special workspace |
| `Super + Alt + Scroll Down`, `Super + Alt + Page_Down`, `Ctrl + Super + Shift + Right` | Move window to next workspace        |
| `Super + Alt + Scroll Up`, `Super + Alt + Page_Up`, `Ctrl + Super + Shift + Left`      | Move window to previous workspace    |
| `Super + Scroll Down`, `Ctrl + Super + Right`, `Super + Page_Down`                     | Go to next workspace                 |
| `Super + Scroll Up`, `Ctrl + Super + Left`, `Super + Page_Up`                          | Go to previous workspace             |
| `Ctrl + Super + Scroll Down`                                                           | Go to next workspace group           |
| `Ctrl + Super + Scroll Up`                                                             | Go to previous workspace group       |

---

### Window groups

| Keybind                    | Action                         |
| -------------------------- | ------------------------------ |
| `Alt + Tab`                | Go to next window in group     |
| `Shift + Alt + Tab`        | Go to previous window in group |
| `Ctrl + Alt + Tab`         | Go to next group               |
| `Ctrl + Shift + Alt + Tab` | Go to previous group           |
| `Super + U`                | Move window out of group       |
| `Super + Comma`            | Toggle group                   |
| `Super + Shift + Comma`    | Lock active group              |

---

### Window actions

| Keybind                                       | Action                                       |
| --------------------------------------------- | -------------------------------------------- |
| `Super + Minus`, `Super + Alt + Left`         | Decrease window width                        |
| `Super + Equal`, `Super + Alt + Right`        | Increase window width                        |
| `Super + Shift + Minus`, `Super + Alt + Up`   | Decrease window height                       |
| `Super + Shift + Minus`, `Super + Alt + Down` | Increase window height                       |
| `Super + Left/Right/Up/Down`                  | Focus window in direction                    |
| `Super + Shift + Left/Right/Up/Down`          | Move window in direction                     |
| `Super + LMB drag`, `Super + Z + LMB`         | Move window (drag)                           |
| `Super + RMB drag`, `Super + X + LMB`         | Resize window (drag)                         |
| `Ctrl + Super + Backslash`                    | Center window                                |
| `Ctrl + Super + Alt + Backslash`              | Resize window to 55×70% of screen and center |
| `Super + Alt + Backslash`                     | Picture-in-picture mode                      |
| `Super + P`                                   | Pin window                                   |
| `Super + F`                                   | Fullscreen window                            |
| `Super + Alt + F`                             | Fullscreen window (bordered)                 |
| `Super + Alt + Space`                         | Toggle floating for window                   |
| `Super + Q`                                   | Close window                                 |

---

### Special workspace toggles

| Keybind                 | Action                          |
| ----------------------- | ------------------------------- |
| `Super + S`             | Toggle special workspace        |
| `Ctrl + Shift + Escape` | Toggle system monitor workspace |
| `Super + M`             | Toggle music workspace          |
| `Super + D`             | Toggle communication workspace  |
| `Super + R`             | Toggle todo workspace           |

---

### Applications

| Keybind          | Action                                |
| ---------------- | ------------------------------------- |
| `Super + T`      | Terminal (default: foot)              |
| `Super + W`      | Browser (default: firefox)            |
| `Super + C`      | Editor (default: codium)              |
| `Super + E`      | File explorer (default: thunar)       |
| `Ctrl + Alt + V` | Audio settings (default: pwvucontrol) |

---

### Utilities

| Keybind                   | Action              |
| ------------------------- | ------------------- |
| `Print`                   | Screenshot          |
| `Super + Shift + S`       | Screenshot (freeze) |
| `Super + Shift + Alt + S` | Screenshot (region) |
| `Ctrl + Alt + R`          | Record fullscreen   |
| `Super + Alt + R`         | Record with sound   |
| `Super + Shift + Alt + R` | Record region       |
| `Super + Shift + C`       | Color picker        |

---

### Media

| Keybind                    | Action         |
| -------------------------- | -------------- |
| `Ctrl + Super + Space`     | Play/pause     |
| `Ctrl + Super + Equal`     | Next track     |
| `Ctrl + Super + Minus`     | Previous track |
| `Ctrl + Super + Backspace` | Stop playback  |
| `Super + Shift + M`        | Mute volume    |

---

### Miscellaneous

| Keybind               | Action                    |
| --------------------- | ------------------------- |
| `Ctrl + Alt + Delete` | Open shell session menu   |
| `Super + N`           | Toggle shell sidebar      |
| `Ctrl + Alt + C`      | Clear shell notifications |
| `Super + K`           | Show all shell panels     |
| `Super + L`           | Lock screen               |
| `Super + Alt + L`     | Restore shell lockscreen  |
| `Super + Shift + L`   | Run sleep command         |

---

### Clipboard / Emoji

| Keybind                  | Action                               |
| ------------------------ | ------------------------------------ |
| `Super + V`              | Open clipboard history               |
| `Super + Alt + V`        | Open clipboard history (delete mode) |
| `Ctrl + Shift + Alt + V` | Paste latest clipboard entry         |
| `Super + Period`         | Open emoji picker                    |

---

### Shell

| Keybind                    | Action        |
| -------------------------- | ------------- |
| `Ctrl + Super + Alt + R`   | Restart shell |
| `Ctrl + Super + Shift + R` | Kill shell    |
