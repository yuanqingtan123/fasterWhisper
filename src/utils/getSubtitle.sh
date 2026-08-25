#!/usr/bin/bash
# ------------------------------------------------------------------------------
# Subtitle Extractor Script
# ------------------------------------------------------------------------------
# Description :
#   Processes `.srt` subtitle files ending with "EN.srt" (or a custom pattern)
#   and extracts every fourth line into a new `.txt` file. This is useful for
#   isolating subtitle text blocks (dialogue lines) from timing and metadata.
#
# Usage :
#   ./getSubtitle.sh [-d DIRECTORY] [-p SEARCH_PATTERN] [-g GREP_ARGS]
#
#   -d   Directory to search for subtitle files
#        If omitted, defaults to the current working directory.
#
#   -p   Search pattern for `find` command
#        If omitted, defaults to "*_EN.srt".
#
#   -g   Additional arguments for `grep` to refine file selection
#        Examples:
#          -g "-v -e sample"   # exclude files containing "sample"
#          -g "-e movie -e show" # include only files containing "movie" or "show"
#
# Examples :
#   ./getSubtitle.sh
#   ./getSubtitle.sh -d ./movies -p "*.srt"
#   ./getSubtitle.sh -d ./movies -p "*.srt" -g "-v -e draft"
#
# Dependencies :
#   bash ≥ 4, standard Unix tools (find, grep, rm, seq)
#
# Author :
#   Yuan Qing
# ------------------------------------------------------------------------------
set -e          # Exit immediately if any command fails
set -u          # Treat unset variables as errors
set -o pipefail # Ensure pipeline errors are caught

SCRIPT_NAME=$(basename "$0")
NL=$'\n'
directory=$(pwd)         # Default search directory
searchPattern="*_EN.srt" # Default search pattern
grepArguments=""         # Default grep arguments (none)

# Construct usage message with defaults
USAGE_MSG="./$SCRIPT_NAME -d [directory to search] -p [search pattern for \"find\" command] -g [grep arguments as a string]"
USAGE_MSG="$USAGE_MSG $NL if -d is omitted, use current directory"
USAGE_MSG="$USAGE_MSG $NL if -p is omitted, default search pattern: $searchPattern"
USAGE_MSG="$USAGE_MSG $NL if -g is omitted, no grep filtering is applied"
USAGE_MSG="$USAGE_MSG $NL Example:"
USAGE_MSG="$USAGE_MSG $NL ./$SCRIPT_NAME -d ../input -p \"*.srt\" -g '-e \"messages.txt\" -v'"

# -------------------------------
# Argument validation
# -------------------------------
if [[ $# -gt 6 ]]; then
    echo "Too many arguments"
    echo "$USAGE_MSG"
    exit 1
fi

if [[ $(($# % 2)) -ne 0 ]]; then
    echo "Invalid number of arguments"
    echo "$USAGE_MSG"
    exit 1
fi

# Parse arguments into array
while getopts "d:p:g:" opt; do
    case "$opt" in
    d) directory="$OPTARG" ;;
    p) searchPattern="$OPTARG" ;;
    g) grepArguments="$OPTARG" ;;
    \?)
        echo "Invalid usage"
        echo "$USAGE_MSG"
        exit 1
        ;;
    esac
done

echo "Directory: $directory"
echo "Search Pattern: $searchPattern"
echo "grep Arguments: $grepArguments"

# Validate directory
if [ ! -d "$directory" ]; then
    echo "Directory not found: $directory"
    exit 1
fi

# -------------------------------
# File discovery
# -------------------------------
# Use `find` to locate files, then optionally filter with grep if arguments are provided
if [[ -n "$grepArguments" ]]; then
    mapfile -t files < <(find "$directory" -name "$searchPattern" | bash -c "grep $grepArguments")
else
    mapfile -t files < <(find "$directory" -name "$searchPattern")
fi

numOfFilesToProcess=${#files[@]}
if [ $numOfFilesToProcess -eq 0 ]; then
    echo "No files to process"
    exit 0
fi
echo "Files to process: $numOfFilesToProcess"

# -------------------------------
# Processing loop
# -------------------------------
filesCreated=()
for file in "${files[@]}"; do
    # Convert filename extension from .srt to .txt
    filename="${file%.srt}.txt"

    # Remove existing output file if present
    if [ -f "$filename" ]; then
        rm "$filename"
    fi

    line=1 # Start at 1 because first block does not begin with newline

    # Read file line by line
    while IFS= read -r row; do
        line=$((line + 1))

        # Record file creation when reaching line 4
        if [ $line -eq 4 ]; then
            filesCreated+=("$filename")
        fi

        # Extract every 4th line into the new file
        if [[ $((line % 4)) -eq 0 ]]; then
            echo "$row" >>"$filename"
        fi
    done <"$file"
done

# -------------------------------
# Output summary
# -------------------------------
echo "--------------------"
for file in "${filesCreated[@]}"; do
    echo "$file"
done
echo "Total ${#filesCreated[@]} files created"
