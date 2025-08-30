#!/bin/bash
#===============================================================================
# HitmanQuickSave v1.0 by TheChilliPL
# Bash version
#===============================================================================
# A simple script that lets you quickly save and load the first manual save slot
# in HITMAN: World of Assassination (previously: HITMAN 3).
# Ported from the AHK version manually to support HITMAN running on Linux via
# Proton.
#-------------------------------------------------------------------------------
# Subcommands:
#   save   Quickly save the game to the first manual slot
#   load   Quickly load the game from the first manual slot
# You can bind these commands to keyboard shortcuts in your DE/WM.
#===============================================================================
# Requirements:
# - grim
# - ydotool
# - magick
#===============================================================================
# Made in 2025 by Chilli.
# GitHub:   TheChilliPL
# Discord:  @chilli2077
#===============================================================================

# --- Config ---
# Color of the selected UI elements
BRAND_COLOR="#FB0014"
# Position of the main menu header
MENU_BRAND_POS=(400 100)
# Position of the save button
SAVE_BTN_POS=(400 250)
# Position of the load button
LOAD_BTN_POS=(400 325)
# Position of the 1st manual save slot
SLOT_M1_POS=(750 460)
# Position of the confirm button
CONFIRM_POS=(1300 630)
# --- End of config ---
# Don't change anything below this line unless you know what you're doing.

set -euo pipefail

# OPTS=$(getopt -o o: --long output: -n "$0"  -- "$@")
# eval set -- "$OPTS"

# output=
# while true; do
#     case "$1" in
#         # -o|--output)
#         #     output="$2"
#         #     shift 2
#         #     ;;
#         --)
#             shift
#             break
#             ;;
#         *)
#             echo "Invalid option: $1. See comment in script." >&2
#             exit 1
#             ;;
#     esac
# done

cmd=${1:-}
shift || true

if [[ $cmd != "save" && $cmd != "load" ]]; then
    echo "Invalid or missing command. Use 'save' or 'load'." >&2
    exit 1
fi

# Checks whether the specific pixel is brand colored
function is_brand {
    local x="$1"
    local y="$2"

    pixel_color=$(grim -g "$x,$y 1x1" - | magick - -format "#%[hex:u.p{0,0}]" info:)
    [[ $pixel_color == "$BRAND_COLOR" ]]
}

function wait_until {
    local predicate="$1"
    local timeout_ms="${2:-10000}"
    local interval_ms=100

    local elapsed_ms=0
    while [[ $timeout_ms -eq 0 || $elapsed_ms -lt $timeout_ms ]]; do
        if $predicate; then
            return 0
        fi
        sleep "$interval_ms"e-3
        ((elapsed_ms += interval_ms))
    done
    return 1
}

function is_menu_opened {
    is_brand "${MENU_BRAND_POS[@]}"
}

function is_save_selected {
    is_brand "${SAVE_BTN_POS[@]}"
}

function is_load_selected {
    is_brand "${LOAD_BTN_POS[@]}"
}

function is_slot_m1_selected {
    is_brand "${SLOT_M1_POS[@]}"
}

function is_confirm_selected {
    is_brand "${CONFIRM_POS[@]}"
}

function save_game {
    if ! is_menu_opened; then
        ydotool key 1:1 1:0 # Esc
        if ! wait_until is_menu_opened 1000; then
            echo "Couldn't open the menu." >&2
            exit 1
        fi
    fi
    if ! is_save_selected; then
        echo "Saving is unavailable." >&2
        exit 1
    fi
    ydotool mousemove -a -- 0 0 # Move mouse to the top-left corner
    ydotool key 28:1 28:0 # Press Enter
    if ! wait_until is_slot_m1_selected 3000; then
        echo "Slot 1 is not selected." >&2
        exit 1
    fi
    ydotool key 28:1 28:0 # Press Enter
    if ! wait_until is_confirm_selected 1000; then
        echo "Confirm is not selected." >&2
        exit 1
    fi
    ydotool key 28:1 28:0 # Press Enter
    if ! wait_until is_menu_opened 3000; then
        echo "Didn't come back to menu." >&2
        exit 1
    fi
    ydotool key 1:1 1:0 # Esc
}

function load_game {
    if ! is_menu_opened; then
        ydotool key 1:1 1:0 # Esc
        if ! wait_until is_menu_opened 1000; then
            echo "Couldn't open the menu." >&2
            exit 1
        fi
    fi
    if is_save_selected; then
        ydotool key 108:1 108:0 # Down
        if ! wait_until is_load_selected 1000; then
            echo "Couldn't select Load." >&2
            exit 1
        fi
    fi
    if ! is_load_selected; then
        echo "Unknown menu position." >&2
        exit 1
    fi
    ydotool mousemove -a -- 0 0 # Move mouse to the top-left corner
    ydotool key 28:1 28:0 # Press Enter
    if ! wait_until is_slot_m1_selected 3000; then
        echo "Slot 1 is not selected." >&2
        exit 1
    fi
    ydotool key 28:1 28:0 # Press Enter
    if ! wait_until is_confirm_selected 1000; then
        echo "Confirm is not selected." >&2
        exit 1
    fi
    ydotool key 28:1 28:0 # Press Enter
}

if [[ $cmd == "save" ]]; then
    save_game
elif [[ $cmd == "load" ]]; then
    load_game
fi
