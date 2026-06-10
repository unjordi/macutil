#!/bin/sh -e

. ../common-script.sh

# Forces Microsoft Outlook for Mac into the classic "legacy" engine instead of
# the "new Outlook" (Hx / Phoenix) engine.
#
# Why this matters for syncing:
#   - The "new Outlook" (Hx) engine keeps only a limited LOCAL cache window of
#     mail (a few months) in an encrypted, non-editable HxStore.hxd. There is NO
#     plist/defaults key to widen that window on Mac, and search of older mail
#     relies on the server.
#   - The classic/legacy engine has NO sync-window limit for Exchange/M365
#     accounts: it downloads the ENTIRE mailbox locally (Data/Messages +
#     Data/Message Attachments). That is what lets you keep a full offline copy
#     and search the complete history locally.
#
# So "removing the 6-month sync limit" == running Outlook in legacy mode.
#
# Mechanism: the admin-documented preference key EnableNewOutlook controls the
# toggle. Values:
#   0 = new Outlook disabled, toggle hidden  (what we set -> forces legacy)
#   1 = toggle shown, default off
#   2 = toggle shown, default on
#   3 = new Outlook forced on, toggle hidden
#
# CAVEAT: Microsoft is deprecating legacy Outlook for Mac and has signaled it may
# retire the EnableNewOutlook preference. This tweak may stop working in a future
# Outlook update, after which the full-mailbox download is no longer possible in
# the desktop client (use OWA / server-side search instead).

forceLegacyOutlook() {
    printf "%b\n" "${YELLOW}Forcing Microsoft Outlook into classic (legacy) mode...${RC}"

    if [ ! -d "/Applications/Microsoft Outlook.app" ]; then
        printf "%b\n" "${YELLOW}Microsoft Outlook is not installed. Nothing to do.${RC}"
        exit 0
    fi

    # com.microsoft.Outlook is a user-level domain, so no escalation is needed.
    printf "%b\n" "${CYAN}Setting EnableNewOutlook = 0 (disable new Outlook, hide toggle)...${RC}"
    defaults write com.microsoft.Outlook EnableNewOutlook -int 0

    if pgrep -f "/Applications/Microsoft Outlook.app/Contents/MacOS/Microsoft Outlook" >/dev/null 2>&1; then
        printf "%b\n" "${YELLOW}Outlook is currently running. Fully quit it (Cmd+Q) and reopen it${RC}"
        printf "%b\n" "${YELLOW}so the preference sticks and the legacy engine takes over.${RC}"
    fi

    printf "%b\n" "${GREEN}Done! Outlook will run in legacy mode and download the full mailbox.${RC}"
    printf "%b\n" "${CYAN}First sync of a large mailbox can take a while and use significant disk space.${RC}"
    printf "%b\n" "${YELLOW}Note: Microsoft is deprecating legacy Outlook; this may stop working in a future update.${RC}"
}

checkEnv
forceLegacyOutlook
