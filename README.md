# Downshift — run RTX-3050-class games on a GTX 1060

**A Kala Laya Studio open-source research project.**

Downshift is a plan for a **general-purpose, game-agnostic rendering interposition layer** that
sits between a game and the GPU driver, intercepts the game's draw calls and shaders at runtime,
and swaps the expensive rendering techniques for cheaper ones that look *good enough* — so that a
game whose published minimum is an RTX 3050 becomes playable on a GTX 1060. An AI agent profiles
each game and decides the swaps automatically; humans never write per-game code.

This repository currently contains **research and architecture only** (milestone M0). No runtime
code ships yet. Read the docs in order; each one ends with its sources.

## What this is — and what it is not

| Is | Is not |
|---|---|
| A runtime layer (Vulkan first, DirectX proxies later) that rewrites *how* a frame is rendered without touching the game's files | A rebuild of each game's engine. The engine is compiled into the game binary; it cannot be generically replaced. |
| Automatic technique substitution: ray-traced effects → screen-space, 4K shadow cascades → 1K, full-res volumetrics → half-res, native → FSR upscale | A magic FPS button. Games that **hard-require** RT cores or mesh shaders (feature level 12_2) cannot be fixed by any software layer. |
| Driven by an AI agent that profiles, classifies, swaps, measures, and iterates — producing a per-game *profile JSON*, not per-game code | Cheating or an anti-cheat bypass. Online games with kernel anti-cheat are out of scope. |
| Built on top of DXVK, vkd3d-proton, FSR and SPIRV-Tools, not in competition with them | A closed, per-vendor trick. Everything here is MIT. |

## Why a GTX 1060 → RTX 3050 gap is bridgeable (mostly)

The RTX 3050 is roughly 1.4–2× faster than a GTX 1060 in raw shader throughput, but most of
the *playability* gap in modern games comes from a handful of techniques that are optional at the
engine level and can be substituted at the API level: ray-traced reflections/GI/shadows, very high
shadow-map resolutions, full-resolution volumetrics and SSR, and native-resolution rendering with
TAA instead of an upscaler. Removing or downgrading those recovers more frame time than the raw
hardware gap costs. See [docs/03-gtx1060-vs-rtx3050-gap.md](docs/03-gtx1060-vs-rtx3050-gap.md).

## Documents

| # | Doc | What it covers |
|---|---|---|
| 01 | [How a GPU renders a frame](docs/01-how-a-gpu-renders-a-frame.md) | CPU → driver → command buffer → SMs/warps → raster → ROP → present. Pascal vs Ampere. What RT and Tensor cores actually do. Curated reference videos. |
| 02 | [Old vs modern engines](docs/02-old-vs-modern-engines.md) | Engine anatomy by era, cost of each technique, and the cheap substitute for each. Screenshot annotation template. |
| 03 | [GTX 1060 vs RTX 3050 gap](docs/03-gtx1060-vs-rtx3050-gap.md) | Spec + feature-level diff. Three buckets of games: already runs / runs with swaps / impossible. |
| 04 | [Prior art](docs/04-prior-art.md) | DXVK, vkd3d-proton, ReShade, OptiScaler, Lossless Scaling, Special K, RTX Remix, FSR, SPIRV-Tools, GFXReconstruct — what we reuse. |
| 05 | [Architecture](docs/05-architecture.md) | The Vulkan implicit layer design, intercept points, SPIR-V rewrite passes, upscaler injection, later DirectX path. |
| 06 | [AI agent design](docs/06-ai-agent-design.md) | Profile → classify → swap → measure → iterate loop. Per-game profile JSON schema. |
| 07 | [Roadmap](docs/07-roadmap.md) | M0 research → M1 layer skeleton + FSR → M2 SPIR-V swaps → M3 agent → M4 DirectX proxies. |
| 08 | [Glossary](docs/08-glossary.md) | Every acronym used above. |
| — | [screenshots/README.md](screenshots/README.md) | What to capture and how to name it, for the real-game comparison set. |

## Contributing

Open an issue or PR. Good first contributions during M0: corrections to any number marked
*(unverified — confirm)*, real GPU-profiler captures (PIX / Nsight / RenderDoc) of per-pass frame
times on a GTX 1060 and an RTX 3050, and screenshots following
[screenshots/README.md](screenshots/README.md).

## License

MIT — see [LICENSE](LICENSE). Chosen to match the FSR / DXVK / vkd3d-proton / GFXReconstruct ecosystem
this project builds on.
