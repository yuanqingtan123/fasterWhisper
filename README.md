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

---

## Utility Scripts (`src/utils/`)

In addition to the main transcription workflow, the repository includes helper scripts for working with subtitle files. These are located in `src/utils/`.

### Subtitle Consolidation Script (`getAllSubtitles.sh`)
- **Purpose**: Consolidates all subtitle files in a directory into a single output file.  
- **Default behavior**: Processes `.srt` files ending with `EN.srt`.  
- **Options**:
  - `-d` → Directory to search (defaults to current directory).  
  - `-p` → Search pattern for `find` (defaults to `*_EN.srt`).  
  - `-g` → Additional `grep` filters (e.g., exclude drafts or include only certain keywords).  
- **Output**: Creates `AllSubtitles.txt` containing filenames, full contents, and blank line separators.  
- **Examples**:
  ```bash
  ./getAllSubtitles.sh
  ./getAllSubtitles.sh -d ./series -p "*.srt"
  ./getAllSubtitles.sh -d ./series -p "*.srt" -g "-v -e draft"
  ```

---

### Subtitle Extractor Script (`getSubtitle.sh`)
- **Purpose**: Extracts every fourth line from `.srt` files (default `*_EN.srt`) into new `.txt` files.  
- **Use case**: Isolates dialogue text from timing and metadata.  
- **Options**:
  - `-d` → Directory to search (defaults to current directory).  
  - `-p` → Search pattern (defaults to `*_EN.srt`).  
  - `-g` → Additional `grep` filters (e.g., exclude samples).  
- **Output**: Creates `.txt` files with extracted dialogue lines.  
- **Examples**:
  ```bash
  ./getSubtitle.sh
  ./getSubtitle.sh -d ./movies -p "*.srt"
  ./getSubtitle.sh -d ./movies -p "*.srt" -g "-v -e draft"
  ```

---

### Subtitle Merger Script (`mergeSubtitles.sh`)
- **Purpose**: Combines an original `.srt` file with a translated `.txt` file to produce a bilingual `.srt`.  
- **Options**:
  - `-o` → Path to the original subtitle file.  
  - `-t` → Path to the translated text file.  
- **Output**: A new `.srt` file named `<original_basename>_<translation_suffix>.srt`.  
  - If the output file already exists, the script prompts before creating a new file prefixed with `New-`.  
- **Example**:
  ```bash
  ./mergeSubtitles.sh -o ./path/to/original.srt -t ./path/to/translated.txt
  ```

---

### 🧠 Notes
- All scripts require **bash ≥ 4** and standard Unix tools (`find`, `grep`, `cat`, `sed`, etc.).  
- Place them in `src/utils/` and run from the repo root or adjust paths accordingly.  
- These utilities are optional helpers for managing subtitle files alongside the main transcription workflow.
