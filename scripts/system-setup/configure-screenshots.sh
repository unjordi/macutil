#!/bin/sh -e

. ../common-script.sh

configureScreenshots() {
    printf "%b\n" "${YELLOW}Configuring screenshot behavior...${RC}"

    printf "%b\n" "${CYAN}Setting screenshots to copy to clipboard instead of saving to file...${RC}"
    $ESCALATION_TOOL defaults write com.apple.screencapture target clipboard

    printf "%b\n" "${CYAN}Disabling screenshot capture sound...${RC}"
    $ESCALATION_TOOL defaults write com.apple.screencapture sound -bool false

    printf "%b\n" "${CYAN}Applying changes...${RC}"
    $ESCALATION_TOOL killall SystemUIServer

    printf "%b\n" "${GREEN}Done! All screenshot shortcuts (cmd+shift+3/4/5) now copy to clipboard.${RC}"
    printf "%b\n" "${YELLOW}Tip: Use cmd+shift+5 to access full screenshot options including save-to-file.${RC}"
}

checkEnv
configureScreenshots
