#!/usr/bin/env bash
# Generates a soft ambient pad for the full duration. If voice.wav exists (from tts.py), mixes it on top.
# usage: make_audio.sh <durationSec> <outDir>
set -euo pipefail
DUR=$1; OUT=$2; mkdir -p "$OUT"
# slow-evolving pad: three detuned sines + filtered noise, gentle tremolo
ffmpeg -y -loglevel error -f lavfi -t "$DUR" \
 -i "aevalsrc=0.08*sin(2*PI*110*t)*(0.6+0.4*sin(2*PI*0.05*t))+0.05*sin(2*PI*164.8*t+0.3)*(0.6+0.4*sin(2*PI*0.037*t))+0.04*sin(2*PI*220.5*t):s=48000" \
 -f lavfi -t "$DUR" -i "anoisesrc=c=pink:a=0.015:s=48000" \
 -filter_complex "[0][1]amix=inputs=2:normalize=0,lowpass=f=900,afade=t=in:d=3,afade=t=out:st=$((DUR-4)):d=4,volume=1.0" \
 -ar 48000 -ac 2 "$OUT/pad.wav"
if [ -f "$OUT/voice.wav" ]; then
  ffmpeg -y -loglevel error -i "$OUT/voice.wav" -i "$OUT/pad.wav" \
   -filter_complex "[1]volume=0.35[p];[0][p]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-16:TP=-1.5" \
   -ar 48000 -ac 2 -c:a aac -b:a 160k "$OUT/audio.m4a"
else
  ffmpeg -y -loglevel error -i "$OUT/pad.wav" -af loudnorm=I=-24:TP=-2 -c:a aac -b:a 128k "$OUT/audio.m4a"
fi
echo "audio → $OUT/audio.m4a"
