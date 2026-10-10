# 02 — Old engines vs modern engines: what changed, and what it costs

The central claim of Downshift: **modern games are not expensive because of one big thing; they are
expensive because of a stack of individually optional techniques layered onto a core that a 2016 GPU
can run fine.** Peel the stack back to roughly the 2015–2018 "PBR + deferred + TAA" level and the
GTX 1060 is a perfectly adequate card — that is the generation it was built for.

## 1. Engine anatomy by era

| Era (typical GPU) | Lighting model | Shadows | AO / reflections | AA | Geometry | Example engines |
|---|---|---|---|---|---|---|
| **2000–2006** fixed-function → early shaders (GeForce 4–7) | Per-vertex / simple per-pixel Phong, lightmaps baked offline | Stencil shadows or one small shadow map | None / cube-map reflections | MSAA | Low-poly + normal maps | Quake 3, Half-Life 2, Doom 3 |
| **2007–2013** forward & early deferred (GeForce 8–700) | Per-pixel Blinn-Phong, few dynamic lights, baked GI | Cascaded shadow maps (1–2K) | SSAO (Crysis invented it), planar/cube reflections | MSAA / FXAA | Normal + parallax maps | CryEngine 2, UE3, Frostbite 2 |
| **2014–2019** PBR deferred (GTX 900–1000 — **the 1060's home era**) | Physically-based BRDF, image-based lighting, baked or probe GI, many lights via tiled/clustered deferred | CSM 2–4K, PCF/PCSS soft | HBAO/GTAO, screen-space reflections (SSR) | TAA | Tessellation, high-res PBR textures | UE4, Frostbite 3, id Tech 6, RE Engine |
| **2020–2026** RT hybrid (RTX 20–50) | Same PBR core **plus** ray-traced reflections / shadows / GI (Lumen, RTXGI), path tracing on the high end | RT shadows or very high-res CSM + contact shadows | RT AO, RT reflections; SSR/GTAO as fallback | TAA + AI upscaler (DLSS/FSR/XeSS) + frame generation | Nanite / mesh shaders, virtual textures | UE5, id Tech 7/8, Northlight, RE Engine (RT), Frostbite (RT) |

The key observation in the last row: **every RT feature has a 2014–2019-era fallback that already
exists inside most engines** (because consoles and mid-range PCs needed it). Downshift's job is to
force that fallback — or supply one — when the game didn't expose a setting for it.

## 2. Technique cost table and cheap substitutes

Costs are *order-of-magnitude* typical values at 1080p on the two target cards. They are not
measurements from this repository — treat every number as *(unverified — confirm with a profiler
capture)*. Real per-game numbers come from the agent's profiling step (doc 06). What matters here is
the **ratio** between a technique and its substitute.

| Technique (modern) | ≈ ms on RTX 3050 | ≈ ms on GTX 1060 | Cheap substitute | ≈ ms on 1060 | Visible loss |
|---|---|---|---|---|---|
| RT reflections (½-res, denoised) | 3–6 | 15–30 (no RT core) | SSR + cube-map fallback | 1–2 | Off-screen reflections vanish |
| RT global illumination (Lumen HW, RTXGI) | 4–8 | 20–40 | Lumen SW / probe GI / baked | 1–3 | Less accurate bounce light |
| RT shadows (sun) | 2–4 | 10–20 | 2K cascaded shadow map + PCF | 1–2 | Softer, less contact detail |
| RT ambient occlusion | 1–3 | 5–12 | GTAO / HBAO at ½-res | 0.5–1 | Minor |
| Native 1080p + TAA | baseline | baseline | 720p internal + **FSR 2/3.1** Quality/Balanced | −30…−45 % total frame | Slight softness/ghosting |
| 4K shadow cascades × 4 | 2–3 | 4–6 | 1–2K × 3 cascades | 1–2 | Shadow edge blur at distance |
| Full-res volumetric fog/lighting | 1.5–3 | 3–6 | ¼-res + temporal reprojection | 0.5–1 | Soft fog edges |
| Full-res SSR | 1–2 | 2–4 | ½-res SSR | 0.5–1 | Slight reflection blur |
| Screen-space subsurface, hair strands, high-sample DoF/motion blur | 1–3 each | 2–6 each | Reduced sample counts via SPIR-V loop clamp | 0.3–1 | Usually unnoticed |
| Mesh shaders / Nanite (hardware path) | n/a on 1060 | **not supported** | Engine's traditional LOD path (UE5 Nanite has a fallback mesh) | varies | Depends on the engine exposing it |
| High-res PBR textures (4K) | bandwidth | VRAM-bound at 6 GB | Clamp mip 0 → mip 1 | −VRAM | Minor at 1080p |

Adding up the first five rows is the whole story: a 1060 running the **substitute** column lands in
the same frame-time range as a 3050 running the **modern** column. That is why "runs on a 3050 →
runs on a 1060" is a defensible target *for games whose RT features are optional*.

## 3. How to read a screenshot (annotation template)

This repository does not generate its own game images; the Kala Laya team will capture real ones
following [screenshots/README.md](../screenshots/README.md). For each pair (old game / modern game,
or modern game at Low / Ultra), annotate using this checklist. The point is to train the eye to see
**where the milliseconds are**, so that the agent's substitutions can be sanity-checked by a human.

```
File: screenshots/<game>-<year>-<preset>-<gpu>.png
GPU time overlay (RivaTuner / in-game profiler): ____ ms   FPS: ____

[ ] Reflections — mirror-like on water/glass/metal (RT) or smeared / only on-screen objects (SSR) or static (cube map)?
[ ] Shadows     — sharp with soft penumbra that widens with distance (RT/PCSS) or uniformly soft/blocky (CSM)?
[ ] Indirect light — coloured bounce light in corners (RT GI / Lumen) or flat ambient (baked / probes)?
[ ] AO          — dark contact creases under objects (any SSAO) or none (very old)?
[ ] Fog/volumetrics — light shafts through fog (volumetric) or flat distance fog?
[ ] Geometry    — silhouettes smooth at any distance (Nanite/mesh shaders) or visible LOD pops?
[ ] AA          — crawling edges (none/FXAA), slight blur + ghosting trails (TAA), clean (DLSS/FSR Quality)?
[ ] Texture     — sharp at close range (4K) or blurry (1K)?
[ ] Resolution  — native or upscaled? (look for fine wires/fences)
Dominant cost guess (top 3):  1.______  2.______  3.______
Which of the above would the player not notice if downgraded? ______
```

## 4. Old games on new hardware vs new games on old hardware

Worth stating because it inverts the usual intuition:

- **Old games are cheap because they do less per pixel**, not because they are "optimised better".
  Half-Life 2 draws a frame on a 1060 in well under 2 ms.
- **New games are expensive because they do more per pixel**, most of it optional. The core
  (geometry + PBR shading + TAA) still costs about what it did in 2017.
- Therefore the cheapest path to "new game on old hardware" is **not** rewriting the game's engine;
  it is **reverting the per-pixel work to 2017 levels while keeping the game's art and logic**.
  That is a runtime substitution problem, which is what docs 05 and 06 solve.

## Sources

- [lousodrome — Courrèges' Deus Ex: HR frame study summary (G-buffer, shadow map, AO, light pre-pass, bloom, AA, DoF stages)](https://lousodrome.net/blog/light/?p=995)
- [Unity Manual — GPU Usage Profiler module (GPU ms per pass)](https://docs.unity.cn/2023.1/Documentation/Manual/ProfilerGPU.html)
- [Unreal AnswerHub — GPU profiler example showing TAA at 0.61 ms of a 5.85 ms frame and SSR depending on the TAA pass](https://answers.unrealengine.com/questions/382838/view.html)
- [Unity discussions — HDRP optimisation: "if something takes 1 ms it better be very important"](https://discussions.unity.com/t/how-to-optimize-graphics-performance-with-hdrp/318741)
- [Real-Time Rendering blog — The evils of FPS (measure techniques in ms)](https://www.realtimerendering.com/blog/the-evils-of-fps/)
- [faceofit — FXAA vs TAA vs DLAA cost comparison](https://www.faceofit.com/compare-fxaa-taa-dlaa-and-gpu-performance/)
- [Notebookcheck — AMD demos FSR on a GTX 1060 (Godfall, +41 % fps in Quality mode)](https://www.notebookcheck.net/AMD-demoes-FidelityFX-Super-Resolution-slated-to-work-on-all-GPUs-including-Navi-10-Polaris-Vega-and-even-NVIDIA-Pascal.541943.0.html)
- [PCGamesN — FSR 3 running on a GTX 1060 (Immortals of Aveum)](https://www.pcgamesn.com/amd/fsr-3-nvidia-geforce-gtx-1060/)
