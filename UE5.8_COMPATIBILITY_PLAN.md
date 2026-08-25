# UDK Import Plugin - Unreal Engine 5.8 Compatibility Plan

**Document Version:** 1.0  
**Target Engine Version:** Unreal Engine 5.8+  
**Current Support:** UE 4.27 - 5.7+  
**Date Created:** 2026-08-25  

---

## Executive Summary

The UDK Import Plugin currently supports Unreal Engine versions 4.27 through 5.7+. This document outlines the assessment and plan to extend official support to Unreal Engine 5.8+, ensuring compatibility with the latest engine release while maintaining backward compatibility with earlier versions.

---

## 1. Current Codebase Assessment

### 1.1 Plugin Metadata & Build Configuration

**File:** `UDKImportPlugin.uplugin`
- **Current Description:** "Automatic importation of Map and related assets from UDK to Unreal Engine 4.27-5.6+."
- **Status:** Outdated (mentions only 5.6+)
- **Action Required:** Update description and metadata to reflect 5.8+ support

**File:** `Source/UDKImportPlugin/UDKImportPlugin.Build.cs`
- **PCH Usage:** ✅ Already uses `PCHUsageMode.UseExplicitOrSharedPCHs` (UE5 compatible)
- **Conditional Modules:** ✅ Includes version guards for UE4 vs UE5 dependencies
- **Status:** Requires verification for UE 5.8 module availability
- **Action Required:** Verify all dependencies exist in UE 5.8

### 1.2 Version Guards & API Compatibility

**File:** `Source/UDKImportPlugin/Private/UDKImportPlugin.cpp`
```cpp
#if ENGINE_MAJOR_VERSION >= 5
    #define STYLE_SET_NAME FAppStyle::GetAppStyleSetName()
    #define GET_BRUSH(name) FAppStyle::GetBrush(name)
#else
    #define STYLE_SET_NAME FEditorStyle::GetStyleSetName()
    #define GET_BRUSH(name) FEditorStyle::GetBrush(name)
#endif
```
- **Status:** ✅ Already version-guarded for UE5
- **Assessment:** FAppStyle remains stable through UE 5.8
- **Action Required:** Test at runtime to confirm

**File:** `Source/UDKImportPlugin/Private/UDKImportPluginPrivatePCH.h`
- **UE5 Style Include:** `#include "Styling/AppStyle.h"`
- **Status:** ✅ Correct modern include path
- **Action Required:** Verify no deprecation warnings in UE 5.8

### 1.3 Slate & UI Framework

**Current Usage:**
- Modern `UToolMenus` API (not deprecated `FExtender`)
- Standard Slate widgets: `SWindow`, `SButton`, `SEditableTextBox`, `SComboBox`, `STextBlock`
- `FSimpleMulticastDelegate::FDelegate` for callbacks

**Status:** ✅ All modern patterns used
**Action Required:** Test UI rendering in UE 5.8 editor

### 1.4 Module Dependencies

**Dependencies in Build.cs:**
- Public: Core, CoreUObject, Engine, InputCore, Slate, SlateCore
- Private: UnrealEd, LevelEditor, AssetTools, EditorSubsystem, Projects, ToolMenus, EditorFramework, PropertyEditor, DesktopPlatform, ContentBrowser, EditorStyle

**Status:** ✅ All standard editor modules
**Action Required:** Confirm all modules available in UE 5.8 (unlikely to have changed)

### 1.5 Parser & Asset Handling Code

**Files:**
- `T3DLevelParser.cpp/h` - UDK T3D map format parsing
- `T3DMaterialParser.cpp/h` - Material parsing
- `T3DMaterialInstanceConstantParser.cpp/h` - Material instance parsing
- `T3DParser.cpp/h` - Base parser

**API Usage:**
- Engine asset creation APIs (`UStaticMesh::StaticConstructor()`, FBX importer)
- Editor-only asset operations
- Standard Unreal Engine Object model

**Status:** ✅ These use stable engine APIs unlikely to change
**Action Required:** Smoke test import workflow in UE 5.8

### 1.6 Settings & Progress Reporting (v2.0)

**Files:**
- `UDKImportPluginSettings.cpp/h` - Plugin configuration
- `UDKImportProgressReporter.cpp/h` - Progress UI

**API Pattern:** Standard `UObject` settings with reflection system

**Status:** ✅ Uses stable core APIs
**Action Required:** Test configuration UI in Project Settings

---

## 2. Known Changes in UE 5.8

> **Note:** Detailed research pending from external sources. Common patterns reviewed here based on historical UE releases.

### 2.1 Likely Stability Areas (No Changes Expected)

1. **Styling System (FAppStyle)**
   - Stable since UE 5.0 introduction
   - No breaking changes anticipated

2. **ToolMenus API**
   - Stable since introduction in UE 4.21
   - No breaking changes anticipated in recent versions

3. **Slate Widget Framework**
   - Core Slate patterns stable
   - New widgets may be added, existing ones unlikely to be removed

4. **Delegate System**
   - Fundamental to engine, stable
   - No anticipated changes

5. **Asset Tools & Editor Subsystems**
   - Stable public APIs
   - No anticipated breaking changes

### 2.2 Areas Requiring Verification

1. **EditorStyle Module Status**
   - Confirm still available/functional in UE 5.8 for UE4 fallback
   - Unlikely to be removed but should verify

2. **Engine Version Macros**
   - Verify `ENGINE_MAJOR_VERSION` and `ENGINE_MINOR_VERSION` still exist
   - Almost certainly will, but confirm in any new version guards

3. **FBX Importer/Exporter APIs**
   - May have improved in UE 5.8
   - Test OBJ/FBX import pathways

4. **Material Expression System**
   - Check if material expression APIs have changed
   - Verify `MaterialExpressionTextureSample`, `MaterialExpressionConstant`, etc.

---

## 3. Upgrade Plan

### Phase 1: Documentation & Assessment (Current Phase)

**Objectives:**
- [ ] Document current codebase architecture
- [ ] Review UE 5.8 release notes for breaking changes
- [ ] Identify all version-specific code sections
- [ ] Create compatibility matrix

**Deliverables:**
- This plan document
- Code audit checklist
- Version-specific code inventory

**Estimated Effort:** 1-2 hours

### Phase 2: Code Updates (Minimal Expected)

**Objectives:**
- [ ] Update `.uplugin` metadata to mention 5.8+ support
- [ ] Add minor engine version guards if needed (unlikely)
- [ ] Update README and documentation strings
- [ ] Add UE 5.8 to CI/testing matrix (if applicable)

**Expected Changes:**
1. **UDKImportPlugin.uplugin**
   - Change description from "4.27-5.6+" to "4.27-5.8+"
   - No other changes needed

2. **UDKImportPlugin.Build.cs**
   - Verify module dependencies (likely no changes)
   - May add UE 5.8 specific optimizations if needed

3. **UDKImportPlugin.cpp**
   - Existing version guards sufficient (ENGINE_MAJOR_VERSION >= 5)
   - No changes anticipated

4. **Documentation Files**
   - README.md: Update engine version range
   - UDKPluginExport/README.md: Update engine support
   - CHANGELOG.md: Add v2.0.1 entry for UE 5.8 support

**Estimated Effort:** 1-2 hours

### Phase 3: Testing & Validation

**Objectives:**
- [ ] Build plugin against UE 5.8
- [ ] Test UI rendering in editor
- [ ] Test import workflows (Map, StaticMesh, Material, MaterialInstanceConstant modes)
- [ ] Verify no console warnings/errors
- [ ] Test across multiple operating systems if possible

**Testing Scope:**
1. **Plugin Loading:** Verify plugin loads without errors
2. **Menu Integration:** Confirm "Help > UDK Import" menu appears
3. **UI Functionality:** Test all import dialog controls
4. **Settings Access:** Test Project Settings > UDK Import Plugin Settings
5. **Import Workflows:** Run sample imports with UDK export data
6. **Console Output:** Verify no deprecation warnings

**Estimated Effort:** 3-4 hours

### Phase 4: Release & Documentation

**Objectives:**
- [ ] Create release notes for v2.0.1 (UE 5.8 support)
- [ ] Tag release in Git
- [ ] Update all references to supported versions
- [ ] Close any related GitHub issues

**Deliverables:**
- Release notes (CHANGELOG.md)
- Git tag (v2.0.1)
- Updated marketplace/repository metadata

**Estimated Effort:** 1 hour

---

## 4. Expected Code Changes Summary

### Minimal Changes Expected

The plugin architecture already uses modern APIs compatible with UE5.8:

```
Changes Required:
├── UDKImportPlugin.uplugin          (description string only)
├── README.md                         (version range updates)
├── UDKPluginExport/README.md        (version range updates)
└── CHANGELOG.md                      (new v2.0.1 entry)

Code Changes:
└── None anticipated (all existing version guards sufficient)

Testing:
└── Comprehensive validation across platforms
```

### Backward Compatibility

All changes maintain backward compatibility:
- UE 4.27 support: ✅ Unaffected
- UE 5.0-5.7 support: ✅ Unaffected
- UE 5.8+ support: ✅ Newly enabled

---

## 5. Risk Assessment

### Low-Risk Areas ✅
- Styling system (FAppStyle) - stable since UE 5.0
- ToolMenus API - stable since introduction
- Slate widgets - core unchanged
- Asset tools - established APIs
- Delegate system - fundamental

### Medium-Risk Areas ⚠️
- Material Expression APIs - verify compatibility
- FBX import system - may have improvements
- Editor subsystem APIs - verify existing subsystems still work

### Mitigation Strategies
- Run full test suite on UE 5.8 build
- Test all import modes (Map, StaticMesh, Material, MIC)
- Verify on Windows, macOS, Linux if possible
- Check plugin console for warnings/deprecations

---

## 6. Checklist for UE 5.8 Support

### Pre-Release
- [ ] Review UE 5.8 official release notes
- [ ] Build plugin against UE 5.8 SDK
- [ ] Fix any compilation warnings/errors
- [ ] Update `.uplugin` descriptor
- [ ] Update documentation (README, guides, etc.)

### Testing
- [ ] Plugin loads without errors
- [ ] Menu integration works
- [ ] UI renders correctly
- [ ] Settings page accessible
- [ ] Map import functionality works
- [ ] StaticMesh import functionality works
- [ ] Material import functionality works
- [ ] MaterialInstanceConstant import functionality works
- [ ] Progress reporting displays correctly
- [ ] No console warnings or errors

### Cross-Platform (if applicable)
- [ ] Windows x64 testing
- [ ] macOS testing (if available)
- [ ] Linux testing (if available)

### Documentation
- [ ] README updated with UE 5.8
- [ ] CHANGELOG updated with v2.0.1 entry
- [ ] Copilot instructions updated (if needed)
- [ ] Setup guide verified (if needed)

### Release
- [ ] All tests passing
- [ ] Code review completed
- [ ] Changes committed and pushed
- [ ] Release tag created (v2.0.1)
- [ ] Release notes published
- [ ] Marketplace/GitHub updated

---

## 7. Timeline Estimate

| Phase | Task | Duration | Total |
|-------|------|----------|-------|
| 1 | Documentation & Assessment | 1-2 hrs | 1-2 hrs |
| 2 | Code Updates | 1-2 hrs | 2-4 hrs |
| 3 | Testing & Validation | 3-4 hrs | 5-8 hrs |
| 4 | Release & Docs | 1 hr | 6-9 hrs |
| | **Total** | | **6-9 hrs** |

**Parallel Work Possible:** Phases can be partially parallelized during testing.

---

## 8. Implementation Notes

### Build Environment
- Ensure you have UE 5.8 SDK installed
- Unreal Build Tool (UBT) must be current
- Visual Studio 2019+ or equivalent compiler

### Testing Environment
- Fresh UE 5.8 project for testing
- Test with sample UDK export data
- Monitor editor console for warnings

### Documentation Workflow
1. Update version strings in all files
2. Add entry to CHANGELOG.md for v2.0.1
3. Update README.md engine compatibility
4. Update UDKPluginExport/README.md if needed
5. Verify all links and references

---

## 9. Success Criteria

✅ **Success Indicators:**
1. Plugin compiles without errors in UE 5.8
2. Plugin loads without console warnings
3. All UI elements render correctly
4. All import workflows execute successfully
5. No deprecation warnings from engine APIs
6. Documentation updated and accurate
7. Version checks confirm 5.8+ support

---

## Appendix A: Files Requiring Review

### Critical Path Files
```
Source/UDKImportPlugin/
├── Private/
│   ├── UDKImportPlugin.cpp          [Version guards present, test needed]
│   ├── UDKImportPluginPrivatePCH.h  [Modern includes, verify]
│   ├── SUDKImportScreen.cpp/h       [UI code, test needed]
│   ├── T3DLevelParser.cpp/h         [Asset creation, test needed]
│   ├── T3DMaterialParser.cpp/h      [Material parsing, test needed]
│   ├── T3DMaterialInstanceConstantParser.cpp/h [MIC parsing, test needed]
│   ├── T3DParser.cpp/h              [Base parser, test needed]
│   ├── UDKImportPluginSettings.cpp/h [Settings UI, test needed]
│   └── UDKImportProgressReporter.cpp/h [Progress UI, test needed]
├── Public/
│   ├── IUDKImportPlugin.h           [Interface, verify]
│   └── UDKImportPluginSettings.h    [Settings, verify]
└── UDKImportPlugin.Build.cs         [Build config, verify modules]

Root/
├── UDKImportPlugin.uplugin          [Descriptor, update version]
├── README.md                         [Update version range]
├── CHANGELOG.md                      [Add v2.0.1 entry]
└── UDKPluginExport/
    └── README.md                     [Update version range]
```

### Low-Priority Files (Reference Only)
- LICENCE
- .gitignore
- Resources/

---

## Appendix B: Version-Specific Code Inventory

### Version Guards Currently Used
```cpp
// UDKImportPlugin.cpp
#if ENGINE_MAJOR_VERSION >= 5
    // UE5 code
#else
    // UE4 code
#endif

// UDKImportPluginPrivatePCH.h
#if ENGINE_MAJOR_VERSION >= 5
    #include "Styling/AppStyle.h"
#else
    #include "EditorStyleSet.h"
#endif
```

### Conditional Module Dependencies (Build.cs)
```csharp
if (Target.Version.MajorVersion == 5)
{
    // UE5-specific modules
}
else
{
    // UE4-specific modules
}
```

**Assessment:** These patterns are sufficient for UE 5.8. No additional guards needed unless UE 6.0 support is planned.

---

## Appendix C: References & Resources

### Official Unreal Engine Documentation
- [UE 5.8 Release Notes](https://docs.unrealengine.com/)
- [Plugin Development Guide](https://docs.unrealengine.com/5.8/en-US/plugins-in-unreal-engine/)
- [Upgrading to Unreal Engine 5](https://docs.unrealengine.com/)

### Related Documentation
- [ToolMenus System](https://docs.unrealengine.com/)
- [Styling and Appearance](https://docs.unrealengine.com/)
- [Editor Extensions](https://docs.unrealengine.com/)

---

**Document Status:** Ready for Implementation  
**Next Steps:** 
1. Review and approve this plan
2. Proceed with Phase 1 detailed assessment
3. Validate against official UE 5.8 release notes
4. Execute Phase 2-4 as outlined
