#!/bin/bash

HEADER_HEIGHT=3

function showPaths {
    path_list="$1"
    field_height="$2"
    curpos="$3"
    distpath="$4"

    echo "$path_list" | head -n $field_height
    tput cup $curpos 0
    tput rev
    echo "$distpath"
    tput sgr0
}

distpath=
keyword=
path_list=
cur=

function updateKeyword {
    keyword=$1
    cur=1
    path_list=$(find -L -path "*${keyword// /*}*" -iname '*.gpg' | sed -e "s/^\.\///" -e "s/\.gpg$//")
}

tput init
tput clear
cd $PREFIX

updateKeyword ""

while [[ true ]]; do
    # Calculate number of lines and cursor position to show
    field_height=$(($(tput lines) - $HEADER_HEIGHT - 1))
    path_list_height=$(echo "$path_list" | wc -l)
    (($path_list_height > $field_height)) && path_list_height=$field_height
    (($path_list_height < $cur)) && cur=$path_list_height
    distpath=$(echo "$path_list" | sed -n "${cur}p")

    tput civis
    tput clear
    tput cup $HEADER_HEIGHT 0
    showPaths "$path_list" "$field_height" $(($HEADER_HEIGHT + $cur - 1)) "$distpath"
    tput cup 0 0
    tput cnorm
    IFS= read -p "Keyword: $keyword" -r -s -N 1 c

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
            updateKeyword ${keyword::-1}
            ;;
        $'\cu')
            # Clear line
            updateKeyword ""
            ;;
        $'\cl') # Ignore
            ;;
        $'\cp'|$'\e[A'|$'\e0A'|$'\e[D'|$'\e0D') # Up
            ((cur > 1)) && ((cur--))
            ;;
        $'\cn'|$'\e[B'|$'\e0B'|$'\e[C'|$'\e0C') # Down
            ((cur++))
            ;;
        $'\x0a') # Enter
            tput clear
            echo "$PROGRAM" "$distpath" "$@"
            "$PROGRAM" "$distpath" "$@"
            break
            ;;
        $'\e'|$'\cd') # ESC or Ctrl-D
            tput clear
            echo "Canceled"
            break
            ;;
        $'\e'*) # Other escape sequence
            ;;
        *)
            updateKeyword "$keyword$c"
            ;;
    esac
done
