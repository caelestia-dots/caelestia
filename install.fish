#!/usr/bin/env fish

argparse -n 'install.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'spotify' \
    'vscode=?!contains -- "$_flag_value" codium code' \
    'discord' \
    'zen' \
    'aur-helper=!contains -- "$_flag_value" yay paru' \
    -- $argv
or exit

# Print help
if set -q _flag_h
    echo 'usage: ./install.sh [-h] [--noconfirm] [--spotify] [--vscode] [--discord] [--aur-helper]'
    echo
    echo 'options:'
    echo '  -h, --help                  show this help message and exit'
    echo '  --noconfirm                 do not confirm package installation'
    echo '  --spotify                   install Spotify (Spicetify)'
    echo '  --vscode=[codium|code]      install VSCodium (or VSCode)'
    echo '  --discord                   install Discord (OpenAsar + Equicord)'
    echo '  --zen                       install Zen browser'
    echo '  --aur-helper=[yay|paru]     the AUR helper to use'

    exit
end


# Helper funcs
function _out -a colour text
    set_color $colour
    # Pass arguments other than text to echo
    echo $argv[3..] -- ":: $text"
    set_color normal
end

function log -a text
    _out cyan $text $argv[2..]
end

function input -a text
    _out blue $text $argv[2..]
end

function sh-read
    sh -c 'read a && echo -n "$a"' || exit 1
end

function confirm-overwrite -a path
    if test -e $path -o -L $path
        # No prompt if noconfirm
        if set -q noconfirm
            input "$path already exists. Overwrite? [Y/n]"
            log 'Removing...'
            rm -rf $path
        else
            # Prompt user
            input "$path already exists. Overwrite? [Y/n] " -n
            set -l confirm (sh-read)

            if test "$confirm" = 'n' -o "$confirm" = 'N'
                log 'Skipping...'
                return 1
            else
                log 'Removing...'
                rm -rf $path
            end
        end
    end

    return 0
end


# Variables
set -q _flag_noconfirm && set noconfirm '--noconfirm'
set -q _flag_aur_helper && set -l aur_helper $_flag_aur_helper || set -l aur_helper paru
set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME || set -l config $HOME/.config
set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state
set -q XDG_DATA_HOME && set -l data $XDG_DATA_HOME || set -l data $HOME/.local/share

# Startup prompt
set_color magenta
echo '╭─────────────────────────────────────────────────╮'
echo '│      ______           __          __  _         │'
echo '│     / ____/___ ____  / /__  _____/ /_(_)___ _   │'
echo '│    / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/   │'
echo '│   / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /    │'
echo '│   \____/\__,_/\___/_/\___/____/\__/_/\__,_/     │'
echo '│                                                 │'
echo '╰─────────────────────────────────────────────────╯'
set_color normal
log 'Welcome to the Caelestia dotfiles installer!'
log 'Before continuing, please ensure you have made a backup of your config directory.'

# Prompt for backup
if ! set -q _flag_noconfirm
    log '[1] Two steps ahead of you!  [2] Make one for me please!'
    input '=> ' -n
    set -l choice (sh-read)

    if contains -- "$choice" 1 2
        if test $choice = 2
            log "Backing up $config..."

            if test -e $config.bak -o -L $config.bak
                input 'Backup already exists. Overwrite? [Y/n] ' -n
                set -l overwrite (sh-read)

                if test "$overwrite" = 'n' -o "$overwrite" = 'N'
                    log 'Skipping...'
                else
                    rm -rf $config.bak
                    cp -r $config $config.bak
                end
            else
                cp -r $config $config.bak
            end
        end
    else
        log 'No choice selected. Exiting...'
        exit 1
    end
end


# Install AUR helper if not already installed
if ! pacman -Q $aur_helper &> /dev/null
    log "$aur_helper not installed. Installing..."

    # Install
    sudo pacman -S --needed git base-devel $noconfirm
    cd /tmp
    git clone https://aur.archlinux.org/$aur_helper.git
    cd $aur_helper
    makepkg -si
    cd ..
    rm -rf $aur_helper

    # Setup
    if test $aur_helper = yay
        $aur_helper -Y --gendb
        $aur_helper -Y --devel --save
    else
        $aur_helper --gendb
    end
end

# Cd into dir
cd (dirname (status filename)) || exit 1

# Install metapackage for deps
log 'Installing metapackage...'
if test $aur_helper = yay
    $aur_helper -Bi . $noconfirm
else
    $aur_helper -Ui $noconfirm
end
fish -c 'rm -f caelestia-meta-*.pkg.tar.zst' 2> /dev/null

# Setup greetd login manager
if systemctl is-enabled greetd &>/dev/null
    log 'greetd already enabled, skipping login manager setup.'
else
    log 'Setting up greetd login manager...'

    # Disable any other display manager if active
    for dm in sddm gdm lightdm lxdm
        if systemctl is-enabled $dm &>/dev/null
            log "Disabling $dm..."
            sudo systemctl disable $dm
        end
    end

    # Write config and enable
    sudo mkdir -p /etc/greetd
    sudo cp (realpath greetd/config.toml) /etc/greetd/config.toml
    sudo systemctl enable greetd
    log 'greetd enabled.'
end

# Detect and install Nvidia drivers
if lspci -k | grep -qiE "(VGA|3D).*nvidia"
    log (string join '' 'Nvidia GPU detected: ' (lspci -k | grep -iE "(VGA|3D).*nvidia" | awk -F ': ' '{print $NF}' | head -1))
    log 'Installing Nvidia drivers...'

    # Kernel headers for all running kernels
    for kbase in /usr/lib/modules/*/pkgbase
        $aur_helper -S --needed (cat $kbase)-headers $noconfirm
    end

    # Driver + Wayland support packages
    $aur_helper -S --needed nvidia-dkms nvidia-utils egl-wayland $noconfirm

    # Early module loading (needed for Wayland DRM)
    if ! grep -q 'nvidia' /etc/mkinitcpio.conf
        sudo sed -i '/MODULES=/ s/)$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        sudo mkinitcpio -P
    end

    # DRM modeset kernel parameter
    if ! test -f /etc/modprobe.d/nvidia.conf; or ! grep -q 'modeset=1' /etc/modprobe.d/nvidia.conf
        echo 'options nvidia-drm modeset=1 fbdev=1' | sudo tee -a /etc/modprobe.d/nvidia.conf
    end

    # Source nvidia.conf in Hyprland via user config
    set -l user_conf $HOME/.config/caelestia/hypr-user.conf
    mkdir -p (dirname $user_conf)
    touch -a $user_conf
    if ! grep -q 'nvidia.conf' $user_conf
        echo 'source = $hl/nvidia.conf' >> $user_conf
    end

    log 'Nvidia setup complete.'
else
    log 'No Nvidia GPU detected, skipping driver installation.'
end

# Install hypr* configs
if confirm-overwrite $config/hypr
    log 'Installing hypr* configs...'
    ln -s (realpath hypr) $config/hypr
    hyprctl reload
end

# Starship
if confirm-overwrite $config/starship.toml
    log 'Installing starship config...'
    ln -s (realpath starship.toml) $config/starship.toml
end

# Maple Mono NF (custom build, bundled in repo)
set -l font_dir $HOME/.local/share/fonts/MapleMono-NF
if ! test -d $font_dir
    log 'Installing Maple Mono NF fonts...'
    mkdir -p $font_dir
    cp (realpath fonts/MapleMono-NF)/*.ttf $font_dir/
    fc-cache -f $font_dir
end

# Kitty
if confirm-overwrite $config/kitty
    log 'Installing kitty config...'
    ln -s (realpath kitty) $config/kitty
end

# Fish
if confirm-overwrite $config/fish
    log 'Installing fish config...'
    ln -s (realpath fish) $config/fish
end

# Fastfetch
if confirm-overwrite $config/fastfetch
    log 'Installing fastfetch config...'
    ln -s (realpath fastfetch) $config/fastfetch
end

# Uwsm
if confirm-overwrite $config/uwsm
    log 'Installing uwsm config...'
    ln -s (realpath uwsm) $config/uwsm
end

# Btop
if confirm-overwrite $config/btop
    log 'Installing btop config...'
    ln -s (realpath btop) $config/btop
end

# Kvantum
mkdir -p $config/Kvantum
if confirm-overwrite $config/Kvantum/kvantum.kvconfig
    log 'Installing Kvantum config...'
    ln -s (realpath Kvantum/kvantum.kvconfig) $config/Kvantum/kvantum.kvconfig
end

# Dracula Kvantum theme (inside dracula/gtk repo under kde/kvantum/)
if ! test -d $config/Kvantum/Dracula
    log 'Installing Dracula Kvantum theme...'
    curl -sL https://github.com/dracula/gtk/archive/refs/heads/master.tar.gz \
        | tar -xz -C /tmp/ --wildcards '*/kde/kvantum/Dracula/*' --strip-components=3
    cp -r /tmp/Dracula $config/Kvantum/
    rm -rf /tmp/Dracula
end

# Qt5ct
if confirm-overwrite $config/qt5ct
    log 'Installing qt5ct config...'
    ln -s (realpath qt5ct) $config/qt5ct
end

# Qt6ct
if confirm-overwrite $config/qt6ct
    log 'Installing qt6ct config...'
    ln -s (realpath qt6ct) $config/qt6ct
end

# Dolphin
if confirm-overwrite $config/dolphinrc
    log 'Installing dolphin config...'
    ln -s (realpath dolphinrc) $config/dolphinrc
end
xdg-mime default org.kde.dolphin.desktop inode/directory

# Dolphin panel layout (sidebar position, toolbar)
if confirm-overwrite $state/dolphinstaterc
    log 'Installing dolphin state (panel layout)...'
    mkdir -p $state
    ln -s (realpath dolphin/dolphinstaterc) $state/dolphinstaterc
end
if confirm-overwrite $data/kxmlgui5/dolphin/dolphinui.rc
    log 'Installing dolphin UI layout...'
    mkdir -p $data/kxmlgui5/dolphin
    ln -s (realpath dolphin/kxmlgui5/dolphinui.rc) $data/kxmlgui5/dolphin/dolphinui.rc
end
if confirm-overwrite $data/dolphin/view_properties/global/.directory
    log 'Installing dolphin view properties...'
    mkdir -p $data/dolphin/view_properties/global
    ln -s (realpath dolphin/view_properties/global/.directory) $data/dolphin/view_properties/global/.directory
end

# KDE globals (transparent view, kitty terminal, Papirus icons)
if confirm-overwrite $config/kdeglobals
    log 'Installing kdeglobals...'
    ln -s (realpath kdeglobals) $config/kdeglobals
end

# Install spicetify
if set -q _flag_spotify
    log 'Installing spotify (spicetify)...'

    set -l has_spicetify (pacman -Q spicetify-cli 2> /dev/null)
    $aur_helper -S --needed spotify spicetify-cli spicetify-marketplace-bin $noconfirm

    # Set permissions and init if new install
    if test -z "$has_spicetify"
        sudo chmod a+wr /opt/spotify
        sudo chmod a+wr /opt/spotify/Apps -R
        spicetify backup apply
    end

    # Install configs
    if confirm-overwrite $config/spicetify
        log 'Installing spicetify config...'
        ln -s (realpath spicetify) $config/spicetify

        # Set spicetify configs
        spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace 2> /dev/null
        spicetify apply
    end
end

# Install vscode
if set -q _flag_vscode
    test "$_flag_vscode" = 'code' && set -l prog 'code' || set -l prog 'codium'
    test "$_flag_vscode" = 'code' && set -l packages 'code' || set -l packages 'vscodium-bin' 'vscodium-bin-marketplace'
    test "$_flag_vscode" = 'code' && set -l folder 'Code' || set -l folder 'VSCodium'
    set -l folder $config/$folder/User

    log "Installing vs$prog..."
    $aur_helper -S --needed $packages $noconfirm

    # Install configs
    if confirm-overwrite $folder/settings.json && confirm-overwrite $folder/keybindings.json && confirm-overwrite $config/$prog-flags.conf
        log "Installing vs$prog config..."
        ln -s (realpath vscode/settings.json) $folder/settings.json
        ln -s (realpath vscode/keybindings.json) $folder/keybindings.json
        ln -s (realpath vscode/flags.conf) $config/$prog-flags.conf

        # Install extension
        $prog --install-extension vscode/caelestia-vscode-integration/caelestia-vscode-integration-*.vsix
    end
end

# Install discord
if set -q _flag_discord
    log 'Installing discord...'
    $aur_helper -S --needed discord equicord-installer-bin $noconfirm

    # Install OpenAsar and Equicord
    sudo Equilotl -install -location /opt/discord
    sudo Equilotl -install-openasar -location /opt/discord

    # Remove installer
    $aur_helper -Rns equicord-installer-bin $noconfirm
end

# Install zen
if set -q _flag_zen
    log 'Installing zen...'
    $aur_helper -S --needed zen-browser-bin $noconfirm

    # Set as default browser
    xdg-settings set default-web-browser zen.desktop
    for mime in text/html x-scheme-handler/http x-scheme-handler/https \
                application/x-extension-html application/xhtml+xml
        xdg-mime default zen.desktop $mime
    end

    # Install userChrome css
    set -l chrome $HOME/.zen/*/chrome
    if confirm-overwrite $chrome/userChrome.css
        log 'Installing zen userChrome...'
        ln -s (realpath zen/userChrome.css) $chrome/userChrome.css
    end

    # Install native app
    set -l hosts $HOME/.mozilla/native-messaging-hosts
    set -l lib $HOME/.local/lib/caelestia

    if confirm-overwrite $hosts/caelestiafox.json
        log 'Installing zen native app manifest...'
        mkdir -p $hosts
        cp zen/native_app/manifest.json $hosts/caelestiafox.json
        sed -i "s|{{ \$lib }}|$lib|g" $hosts/caelestiafox.json
    end

    if confirm-overwrite $lib/caelestiafox
        log 'Installing zen native app...'
        mkdir -p $lib
        ln -s (realpath zen/native_app/app.fish) $lib/caelestiafox
    end

    # Prompt user to install extension
    log 'Please install the CaelestiaFox extension from https://addons.mozilla.org/en-US/firefox/addon/caelestiafox if you have not already done so.'
end

# Install quickshell overrides
set -l qs_overrides $HOME/quickshell-overrides/caelestia
set -l qs_config $config/quickshell/caelestia

if test -d $qs_overrides
    log 'Installing quickshell overrides...'
    for file in (find $qs_overrides -type f)
        set -l rel (string replace "$qs_overrides/" "" $file)
        set -l target $qs_config/$rel
        if confirm-overwrite $target
            mkdir -p (dirname $target)
            ln -s (realpath $file) $target
        end
    end
else
    log 'quickshell-overrides not found. Cloning...'
    git clone git@github.com:soyeb-jim285/quickshell-overrides.git $HOME/quickshell-overrides
    log 'Installing quickshell overrides...'
    for file in (find $qs_overrides -type f)
        set -l rel (string replace "$qs_overrides/" "" $file)
        set -l target $qs_config/$rel
        if confirm-overwrite $target
            mkdir -p (dirname $target)
            ln -s (realpath $file) $target
        end
    end
end

# Generate scheme stuff if needed
if ! test -f $state/caelestia/scheme.json
    caelestia scheme set -n shadotheme
    sleep .5
    hyprctl reload
end

# Start the shell
caelestia shell -d > /dev/null

log 'Done!'
