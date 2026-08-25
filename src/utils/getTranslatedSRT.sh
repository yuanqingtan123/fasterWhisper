#!/usr/bin/bash
# ------------------------------------------------------------------------------
# Subtitle Merger Script
# ------------------------------------------------------------------------------
# Description : Combines an original `.srt` subtitle file with a translated `.txt`
#               file. The translated lines are inserted alongside the original
#               subtitle text every 4th line, producing a bilingual `.srt` file.
#
# Usage       : ./script.sh -o ./path/to/original.srt -t ./path/to/translated.txt
#
# Arguments   :
#   -o   Path to the original subtitle file (.srt)
#   -t   Path to the translated text file (.txt)
#
# Output      : A new `.srt` file named <original_basename>_<translation_suffix>.srt
#               If the output file already exists, user is prompted to confirm
#               creating a new file prefixed with "New-".
#
# Dependencies: bash ≥ 4, sed, standard Unix tools
# Author      : Yuan Qing
# ------------------------------------------------------------------------------

USAGE_MSG="Usage ./$(basename $0) -o [./path/to/original.srt] -t [./path/to/translated.txt]"

# Ensure exactly 4 arguments are provided (two flags + two paths)
if [[ $# -ne 4 ]]; then
    echo "Invalid usage"
    echo "$USAGE_MSG"
    exit 1
fi

# Convert arguments into an array for easier parsing
mapfile -t args < <(echo "$@" | tr " " "\n")

# Parse flags and assign file paths
for i in $(seq 0 2 $(($# - 1))); do
    case "${args[$i]}" in
    "-o")
        originalSRTPath=${args[$((i + 1))]}
        ;;
    "-t")
        translatedTxtPath=${args[$((i + 1))]}
        ;;
    *)
        echo "$USAGE_MSG"
        echo "Invalid script argument flags. Ending $(basename $0)"
        exit 1
        ;;
    esac
done

# Derive output filename:
# - Base name from original SRT (without extension)
# - Suffix from translated TXT (after last underscore)
originalSRTBaseName=$(basename "${originalSRTPath%.srt}")
translationSuffix=$(basename "${translatedTxtPath%.txt}" | sed "s/.*_\(.*\)/\1/")
outputFileName="${originalSRTBaseName}_${translationSuffix}.srt"
currentWorkingDirectory=$(pwd)

# If output file already exists, prompt user for confirmation
if [ -f "$outputFileName" ]; then
    echo "Output file $outputFileName exists"
    read -p "Continue with filename New-$outputFileName? (y/n) " answer
    case "$answer" in
    [yY] | [yY][eE][sS])
        echo "Running..."
        ;;
    [nN] | [nN][oO])
        echo "Ending Program"
        exit 1
        ;;
    *)
        echo "Invalid response. Ending Program"
        exit 1
        ;;
    esac
    outputFileName="New-$outputFileName"
fi

# Load original and translated files into arrays (one line per element)
mapfile -t originalSRTLines < <(cat "$originalSRTPath")
mapfile -t translatedLines < <(cat "$translatedTxtPath")

# Merge logic:
# - Iterate through original SRT lines
# - Every 4th line: insert corresponding translated line before original subtitle text
for i in "${!originalSRTLines[@]}"; do
    if [[ $((($i + 1) % 4)) -eq 0 ]]; then
        echo "${translatedLines[$((($i - 3) / 4))]}" >>"$outputFileName"
        echo "${originalSRTLines[$i]}" >>"$outputFileName"
    else
        echo "${originalSRTLines[$i]}" >>"$outputFileName"
    fi
done

# Final output location
echo "Output File Location: ${currentWorkingDirectory}/$outputFileName"

exit 0
