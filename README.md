# Audio Transcription with Faster‑Whisper

This repository provides a Python script that converts audio files into subtitle files (`.SRT`) using the **faster_whisper** `large-v3-turbo` model.  
It was developed in **WSL** with **uv** managing the virtual environment.

---

## Requirements

### Core Dependencies
- Python 3.10+
- ffmpeg (for audio splitting)
- faster_whisper (for transcription)
- click (for CLI handling)

### uv Package Manager
Install `uv` to manage the virtual environment:

- **Linux/macOS**
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

---

## Project Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yuanqingtan123/fasterWhisper.git
   cd fasterWhisper
   ```

2. **Create directory structure**
   ```
   fasterWhisper
   ├── inputAudioFiles/     # place input audio files here
   ├── outputSRTFiles/      # generated SRT files will be saved here
   ├── src/                 # transcription script
   ├── pyproject.toml
   ├── uv.lock
   └── .venv/
   ```

3. **Install dependencies**
   ```bash
   uv sync
   ```

4. **Activate environment**
   ```bash
   source .venv/bin/activate
   ```

---

## Usage

Place audio files (`.wav`, `.mp3`, `.m4a`) into the `inputAudioFiles` folder, then run:

```bash
uv run src/transcription.py --input-folder inputAudioFiles --output-folder outputSRTFiles
```

### Example
```bash
uv run src/transcription.py \
  --input-folder ./inputAudioFiles \
  --output-folder ./outputSRTFiles
```

After transcription, clear the `inputAudioFiles` folder to avoid reprocessing on subsequent runs.

---

## Suggested Workflow on Windows + WSL

This workflow sets up a convenient way to run transcriptions from Windows while leveraging WSL.

1. **Open a terminal** at the project repo root directory (`fasterWhisper`).
1. **Set up the project** as described in [Project Setup](#project-setup), Steps 1 and 2.
1. **Run the setup script**:
   ```bash
   src/run.sh
   ```
   - The script will configure the required environment variable.
   - Follow the on‑screen instructions displayed in the terminal.
   - On successful completion, you will see:
     ```
     Script completed.
     ```
1. **Simplified workflow after setup**:
   1. Copy audio files into the `inputAudioFiles` folder (you can use the shortcut created by the script).
   1. Start transcription by double‑clicking `startTranscription.bat` from Windows.
   1. When transcription finishes, access the generated `.SRT` files in the `outputSRTFiles` folder (via the shortcut).
   1. Delete or move the processed audio files from `inputAudioFiles` to avoid reprocessing on the next run.

---

## Error Handling

### Chunk Folder Exists
- Each input file is split into chunks stored in a temporary folder.
- If the folder already exists and is not empty, the script will fail.
- Check logs and delete the folder before retrying.

### Unsupported Input Files
- Unsupported or corrupted files are skipped.
- Errors are logged, and the script continues with remaining files.
- At the end, a summary of failed files is displayed.

### Model File
- The script first attempts to load the model from local cache.
- If missing, it downloads the model from Hugging Face (requires internet).

---

## Notes
- Default chunk length: **5 minutes**.
- Default model: **large-v3-turbo** (CPU, quantized `int8`).
- Output timestamps follow standard SRT format: `HH:MM:SS,mmm`.
