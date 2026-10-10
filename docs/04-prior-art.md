# 04 — Prior art: what already exists and what Downshift reuses

Nothing in Downshift is a new idea in isolation. Every mechanism it needs has been proven by an
existing open-source project. The novelty is combining them under an agent that decides *what* to
substitute per game. Build on these; do not reimplement them.

| Project | What it does | License | How it hooks | Downshift uses it for |
|---|---|---|---|---|
| **DXVK** | Implements D3D9/10/11 on top of Vulkan. Game stays a Windows binary; DXVK supplies replacement `d3d11.dll` / `dxgi.dll`. | zlib | Proxy DLLs (Windows) / Wine (Linux) | The D3D11 → Vulkan bridge. On Linux it means every D3D11 game is already a Vulkan app that our layer can see. On Windows it is the later "DirectX proxy" path. |
| **vkd3d-proton** | Implements the full D3D12 API over Vulkan; Valve-funded; aims at performance + compatibility with modern Vulkan features; already ships **Pascal-specific fallbacks** (compute derivatives, SM 6.7). | LGPL 2.1 | Proxy `d3d12.dll` / Wine | D3D12 → Vulkan bridge. The place where DXR calls can be routed to a fallback. Its Pascal work is direct evidence the approach is viable. |
| **ReShade** | Generic post-processing injector for D3D9–12, OpenGL, Vulkan. Exposes colour **and depth** buffers to effect shaders. On Vulkan it installs itself as a **Vulkan layer** via a registry key. | BSD-3 | Proxy DLL (D3D) / implicit Vulkan layer | The reference implementation of "be a Vulkan layer and find the depth buffer". Its depth-buffer heuristics are directly reusable. |
| **OptiScaler** | Middleware that intercepts a game's DLSS/XeSS/FSR calls and redirects them to the upscaler of your choice; can add FSR frame generation to D3D12 games (OptiFG). | MIT | Proxy DLLs (`nvngx.dll`, `dxgi.dll`, …) | The proof that upscalers can be **swapped at the API boundary**. Downshift's "DLSS → FSR on Pascal" step is literally OptiScaler's job; integrate rather than rewrite. Caveat: needs the game to already ship *some* upscaler. |
| **Lossless Scaling** | Window-level overlay: FSR 1 upscale + frame generation for any borderless-windowed game. | **Closed source** (paid) | Screen capture + overlay | Reference for the last-resort "no hooks possible" path. Not reusable; cite only. |
| **Special K** | Windows injection framework: frame pacing, texture mods, HDR, API hooks for D3D9–12. | GPL-3 | Proxy DLLs | Reference for robust Windows hooking and anti-cheat avoidance patterns *(not confirmed by this research — verify its repo)*. |
| **RTX Remix** | NVIDIA's runtime that intercepts fixed-function D3D9 games and **re-renders them with path tracing** — the exact inverse of Downshift (old → new). | MIT (runtime) | Proxy `d3d9.dll` | Proof that a runtime layer can **replace an entire lighting model** behind the game's back. If "cheap → expensive" works, "expensive → cheap" works. |
| **AMD FidelityFX SDK (FSR 1 / 2 / 3.1)** | Spatial (1) and temporal (2, 3.1) upscalers + frame generation. Shader-only, no tensor cores, runs on Pascal. Also available via Microsoft DirectSR. | MIT | Library the game (or a layer) links | **The upscaler.** FSR 3.1 Quality/Balanced on 720p–810p internal is the single biggest win on a 1060. |
| **SPIRV-Tools / SPIRV-Cross / spirv-reflect** | Khronos tools: validate, optimise, transform, reflect, and cross-compile SPIR-V. | Apache-2 | Library | The shader rewrite engine. Downshift's "drop RT calls / clamp loop counts / lower precision" passes are SPIRV-Tools passes. |
| **GFXReconstruct** | Capture + replay of Vulkan and D3D12 API streams to `.gfxr` files; frame-trimmed captures via `GFXRECON_CAPTURE_FRAMES`; built for CI automation. Does **not** record GPU timestamps. | MIT | Implicit Vulkan layer | The **profiling** front end for the agent: capture one frame, replay it with per-pass timing queries inserted, feed costs to the planner. |
| **RenderDoc** | Full frame debugger with Python API; per-draw timing. | MIT | Implicit layer / injection | Human-in-the-loop inspection; possible automation of per-pass timing where GFXReconstruct can't. |
| **Khronos Vulkan-Loader + layer manifest** | The loader discovers implicit layers via JSON manifests in `implicit_layer.d` / registry; each implicit layer must declare a `disable_environment` variable. | Apache-2 | — | How Downshift gets loaded into every Vulkan process without touching game files. |

## What is genuinely new in Downshift

1. **Generalised technique substitution** — ReShade adds effects, OptiScaler swaps one effect
   (the upscaler); nobody yet *removes or downgrades arbitrary passes* based on cost.
2. **An agent in the loop** — profile → classify → substitute → measure → iterate, producing a
   per-game profile JSON. The existing tools are configured by hand, per game, by enthusiasts.
3. **An honest capability oracle** — detect Bucket C (hard RT / mesh-shader requirement) up front.

## Anti-cheat note (applies to every project above)

OptiScaler's own guidance: do not use injected layers in online games — anti-cheat may ban. Lossless
Scaling is the only tool safe for online play because it does not touch the process. Downshift
inherits the same constraint and should refuse to load into processes with known kernel anti-cheat
drivers (EAC, BattlEye, Vanguard, Ricochet) unless the user overrides.

## Sources

- [GamingOnLinux — vkd3d-proton becomes the official D3D12→Vulkan layer for Proton](https://www.gamingonlinux.com/2020/07/vkd3d-proton-is-the-new-official-direct3d-12-to-vulkan-layer-for-proton)
- [macmyths — DXVK explained (replacement D3D DLLs over Vulkan)](https://macmyths.com/dxvk-2-0-explained-the-vulkan-layer-for-direct3d-9-10-and-11/)
- [GamingOnLinux — vkd3d-proton 2.12 Pascal fallbacks](https://gamingonlinux.com/2024/03/vkd3d-proton-version-212-adds-nvidia-reflex-support)
- [Guru3D forum — ReShade: Vulkan layer install via registry key, depth access](https://forums.guru3d.com/goto/post?id=5779367)
- [Guru3D — ReShade download / feature list](https://www.guru3d.com/files-details/reshade-download.html)
- [hwcooling — OptiScaler universal upscaler wrapper](https://hwcooling.net/en/optiscaler-unlock-fsr4-xess-or-framegen-in-unsupported-games)
- [tecnobits — How OptiScaler works](https://tecnobits.com/en/How-does-Optiscaler-work-and-what-is-it-for/)
- [Wccftech — Lossless Scaling universal frame generation](https://wccftech.com/lossless-scaling-adds-universal-frame-generation-feature/amp/)
- [HotHardware — FSR as AMD's open-source answer to DLSS (MIT, GPUOpen)](https://amp.hothardware.com/news/exploring-fidelityfx-super-resolution-amds-open-source-answer-to-dlss)
- [ElevenForum — DirectSR preview supports FSR 3.1](https://www.elevenforum.com/t/directsr-preview-now-supporting-amd-fidelityfx-super-resolution-fsr-3-1-upscaler.29874)
- [LunarG — Mastering GFXReconstruct Part 1](https://www.lunarg.com/mastering-gfxreconstuct-part-1/)
- [LunarG — GFXReconstruct for capture/replay with Vulkan and DX12 (PDF)](https://lunarg.com/wp-content/uploads/2023/08/Using-GFXReconstruct-for-Capture-Replay-with-Vulkan-and-DX12-08-07-2023.pdf)
- [LunarG — Layers overview and configuration](https://vulkan.lunarg.com/doc/view/1.3.250.1/windows/layer_configuration.html)
- [LunarG — Layer interface to the loader](https://vulkan.lunarg.com/doc/view/latest/mac/loader_and_layer_interface.html)
- [LunarG — SPIR-V shader compiler technologies](https://lunarg.com/shader-compiler-technologies/)
