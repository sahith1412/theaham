# 08 — Glossary

| Term | Meaning |
|---|---|
| **AO / SSAO / HBAO / GTAO** | Ambient occlusion — darkening in creases and contacts. SS = screen-space (cheap, approximate). |
| **BVH** | Bounding-volume hierarchy — the tree RT cores walk to find ray hits. |
| **Bucket A / B / C** | Downshift's game classes: already runs / runs with substitutions / impossible (doc 03). |
| **CSM** | Cascaded shadow maps — several shadow maps at increasing distance for a directional light. |
| **CUDA core** | NVIDIA's name for one FP32 ALU lane inside an SM. |
| **D3D11 / D3D12** | Microsoft Direct3D graphics APIs. |
| **DLSS** | NVIDIA Deep Learning Super Sampling — AI upscaler needing Tensor cores (RTX only). |
| **DXIL / DXBC** | Shader bytecode formats for D3D12 / D3D11. |
| **DXR** | DirectX Raytracing. 1.0 = RT pipelines; 1.1 = inline `RayQuery`. |
| **DXVK** | D3D9/10/11 → Vulkan translation layer. |
| **Feature level 12_1 / 12_2** | Direct3D capability tiers. 12_2 = DXR 1.1 + mesh shaders + VRS 2 + sampler feedback (Turing/Ampere/RDNA2+). Pascal = 12_1. |
| **FLIP** | NVIDIA's perceptual image-difference metric. |
| **Frame generation** | Synthesising intermediate frames (DLSS 3, FSR 3). |
| **FSR 1 / 2 / 3.1** | AMD FidelityFX Super Resolution — spatial (1) / temporal (2, 3.1) upscalers; shader-only, MIT, run on Pascal. |
| **G-buffer** | The set of render targets (albedo, normal, roughness, depth…) a deferred renderer writes before lighting. |
| **GFXReconstruct** | LunarG capture/replay tool for Vulkan and D3D12. |
| **GI** | Global illumination — indirect/bounce light. |
| **GPC / TPC / SM** | NVIDIA GPU hierarchy: cluster → texture-processing cluster → streaming multiprocessor. |
| **Implicit layer** | A Vulkan layer the loader enables automatically for every process (unless its disable env var is set). |
| **Lumen** | UE5's GI/reflection system; has hardware-RT and software (screen-space + distance-field) modes. |
| **Mesh shader** | Modern geometry stage replacing vertex/geometry shaders; 12_2 feature, no Pascal support. |
| **Nanite** | UE5 virtualised geometry; hardware path uses mesh shaders, fallback uses traditional meshes. |
| **OptiScaler** | Open-source shim that redirects a game's DLSS/XeSS/FSR calls to a chosen upscaler. |
| **Pascal / Turing / Ampere** | NVIDIA GPU generations: GTX 10 (2016) / RTX 20 (2018) / RTX 30 (2020). |
| **PBR** | Physically-based rendering — the standard material/lighting model since ~2014. |
| **PCF / PCSS** | Shadow-map filtering techniques (fixed softness / distance-dependent softness). |
| **Profile JSON** | Downshift's per-game substitution data file (doc 05 §6). |
| **ReShade** | Open-source post-processing injector; also a Vulkan layer. |
| **ROP** | Render output unit — depth test, blend, final pixel write. |
| **RT core / Tensor core** | Dedicated ray-traversal / matrix-multiply hardware in RTX GPUs. |
| **SPIR-V** | Vulkan's shader bytecode. **SPIRV-Tools** = Khronos library to validate/optimise/rewrite it. |
| **SSR** | Screen-space reflections — reflections computed from what is already on screen. |
| **SSIM** | Structural similarity — classic image-similarity metric. |
| **TAA** | Temporal anti-aliasing — accumulates samples across frames using motion vectors. |
| **vkd3d-proton** | D3D12 → Vulkan translation layer (Valve-funded). |
| **Volumetrics / froxels** | Fog and light-shaft rendering on a 3D frustum-aligned voxel grid. |
| **VRAM** | GPU memory. 1060 = 6 GB, 3050 = 8 GB. |
| **VRS** | Variable-rate shading — shading fewer pixels where detail is low; 12_2 feature. |
| **Warp** | 32 GPU threads executing in lockstep on an SM. |
| **XeSS** | Intel's upscaler; its DP4a fallback path is unavailable on Pascal. |
