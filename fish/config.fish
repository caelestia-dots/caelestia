if status is-interactive
    # Starship custom prompt
    command -v starship &> /dev/null && starship init fish | source

    # npm global path
    set -x PATH ~/.npm-global/bin $PATH

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    command -v eza &> /dev/null && alias ls='eza --icons --group-directories-first -1'

    # Command not found handler
    function fish_command_not_found
        set pkgs (pkgfile --search $argv[1] 2>/dev/null)
        if test -n "$pkgs"
            echo "'$argv[1]' not found. It may be in:"
            echo $pkgs
            read -P "Would you like to install it? [Y/n] " answer
            if test "$answer" != n -a "$answer" != N
                sudo pacman -S $argv[1]
            end
        else
            set aur_pkgs (yay -Ss $argv[1] 2>/dev/null | grep -E "^aur/" | head -5)
            if test -n "$aur_pkgs"
                echo "'$argv[1]' not found in repos. Found in AUR:"
                echo $aur_pkgs
                read -P "Would you like to install from AUR? [Y/n] " answer
                if test "$answer" != n -a "$answer" != N
                    yay -S $argv[1] --noconfirm
                end
            else
                echo "'$argv[1]': command not found"
            end
        end
    end

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'
    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    # Custom fish config
    set -q XDG_CONFIG_HOME && set -l cConf $XDG_CONFIG_HOME/caelestia || set -l cConf $HOME/.config/caelestia
    source $cConf/user-config.fish 2> /dev/null
end
