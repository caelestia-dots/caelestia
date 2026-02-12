# Caelestia

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/caelestia-dots/caelestia/graphs/commit-activity)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![AUR](https://img.shields.io/aur/version/caelestia-shell?color=1793D1&label=AUR%20Package)](https://aur.archlinux.org/packages/caelestia-shell)

> This is the main repo of the caelestia dots and contains the user configs for apps. This repo also includes an install script to install the entire dots.

## Screenshots

| ![Main Desktop](screenshots/main.png) | 
|:--:| 
| *Caelestia Desktop Environment* |

| ![Screenshot 1](screenshots/20251020210630.png) |
|:--:|
| *Application View* | *Terminal Workflow* |

| ![Screenshot 2](screenshots/20251020210651.png) | ![Screenshot 3](screenshots/20251020210714.png) |
|:--:|:--:|
| *Customization* | *All Tabs* |

## Features

-  **Hyprland** - A dynamic tiling Wayland compositor
-  **Fish Shell** with Starship prompt for a modern terminal experience
-  Consistent theming across all applications
-  Optimized for performance and productivity
-  Easy installation and configuration
-  Works out of the box with sensible defaults

##  Installation

### Prerequisites

- [Fish shell](https://github.com/fish-shell/fish-shell)
- Git
- An AUR helper (yay or paru) for Arch Linux users

### Quick Install (Recommended)

```bash
git clone https://github.com/caelestia-dots/caelestia.git ~/.local/share/caelestia
~/.local/share/caelestia/install.fish
```

> [!WARNING]
> The install script symlinks all configs into place, so you CANNOT
> move/remove the repo folder once you run the install script. If
> you do, most apps will not behave properly and some (e.g. Hyprland)
> will fail to start completely. I recommend cloning the repo to
> `~/.local/share/caelestia`.
### Installation Options

The install script includes several options:

```bash
$ ./install.fish -h
Usage: ./install.fish [OPTIONS]

Options:
  -h, --help                  Show this help message
  --noconfirm                 Skip confirmation prompts
  --spotify                   Install Spotify with Spicetify
  --vscode=[codium|code]      Install VSCodium or VSCode
  --discord                   Install Discord with OpenAsar + Equicord
  --zen                       Install Zen browser
  --aur-helper=[yay|paru]     Specify AUR helper (default: auto-detect)
```

### Manual Installation

For manual installation, you'll need to install the following dependencies:

#### Core Dependencies

```bash
# Core Components
hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
hyprpicker wl-clipboard cliphist inotify-tools app2unit
wireplumber trash-cli

# Terminal & Shell
foot fish fastfetch starship btop jq eza

# Theming
adw-gtk-theme papirus-icon-theme qt5ct-kde qt6ct-kde ttf-jetbrains-mono-nerd
```

> [!TIP]
> If on Arch or an Arch-based distro, there is a meta package available [in this repository](PKGBUILD)
> that pulls in all dependencies. It can be installed through the install script, makepkg/pacman, yay,
> paru, or your preferred AUR helper.



#### Configuration Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/caelestia-dots/caelestia.git ~/.local/share/caelestia
   ```

2. Create symlinks for configuration files:
   ```bash
   ln -sf ~/.local/share/caelestia/{hypr,foot,fish,fastfetch,uwsm,btop} ~/.config/
   ln -sf ~/.local/share/caelestia/starship.toml ~/.config/
   ```

##  Application-Specific Setup

###  Spicetify (Spotify)

```bash
spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace
spicetify apply
```

###  VSCode/VSCodium

1. Symlink configuration files:
   ```bash
   mkdir -p ~/.config/Code/User  # or ~/.config/VSCodium/User for VSCodium
   ln -sf ~/.local/share/caelestia/vscode/{settings.json,keybindings.json} ~/.config/Code/User/
   ln -sf ~/.local/share/caelestia/vscode/flags.conf ~/.config/code-flags.conf
   ```

2. Install the Caelestia extension:
   ```bash
   code --install-extension vscode/caelestia-vscode-integration/caelestia-vscode-integration-*.vsix
   ```

###  Zen Browser

1. Install Zen Browser
2. Set up the theme:
   ```bash
   mkdir -p ~/.zen/<profile>/chrome
   ln -sf ~/.local/share/caelestia/zen/userChrome.css ~/.zen/<profile>/chrome/
   ```

3. Install the native app:
   ```bash
   mkdir -p ~/.mozilla/native-messaging-hosts
   cp ~/.local/share/caelestia/zen/native_app/manifest.json ~/.mozilla/native-messaging-hosts/caelestiafox.json
   # Edit the manifest to replace {{ $lib }} with the absolute path to ~/.local/lib/caelestia
   mkdir -p ~/.local/lib/caelestia
   ln -sf ~/.local/share/caelestia/zen/native_app/app.fish ~/.local/lib/caelestia/caelestiafox
   ```

4. Install the [CaelestiaFox](https://addons.mozilla.org/en-US/firefox/addon/caelestiafox) extension

##  Updating

To update Caelestia and all dependencies:

```bash
# Update AUR packages (Arch Linux)
yay -Syu

# Update Caelestia configuration
cd ~/.local/share/caelestia
git pull
```

##  Keybindings And Usage

| Key Combination | Action |
|----------------|--------|
| `Super` | Open application launcher |
| `Super` + `#` | Switch to workspace # |
| `Super` + `Alt` + `#` | Move window to workspace # |
| `Super` + `T` | Open terminal (foot) |
| `Super` + `W` | Open browser (Zen) |
| `Super` + `C` | Open IDE (VSCodium) |
| `Super` + `S` | Toggle special workspace |
| `Ctrl` + `Alt` + `Delete` | Open session menu |
| `Ctrl` + `Super` + `Space` | Toggle media play state |
| `Ctrl` + `Super` + `Alt` + `R` | Restart the shell |

> [!NOTE]
> These dots do not contain a login manager (for now), so you must install a
> login manager yourself unless you want to log in from a TTY. I recommend
> [`greetd`](https://sr.ht/~kennylevinsen/greetd) with
> [`tuigreet`](https://github.com/apognu/tuigreet), however you can use
> any login manager you want.


##  Acknowledgments

- [Hyprland](https://hyprland.org/) - The amazing Wayland compositor
- [Fish shell](https://fishshell.com/) - A smart and user-friendly shell
- [Starship](https://starship.rs/) - A minimal, blazing-fast prompt
- And all the amazing open-source projects that make this possible!
