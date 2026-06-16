#!/usr/bin/env bash

print_flame() {
    local flame=(
'                  ▄█▄                    '
'                   ████▄                 '
'                    ██████               '
'        ▄          ████████▄             '
'        ██        █████████              '
'        ████     █████ ███               '
'         ███    █████   ██▌              '
'         ████  ███████  ████             '
'     █▄   ███████████   █████            '
'     ████  █████████     ███      ▄█▄    '
'    ███████████████      ████    ████    '
'    ██████ █████████      ███  █████     '
'   ██████   ████████       ██████ ███▌   '
'   █████     ██████         ████   ███▌  '
'   ████       ████           ██     ███  '
'    ███        ██           █      ███   '
'    ████                          ███    '
'     ████                        ██      '
'      █████                     ██       '
'        █████▄               ▄███        '
'          ██████████████████████▀        '
'           ▀███████████████████▀         '
'              ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀            '
)

    local count=${#flame[@]}
    local index red green blue position

    for ((index = 0; index < count; index++)); do
        position=$((255 * index / (count - 1)))

        if ((position < 60)); then
            # Bright yellow tip
            red=255
            green=$((255 - position * 40 / 60))
            blue=$((80 - position * 80 / 60))
        elif ((position < 140)); then
            # Yellow -> orange
            local p=$((position - 60))
            red=255
            green=$((215 - p * 100 / 80))
            blue=0
        elif ((position < 210)); then
            # Orange -> deep orange
            local p=$((position - 140))
            red=255
            green=$((115 - p * 75 / 70))
            blue=0
        else
            # Deep orange -> red
            local p=$((position - 210))
            red=255
            green=$((40 - p * 40 / 45))
            blue=0
        fi

        printf '\033[38;2;%d;%d;%dm%s\033[0m\n' \
            "$red" "$green" "$blue" "${flame[index]}"
    done
}

print_flame