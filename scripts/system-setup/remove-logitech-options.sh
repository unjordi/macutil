#!/bin/sh -e

. ../common-script.sh

removeLogitechOptions() {
    printf "%b\n" "${YELLOW}Removing Logitech Options / Options+ completely...${RC}"

    # --- Stop running processes ---
    printf "%b\n" "${CYAN}Stopping Logitech processes...${RC}"
    for proc in LogiMgrDaemon LogiMgrAgent "Logi Options" "Logi Options+" \
        LogiMgrUpdater LogiPluginService logioptionsplus_agent logimgr; do
        $ESCALATION_TOOL killall -q "$proc" 2>/dev/null || true
    done

    # --- Unload + remove any Logi LaunchAgents / LaunchDaemons ---
    printf "%b\n" "${CYAN}Removing Logitech launchd jobs...${RC}"
    for dir in /Library/LaunchAgents /Library/LaunchDaemons "$HOME/Library/LaunchAgents"; do
        find "$dir" -iname '*logi*' 2>/dev/null | while IFS= read -r plist; do
            $ESCALATION_TOOL launchctl unload "$plist" 2>/dev/null || true
            $ESCALATION_TOOL rm -f "$plist" && printf "%b\n" "  Removed: $plist"
        done
    done

    # --- System-level files (needs elevation) ---
    printf "%b\n" "${CYAN}Removing system-level Logitech files...${RC}"
    $ESCALATION_TOOL rm -rf \
        "/Library/Application Support/Logi" \
        "/Library/Application Support/Logitech" \
        "/Library/Application Support/Logitech.localized" \
        "/Library/Application Support/LogiOptionsPlus" \
        "/Applications/Utilities/LogiMgr Uninstaller.app" \
        "/Applications/Logi Options.app" \
        "/Applications/Logi Options+.app"
    find /Library/PrivilegedHelperTools -iname '*logi*' 2>/dev/null | while IFS= read -r f; do
        $ESCALATION_TOOL rm -f "$f" && printf "%b\n" "  Removed: $f"
    done

    # --- User-level preferences (case-insensitive: catches com.Logitech.* too) ---
    printf "%b\n" "${CYAN}Removing Logitech preferences...${RC}"
    find "$HOME/Library/Preferences" -iname 'com.logi*' 2>/dev/null | while IFS= read -r f; do
        rm -f "$f" && printf "%b\n" "  Removed: $f"
    done

    # --- User-level app support, logs, caches, storage ---
    printf "%b\n" "${CYAN}Removing Logitech app data...${RC}"
    rm -rf \
        "$HOME/Library/Application Support/Logi" \
        "$HOME/Library/Application Support/Logitech" \
        "$HOME/Library/Logs/xlog_logitech" \
        "$HOME/Library/HTTPStorages/LogiPluginServiceNative"
    for base in "$HOME/Library/Caches" "$HOME/Library/HTTPStorages" "$HOME/Library/WebKit"; do
        find "$base" -maxdepth 1 -iname '*logi*' 2>/dev/null | while IFS= read -r f; do
            rm -rf "$f" && printf "%b\n" "  Removed: $f"
        done
    done

    # --- Forget package receipts ---
    printf "%b\n" "${CYAN}Forgetting Logitech package receipts...${RC}"
    pkgutil --pkgs 2>/dev/null | grep -iE 'logi' | while IFS= read -r pkg; do
        $ESCALATION_TOOL pkgutil --forget "$pkg" >/dev/null 2>&1 && printf "%b\n" "  Forgot: $pkg"
    done

    # --- Reset TCC privacy permissions (incl. Input Monitoring / ListenEvent) ---
    # tccutil has no wildcard, so enumerate every known Logi client id. An orphaned
    # Privacy entry (e.g. "Logi Options+ Driver Installer.bundle" left in Input
    # Monitoring after the bundle is gone) is cleared by reset-ing its bundle id.
    printf "%b\n" "${CYAN}Resetting privacy permissions (TCC)...${RC}"
    for bundle in \
        com.logitech.manager.daemon \
        com.logi.optionsplus \
        com.logi.optionsplus.driver \
        com.logi.optionsplus.driverhost \
        com.logi.optionsplus.driver.installer \
        com.logi.cp-dev-mgr \
        com.logi.pluginservice \
        com.logitech.Logi-Options \
        com.Logitech.Updater; do
        $ESCALATION_TOOL tccutil reset All "$bundle" >/dev/null 2>&1 || true
    done

    printf "%b\n" "${GREEN}Done! Logitech Options has been completely removed.${RC}"
    printf "%b\n" "${YELLOW}A logout/restart is recommended to flush cached Privacy entries.${RC}"
}

checkEnv
removeLogitechOptions
