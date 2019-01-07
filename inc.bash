#!/bin/bash

HEADER_HEIGHT=3
PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

unset keyword

tput init
tput clear
cd $PREFIX

while [[ true ]]; do
    tput cup 0 0
    echo -n "Keyword: $keyword"
    IFS= read -r -s -N 1 c

    tput clear
    tput cup $HEADER_HEIGHT 0

    case $c in
        $'\b'|$'\x7f') # BackSpace
            if [[ "$keyword" = "" ]]; then
                continue
            fi
            keyword=${keyword::-1}
            ;;
        $'\cu')
            # Clear line
            keyword=
            ;;
        $'\cp'|$'\cn'|$'\c['|$'\cl') # Ignore
            ;;
        $'\x0a') # Enter
            echo "Enter pressed"
            break
            ;;
        $'\e'|$'\cd') # ESC or Ctrl-D
            echo "Canceled"
            break
            ;;
        *)
            keyword+="$c"
            ;;
    esac


    pass_field_height=$(expr $(tput lines) - $HEADER_HEIGHT - 1)

    find -L -name "*${keyword}*" -iname '*.gpg' | head -n "$pass_field_height"
done
