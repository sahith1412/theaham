#!/usr/bin/env bash
# Full build: render frames → audio → encode. Needs node + playwright (chromium) + ffmpeg.
# usage: build.sh <workDir> [fps]
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd); WORK=${1:-/tmp/downshift-video}; FPS=${2:-30}
mkdir -p "$WORK/frames"
export NODE_PATH=${NODE_PATH:-$(npm root -g):/opt/node-tools/node_modules}
node "$HERE/render.mjs" "$WORK/frames" "$FPS"
DUR=$(NODE_PATH=$NODE_PATH node -e "import('playwright').then(async({chromium})=>{const b=await chromium.launch();const p=await b.newPage();await p.goto('file://$HERE/scenes.html');console.log(await p.evaluate(()=>window.__total()));await b.close()})")
bash "$HERE/make_audio.sh" "${DUR%.*}" "$WORK"
ffmpeg -y -loglevel error -framerate "$FPS" -i "$WORK/frames/%06d.png" -i "$WORK/audio.m4a" \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -c:a copy -shortest -movflags +faststart \
  "$WORK/downshift-explainer.mp4"
ffprobe -v error -show_entries format=duration:stream=codec_name,width,height,r_frame_rate -of compact "$WORK/downshift-explainer.mp4"
