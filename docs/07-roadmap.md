# 07 — Roadmap

| Milestone | Deliverable | Done when |
|---|---|---|
| **M0 — Research (this repo state)** | Docs 01–08, screenshot protocol, licence | Team has read docs; real screenshots + at least one PIX/Nsight per-pass capture on a 1060 and a 3050 added to `screenshots/` to replace the *(unverified)* cost numbers in doc 02 |
| **M1 — Layer skeleton + FSR** | Implicit Vulkan layer (C++17, CMake) that loads via manifest, logs every intercept point from doc 05 §3, implements Bucket C detection, and performs swapchain-level FSR 1 → FSR 3.1 upscale on a Vulkan sample app, then on one Bucket A game under Proton | A 1060 runs the sample at 720p-internal → 1080p with the layer and `DOWNSHIFT_DISABLE=1` cleanly turns it off |
| **M2 — SPIR-V substitution passes** | `clamp-loop-trip`, `relax-precision`, `lod-bias`, image-extent clamping, extension hiding; shader cache; `spirv-val` gate | One Bucket B game (chosen from doc 03 candidates after profiling) reaches 1080p60 on a 1060 with FLIP under floor, with a **hand-written** profile JSON |
| **M3 — Agent** | Capture → profile → classify → plan → measure loop from doc 06; cost library as data; `profiles/` directory | The same game's profile is produced by the agent, not by hand, within a bounded number of iterations; two more games profiled without code changes |
| **M4 — Windows DirectX path** | DXVK + vkd3d-proton shipped as Windows proxy DLLs under a Downshift launcher; OptiScaler integration for DLSS → FSR | A D3D12 Bucket B game runs through the full stack on Windows on a 1060 |
| **M5 — Community** | Installer, profile sharing, anti-cheat blocklist, docs for contributors | External profiles merged |

## Success metrics (fixed in doc 03 §4)

- 1080p, ≥ 60 fps average, ≥ 45 fps 1 % low on a GTX 1060 6GB.
- FLIP mean ≤ agreed floor (proposed 0.15 — *to be calibrated in M2*) vs RTX 3050 Medium reference.
- Zero game files modified; layer fully disabled by one env var.

## Risks

| Risk | Mitigation |
|---|---|
| Motion vectors not findable → FSR 2/3.1 impossible | FSR 1 spatial fallback; heuristics improved per game by the agent |
| Pass classifier mislabels a gameplay-critical compute pass | Never touch passes whose outputs are read back by the CPU; human review gate |
| Anti-cheat | Blocklist + refuse by default |
| Bucket C games dominate new releases | Honest reporting; the 1060's realistic lifetime target is 2020–2024 titles |
| DXVK/vkd3d-proton on Windows slower than native | Measure; M4 may need native D3D12 hooks for some titles |
