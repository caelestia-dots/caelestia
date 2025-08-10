#!/usr/bin/env fish

argparse -n 'install.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'spotify' \
    'vscode=?!contains -- "$_flag_value" codium code' \
    'codeready=?!string match -q "*" "$_flag_value"' \
    'discord' \
    'zen' \
    'paru' \
    -- $argv
or exit

# Print help
if set -q _flag_h
    echo 'usage: ./install.fish [-h] [--noconfirm] [--spotify] [--vscode] [--codeready] [--discord] [--zen] [--paru]'
    echo
    echo 'options:'
    echo '  -h, --help                  show this help message and exit'
    echo '  --noconfirm                 do not confirm package installation'
    echo '  --spotify                   install Spotify (Spicetify)'
    echo '  --vscode=[codium|code]      install VSCodium (or VSCode)'
    echo '  --codeready[=groups]        install development tools'
    echo '                              groups: python,java,nodejs,tools (comma-separated)'
    echo '                              default: all groups if no value specified'
    echo '                              example: --codeready=python,java'
    echo '  --discord                   install Discord (OpenAsar + Equicord)'
    echo '  --zen                       install Zen browser'
    echo '  --paru                      use paru instead of yay as AUR helper'

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

function confirm-overwrite -a path
    if test -e $path -o -L $path
        # No prompt if noconfirm
        if set -q noconfirm
            input "$path already exists. Overwrite? [Y/n]"
            log 'Removing...'
            rm -rf $path
        else
            # Prompt user
            read -l -p "input '$path already exists. Overwrite? [Y/n] ' -n" confirm || exit 1

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
set -q _flag_paru && set -l aur_helper paru || set -l aur_helper yay
set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME || set -l config $HOME/.config
set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state

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
    read -l -p "input '=> ' -n" choice || exit 1

    if contains -- "$choice" 1 2
        if test $choice = 2
            log "Backing up $config..."

            if test -e $config.bak -o -L $config.bak
                read -l -p "input 'Backup already exists. Overwrite? [Y/n] ' -n" overwrite || exit 1

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
    $aur_helper -Y --gendb
    $aur_helper -Y --devel --save
end

# Install metapackage for deps
log 'Installing metapackage...'
$aur_helper -S --needed caelestia-meta $noconfirm

# Cd into dir
cd (dirname (status filename)) || exit 1

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

# Foot
if confirm-overwrite $config/foot
    log 'Installing foot config...'
    ln -s (realpath foot) $config/foot
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

# Install development tools (codeready)
if set -q _flag_codeready
    log 'Installing development tools...'
    
    # Parse selected groups
    set -l selected_groups
    if test -n "$_flag_codeready"
        set selected_groups (string split ',' "$_flag_codeready")
    else
        set selected_groups python java nodejs tools
    end
    
    # Python ecosystem
    if contains python $selected_groups
        log 'Installing Python ecosystem...'
        set -l python_packages python python-pip python-virtualenv python-poetry
        $aur_helper -S --needed $python_packages $noconfirm
        log '✓ Python: python, pip, virtualenv, poetry installed!'
    end
    
    # Java ecosystem
    if contains java $selected_groups
        log 'Installing Java ecosystem...'
        set -l java_packages jdk-openjdk openjdk-doc maven gradle
        $aur_helper -S --needed $java_packages $noconfirm
        log '✓ Java: OpenJDK, Maven, Gradle installed!'
    end
    
    # Node.js ecosystem
    if contains nodejs $selected_groups
        log 'Installing Node.js ecosystem...'
        set -l nodejs_packages nodejs npm
        $aur_helper -S --needed $nodejs_packages $noconfirm
        
        log 'Installing nvm for Node.js version management...'
        $aur_helper -S --needed nvm $noconfirm
        log '✓ Node.js: nodejs, npm, nvm installed!'
    end
    
    # Essential development tools
    if contains tools $selected_groups
        log 'Installing essential development tools...'
        set -l essential_tools git curl wget tree
        $aur_helper -S --needed $essential_tools $noconfirm
        log '✓ Tools: git, curl, wget, tree installed!'
    end
    
    # Configure Java in VSCode/Codium if Java was installed
    if contains java $selected_groups
        for vscode_variant in 'Code' 'VSCodium'
            set -l vscode_settings $config/$vscode_variant/User/settings.json
            if test -f $vscode_settings
                log "Configuring Java for $vscode_variant..."
                
                set -l java_home ""
                for java_path in /usr/lib/jvm/java-*-openjdk
                    if test -d $java_path
                        set java_home $java_path
                        break
                    end
                end
                
                if test -n "$java_home"
                    set -l temp_file (mktemp)
                    cat $vscode_settings > $temp_file
                    
                    set -l java_config "    \"java.home\": \"$java_home\",
    \"java.configuration.detectJdksAtStart\": false,
    \"java.jdt.ls.java.home\": \"$java_home\""
                    
                    sed -i '$d' $temp_file
                    echo "," >> $temp_file
                    echo "$java_config" >> $temp_file
                    echo "}" >> $temp_file
                    
                    mv $temp_file $vscode_settings
                    
                    log "Java configured with home: $java_home"
                else
                    log "Warning: Java installation not found."
                end
            end
        end
    end
    
    log 'Development environment ready!'
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

# Generate scheme stuff if needed
if ! test -f $state/caelestia/scheme.json
    caelestia scheme set -n shadotheme
    sleep .5
    hyprctl reload
end

# Start the shell
caelestia shell -d > /dev/null

log 'Done!'
