#!/usr/bin/python3
"""
Audio-to-SRT transcription script using Faster-Whisper.

Steps:
1. Splits a .wav audio file into fixed-length chunks using ffmpeg.
2. Loads a Faster-Whisper model for CPU-based transcription.
3. Transcribes each chunk sequentially and writes results into an .SRT subtitle file.

Input:
    --audioFileName <filename.wav>

Output:
    Subtitle file (.SRT) saved in /home/yuanqing/fasterWhisper/outputSRTFiles/
"""

import os
import glob
import subprocess
import time
from faster_whisper import WhisperModel
import argparse


def get_timestamp(seconds: float) -> str:
    """Convert seconds to SRT timestamp format (HH:MM:SS,mmm)."""
    hours, remainder = divmod(seconds, 3600)
    minutes, secs = divmod(remainder, 60)
    return f"{int(hours):02}:{int(minutes):02}:{secs:06.3f}".replace(".", ",")


def split_audio(input_file: str, chunk_dir: str, chunk_length: int) -> None:
    """Split audio into .wav chunks using ffmpeg."""
    os.makedirs(chunk_dir, exist_ok=True)
    if os.path.exists(chunk_dir) and os.listdir(chunk_dir):
        raise FileExistsError(f"Chunk directory {chunk_dir} exists and is not empty.")

    subprocess.run([
        "ffmpeg", "-i", input_file,
        "-f", "segment", "-segment_time", str(chunk_length),
        "-c", "pcm_s16le",  # force raw WAV encoding
        f"{chunk_dir}/chunk_%03d.wav"
    ], check=True)


def transcribe_chunks(chunk_dir: str, output_file: str, model_size: str, compute_type: str) -> None:
    """Transcribe audio chunks and write results to an SRT file."""
    model = WhisperModel(model_size, device="cpu", compute_type=compute_type)

    cumulative_time = 0.0
    srt_seq = 1

    with open(output_file, "w", encoding="utf-8") as f:
        for file in sorted(glob.glob(f"{chunk_dir}/chunk_*.wav")):
            start = time.time()
            print(f"Transcribing {file}...")
            segments, _ = model.transcribe(file, beam_size=5)
            print(f"Finished {file} in {time.time() - start:.2f} seconds")

            for seg in segments:
                start_ts = get_timestamp(seg.start + cumulative_time)
                end_ts = get_timestamp(seg.end + cumulative_time)
                line = f"{srt_seq}\n{start_ts} --> {end_ts}\n{seg.text}\n\n"
                f.write(line)
                srt_seq += 1

            cumulative_time += seg.end - seg.start

    print(f"✅ Transcription complete. See {output_file}")


def main():
    parser = argparse.ArgumentParser(description="Convert .wav audio file into .SRT subtitle file")
    parser.add_argument("--audioFileName", required=True, help="Input audio file name (e.g., FileName.wav)")
    args = parser.parse_args()

    file_name = args.audioFileName
    audio_file = f"/home/yuanqing/fasterWhisper/inputAudioFiles/{file_name}"
    chunk_dir = "/home/yuanqing/fasterWhisper/inputAudioFiles/chunk"
    base_name= ".".join(file_name.split(".")[:-1])
    output_name = f"{base_name}.SRT"
    output_file = f"/home/yuanqing/fasterWhisper/outputSRTFiles/{output_name}"

    try:
        split_audio(audio_file, chunk_dir, chunk_length=5 * 60)
        transcribe_chunks(chunk_dir, output_file, model_size="large-v3-turbo", compute_type="int8")
    except FileNotFoundError:
        print(f"❌ File not found: {audio_file}")
    except FileExistsError as e:
        print(f"❌ {e}")
    except subprocess.CalledProcessError:
        print(f"❌ ffmpeg failed to process {audio_file}")


if __name__ == "__main__":
    main()