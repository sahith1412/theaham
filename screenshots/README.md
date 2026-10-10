# Screenshot and capture protocol

This repository does not generate its own game images. The Kala Laya team captures real ones here,
and they become the evidence base that replaces every *(unverified — confirm)* number in
[docs/02-old-vs-modern-engines.md](../docs/02-old-vs-modern-engines.md).

## What to capture

For each game, the **same scene and camera position** at every variant. Pick a scene with water or
glass (reflections), a strong sun with long shadows, an interior corner (indirect light), and fog or
dust if the game has it.

| Set | Variants | Why |
|---|---|---|
| **Old game** (pick 2: e.g. Half-Life 2 (2004), Crysis (2007), Bioshock Infinite (2013)) | Max settings on both cards | Baseline for "what a 2016 card does effortlessly" |
| **2017-era game** (pick 2: e.g. The Witcher 3 (2015, no RT), Doom (2016), Battlefield 1) | Ultra on both cards | The 1060's home era — proves PBR+deferred+TAA is fine |
| **Modern Bucket A** (e.g. Cyberpunk 2077 RT off, RE4 Remake RT off) | Low / Medium / Ultra on both cards | Shows which settings matter |
| **Modern Bucket B candidate** (any UE5 Lumen title, any DLSS-only title) | Lowest possible on 1060; Medium on 3050; Medium + RT on 3050 | The target gap |
| **Modern Bucket C** (e.g. Indiana Jones: Great Circle) | Launch attempt on 1060 (error screenshot); Medium on 3050 | Documents the honest limit |

## How to capture

1. Install **RivaTuner Statistics Server** (RTSS) with MSI Afterburner, or use the in-game
   performance overlay. Show at minimum: **GPU name, FPS, frametime (ms), GPU %, VRAM used**.
2. Resolution **1920×1080**, borderless or fullscreen, V-sync **off**, frame cap **off**.
3. Stand still for 5 s before capturing so TAA/temporal effects settle.
4. Capture with the game's own screenshot key or Win+Alt+PrtScn (lossless PNG). No compression.
5. If you can, also record a **PIX** (D3D12), **Nsight Graphics**, or **RenderDoc** frame capture of
   the same moment and export the per-pass timing table as CSV. That is the single most valuable
   artefact for this project — it replaces the guessed ms numbers in doc 02.
6. Optional: a 10–20 s video clip (OBS, 1080p60) panning the same scene, for motion artefacts
   (TAA ghosting, FSR shimmer).

## Naming

```
screenshots/<game-slug>-<year>-<preset>-<rt|nort>-<gpu>.png
screenshots/<game-slug>-<year>-<preset>-<rt|nort>-<gpu>.passes.csv   (profiler export)
screenshots/<game-slug>-<year>-<preset>-<rt|nort>-<gpu>.mp4          (optional clip)

examples:
screenshots/cyberpunk2077-2020-medium-nort-gtx1060.png
screenshots/cyberpunk2077-2020-medium-rt-rtx3050.png
screenshots/cyberpunk2077-2020-medium-rt-rtx3050.passes.csv
screenshots/indianajones-2024-launchfail-rt-gtx1060.png
```

`<gpu>` is one of `gtx1060`, `rtx3050`.

## After capturing

For each pair, fill in the annotation template from
[docs/02-old-vs-modern-engines.md §3](../docs/02-old-vs-modern-engines.md#3-how-to-read-a-screenshot-annotation-template)
in a sibling `.md` file with the same base name, and open a PR. Large files (> 10 MB) should go
through Git LFS.
