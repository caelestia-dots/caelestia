#!/usr/bin/env fish

set -qx WAYLAND_DISPLAY; or set -x WAYLAND_DISPLAY wayland-0
set -x OMP_THREAD_LIMIT 1

set lang (test (count $argv) -ge 1; and echo $argv[1]; or echo eng)

set area (slurp -b '#00000088' -c '#ffffffaa' -w 1); or exit 1

set tmp (mktemp /tmp/ocr-XXXXXX.txt)
grim -g $area - | magick - -colorspace gray -resize 150% -contrast-stretch 0 - \
    | tesseract -l $lang - - --psm 6 2>/dev/null > $tmp

if test -s $tmp
    cat $tmp | awk -v RS= -v ORS='\n\n' '{$1=$1}1' | wl-copy
    notify-send -t 1500 -a OCR "Copied" "Text recognised and copied to clipboard"
else
    notify-send -t 2000 -u critical -a OCR "Error" "Failed to recognise text"
end

rm -f $tmp
