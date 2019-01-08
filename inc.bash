#!/bin/bash

HEADER_HEIGHT=3

function showPaths() {
    path_list=$1
    field_height=$2
    cur=$3

    echo "$path_list" | head -n $field_height
    tput cup $(($HEADER_HEIGHT + $cur - 1)) 0
    tput rev
    echo "$distpath"
    tput sgr0
}

unset distpath
unset keyword
unset path_list
cur=1

function updatePathList() {
    path_list=$(find -L -name "*${keyword}*" -iname '*.gpg')
}

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
            updatePathList
            ;;
        $'\cu')
            # Clear line
            keyword=
            updatePathList
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
            updatePathList
            ;;
    esac

    # Calculate number of lines and cursor position to show
    field_height=$(($(tput lines) - $HEADER_HEIGHT - 1))
    path_list_height=$(echo "$path_list" | wc -l)
    (($path_list_height > $field_height)) && path_list_height=$field_height
    (($path_list_height < $cur)) && cur=$path_list_height
    distpath=$(echo "$path_list" | sed -n "${cur}p")

    showPaths "$path_list" "$field_height" "$cur"
done
