#!/bin/sh -e

. ../common-script.sh

configureRecents() {
    CODE_DIR="$HOME/Code"
    SAVED_SEARCHES_DIR="$HOME/Library/Saved Searches"
    SMART_FOLDER="$SAVED_SEARCHES_DIR/Recientes (sin Code).savedSearch"

    printf "%b\n" "${YELLOW}Configuring Recent Items...${RC}"

    # Increase per-app recent documents limit
    printf "%b\n" "${CYAN}Setting recent documents limit to 50 for all apps...${RC}"
    $ESCALATION_TOOL defaults write -g NSRecentDocumentsLimit -int 50

    # Increase Apple Menu recent documents count without clobbering existing list
    printf "%b\n" "${CYAN}Increasing Apple Menu recent documents count to 50...${RC}"
    /usr/libexec/PlistBuddy -c "Set :RecentDocuments:MaxAmount 50" \
        "$HOME/Library/Preferences/com.apple.recentitems.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :RecentDocuments:MaxAmount integer 50" \
        "$HOME/Library/Preferences/com.apple.recentitems.plist" 2>/dev/null || true

    # Create Smart Folder that shows files from the last 30 days, excluding CODE_DIR
    printf "%b\n" "${CYAN}Creating Smart Folder 'Recientes (sin Code)' (excluding $CODE_DIR)...${RC}"
    mkdir -p "$SAVED_SEARCHES_DIR"

    # Use Python to write the plist so XML encoding is handled correctly.
    # Single-quoted heredoc ('PYEOF') prevents shell from expanding $time in the query.
    # Paths are passed as argv to avoid $HOME confusion when running elevated.
    python3 - "$CODE_DIR" "$SMART_FOLDER" << 'PYEOF'
import plistlib, sys
code_dir, smart_folder = sys.argv[1], sys.argv[2]
plist_data = {
    'RawQuery': f'kMDItemLastUsedDate >= $time.today(-30d) && (kMDItemContentTypeTree != "public.folder") && !(kMDItemPath = "{code_dir}/*"c)',
    'SearchScopes': ['kMDQueryScopeHome'],
    'SortingAttributes': [{'ascending': False, 'name': 'kMDItemLastUsedDate'}]
}
with open(smart_folder, 'wb') as f:
    plistlib.dump(plist_data, f, fmt=plistlib.FMT_XML)
PYEOF

    # Add the Smart Folder to the Finder sidebar
    printf "%b\n" "${CYAN}Adding Smart Folder to Finder sidebar...${RC}"
    SMART_FOLDER_URL=$(python3 -c "import urllib.parse, sys; print('file://' + urllib.parse.quote(sys.argv[1]))" "$SMART_FOLDER")
    if sfltool add-item com.apple.LSSharedFileList.FavoriteItems "$SMART_FOLDER_URL" 2>/dev/null; then
        printf "%b\n" "${GREEN}Smart Folder added to Finder sidebar.${RC}"
    else
        printf "%b\n" "${YELLOW}Could not add to sidebar automatically. To add manually:${RC}"
        printf "%b\n" "${CYAN}  Drag this file to your Finder sidebar:${RC}"
        printf "%b\n" "${CYAN}  $SMART_FOLDER${RC}"
    fi

    printf "%b\n" "${CYAN}Restarting Finder...${RC}"
    $ESCALATION_TOOL killall Finder

    printf "%b\n" "${GREEN}Done!${RC}"
    printf "%b\n" "${GREEN}  - Recent documents limit: 50${RC}"
    printf "%b\n" "${GREEN}  - Smart Folder shows files from the last 30 days, excluding $CODE_DIR${RC}"
}

checkEnv
configureRecents
