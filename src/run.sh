#!/bin/bash

currentWorkingDir=$(pwd)
folder=$(basename $currentWorkingDir)

if [[ "$folder" == "fasterWhisper" ]]; then
    echo "export fasterWhisper=$currentWorkingDir" >>$HOME/.bashrc

    read -p $'1. Copy startTranscription.bat into a convenient location. Eg: Desktop.\n   Press any key to continue...' -n 1 response
    explorer.exe src || true

    read -p $'\n2. Create shortcuts to inputAudioFiles and outputSRTFiles folders at a convenient location. Eg: Desktop.\n   Press any key to continue...' -n 1 response
    explorer.exe . || true

    read -p $'\n   Script completed.' -n 1 response

else
    echo "Please run this script from the repo root directory."
    exit 1
fi
