# Native FBX Export Module for UDK

This native C++ module provides **reliable FBX export functionality** for UDK StaticMeshes by directly accessing UDK's native `StaticMeshExporterFBX` class.

## Why This Exists

**Problem**: UDK's UnrealScript cannot call the native FBX export API directly. The built-in `batchexport` commandlet produces corrupt FBX files.

**Solution**: This native C++ DLL bridges the gap, providing proper FBX export from commandlet.

---

## Prerequisites

- **UDK Installation**: `D:\UDK\Custom`
- **Visual Studio**: 2010, 2012, 2013, 2017, 2019, or 2022
- **UDK Development Headers**: Included with UDK installation

> **64-bit Support**: See [X64_SUPPORT.md](../X64_SUPPORT.md) for building both Win32 and x64 versions

---

## Installation & Build Instructions

### Step 1: Copy Module to UDK

Copy this entire `FBXExportModule` folder to your UDK development source:

```bash
# Copy from plugin location
xcopy /E /I "UDKImportPlugin\UDKPluginExport\Native\FBXExportModule" "D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule"
```

### Step 2: Choose Build Method

**For Standard UDK (32-bit only):**
```bash
cd D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule

# Option A: Automated build
.\Build.bat

# Option B: Manual Visual Studio
start FBXExportModule.vcxproj
```

**For 64-bit UDK (Custom builds with Win64 support):**
```bash
# Use the multi-platform build script
.\Build_Both.bat

# Or manually open the x64 project
start FBXExportModule_x64.vcxproj
```

See [X64_SUPPORT.md](../X64_SUPPORT.md) for details on 64-bit support.

### Step 3: Verify Project Settings

In Visual Studio, check **Project Properties** (Alt+F7):

**Configuration Properties > General**
- Platform Toolset: `v110` (VS2012) or compatible
- Configuration Type: `Dynamic Library (.dll)`
- Character Set: `Use Unicode Character Set`

**C/C++ > General > Additional Include Directories**:
```
D:\UDK\Custom\Development\Src\Core\Inc
D:\UDK\Custom\Development\Src\Engine\Inc
D:\UDK\Custom\Development\Src\UnrealEd\Inc
$(ProjectDir)Inc
```

**Linker > General > Additional Library Directories**:
```
D:\UDK\Custom\Binaries\Win32
```

**Linker > Input > Additional Dependencies**:
```
Core.lib
Engine.lib
UnrealEd.lib
```

### Step 4: Build the DLL

**Using Build Script (Recommended):**
```bash
.\Build.bat              # Win32 only
.\Build_Both.bat         # Win32 + x64 (if supported)
```

**Manual Build:**
1. Select **Release | Win32** configuration (or **Release | x64**)
2. Build Solution: `Ctrl+Shift+B`
3. Output: `Release\FBXExportModule.dll` (Win32) or `x64\Release\FBXExportModule.dll` (x64)

### Step 5: Deploy DLL to UDK

**Automatic (if using Build.bat or Build_Both.bat):**
- DLLs are automatically copied to the correct folders

**Manual:**
```bash
# Win32
copy "Release\FBXExportModule.dll" "D:\UDK\Custom\Binaries\Win32\FBXExportModule.dll"

# x64 (if applicable)
copy "x64\Release\FBXExportModule.dll" "D:\UDK\Custom\Binaries\Win64\FBXExportModule.dll"
```

### Step 6: Rebuild UDK Scripts

```bash
cd D:\UDK\Custom\Binaries\Win32
UDK.exe make
```

This compiles the `NativeFBXExportCommandlet.uc` which binds to the DLL.

---

## Usage

### Single Mesh Export

```bash
cd D:\UDK\Custom\Binaries\Win32

UDK.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/MyMesh.fbx
```

### Batch Export Multiple Meshes

```bash
UDK.exe NativeFBXExportCommandlet ^
    MyPackage.Mesh1 D:/Export/Mesh1.fbx ^
    MyPackage.Mesh2 D:/Export/Mesh2.fbx ^
    MyPackage.Mesh3 D:/Export/Mesh3.fbx
```

### Using with Discovery Commandlet

First discover all meshes in a package:

```bash
# Step 1: Discover what meshes exist
UDK.exe DiscoverPackageCommandlet MyLevel

# Step 2: Export discovered meshes
UDK.exe NativeFBXExportCommandlet ^
    MyLevel.Mesh1 D:/Export/MyLevel/Mesh1.fbx ^
    MyLevel.Mesh2 D:/Export/MyLevel/Mesh2.fbx
```

---

## Output Example

```
========================================
  NATIVE FBX BATCH EXPORT
========================================
Exporting 2 mesh(es)

----------------------------------------
Mesh 1 of 2
  Input: MyPackage.MyMesh
  Output: D:/Export/MyMesh.fbx

Loading StaticMesh: MyPackage.MyMesh
StaticMesh loaded successfully
  Vertices (LOD0): 1234
  LODs: 3
FBX Exporter created
Output file created: D:/Export/MyMesh.fbx
Exporting to FBX...
SUCCESS: Exported MyPackage.MyMesh to D:/Export/MyMesh.fbx (45678 bytes)

----------------------------------------
Mesh 2 of 2
  Input: MyPackage.AnotherMesh
  Output: D:/Export/AnotherMesh.fbx

[... similar output ...]

========================================
  EXPORT SUMMARY
========================================
Total: 2
Success: 2
Failed: 0
========================================
```

---

## Advantages Over UnrealScript Approach

✅ **Direct API Access**: Calls native `StaticMeshExporterFBX` directly  
✅ **Binary FBX Output**: Produces proper binary FBX files  
✅ **No UDK Bugs**: Bypasses the broken `batchexport` commandlet  
✅ **Full Control**: Can set export parameters precisely  
✅ **Reliable**: Works with complex meshes that fail with UnrealScript  
✅ **Fast**: Native C++ performance  
✅ **Detailed Logging**: Reports vertex counts, LOD info, file sizes  

---

## Troubleshooting

### Build Errors

**Error: Cannot open include file 'Engine.h'**
- **Fix**: Verify UDK include paths in project properties
- Check that `D:\UDK\Custom\Development\Src\` folders exist

**Error: Cannot open file 'Core.lib'**
- **Fix**: Verify UDK library path in project properties
- Check that `D:\UDK\Custom\Binaries\Win32\` contains `.lib` files
- You may need to run UDK once to generate these files

**Error: Unresolved external symbol**
- **Fix**: Ensure all three libraries are linked: `Core.lib`, `Engine.lib`, `UnrealEd.lib`

### Runtime Errors

**Commandlet not found**
- **Fix**: Run `UDK.exe make` to compile UnrealScript
- Check that `NativeFBXExportCommandlet.uc` is in `UDKPluginExport/Classes/`

**DLL not found / Failed to bind DLL**
- **Fix**: Ensure `FBXExportModule.dll` is in `D:\UDK\Custom\Binaries\Win32\`
- Check DLL is not blocked (Right-click > Properties > Unblock)

**Failed to load StaticMesh**
- **Fix**: Verify mesh path is correct (case-sensitive)
- Use `DiscoverPackageCommandlet` to find correct asset names
- Example: `MyPackage.MyMesh` not `MyPackage.mymesh`

**Export completed but file is empty**
- **Cause**: Mesh has corrupted data or missing materials
- **Fix**: Run `ValidateExportReadinessCommandlet` first
- Check UDK Content Browser can view the mesh

**Could not find StaticMeshExporterFBX class**
- **Cause**: Your UDK build doesn't include FBX support
- **Fix**: Install full UDK (not minimal version)
- **Workaround**: Use OBJ export + FBX Converter

---

## Development Notes

### DLLBind Mechanism

UnrealScript's `DLLBind` allows calling native DLL functions:

```unrealscript
class NativeFBXExportCommandlet extends Commandlet
    DLLBind(FBXExportModule);  // Looks for FBXExportModule.dll

// Native functions must match C++ signatures exactly
native static function bool ExportStaticMeshToFBX(string MeshPath, string OutputPath);
```

The DLL must:
1. Export functions with `extern "C"` and `__declspec(dllexport)`
2. Use UDK types (`UBOOL`, `TCHAR*`, `INT`)
3. Be in the same directory as `UDK.exe`

### Memory Management

- UDK's `LoadObject` manages memory automatically
- Don't delete UDK objects (UObject, StaticMesh, etc.)
- Do delete: `FArchive*`, manual allocations

### Thread Safety

- This module is **not thread-safe**
- UDK commandlets run single-threaded, so this is fine
- Don't call from multiple threads simultaneously

---

## Alternative: Building Without Visual Studio

If you don't have Visual Studio, you can use MinGW or Windows SDK:

```bash
# Using Windows SDK (cl.exe)
cl /LD /MD ^
   /I"D:\UDK\Custom\Development\Src\Core\Inc" ^
   /I"D:\UDK\Custom\Development\Src\Engine\Inc" ^
   /I"D:\UDK\Custom\Development\Src\UnrealEd\Inc" ^
   /DFBXEXPORTMODULE_EXPORTS ^
   Src\FBXExportModule.cpp ^
   /link /LIBPATH:"D:\UDK\Custom\Binaries\Win32" ^
   Core.lib Engine.lib UnrealEd.lib ^
   /OUT:FBXExportModule.dll
```

---

## Future Enhancements

Potential improvements:
- [ ] Support for SkeletalMesh export
- [ ] Material/texture export alongside meshes
- [ ] Animation export
- [ ] FBX export options (ASCII vs Binary, version selection)
- [ ] Progress callbacks for UI integration
- [ ] Multi-threaded batch processing

---

## Credits

**Author**: AlleyKatPr0  
**Based on**: UDK Import Plugin by Vincent (Speedy37) Rouille  
**Repository**: https://github.com/AlleyKatPr0/UDKImportPlugin

---

## License

This module is part of the UDK Import Plugin and follows the same license as the main project.
