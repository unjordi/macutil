#!/bin/sh -e

. ../common-script.sh

removeAdobeOfficeAddins() {
    printf "%b\n" "${YELLOW}Removing Adobe add-ins from Microsoft Office...${RC}"

    OFFICE_STARTUP="$HOME/Library/Group Containers/UBF8T346G9.Office"
    REMOVED=0

    if [ ! -d "$OFFICE_STARTUP" ]; then
        printf "%b\n" "${YELLOW}Microsoft Office not found. Nothing to remove.${RC}"
        exit 0
    fi

    # Search by pattern (SaveAsAdobePDF.*, PDFMaker.*, etc.)
    # and by known Adobe add-in names that don't contain "adobe" in the filename
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        printf "%b\n" "${CYAN}Removing: $f${RC}"
        rm -f "$f"
        REMOVED=$((REMOVED + 1))
    done << EOF
$(find "$OFFICE_STARTUP" \( -iname "*adobe*" -o -iname "*pdfmaker*" -o -iname "linkCreation.dotm" -o -iname "~\$nkCreation.dotm" \) -not -path "*/.localized/*" -type f 2>/dev/null)
EOF

    # Remove the system-level MACPDFM framework (broken Adobe Acrobat remnant)
    MACPDFM="/Library/Application Support/Adobe/MACPDFM"
    if [ -d "$MACPDFM" ]; then
        printf "%b\n" "${CYAN}Removing broken MACPDFM framework from /Library...${RC}"
        $ESCALATION_TOOL rm -rf "$MACPDFM"
        REMOVED=$((REMOVED + 1))
    fi

    if [ "$REMOVED" -eq 0 ]; then
        printf "%b\n" "${GREEN}No Adobe Office add-ins found.${RC}"
    else
        printf "%b\n" "${GREEN}Done! Removed $REMOVED Adobe add-in(s) from Microsoft Office.${RC}"
        printf "%b\n" "${YELLOW}Restart Word, Excel, and PowerPoint for changes to take effect.${RC}"
    fi
}

checkEnv
removeAdobeOfficeAddins
