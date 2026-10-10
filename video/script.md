# Downshift explainer — narration script

Each scene lists its duration and caption lines with the second (within the scene) at which each
line appears. `scenes.html` embeds this same data as JSON; keep both in sync.

Total runtime ≈ 11 min 20 s.

---

## Scene 0 — Title (0:00, 14 s)

- 0.5 — Downshift. A Kala Laya Studio open-source project.
- 5.0 — The question: can a game built for an RTX 3050 run on a GTX 1060?
- 9.5 — This video explains everything the research found — and what we are going to build.

## Scene 1 — The goal (0:14, 40 s)

- 0.5 — The RTX 3050 is a 2022 card. The GTX 1060 is from 2016. Millions of people still own one.
- 7.0 — Our target: any game that runs on the 3050 should run on the 1060 — at 1080p, 60 frames per second.
- 14.0 — Not by lowering the whole game to a blurry mess, and not by rewriting the game.
- 20.0 — By swapping the handful of expensive rendering techniques for cheaper ones the player barely notices.
- 27.0 — And by letting an AI agent decide those swaps for each game automatically — no per-game code, ever.
- 34.0 — Every game ends up in one of three buckets. We will come back to them.

## Scene 2 — The honest limit (0:54, 48 s)

- 0.5 — First, the honest part. The original idea was "rebuild the graphics engine of every game".
- 7.0 — That is impossible in general. The engine is compiled into the game binary. There is nothing to swap out.
- 14.0 — But there is a place where we can stand between the game and the GPU: the graphics API boundary.
- 21.0 — Every shader and every draw call passes through it, as data, at runtime.
- 27.0 — This is not a new trick. DXVK translates DirectX to Vulkan this way. ReShade injects effects this way.
- 34.0 — OptiScaler swaps one upscaler for another this way. NVIDIA's own RTX Remix re-lights 2004 games this way.
- 41.0 — Downshift does the same thing in the other direction: it makes rendering cheaper, not prettier.

## Scene 3 — How a GPU renders a frame (1:42, 70 s)

- 0.5 — To know what to make cheaper, you have to know where a frame spends its time.
- 6.0 — The CPU runs the game logic and decides what to draw.
- 11.0 — It talks to a graphics API — Direct3D or Vulkan — and those calls are recorded into command buffers.
- 18.0 — The driver, or a translation layer like DXVK, turns them into something the GPU understands.
- 25.0 — Inside the GPU, geometry is transformed first: vertex, tessellation, mesh shaders.
- 32.0 — The rasteriser turns triangles into pixels — fragments.
- 37.0 — Then the pixel shaders run. For every pixel, every frame. This is where most of the time goes.
- 45.0 — The ROPs do the depth test and blending and write the result to memory.
- 51.0 — Then post-processing: ambient occlusion, reflections, bloom, anti-aliasing, upscaling, tone mapping.
- 59.0 — And finally the frame is presented. The whole loop runs sixty or more times every second.
- 65.0 — Pixel shading and post-processing dominate. They are also the stages a layer can rewrite.

## Scene 4 — Inside an NVIDIA GPU (2:52, 64 s)

- 0.5 — Zoom inside the chip. NVIDIA GPUs are a hierarchy.
- 5.0 — Graphics Processing Clusters contain Texture Processing Clusters.
- 10.0 — Each TPC holds a pair of Streaming Multiprocessors — the SMs. They do the actual work.
- 17.0 — An SM runs threads in groups of 32 called warps. A pixel shader runs on a warp of 32 pixels in lockstep.
- 25.0 — The CUDA cores are the arithmetic units inside each SM. The 1060 has 1280 of them. The 3050 has 2560.
- 33.0 — On Turing and Ampere, each SM also has an RT core — a hardware unit that walks a bounding-volume tree to find what a ray hits.
- 42.0 — And Tensor cores — matrix-multiply units that power DLSS upscaling.
- 48.0 — Pascal has neither. The GTX 1060 can do ray tracing only in software on the SMs — five to ten times slower.
- 56.0 — This is the real gap. Not clock speed. Not core count. Missing hardware units.

## Scene 5 — Pascal vs Ampere (3:56, 52 s)

- 0.5 — Put them side by side.
- 4.0 — Raw shader throughput: the 3050 is about 1.4 times faster in composite benchmarks. That is a small gap.
- 12.0 — Memory bandwidth: 192 versus 224 gigabytes per second. Also small.
- 18.0 — Then the feature table. DirectX feature level 12_1 versus 12_2.
- 24.0 — 12_2 bundles ray tracing 1.1, mesh shaders, variable-rate shading and sampler feedback. Pascal has none of them.
- 33.0 — DLSS: no. FSR 1, 2 and 3.1: yes — because FSR is ordinary shader code, open source under MIT.
- 41.0 — So there are two gaps. A raw gap of 1.4× we can close by rendering cheaper. And a feature gap we must route around.

## Scene 6 — Engines by era (4:48, 66 s)

- 0.5 — Why are modern games so expensive? Look at how engines grew.
- 6.0 — Early 2000s: per-vertex lighting, baked lightmaps, one small shadow map. Half-Life 2, Doom 3.
- 14.0 — Late 2000s: per-pixel lighting, cascaded shadow maps, screen-space ambient occlusion. Crysis invented SSAO.
- 23.0 — 2014 to 2019: physically-based materials, deferred lighting, screen-space reflections, temporal anti-aliasing.
- 32.0 — This is the GTX 1060's home era. It was built for exactly this stack, and it runs it well.
- 39.0 — 2020 onward: the same PBR core — plus ray-traced reflections, shadows and global illumination, plus AI upscaling, plus mesh-shader geometry.
- 49.0 — The key observation: every one of those new layers has a 2017-era fallback that still exists inside most engines.
- 58.0 — Consoles and mid-range PCs needed those fallbacks. Downshift's job is to force them.

## Scene 7 — Where the milliseconds go (5:54, 72 s)

- 0.5 — Here is a modern frame on an RTX 3050 at 1080p. About 16 milliseconds — 60 frames per second.
- 8.0 — The same frame on a GTX 1060. Ray tracing runs in software. Over 30 milliseconds. Unplayable.
- 16.0 — Now swap techniques one at a time.
- 20.0 — Ray-traced reflections become screen-space reflections. Twelve milliseconds saved.
- 27.0 — Ray-traced global illumination becomes probe or software GI.
- 33.0 — Ray-traced shadows become 2K cascaded shadow maps.
- 39.0 — Volumetric fog drops to quarter resolution with temporal reprojection.
- 45.0 — Then the biggest single win: render at 720p and let FSR 3.1 upscale to 1080p. About thirty percent off everything.
- 55.0 — The 1060 lands back near 16 milliseconds. The art, the gameplay, the game — unchanged.
- 63.0 — These numbers are estimates until the team replaces them with real profiler captures. The ratios are what matter.

## Scene 8 — Three buckets (7:06, 60 s)

- 0.5 — Every game lands in one of three buckets, and the agent decides which at launch.
- 7.0 — Bucket A: it already runs. The Low preset uses the old fallbacks. Cyberpunk with ray tracing off. Most Unreal 4 games.
- 16.0 — Downshift only adds value by automating the settings and injecting FSR where the game lacks it.
- 23.0 — Bucket B: the target. The game's default path uses RT or DLSS, but a fallback exists inside the engine and is just not exposed.
- 33.0 — This is where all of our engineering goes.
- 37.0 — Bucket C: impossible. The engine has no non-RT path, or requires mesh shaders with no fallback.
- 45.0 — Indiana Jones and the Great Circle. Doom: The Dark Ages. No layer can make a GPU grow RT cores.
- 52.0 — Downshift must detect Bucket C up front and say so plainly — never crash, never render garbage.

## Scene 9 — The layer (8:06, 84 s)

- 0.5 — Now the architecture.
- 4.0 — The game speaks Direct3D 11, Direct3D 12, or Vulkan.
- 9.0 — DXVK and vkd3d-proton turn the first two into Vulkan. On Linux and Steam Deck they already do this for every game.
- 18.0 — Downshift is an implicit Vulkan layer. The loader inserts it into every Vulkan process — opt-in by an environment variable, no game files touched.
- 28.0 — It intercepts specific calls. On device creation: read the GPU's capabilities and detect Bucket C.
- 36.0 — On extension enumeration: hide ray-tracing extensions so the engine takes its own non-RT path. The cheapest substitution of all.
- 46.0 — On shader creation: the full SPIR-V bytecode is in our hands. Rewrite it. A 64-sample loop becomes 16. A ray query becomes a constant miss.
- 57.0 — On image creation: a 4K shadow map becomes 2K. A full-res volumetric target becomes half-res.
- 65.0 — On present: run FSR from the lower internal resolution up to the display.
- 71.0 — All of this is driven by a profile JSON per game. Data, not code. Shareable by the community.
- 78.0 — Windows DirectX games get the same stack later, by shipping DXVK and vkd3d-proton as proxy DLLs.

## Scene 10 — The agent loop (9:30, 60 s)

- 0.5 — Who writes the profile? The agent.
- 4.0 — Capture one representative frame with GFXReconstruct.
- 9.0 — Replay it through the layer with timestamps around every pass. Now we know the milliseconds per pass.
- 17.0 — Classify each pass from its structure: shadow cascade, SSAO, SSR, volumetric, ray tracing, TAA, UI.
- 25.0 — Plan: the model picks substitutions from the cost library, biggest saving per quality loss first.
- 33.0 — Apply and measure: frame time, plus a perceptual difference score — FLIP — against the reference frame.
- 41.0 — Iterate until the target is met or the library is exhausted. Then a human reviews and the profile is published.
- 50.0 — Rules the agent cannot break: never touch UI passes, never emit a profile without measurements, never call a Bucket C game Bucket B.

## Scene 11 — Roadmap and how to help (10:30, 50 s)

- 0.5 — Where we are: M0, the research package — done and open as a pull request.
- 7.0 — M1: the Vulkan layer skeleton, Bucket C detection, FSR injection on a sample app.
- 14.0 — M2: the SPIR-V substitution passes. One Bucket B game at 1080p60 on a 1060.
- 21.0 — M3: the agent. The same game, profiled automatically.
- 26.0 — M4: Windows DirectX. M5: community profiles and an installer.
- 32.0 — The most valuable thing you can do today: real screenshots and profiler captures on both cards. The protocol is in the repo.
- 41.0 — Everything is MIT. Downshift — Kala Laya Studio.
