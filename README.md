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
### Launcher  
  
| Keybind | Action |  
|---------|--------|  
| `Super` (press & release) | Open launcher |  
  
---  
  
### Applications  
  
| Keybind | Action |  
|---------|--------|  
| `Super + T` | Terminal (foot) |  
| `Super + W` | Browser (firefox) |  
| `Super + C` | Editor (codium) |  
| `Super + E` | File explorer (thunar) |  
| `Ctrl + Alt + V` | Audio settings (pavucontrol) |  
  
---  
  
### Workspaces  
  
| Keybind | Action |  
|---------|--------|  
| `Super + 1~9, 0` | Go to workspace 1~10 |  
| `Super + Alt + 1~9, 0` | Move window to workspace 1~10 |  
| `Ctrl + Super + 1~9, 0` | Go to workspace group (×10) |  
| `Ctrl + Super + Alt + 1~9, 0` | Move window to workspace group |  
| `Ctrl + Super + Right` | Next workspace |  
| `Ctrl + Super + Left` | Previous workspace |  
| `Super + Page_Up` | Previous workspace |  
| `Super + Page_Down` | Next workspace |  
| `Super + Scroll Up/Down` | Switch workspace |  
| `Ctrl + Super + Scroll Up/Down` | Switch workspace group |  
  
---  
  
### Special Workspaces  
  
| Keybind | Action |  
|---------|--------|  
| `Super + S` | Toggle special workspace |  
| `Ctrl + Shift + Escape` | Toggle system monitor workspace |  
| `Super + M` | Toggle music workspace |  
| `Super + D` | Toggle communication workspace |  
| `Super + R` | Toggle todo workspace |  
| `Super + Alt + S` | Move window to special workspace |  
| `Ctrl + Super + Shift + Up` | Move window to special workspace |  
| `Ctrl + Super + Shift + Down` | Move window out of special workspace |  
  
---  
  
### Window Actions  
  
| Keybind | Action |  
|---------|--------|  
| `Super + Arrow Keys` | Focus window in direction |  
| `Super + Shift + Arrow Keys` | Move window in direction |  
| `Super + Alt + Arrow Keys` | Resize window |  
| `Super + -` / `Super + =` | Decrease/increase window width |  
| `Super + Shift + -` / `Super + Shift + =` | Decrease/increase window height |  
| `Super + Alt + Page_Up/Down` | Move window to prev/next workspace |  
| `Super + Alt + Scroll Up/Down` | Move window to prev/next workspace |  
| `Ctrl + Super + Shift + Right/Left` | Move window to next/prev workspace |  
| `Super + Q` | Close window |  
| `Super + F` | Fullscreen |  
| `Super + Alt + F` | Maximized (bordered fullscreen) |  
| `Super + Alt + Space` | Toggle floating |  
| `Super + P` | Pin window |  
| `Super + Alt + \` | Picture-in-picture mode |  
| `Ctrl + Super + \` | Center window |  
| `Ctrl + Super + Alt + \` | Resize to 55×70% of screen and center |  
| `Super + LMB drag` / `Super + Z + LMB` | Drag window |  
| `Super + RMB drag` / `Super + X + LMB` | Resize window |  
  
---  
  
### Window Groups  
  
| Keybind | Action |  
|---------|--------|  
| `Super + ,` | Toggle group |  
| `Super + U` | Move window out of group |  
| `Super + Shift + ,` | Lock active group |  
| `Alt + Tab` | Cycle next in group |  
| `Shift + Alt + Tab` | Cycle prev in group |  
| `Ctrl + Alt + Tab` | Next group |  
| `Ctrl + Shift + Alt + Tab` | Previous group |  
  
---  
  
### Media Controls  
  
| Keybind | Action |  
|---------|--------|  
| `Ctrl + Super + Space` / `XF86AudioPlay/Pause` | Play/pause |  
| `Ctrl + Super + =` / `XF86AudioNext` | Next track |  
| `Ctrl + Super + -` / `XF86AudioPrev` | Previous track |  
| `XF86AudioStop` | Stop playback |  
  
---  
  
### Volume  
  
| Keybind | Action |  
|---------|--------|  
| `XF86AudioRaiseVolume` | Volume +10% |  
| `XF86AudioLowerVolume` | Volume -10% |  
| `XF86AudioMute` / `Super + Shift + M` | Toggle mute (output) |  
| `XF86AudioMicMute` | Toggle mute (microphone) |  
  
---  
  
### Brightness  
  
| Keybind | Action |  
|---------|--------|  
| `XF86MonBrightnessUp` | Increase brightness |  
| `XF86MonBrightnessDown` | Decrease brightness |  
  
---  
  
### Screenshot / Screen Recording  
  
| Keybind | Action |  
|---------|--------|  
| `Print` | Screenshot |  
| `Super + Shift + S` | Freeze screen then screenshot |  
| `Super + Shift + Alt + S` | Screenshot (alternate mode) |  
| `Super + Alt + R` | Record selection |  
| `Ctrl + Alt + R` | Record fullscreen |  
| `Super + Shift + Alt + R` | Stop recording |  
| `Super + Shift + C` | Color picker (hyprpicker) |  
  
---  
  
### Clipboard / Emoji  
  
| Keybind | Action |  
|---------|--------|  
| `Super + V` | Open clipboard history |  
| `Super + Alt + V` | Open clipboard history (delete mode) |  
| `Super + .` | Open emoji picker |  
| `Ctrl + Shift + Alt + V` | Paste latest clipboard entry (ydotool) |  
  
---  
  
### UI / Shell  
  
| Keybind | Action |  
|---------|--------|  
| `Super + N` | Toggle sidebar |  
| `Super + K` | Show all panels |  
| `Ctrl + Alt + C` | Clear notifications |  
| `Ctrl + Super + Shift + R` | Kill shell |  
| `Ctrl + Super + Alt + R` | Restart shell |  
  
---  
  
### Lock / Session  
  
| Keybind | Action |  
|---------|--------|  
| `Super + L` | Lock screen |  
| `Super + Alt + L` | Restart shell and lock |  
| `Super + Shift + L` | Sleep (suspend-then-hibernate) |  
| `Ctrl + Alt + Delete` | Open session menu |  
  
---  
  
> [!NOTE]
> Most keybinds can be customized by overriding the corresponding `kb*` variables in `~/.config/caelestia/hypr-vars.lua`.
