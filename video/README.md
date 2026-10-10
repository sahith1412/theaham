# Downshift explainer video

A ~11-minute motion-graphics explainer of the whole M0 research package (docs 01–08), produced
entirely from code so it can be regenerated when the docs change.

- `script.md` — narration script with per-scene timestamps. Also the source of the on-screen
  captions (embedded as JSON in `build/scenes.html`); keep both in sync.
- `build/scenes.html` — the animation. Twelve scenes drawn in SVG; every frame is a pure function
  of time via `window.__seek(seconds)`, so renders are deterministic.
- `build/render.mjs` — Playwright/Chromium frame renderer (1920×1080, 30 fps → PNG sequence).
- `build/make_audio.sh` — ffmpeg-synthesised ambient bed; mixes `voice.wav` on top if present.
- `build/build.sh` — render → audio → H.264/AAC mp4.

## Rebuild

Needs Node ≥ 18 with `playwright` (and its Chromium) resolvable, plus `ffmpeg`.

```bash
NODE_PATH=$(npm root -g) bash video/build/build.sh /tmp/downshift-video
# → /tmp/downshift-video/downshift-explainer.mp4
```

Rendering ~20 000 frames takes ~15 min on 4 cores if you split the time range across workers
(`render.mjs <out> 30 <startSec> <endSec>`), or ~55 min single-threaded.

## Voice-over

No TTS engine was reachable from the build environment, so the narration is delivered as captions.
To add a voice track: generate `voice.wav` from `script.md` with any TTS (e.g. `edge-tts`, Piper),
aligned to the scene timestamps, drop it in the work dir, and re-run `make_audio.sh` + the encode.

## Output

`downshift-explainer.mp4` is not committed (size). It is attached to PR #1 / shared directly.
Preview the animation without rendering: open `build/scenes.html` in a browser and call
`__seek(120)` in the console.
