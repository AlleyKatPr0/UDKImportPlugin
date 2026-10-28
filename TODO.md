# TODO — UDK Import Plugin

Consolidated list of outstanding work items for the plugin, commandlets, and native FBX module.
Sources: CHANGELOG.md roadmap, NATIVE_FBX_SOLUTION.md future enhancements, X64_IMPLEMENTATION_SUMMARY.md, and code review.

Legend: 🔴 High priority · 🟡 Medium priority · 🔵 Low priority

---

## 🔴 High Priority

### Plugin Core
- [ ] **UI progress dialog with cancellation** — `FUDKImportProgressReporterUI` is declared (`Source/UDKImportPlugin/Public/UDKImportProgressReporter.h:55-70`) but not fully wired into the import flow; implement the editor slow-task dialog and hook cancellation into `T3DLevelParser`.
- [ ] **Requirement resolution coverage** — `T3DLevelParser::ResolveRequirements` only resolves `StaticMesh` and `Texture*` requirement types (`Source/UDKImportPlugin/Private/T3DLevelParser.cpp:206-229`); other referenced asset types (Material, MaterialInstanceConstant, SoundCue, etc.) are silently skipped and need explicit resolution/import branches.
- [ ] **Honor asset filter settings** — `bImportStaticMeshes` / `bImportMaterials` / `bImportTextures` / `bImportLights` / `bImportBrushes` exist in `UUDKImportPluginSettings` but are not enforced during parsing/import.
- [ ] **Honor performance settings** — `bCacheExportedMeshes` and `MaxParallelImports` settings exist but are not consumed by the import pipeline.
- [ ] **Parallel asset processing** — use `MaxParallelImports` to parallelize asset import once settings are honored.

### New Asset Types
- [ ] **SkeletalMesh support** — parser + UDK export path (native FBX module can be extended).
- [ ] **Animation support** — export/import animations for skeletal assets.
- [ ] **Sound import improvements** — SoundCue discovery exists in `DiscoverPackageCommandlet`; add full import path.

---

## 🟡 Medium Priority

### UE5 Features (placeholders already in settings)
- [ ] **Nanite conversion option** — enable `bEnableNanite` setting (`EditCondition=false` currently disabled) and apply Nanite to imported StaticMeshes.
- [ ] **Lumen material conversion** — enable `bConvertToLumenMaterials` setting and implement conversion.

### Import Quality
- [ ] **Material parameter mapping improvements** — better translation of complex UDK material graphs.
- [ ] **Brush CSG order preservation** — investigate whether order can be recovered (currently lost; UDK T3D limitation documented in README).
- [ ] **Automated OBJ→FBX conversion** — implement `bAutoConvertOBJToFBX` using the configured `FBXConverterPath` so the Autodesk FBX Converter step runs unattended.

### Native FBX Module / Commandlets
- [ ] **Material/texture export alongside meshes** in `NativeFBXExportCommandlet`.
- [ ] **Progress callbacks for UI** during native batch export.
- [ ] **Multi-threaded batch processing** in the native FBX module.
- [ ] **FBX format options** — ASCII vs Binary, FBX version selection.
- [ ] **User validation of x64 build** — X64_IMPLEMENTATION_SUMMARY.md marks Win32/x64 testing as "user validation needed"; confirm DLL works on both platforms and VS versions.

---

## 🔵 Low Priority

### Testing & Infrastructure
- [ ] **Unit tests for parsers** — T3DParser, T3DLevelParser, T3DMaterialParser, T3DMaterialInstanceConstantParser.
- [ ] **Automated integration tests** — end-to-end import runs per supported engine version (UE 4.27, 5.0–5.3, 5.4–5.6+); see the Testing Checklist in CHANGELOG.md.
- [ ] **CI build validation** — compile plugin against supported engine versions.

### Extended Migration Scope
- [ ] **Blueprint migration support**.
- [ ] **Level scripting (Kismet) migration**.
- [ ] **Particle system migration** (Cascade → Niagara).

---

## Known Limitations (documented, not currently actionable)

1. **Brush CSG order** is lost during migration (UDK T3D format limitation) — see README.md.
2. **UDK `batchexport` FBX export** produces corrupt files — bypassed by the native FBX module; `BatchExportStaticMeshFBXCommandlet` is deprecated/diagnostic only.
3. **Complex material graphs** may need manual fixes after import.
4. **Light intensity** needs adjustment post-import (configurable via `LightIntensityMultiplier`).

---

## How to contribute

- New asset types: add a parser in `Source/UDKImportPlugin/Private/` and register it in `T3DLevelParser.cpp`.
- Check items off by editing this file in the same PR that implements the change.
- See README.md and SETUP_GUIDE.md for build/setup instructions.
