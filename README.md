# caelestia

This is the main repo of the Caelestia dotfiles and contains user configs for
various apps.

> [!IMPORTANT]
> The legacy `install.fish` script in this repo has been removed in favour
> of the [CLI][cli-repo]'s install command.
>
> If you have an existing installation with the legacy script, please update
> the CLI and run the install command to complete the migration.

> [!IMPORTANT]
> We have switched to using Lua for the Hyprland config!
> For everyone with a custom `~/.config/caelestia/hypr-user.conf`
> or `~/.config/caelestia/hypr-vars.conf`, please convert it to Lua
> either manually or using one of the available converters online.
>
> For more information on using these files, see the [Configuring](#configuring) section.

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
> [`tuigreet`](https://github.com/apognu/tuigreet); however, you can use
> any login manager you want.

## Configuring

> [!CAUTION]
> You should never modify any files inside `~/.config/hypr/`, as this will cause conflicts during updates to the dots.
>
> Any personal changes should be made in `~/.config/caelestia/hypr-user.lua` or `hypr-vars.lua`, as
> the installation/update workflows never modify these files. Writing your own changes to files in `~/.config/hypr/`
> will prevent new updates from being applied, and you will have to reconcile conflicts every time you update manually.

### hypr-vars.lua

Most default Hyprland values can be modified by overriding variables in `~/.config/caelestia/hypr-vars.lua`. You can use this file to set
default apps, keybinds, mouse cursor, window decorations, and much more.
Use the [`variables.lua`](hypr/variables.lua) file as a reference for all available variables and their default values.

Example usage for `hypr-vars.lua`:

```lua
return {
  -- Changing default apps:
  browser          = "zen-browser",    -- Change default browser to Zen
  editor           = "code",           -- Change default editor to Code

  -- Changing window/decoration properties:
  blurEnabled      = false,            -- Disable window blur
  windowBorderSize = 3,                -- Increase window border size (default: 1)

  -- Changing keybinds:
  kbTerminal       = "SUPER + Return", -- Change the keybind for opening terminal
}
```

### hypr-user.lua

You can put any custom Hyprland configuration in `~/.config/caelestia/hypr-user.lua`. This file is loaded at the end of the Hyprland
loading sequence. This allows you to customise the behavior of Hyprland outside of the premade configs, including monitor layout, additional
keybinds, and window rules. It is preferable to use `hypr-vars.lua` for changes to options that the dots already manage
(e.g. keybinds, window borders, etc.). Still, for configuration that isn't covered by dots or needs to be managed outside variables,
any changes should be made in `hypr-user.lua`.
You can read more about configuring Hyprland on their [wiki](https://wiki.hypr.land/Configuring/Start/).

### Additional configuration

Caelestia is a multifaceted ecosystem comprising the dotfiles (this repo), the [shell][shell-repo], and the [CLI][cli-repo].
The shell’s configuration is managed by `~/.config/caelestia/shell.json`, which modifies the shell’s behavior.
The CLI config file (`~/.config/caelestia/cli.json`) lets you adjust the CLI’s theming and handling of special workspaces.
You can find more information on configuring the shell and the CLI in their respective repos.

## Default keybinds

> [!TIP]
> All keybinds can be customised by overriding their corresponding variables in `hypr-vars.lua` (excluding the shell restart/kill binds).
> See [Configuring](#configuring) for more information.

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

[shell-repo]: https://github.com/caelestia-dots/shell
[cli-repo]: https://github.com/caelestia-dots/cli
