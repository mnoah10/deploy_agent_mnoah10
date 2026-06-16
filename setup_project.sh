#!/usr/bin/env bash

# setup_project.sh
# This script builds the full workspace for the Student Attendance Tracker.
# Run it once and it handles everything: folders, files, config, and a quick
# sanity check to make sure your machine is ready to go.

echo ""
echo "  Student Attendance Tracker — Project Setup"
echo "  -------------------------------------------"
echo ""

# First thing we need is a name for this project.
# It gets used as part of the folder name, so we keep it clean.
read -rp "What do you want to call this project? " INPUT

if [[ -z "$INPUT" ]]; then
    echo "You didn't enter a name. Please re-run the script and try again."
    exit 1
fi

# Replace any spaces or special characters with underscores.
# This avoids headaches with directory names later.
INPUT="${INPUT//[^a-zA-Z0-9_]/_}"

PROJECT_DIR="attendance_tracker_${INPUT}"
ARCHIVE_NAME="attendance_tracker_${INPUT}_archive"


# What happens if the user hits Ctrl+C mid-setup?
# We don't want a half-built folder just sitting there making a mess.
# This function runs automatically on interrupt: it zips up whatever
# was created, then wipes the incomplete folder so the workspace stays clean.
cleanup() {
    echo ""
    echo "Looks like you cancelled the setup. No worries — cleaning up now..."

    if [[ -d "$PROJECT_DIR" ]]; then
        echo "Saving what was built so far to ${ARCHIVE_NAME}.tar.gz ..."
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR" 2>/dev/null \
            && echo "Archive saved successfully." \
            || echo "Hmm, couldn't create the archive. You may need to clean up manually."

        echo "Removing the incomplete project folder..."
        rm -rf "$PROJECT_DIR" \
            && echo "Done. The folder has been removed." \
            || echo "Couldn't remove the folder. You might need to delete it manually."
    else
        echo "Nothing was created yet, so there's nothing to archive."
    fi

    echo ""
    echo "Exiting. Your workspace is clean."
    exit 130
}

# Register the cleanup function so it fires on Ctrl+C
trap cleanup SIGINT


# Create the folder structure.
# The layout the Python app expects is:
#   attendance_tracker_{name}/
#       attendance_checker.py
#       Helpers/
#           assets.csv
#           config.json
#       reports/
#           reports.log
echo ""
echo "Setting up your project folder: ${PROJECT_DIR}"

if [[ -d "$PROJECT_DIR" ]]; then
    echo ""
    echo "A folder called '${PROJECT_DIR}' already exists."
    read -rp "Do you want to overwrite it and start fresh? [y/N]: " OVERWRITE
    if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR"
    else
        echo "Got it, leaving it as-is. Exiting."
        exit 0
    fi
fi

mkdir -p "${PROJECT_DIR}/Helpers" || { echo "Couldn't create the Helpers folder. Do you have write permissions here?"; exit 1; }
mkdir -p "${PROJECT_DIR}/reports"  || { echo "Couldn't create the reports folder."; exit 1; }

echo "Folder structure created."


# Copy all the source files into the right places.
# If a file is missing from the repo, we'll say so instead of silently failing.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_file() {
    local SRC="$1"
    local DEST="$2"
    if [[ -f "$SRC" ]]; then
        cp "$SRC" "$DEST" && echo "  Copied $(basename "$SRC")"
    else
        echo "  Warning: couldn't find $(basename "$SRC") at $SRC — skipping."
    fi
}

copy_file "${SCRIPT_DIR}/attendance_checker.py" "${PROJECT_DIR}/attendance_checker.py"
copy_file "${SCRIPT_DIR}/Helpers/assets.csv"    "${PROJECT_DIR}/Helpers/assets.csv"
copy_file "${SCRIPT_DIR}/Helpers/config.json"   "${PROJECT_DIR}/Helpers/config.json"
copy_file "${SCRIPT_DIR}/reports/reports.log"   "${PROJECT_DIR}/reports/reports.log"


# The config file has two thresholds that control when students get flagged:
#   - Warning: student is cutting it close but might still pass
#   - Failure: student is almost certainly going to fail
#
# The defaults are 75% (warning) and 50% (failure).
# We give the user a chance to change them before we finish setup.
CONFIG_FILE="${PROJECT_DIR}/Helpers/config.json"

echo ""
echo "The default attendance thresholds are:"
echo "  Warning  — 75%   (students below this get a heads-up)"
echo "  Failure  — 50%   (students below this get an urgent alert)"
echo ""
read -rp "Do you want to change these? [y/N]: " UPDATE_THRESHOLDS

if [[ "$UPDATE_THRESHOLDS" =~ ^[Yy]$ ]]; then

    # Keep asking until the user gives us a valid number
    while true; do
        read -rp "  New Warning threshold (1-100, just press Enter to keep 75): " NEW_WARNING
        NEW_WARNING="${NEW_WARNING:-75}"
        if [[ "$NEW_WARNING" =~ ^[0-9]+$ ]] && (( NEW_WARNING >= 1 && NEW_WARNING <= 100 )); then
            break
        else
            echo "  That doesn't look right. Please enter a whole number between 1 and 100."
        fi
    done

    while true; do
        read -rp "  New Failure threshold (1-100, just press Enter to keep 50): " NEW_FAILURE
        NEW_FAILURE="${NEW_FAILURE:-50}"
        if [[ "$NEW_FAILURE" =~ ^[0-9]+$ ]] && (( NEW_FAILURE >= 1 && NEW_FAILURE <= 100 )); then
            break
        else
            echo "  That doesn't look right. Please enter a whole number between 1 and 100."
        fi
    done

    # It doesn't make sense for the warning to be lower than or equal to the failure level.
    # If that happens, we fall back to the defaults and let the user know.
    if (( NEW_WARNING <= NEW_FAILURE )); then
        echo "  Heads up: the warning level needs to be higher than the failure level."
        echo "  Falling back to the defaults (75 / 50)."
        NEW_WARNING=75
        NEW_FAILURE=50
    fi

    # Use sed to swap out the old numbers directly in the config file.
    # The .bak suffix is required on macOS — we remove it right after.
    sed -i.bak "s/\"warning\": [0-9]*/\"warning\": ${NEW_WARNING}/" "$CONFIG_FILE"
    sed -i.bak "s/\"failure\": [0-9]*/\"failure\": ${NEW_FAILURE}/" "$CONFIG_FILE"
    rm -f "${CONFIG_FILE}.bak"

    echo "  Config updated — warning: ${NEW_WARNING}%, failure: ${NEW_FAILURE}%"

else
    echo "Keeping the defaults (warning: 75%, failure: 50%)."
fi


# Before we wrap up, let's do a quick health check.
# We want to make sure Python 3 is available, since that's what runs the tracker.
# We also confirm that every expected file actually ended up in the right place.
echo ""
echo "Running a quick health check..."

if python3 --version &>/dev/null; then
    PY_VER=$(python3 --version 2>&1)
    echo "  Python 3 is installed: ${PY_VER}"
else
    echo "  Warning: Python 3 doesn't seem to be installed (or it's not on your PATH)."
    echo "  You'll need it to run attendance_checker.py."
fi

# Walk through the expected files and flag anything that's missing
ALL_GOOD=true
for EXPECTED in \
    "${PROJECT_DIR}/attendance_checker.py" \
    "${PROJECT_DIR}/Helpers/assets.csv" \
    "${PROJECT_DIR}/Helpers/config.json" \
    "${PROJECT_DIR}/reports/reports.log"; do
    if [[ ! -f "$EXPECTED" ]]; then
        echo "  Missing: $EXPECTED"
        ALL_GOOD=false
    fi
done

if $ALL_GOOD; then
    echo "  All files are in place."
else
    echo "  Some files are missing — check the output above to see what went wrong."
fi


# All done!
echo ""
echo "  Setup complete!"
echo "  Your project is ready at: ./${PROJECT_DIR}"
echo ""
echo "  To run the attendance tracker:"
echo "    cd ${PROJECT_DIR} && python3 attendance_checker.py"
echo ""
echo "  Tip: if you run this script again and press Ctrl+C partway through,"
echo "  it will automatically archive and clean up whatever was created."
echo ""
