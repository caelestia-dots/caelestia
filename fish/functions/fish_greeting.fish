function fish_greeting
    echo -ne '\x1b[38;5;16m'  # Set colour to primary
    echo '    _   __           __                         '
    echo '   / | / /___  _____/ /___  __________  ___     '
    echo '  /  |/ / __ \/ ___/ __/ / / / ___/ __ \/ _ \    '
    echo ' / /|  / /_/ / /__/ /_/ /_/ / /  / / / /  __/    '
    echo '/_/ |_/\____/\___/\__/\__,_/_/  /_/ /_/\___/     '
    set_color normal
    fastfetch --key-padding-left 5
end
