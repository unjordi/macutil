#!/bin/sh -e

. ../common-script.sh

# Makes the numeric keypad decimal key type "." for the CURRENT login session,
# regardless of keyboard layout.
#
# Root cause (confirmed via HID + CGEvent tracing): the numpad decimal key sends
# HID usage 0x63 (Keypad . and Delete). The CHARACTER it produces is decided by the
# keyboard LAYOUT: "Spanish - ISO" maps that key to ",", "Latin American" to ".".
# AppleICUNumberSymbols does NOT affect it. Remapping HID 0x63 -> main period key
# 0x37 makes it deliver virtual keycode 0x2F, which renders as "." on any layout.
#
# IMPORTANT - this is a SESSION-scoped stopgap, not a permanent fix:
#   * hidutil's UserKeyMapping only takes effect for the session that applied it.
#     Setting it from launchd (a LaunchAgent, with or without LimitLoadToSessionType
#     = Aqua) shows up in `hidutil property --get` but does NOT reach the GUI session
#     that delivers keystrokes -- so a login agent canNOT persist this. It also does
#     not survive a reboot. Run this script again when you need it (e.g. after a
#     reboot, or on a layout that types a comma there).
#   * The PERMANENT fix is a custom keyboard layout (a .keylayout cloning your normal
#     layout with the keypad-decimal key set to "."), which is layout-level and
#     survives reboots/reconnects with no daemon. Prefer that for Spanish - ISO.

MAPPING='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000063,"HIDKeyboardModifierMappingDst":0x700000037}]}'

fixNumpadDecimal() {
    printf "%b\n" "${YELLOW}Remapping the numeric keypad decimal key to type a period (.)...${RC}"
    hidutil property --set "$MAPPING" >/dev/null
    printf "%b\n" "${GREEN}Done -- the numpad decimal key types '.' for this login session.${RC}"
    printf "%b\n" "${CYAN}Not permanent: re-run after a reboot, or use a custom keyboard layout for a lasting fix.${RC}"
    printf "%b\n" "${YELLOW}To undo now: hidutil property --set '{\"UserKeyMapping\":[]}'${RC}"
}

checkEnv
fixNumpadDecimal
