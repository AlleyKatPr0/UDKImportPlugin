# UDKImportPlugin - Plans and Roadmap

This file describes the short-term plans and concrete tasks to extend the UDKImportPlugin with a robust live exporter and conversion pipeline. It is written for inclusion in the repository under the udkliveexporter-scaffold branch.

Goals
- Provide a safe in-editor "Export Live Scene" feature that captures the running UWorld and serializes actors, transforms, and referenced assets.
- Support export target formats: OBJ (fallback), glTF/GLB (preferred interchange), and FBX (for skeletal/animation compatibility).
- Keep editor-thread work minimal and perform heavy conversion offline or in background tasks.

Deliverables (short-term)
1) UDKLiveExporter scaffold (already added): enumerates actors, writes manifest.json, exports per-mesh blobs.
2) UI integration: "Export Live Scene" button and format selector (OBJ/GLTF/FBX) in SUDKImportScreen.
3) Format stubs: working OBJ writer; minimal glTF stub (bin+gltf); FBX conversion shim calling external converter.
4) PLANS.md & design spec (this file) documenting mapping of UDK asset types to export targets and the data to capture.

Implementation Roadmap (concrete tasks)
- Phase 1 (MVP)
  - Finish UDKLiveExporter implementation: ensure WriteOBJ is robust for indexed meshes, include normals & first UV set.
  - Wire SUDKImportScreen to call exporter with selected format and user-specified output folder.
  - Add basic logging and saved manifest verification tests.

- Phase 2 (interchange quality)
  - Implement full glTF writer: bufferViews, accessors, proper mesh attributes, primitive materials, and embed or reference images; support GLB.
  - Export textures to PNG/ktx2 and include material mapping table (UDK→PBR).
  - Add per-asset hashing and incremental export to skip unchanged assets.

- Phase 3 (animation & fidelity)
  - Support SkeletalMesh and Animation export using FBX (via FBX SDK) or glTF skinning/animation.
  - Extract collision shapes and sockets.
  - Add background worker threads and progress/cancel UI.

- Phase 4 (polish)
  - Provide automatic OBJ→FBX conversion fallback using Blender CLI or FBX SDK if available.
  - Add unit and integration tests: compare exported geometry against UDK batchexport results and manual FBX exports.
  - Improve material remapping rules and per-game tuning presets.

Short task list for a first PR (MVP)
- [ ] Add UDKLiveExporter.cpp implementation (OBJ writer + manifest writer + FBX shim)
- [ ] Update SUDKImportScreen.{h,cpp} to include format selector and Export Live Scene button (already scaffolded)
- [ ] Add PLANS.md (this file)
- [ ] CI note: run basic static build in project to ensure no compile regressions

Notes & constraints
- OBJ is the simplest interoperable format and works well for static geometry; it does not cover skinning or complex material graphs.
- glTF/GLB is the recommended long-term target for scene interchange; it requires careful implementation of bufferViews/accessors and material mapping.
- FBX is needed for skeletal meshes/animations to interoperate with the UE pipeline; native FBX writing usually requires the Autodesk FBX SDK.
- Keep heavy conversion out of the editor main thread; prefer external converter processes or background tasks.

Contact & next steps
- I will open a focused PR on udkliveexporter-scaffold with UDKLiveExporter.cpp, SUDKImportScreen changes, and PLANS.md. After that we can iterate on glTF and FBX integration in separate PRs.

---