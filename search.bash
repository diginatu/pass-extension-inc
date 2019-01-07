#!/bin/bash

HEADER_HEIGHT=3

unset keyword

tput init
tput clear

while [[ true ]]; do
    tput cup 0 0
    echo -n "Keyword: $keyword"
    IFS= read -r -N 1 c

    tput clear
    tput cup $HEADER_HEIGHT 0

    case $c in
        $'\b') # BackSpace
            if [[ "$keyword" = "" ]]; then
                continue
            fi
            keyword=${keyword::-1}
            ;;
        $'\cu')
            # Clear line
            keyword=
            ;;
        $'\x0a') # Enter
            echo "Enter pressed"
            break
            ;;
        $'\e') # ESC
            echo "Canceled"
            break
            ;;
        *)
            echo "aaaa:$c"
            keyword+="$c"
            ;;
    esac


    pass_field_height=$(expr $(tput lines) - $HEADER_HEIGHT - 1)

    pass find "$keyword" | head -n "$pass_field_height"
done
