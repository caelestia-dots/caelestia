#!/usr/bin/env fish

argparse -n 'install.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'spotify' \
    'vscode=?!contains -- "$_flag_value" codium code' \
    'discord' \
    'zen' \
    'cursor' \
    'opencode' \
    'claude-code' \
    'aur-helper=!contains -- "$_flag_value" yay paru' \
    -- $argv
or exit

# Print help
if set -q _flag_h
    echo 'usage: ./install.sh [-h] [--noconfirm] [--spotify] [--vscode] [--discord] [--zen] [--cursor] [--opencode] [--claude-code] [--aur-helper]'
    echo
    echo 'options:'
    echo '  -h, --help                  show this help message and exit'
    echo '  --noconfirm                 do not confirm package installation'
    echo '  --spotify                   install Spotify (Spicetify)'
    echo '  --vscode=[codium|code]      install VSCodium (or VSCode)'
    echo '  --discord                   install Discord (OpenAsar + Equicord)'
    echo '  --zen                       install Zen browser'
    echo '  --cursor                    install Cursor AI editor'
    echo '  --opencode                  install OpenCode AI CLI'
    echo '  --claude-code               install Claude Code CLI'
    echo '  --aur-helper=[yay|paru]     the AUR helper to use'

    exit
end


# Helper funcs
function _out -a colour text
    set_color $colour
    # Pass arguments other than text to echo
    echo $argv[3..] -- ":: $text"
    set_color normal
    # Also write to log file (no colour codes)
    echo $argv[3..] -- ":: $text" >> $logfile
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
        if set -q overwrite_all; or set -q noconfirm
            rm -rf $path
        else
            input "$path already exists. Overwrite? [Y/n] " -n
            set -l confirm (sh-read)

            if test "$confirm" = 'n' -o "$confirm" = 'N'
                log 'Skipping...'
                return 1
            else
                rm -rf $path
            end
        end
    end

    return 0
end


# Log file (must be set before the begin block so 'end 2>> $logfile' can expand it)
if set -q XDG_STATE_HOME
    set -g logfile $XDG_STATE_HOME/caelestia/install-(date +%Y%m%d-%H%M%S).log
else
    set -g logfile $HOME/.local/state/caelestia/install-(date +%Y%m%d-%H%M%S).log
end
mkdir -p (dirname $logfile)
echo "=== Caelestia install log - $(date) ===" > $logfile

begin # stderr from all commands is redirected to the log file

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

    # Ask once: overwrite all existing configs?
    input 'Overwrite all existing configs without asking? [Y/n] ' -n
    set -l ow (sh-read)
    if test "$ow" != 'n' -a "$ow" != 'N'
        set -g overwrite_all
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
    sudo cp greetd/config.toml /etc/greetd/config.toml
    sudo systemctl enable greetd
    log 'greetd enabled.'
end

# Detect and install Nvidia drivers
if lspci -k | grep -qiE "(VGA|3D).*nvidia"
    log (string join '' 'Nvidia GPU detected: ' (lspci -k | grep -iE "(VGA|3D).*nvidia" | awk -F ': ' '{print $NF}' | head -1))
    log 'Installing Nvidia drivers...'

    # Kernel headers for all running kernels
    set -l kbases (string match -r '.*' /usr/lib/modules/*/pkgbase 2>/dev/null)
    if test (count $kbases) -eq 0
        log 'Warning: no kernel pkgbase files found in /usr/lib/modules — skipping header install.'
    else
        for kbase in $kbases
            if test -f $kbase
                set -l hdr_pkg (cat $kbase)-headers
                log "Installing kernel headers: $hdr_pkg"
                $aur_helper -S --needed $hdr_pkg $noconfirm 2>> $logfile
            end
        end
    end

    # Driver + Wayland support packages
    log 'Installing nvidia-dkms, nvidia-utils, egl-wayland...'
    $aur_helper -S --needed nvidia-dkms nvidia-utils egl-wayland $noconfirm 2>> $logfile

    # Wait for DKMS to finish building the nvidia module before running mkinitcpio
    log 'Running dkms autoinstall to build nvidia kernel modules...'
    if ! sudo dkms autoinstall 2>> $logfile
        log 'Warning: dkms autoinstall reported errors — check log for details.'
    end

    # Verify the module was actually built before touching mkinitcpio
    if ! sudo modinfo nvidia &>> $logfile
        log 'Warning: nvidia module not found after DKMS build. Skipping mkinitcpio step to avoid a broken initramfs.'
        log 'You may need to reboot and re-run this script, or install the correct kernel headers manually.'
    else
        # Early module loading (needed for Wayland DRM)
        if ! grep -q 'nvidia' /etc/mkinitcpio.conf
            log 'Adding nvidia modules to mkinitcpio.conf...'
            sudo sed -i '/MODULES=/ s/)$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
            log 'Regenerating initramfs (mkinitcpio -P)...'
            sudo mkinitcpio -P 2>> $logfile
        end
    end

    # DRM modeset kernel parameter
    if ! test -f /etc/modprobe.d/nvidia.conf; or ! grep -q 'modeset=1' /etc/modprobe.d/nvidia.conf
        log 'Setting nvidia-drm modeset=1...'
        echo 'options nvidia-drm modeset=1 fbdev=1' | sudo tee -a /etc/modprobe.d/nvidia.conf >> $logfile
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
    cp -r hypr $config/hypr
    hyprctl reload
end

# Starship
if confirm-overwrite $config/starship.toml
    log 'Installing starship config...'
    cp starship.toml $config/starship.toml
end

# Maple Mono NF (custom build, bundled in repo)
set -l font_dir $HOME/.local/share/fonts/MapleMono-NF
if ! test -d $font_dir
    log 'Installing Maple Mono NF fonts...'
    mkdir -p $font_dir
    cp fonts/MapleMono-NF/*.ttf $font_dir/
    fc-cache -f $font_dir
end

# Kitty
if confirm-overwrite $config/kitty
    log 'Installing kitty config...'
    cp -r kitty $config/kitty
end

# Fish
if confirm-overwrite $config/fish
    log 'Installing fish config...'
    cp -r fish $config/fish
end

# Fastfetch
if confirm-overwrite $config/fastfetch
    log 'Installing fastfetch config...'
    cp -r fastfetch $config/fastfetch
end

# Uwsm
if confirm-overwrite $config/uwsm
    log 'Installing uwsm config...'
    cp -r uwsm $config/uwsm
end

# Btop
if confirm-overwrite $config/btop
    log 'Installing btop config...'
    cp -r btop $config/btop
end

# Neovim
if confirm-overwrite $config/nvim
    log 'Installing neovim config...'
    cp -r nvim $config/nvim
end

# Tmux
if confirm-overwrite $config/tmux/tmux.conf
    log 'Installing tmux config...'
    mkdir -p $config/tmux
    cp tmux/tmux.conf $config/tmux/tmux.conf
end

# TPM (tmux plugin manager)
if ! test -d $config/tmux/plugins/tpm
    log 'Installing TPM...'
    git clone https://github.com/tmux-plugins/tpm $config/tmux/plugins/tpm
    log 'Installing tmux plugins...'
    $config/tmux/plugins/tpm/scripts/install_plugins.sh
end

# Kvantum
mkdir -p $config/Kvantum
if confirm-overwrite $config/Kvantum/kvantum.kvconfig
    log 'Installing Kvantum config...'
    cp Kvantum/kvantum.kvconfig $config/Kvantum/kvantum.kvconfig
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
    cp -r qt5ct $config/qt5ct
end

# Qt6ct
if confirm-overwrite $config/qt6ct
    log 'Installing qt6ct config...'
    cp -r qt6ct $config/qt6ct
end

# Dolphin (all dolphin files grouped under one confirm)
if confirm-overwrite $config/dolphinrc
    log 'Installing dolphin configs...'
    cp dolphinrc $config/dolphinrc
    xdg-mime default org.kde.dolphin.desktop inode/directory
    rm -rf $state/dolphinstaterc $data/kxmlgui5/dolphin/dolphinui.rc $data/dolphin/view_properties/global/.directory
    mkdir -p $state $data/kxmlgui5/dolphin $data/dolphin/view_properties/global
    cp dolphin/dolphinstaterc $state/dolphinstaterc
    cp dolphin/kxmlgui5/dolphinui.rc $data/kxmlgui5/dolphin/dolphinui.rc
    cp dolphin/view_properties/global/.directory $data/dolphin/view_properties/global/.directory
end

# KDE globals (transparent view, kitty terminal, Papirus icons)
if confirm-overwrite $config/kdeglobals
    log 'Installing kdeglobals...'
    cp kdeglobals $config/kdeglobals
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
        cp -r spicetify $config/spicetify

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
        cp vscode/settings.json $folder/settings.json
        cp vscode/keybindings.json $folder/keybindings.json
        cp vscode/flags.conf $config/$prog-flags.conf

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
        cp zen/userChrome.css $chrome/userChrome.css
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
        cp zen/native_app/app.fish $lib/caelestiafox
    end

    # Prompt user to install extension
    log 'Please install the CaelestiaFox extension from https://addons.mozilla.org/en-US/firefox/addon/caelestiafox if you have not already done so.'
end

# Install cursor
if set -q _flag_cursor
    log 'Installing Cursor AI editor...'
    $aur_helper -S --needed cursor-bin $noconfirm
end

# Install opencode
if set -q _flag_opencode
    log 'Installing OpenCode...'
    $aur_helper -S --needed opencode $noconfirm
end

# Install claude-code
if set -q _flag_claude_code
    log 'Installing Claude Code...'
    $aur_helper -S --needed claude-code $noconfirm
end

# Install quickshell overrides
set -l qs_overrides $HOME/quickshell-overrides/caelestia
set -l qs_config $config/quickshell/caelestia

if ! test -d $HOME/quickshell-overrides
    log 'quickshell-overrides not found. Cloning...'
    git clone https://github.com/soyeb-jim285/quickshell-overrides.git $HOME/quickshell-overrides 2>> $logfile
end

if ! test -d $HOME/quickshell-overrides
    log 'Warning: failed to clone quickshell-overrides, skipping.'
else if ! test -d $qs_overrides
    log "Warning: quickshell-overrides cloned but '$qs_overrides' subdirectory not found, skipping."
end

if test -d $qs_overrides
    if confirm-overwrite $qs_config
        log 'Installing quickshell overrides...'
        for file in (find $qs_overrides -type f)
            set -l rel (string replace "$qs_overrides/" "" $file)
            set -l target $qs_config/$rel
            rm -rf $target
            mkdir -p (dirname $target)
            cp $file $target
        end
    end
end

# Generate scheme stuff if needed
if ! test -f $state/caelestia/scheme.json
    caelestia scheme set -n shadotheme
    sleep .5
    hyprctl reload
end

# Start the shell (only if not already running)
if ! pgrep -x qs > /dev/null
    caelestia shell -d > /dev/null
end

log 'Done!'
log "Install log written to: $logfile"

end 2>> $logfile
