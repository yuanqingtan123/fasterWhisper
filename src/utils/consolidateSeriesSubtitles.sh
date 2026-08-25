#!/usr/bin/bash
# ------------------------------------------------------------------------------
# Subtitle Consolidation Script
# ------------------------------------------------------------------------------
# Description :
#   Consolidates all subtitle files in a directory into a single output file.
#   By default, it processes `.srt` files ending with "EN.srt", but you can
#   override the search pattern and apply additional `grep` filters.
#
# Usage :
#   ./getAllSubtitles.sh [-d DIRECTORY] [-p SEARCH_PATTERN] [-g GREP_ARGS]
#
#   -d   Directory to search for subtitle files
#        If omitted, defaults to the current working directory.
#
#   -p   Search pattern for `find` command
#        If omitted, defaults to "*_EN.srt".
#
#   -g   Additional arguments for `grep` to refine file selection
#        Examples:
#          -g "-v -e draft"       # exclude files containing "draft"
#          -g "-e movie -e show"  # include only files containing "movie" or "show"
#
# Output :
#   Creates a single file named "AllSubtitles.txt" containing:
#     - The filename of each subtitle file
#     - The full contents of the subtitle file
#     - A blank line separator between files
#
# Examples :
#   ./getAllSubtitles.sh
#   ./getAllSubtitles.sh -d ./series -p "*.srt"
#   ./getAllSubtitles.sh -d ./series -p "*.srt" -g "-v -e draft"
#
# Dependencies :
#   bash ≥ 4, standard Unix tools (find, grep, cat)
#
# Author :
#   Yuan Qing
# ------------------------------------------------------------------------------
set -e          # Exit immediately if any command fails
set -u          # Treat unset variables as errors
set -o pipefail # Ensure pipeline errors are caught

language=""
SCRIPT_NAME=$(basename "$0")
NL=$'\n'
directory="."            # Default search directory
searchPattern="*_EN.srt" # Default search pattern
grepArguments=""         # Default grep arguments (none)

# Construct usage message with defaults
USAGE_MSG="./$SCRIPT_NAME -d [directory] -p [search pattern] -g [grep arguments] -l ['CN' or 'EN']"
USAGE_MSG="$USAGE_MSG $NL if -d is omitted, use current directory"
USAGE_MSG="$USAGE_MSG $NL if -p is omitted, default search pattern: $searchPattern"
USAGE_MSG="$USAGE_MSG $NL if -g is omitted, no grep filtering is applied"
USAGE_MSG="$USAGE_MSG $NL -l is compulsory, script will exit if unspecified"
USAGE_MSG="$USAGE_MSG $NL Example:"
USAGE_MSG="$USAGE_MSG $NL ./$SCRIPT_NAME -d ../input -p \"*.srt\" -g '-v -e draft' -l 'EN'"

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
while getopts "d:p:g:l:" opt; do
    case "$opt" in
    d) directory="$OPTARG" ;;
    p) searchPattern="$OPTARG" ;;
    g) grepArguments="$OPTARG" ;;
    l) language="$OPTARG" ;;
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

# Validate language
if [[ -z "$language" ]]; then
    echo "Language unspecified. Please pass argument to -l"
    echo "$USAGE_MSG"
    exit 1
fi

outputFileName="AllSubtitles_$language.txt"

if [[ -f "$outputFileName" ]]; then
    echo "Output File $outputFileName exists. Please rename or remove before running script."
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

# -------------------------------
# Consolidation loop
# -------------------------------
for file in "${files[@]}"; do
    echo "Appending $file to $outputFileName"
    echo -e "$file" >>"$outputFileName" # record filename
    cat "$file" >>"$outputFileName"     # append contents
    echo "" >>"$outputFileName"         # add separator
done

echo "Subtitle consolidation complete. Output written to $outputFileName"
