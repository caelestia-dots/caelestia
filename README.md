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

Here's a list of useful keybinds though:

| Keybind                        | Action                                                      |
| ------------------------------ | ----------------------------------------------------------- |
| `Super`                        | Open launcher                                               |
| `Super` + `#`                  | Switch to workspace `#`                                     |
| `Super` + `Alt` + `#`          | Move window to workspace `#`                                |
| `Super` + `T`                  | Open terminal (default: foot)                               |
| `Super` + `W`                  | Open browser (default: firefox)                             |
| `Super` + `C`                  | Open IDE (default: vscodium)                                |
| `Super` + `S`                  | Toggle special workspace or close current special workspace |
| `Ctrl` + `Alt` + `Delete`      | Open session menu                                           |
| `Ctrl` + `Super` + `Space`     | Toggle media play state                                     |
| `Ctrl` + `Super` + `Alt` + `R` | Restart the shell                                           |
