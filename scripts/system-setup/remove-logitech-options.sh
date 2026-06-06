#!/bin/sh -e

. ../common-script.sh

removeLogitechOptions() {
    printf "%b\n" "${YELLOW}Removing Logitech Options / Options+ completely...${RC}"

    # --- Stop running processes ---
    printf "%b\n" "${CYAN}Stopping Logitech processes...${RC}"
    for proc in LogiMgrDaemon LogiMgrAgent "Logi Options" LogiMgrUpdater LogiPluginService; do
        $ESCALATION_TOOL killall -q "$proc" 2>/dev/null || true
    done

    # --- Unload LaunchAgent ---
    LAUNCH_AGENT="/Library/LaunchAgents/com.logitech.manager.daemon.plist"
    if [ -f "$LAUNCH_AGENT" ]; then
        printf "%b\n" "${CYAN}Unloading LaunchAgent...${RC}"
        $ESCALATION_TOOL launchctl unload "$LAUNCH_AGENT" 2>/dev/null || true
        $ESCALATION_TOOL rm -f "$LAUNCH_AGENT"
    fi

    # --- System-level files (needs elevation) ---
    printf "%b\n" "${CYAN}Removing system-level Logitech files...${RC}"
    $ESCALATION_TOOL rm -rf \
        "/Library/Application Support/Logitech.localized" \
        "/Applications/Utilities/LogiMgr Uninstaller.app" \
        "/Applications/Logi Options.app" \
        "/Applications/Logi Options+.app"

    # --- User-level preferences ---
    printf "%b\n" "${CYAN}Removing Logitech preferences...${RC}"
    find ~/Library/Preferences -name "com.logitech.*" -o -name "com.logi.*" 2>/dev/null | while IFS= read -r f; do
        rm -f "$f" && printf "%b\n" "  Removed: $f"
    done

    # --- User-level app support, logs, caches, storage ---
    printf "%b\n" "${CYAN}Removing Logitech app data...${RC}"
    rm -rf \
        ~/Library/Application\ Support/Logitech \
        ~/Library/Logs/xlog_logitech \
        ~/Library/HTTPStorages/LogiPluginServiceNative \
        ~/Library/Caches/com.logitech.manager.daemon \
        ~/Library/Caches/com.logi.optionsplus \
        ~/Library/Caches/com.Logitech.Updater

    # --- Reset TCC privacy permissions ---
    printf "%b\n" "${CYAN}Resetting privacy permissions (TCC)...${RC}"
    for bundle in \
        com.logitech.manager.daemon \
        com.logi.optionsplus \
        com.logi.cp-dev-mgr \
        com.logi.pluginservice \
        com.logi.optionsplus.driverhost \
        com.Logitech.Updater; do
        $ESCALATION_TOOL tccutil reset All "$bundle" 2>/dev/null || true
    done

    printf "%b\n" "${GREEN}Done! Logitech Options has been completely removed.${RC}"
    printf "%b\n" "${YELLOW}A restart is recommended to flush any cached permissions.${RC}"
}

checkEnv
removeLogitechOptions
