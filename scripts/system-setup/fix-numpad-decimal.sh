#!/bin/sh -e

. ../common-script.sh

fixNumpadDecimal() {
    printf "%b\n" "${YELLOW}Fixing numeric keypad decimal separator...${RC}"

    printf "%b\n" "${CYAN}Setting decimal separator to period (.) for numeric keypad...${RC}"
    defaults write -g AppleICUNumberSymbols -dict-add 0 "."
    defaults write -g AppleICUNumberSymbols -dict-add 14 "."

    printf "%b\n" "${GREEN}Done! The numeric keypad decimal key will now produce a period (.).${RC}"
    printf "%b\n" "${YELLOW}Log out and back in for the change to take full effect.${RC}"
}

checkEnv
fixNumpadDecimal
