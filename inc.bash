#!/bin/bash

HEADER_HEIGHT=3
PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

function showPaths() {
    local keyword="$1"
    local row="$2"

    local field_height=$(expr $(tput lines) - $HEADER_HEIGHT - 1)
    local path_list=$(find -L -name "*${1}*" -iname '*.gpg')
    
    echo "$path_list" | head -n "$field_height"
    tput rev
    echo "$path_list" | tail -n $(expr "$row" - 0)
    tput sgr0
}

unset keyword
row=0

tput init
tput clear
cd $PREFIX

while [[ true ]]; do
    tput cup 0 0
    echo -n "Keyword: $keyword"
    IFS= read -r -s -N 1 c

    tput clear
    tput cup $HEADER_HEIGHT 0

    if [[ "$c" = $'\e' ]]; then
        # Escape Character
        read -sN1 -t 0.0001 k1
        read -sN1 -t 0.0001 k2
        read -sN1 -t 0.0001 k3
        c+="$k1$k2$k3"
    fi

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
        $'\cl') # Ignore
            ;;
        $'\cp'|$'\e[A'|$'\e0A'|$'\e[D'|$'\e0D') # Up
            echo "UP"
            ;;
        $'\cn'|$'\e[B'|$'\e0B'|$'\e[C'|$'\e0C') # Down
            echo "DOWN"
            ;;
        $'\e[1~'|$'\e0H'|$'\e[H')  # Home
            echo "HOME"
            ;;
        $'\e[4~'|$'\e0F'|$'\e[F')  # End
            echo "END"
            ;;
        $'\x0a') # Enter
            echo "Enter pressed"
            break
            ;;
        $'\e'|$'\cd') # ESC or Ctrl-D
            echo "Canceled"
            break
            ;;
        $'\e'*) # Other escape sequence
            ;;
        *)
            keyword+="$c"
            ;;
    esac

    showPaths "$keyword" $row
done
