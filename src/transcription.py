import os
import glob
import subprocess
import time
from faster_whisper import WhisperModel

def getTimestamp(seconds):
    hours, remainder = divmod(seconds, 3600)
    minutes, secs = divmod(remainder, 60)
    return (f"{int(hours):02}:{int(minutes):02}:{secs:06.3f}").replace(".", ",")

# ---- CONFIG ----
# your 2h audio file
FILE_NAME = "05-20-2026 20.18.wav"
AUDIO_FILE = f"/home/yuanqing/fasterWhisper/inputAudioFiles/{FILE_NAME}"
CHUNK_DIR = "/home/yuanqing/fasterWhisper/inputAudioFiles/chunk"
CHUNK_LENGTH = 5*60              # seconds per chunk
MODEL_SIZE = "large-v3-turbo"            # try "small" or "medium"
COMPUTE_TYPE = "int8"           # quantized inference
OUTPUT_NAME = FILE_NAME.replace(".wav", ".SRT")
OUTPUT_FILE = f"/home/yuanqing/fasterWhisper/outputSRTFiles/{OUTPUT_NAME}"

# ---- STEP 1: Split audio into chunks using ffmpeg ----
os.makedirs(CHUNK_DIR, exist_ok=True)

# ffmpeg command: split into 10-min segments
subprocess.run([
    "ffmpeg", "-i", AUDIO_FILE,
    "-f", "segment", "-segment_time", str(CHUNK_LENGTH),
    "-c", "copy", f"{CHUNK_DIR}/chunk_%03d.wav"
])

# ---- STEP 2: Load Faster-Whisper model ----
model = WhisperModel(MODEL_SIZE, device="cpu", compute_type=COMPUTE_TYPE)

# ---- STEP 3: Transcribe each chunk ----
cumulativeTime = 0
SRT_Seq = 1
f = open(OUTPUT_FILE, "a", encoding="utf-8")
for file in sorted(glob.glob(f"{CHUNK_DIR}/chunk_*.wav")):
    start = time.time()
    print(f"Transcribing {file}...")
    segments, info = model.transcribe(file, beam_size=5)
    end = time.time()
    print(f"Finish Transcribing {file}...")
    print(f"Processing time: {end - start:.2f} seconds")

    for seg in segments:
        startTimeStamp = getTimestamp(seg.start+cumulativeTime)
        endTimeStamp = getTimestamp(seg.end+cumulativeTime)
        line = f"{SRT_Seq}\n{startTimeStamp} -> {endTimeStamp}\n{seg.text}\n\n"
        cumulativeTime += seg.end-seg.start
        SRT_Seq += 1
        f.write(line)
        f.flush()


print(f"✅ Transcription complete. See {OUTPUT_FILE}")
