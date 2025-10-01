# UDK Commandlets Documentation

This folder contains enhanced UDK commandlets for improved asset export and validation when migrating to Unreal Engine 4.27-5.6.

## Installation

1. Copy this entire `UDKPluginExport` folder to `YourUDKPath/Development/Src/`
2. Edit `YourUDKPath/UDKGame/Config/DefaultEngineUDK.ini`
3. Under `[UnrealEd.EditorEngine]`, add: `ModEditPackages=UDKPluginExport`
4. Build the commandlets:
   ```
   cd YourUDKPath/Binaries/Win32
   UDK.exe make
   ```

## Commandlets

### 1. ExportStaticMeshMaterialsCommandlet (Enhanced)

**Purpose**: Export detailed StaticMesh information including materials, LODs, and collision data.

**Usage**:
```
UDK.exe ExportStaticMeshMaterialsCommandlet Package.MeshName [Package.MeshName2 ...]
```

**Example**:
```
UDK.exe ExportStaticMeshMaterialsCommandlet MyPackage.MyMesh MyPackage.AnotherMesh
```

**Output Format**:
```
==== BEGIN STATICMESH EXPORT ====
Processing: MyPackage.MyMesh
MESH_START: MyPackage.MyMesh
  LOD_COUNT: 3
  MATERIAL_COUNT: 2
  MATERIAL[0]: Material'MyPackage.MyMaterial'
  MATERIAL[1]: Material'MyPackage.MyMaterial2'
  LOD[0].VERTICES: 1234
  LOD[0].TRIANGLES: 456
  UV_CHANNELS: 2
  COLLISION.BOX_ELEMS: 1
MESH_END: MyPackage.MyMesh
==== END STATICMESH EXPORT ====
```

**Improvements over original**:
- LOD information (vertex/triangle counts per LOD)
- UV channel count
- Collision primitive counts
- Better error handling
- Structured output for easier parsing

---

### 2. ValidateExportReadinessCommandlet (New)

**Purpose**: Validate assets before export to catch issues early and ensure successful migration.

**Usage**:
```
UDK.exe ValidateExportReadinessCommandlet Package.AssetName [Package.AssetName2 ...]
```

**Example**:
```
UDK.exe ValidateExportReadinessCommandlet MyPackage.MyMesh MyPackage.MyMaterial
```

**What it checks**:
- **StaticMeshes**: LOD data, vertex counts, material slots, collision, UV channels
- **Materials**: Expression graphs, texture references
- **Material Instances**: Parent material references
- **Textures**: Valid dimensions, data integrity

**Output**:
```
==== BEGIN EXPORT VALIDATION ====
Processing: MyPackage.MyMesh
  Validating StaticMesh: MyPackage.MyMesh
    LODs: 3
    LOD 0 Vertices: 1234
    LOD 0 Triangles: 456
    UV Channels: 2
    Material Slots: 2
      [0] MyPackage.MyMaterial
      [1] MyPackage.MyMaterial2
    Collision: YES

==== VALIDATION SUMMARY ====
Total Assets: 1
Valid: 1
Invalid: 0
Errors: 0
Warnings: 0

RESULT: VALIDATION PASSED
Assets are ready for export
```

**Return codes**:
- `0`: Validation passed (with or without warnings)
- `1`: Validation failed (errors found)

---

### 3. DiscoverPackageCommandlet (New)

**Purpose**: Discover and catalog all assets in a UDK package for migration planning.

**Usage**:
```
UDK.exe DiscoverPackageCommandlet PackageName [PackageName2 ...]
```

**Example**:
```
UDK.exe DiscoverPackageCommandlet MyLevel
```

**Output**:
```
==== BEGIN PACKAGE DISCOVERY ====
========================================
PACKAGE: MyLevel
========================================
Package loaded successfully

Scanning for StaticMeshes...
  [STATICMESH] StaticMesh'MyLevel.Mesh1'
    Vertices: 1234 Triangles: 456
  [STATICMESH] StaticMesh'MyLevel.Mesh2'
    Vertices: 5678 Triangles: 890

Scanning for Materials...
  [MATERIAL] Material'MyLevel.Material1'
  [MATERIAL] Material'MyLevel.Material2'

Scanning for Material Instances...
  [MATERIAL_INSTANCE] MaterialInstanceConstant'MyLevel.MIC1'
    Parent: Material'BaseMaterials.Master'

Scanning for Textures...
  [TEXTURE] Texture2D'MyLevel.Texture1' Size: 1024x1024
  [TEXTURE] Texture2D'MyLevel.Texture2' Size: 2048x2048

Scanning for Sounds...
  [SOUNDCUE] SoundCue'MyLevel.Sound1'

PACKAGE SUMMARY:
  StaticMeshes: 2
  Materials: 2
  Material Instances: 1
  Textures: 2
  Sound Cues: 1
  Total Assets: 8
==== END PACKAGE DISCOVERY ====
```

**Use cases**:
- Planning migration scope
- Estimating export time
- Identifying asset dependencies
- Creating migration checklists

---

### 4. NativeFBXExportCommandlet (New - Native C++ Solution) ⭐

**Purpose**: **Reliable automated FBX export** using native C++ DLL that directly accesses UDK's FBX exporter.

**Status**: ✅ **WORKING** - Produces valid FBX files programmatically

**Location**: `Native/FBXExportModule/` (requires building C++ DLL)

**Usage**:
```
UDK.exe NativeFBXExportCommandlet Package.MeshName OutputPath.fbx [Package.MeshName2 OutputPath2.fbx ...]
```

**Example**:
```
UDK.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/MyMesh.fbx
```

**Advantages**:
- ✅ Direct access to native FBX export API
- ✅ Produces valid binary FBX files
- ✅ No UDK FBX export bugs
- ✅ Batch processing support
- ✅ Detailed progress logging

**Setup Required**:
1. Build the native C++ DLL (see `Native/FBXExportModule/README.md`)
2. Copy DLL to UDK Binaries folder
3. Rebuild UDK scripts

**Quick Start**: See `Native/QUICKSTART.md` for step-by-step setup guide

---

### 5. BatchExportStaticMeshFBXCommandlet (Deprecated - Use NativeFBXExportCommandlet Instead)

**Purpose**: Attempt automated FBX export (note: UDK's FBX export has known bugs).

**Usage**:
```
UDK.exe BatchExportStaticMeshFBXCommandlet MeshRef OutputPath [MeshRef2 OutputPath2 ...]
```

**Example**:
```
UDK.exe BatchExportStaticMeshFBXCommandlet MyPackage.MyMesh C:/Export/MyMesh.fbx
```

**Important Notes**:
- ⚠️ UDK's built-in FBX exporter is **known to produce corrupt files**
- This commandlet provides diagnostic information about **why** FBX export fails
- **Recommendation**: Use manual export from UDK Content Browser for FBX
- **Alternative**: Plugin auto-exports to OBJ format which works reliably

**Why FBX export fails in UDK**:
UDK's `batchexport` commandlet has bugs that produce empty or corrupt FBX files. This is a known limitation of UDK itself, not the plugin. The workaround is:
1. Use OBJ export (automatic, reliable)
2. Convert OBJ to FBX using Autodesk FBX Converter 2013
3. Or manually export FBX from Content Browser (slow but reliable)

---

## Workflow Examples

### Full Package Migration Workflow

```batch
# Step 1: Discover what's in the package
UDK.exe DiscoverPackageCommandlet MyLevel

# Step 2: Validate assets are export-ready
UDK.exe ValidateExportReadinessCommandlet MyLevel.Mesh1 MyLevel.Mesh2 MyLevel.Material1

# Step 3: Export mesh material information
UDK.exe ExportStaticMeshMaterialsCommandlet MyLevel.Mesh1 MyLevel.Mesh2

# Step 4: Use the UDK Import Plugin in UE4/5 to complete the migration
```

### Quick Asset Check

```batch
# Validate a single asset before export
UDK.exe ValidateExportReadinessCommandlet MyPackage.MyAsset
```

### Batch Processing Multiple Packages

```batch
# Discover all assets in multiple packages
UDK.exe DiscoverPackageCommandlet Package1 Package2 Package3

# Validate all meshes from discovery results
UDK.exe ValidateExportReadinessCommandlet Package1.Mesh1 Package1.Mesh2 Package2.Mesh1
```

---

## Troubleshooting

### Commandlet not found
- Ensure `ModEditPackages=UDKPluginExport` is in `DefaultEngineUDK.ini`
- Run `UDK.exe make` to compile the commandlets
- Check `YourUDKPath/UDKGame/Logs/Launch.log` for compilation errors

### "Failed to load package"
- Verify the package name is correct (case-sensitive)
- Ensure the package file exists in `YourUDKPath/UDKGame/Content/`
- Try loading the package in UDK Editor first

### "Failed to load asset"
- Check the full reference path: `Package.AssetName`
- Use the DiscoverPackageCommandlet to find correct asset names
- Some assets may not be exportable due to UDK limitations

---

## Output Parsing Tips

The commandlets use structured output with markers like:
- `==== BEGIN ... ====` / `==== END ... ====`: Section boundaries
- `MESH_START:` / `MESH_END:`: Individual asset boundaries
- `[ERROR]`, `[WARNING]`: Problem indicators
- `Key: Value`: Parseable key-value pairs

This format is designed to be both human-readable and machine-parseable for automation.

---

## Contributing

To add new commandlets:
1. Create a new `.uc` file in `UDKPluginExport/Classes/`
2. Extend `Commandlet` class
3. Implement `event int Main(string Params)`
4. Set `LogToConsole=true` in defaultproperties
5. Rebuild with `UDK.exe make`

---

## Credits

Based on the original work by Vincent (Speedy37) Rouille  
Enhanced and expanded by AlleyKatPr0  
https://github.com/AlleyKatPr0/UDKImportPlugin
