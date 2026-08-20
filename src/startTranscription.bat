@echo off
:: Launches WSL, runs commands, and drops you into an active Bash prompt
wsl -e bash -lic "cd $fasterWhisper; uv run src/transcription.py --input-folder inputAudioFiles --output-folder outputSRTFiles; exec bash"
