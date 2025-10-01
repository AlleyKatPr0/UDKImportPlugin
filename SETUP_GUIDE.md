# Complete Setup Guide for D:\UDK\Custom

This guide is specifically tailored for your UDK installation at `D:\UDK\Custom`.

---

## Overview

You now have **5 powerful UDK commandlets** + **1 native C++ FBX exporter**:

1. ✅ **ValidateExportReadinessCommandlet** - Check assets before export
2. ✅ **DiscoverPackageCommandlet** - List all assets in packages
3. ✅ **ExportStaticMeshMaterialsCommandlet** - Get detailed mesh info
4. ⭐ **NativeFBXExportCommandlet** - Reliable FBX export (C++ DLL)
5. ⚠️ **BatchExportStaticMeshFBXCommandlet** - Experimental (UnrealScript only)

---

## Phase 1: Basic Setup (UnrealScript Commandlets)

### Step 1: Copy UnrealScript Files

```powershell
# Copy commandlets to UDK
$sourceClasses = "path\to\UDKImportPlugin\UDKPluginExport\Classes"
$targetClasses = "D:\UDK\Custom\Development\Src\UDKPluginExport\Classes"

New-Item -ItemType Directory -Force -Path $targetClasses

Copy-Item "$sourceClasses\*.uc" $targetClasses
```

### Step 2: Update UDK Configuration

Edit `D:\UDK\Custom\UDKGame\Config\DefaultEngineUDK.ini`:

Find the section `[UnrealEd.EditorEngine]` and add:

```ini
ModEditPackages=UDKPluginExport
```

### Step 3: Build UnrealScript Commandlets

```powershell
cd D:\UDK\Custom\Binaries\Win32
.\UDK.exe make
```

Look for successful compilation messages for all commandlets.

### Step 4: Test Basic Commandlets

```powershell
# Test discovery
.\UDK.exe DiscoverPackageCommandlet UTGame

# Test validation (replace with actual asset)
.\UDK.exe ValidateExportReadinessCommandlet UTGame.SomeAsset
```

---

## Phase 2: Native FBX Export Setup (Optional but Recommended)

### Prerequisites

- Visual Studio 2010, 2012, or compatible
- Windows SDK (usually included with VS)

### Step 1: Copy Native Module

```powershell
$sourceNative = "path\to\UDKImportPlugin\UDKPluginExport\Native"
$targetNative = "D:\UDK\Custom\Development\Src\UDKPluginExport\Native"

New-Item -ItemType Directory -Force -Path $targetNative

Copy-Item -Recurse -Force "$sourceNative\FBXExportModule" "$targetNative\FBXExportModule"
```

### Step 2: Verify Project Paths

Open in text editor: `D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule\FBXExportModule.vcxproj`

Verify these paths match your UDK installation (should be correct already):

```xml
<AdditionalIncludeDirectories>
    D:\UDK\Custom\Development\Src\Core\Inc;
    D:\UDK\Custom\Development\Src\Engine\Inc;
    D:\UDK\Custom\Development\Src\UnrealEd\Inc;
</AdditionalIncludeDirectories>

<AdditionalLibraryDirectories>
    D:\UDK\Custom\Binaries\Win32;
</AdditionalLibraryDirectories>
```

### Step 3: Build the DLL

**Option A: Automated** (from Visual Studio Developer Command Prompt):

```powershell
cd D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule
.\Build.bat
```

**Option B: Manual** (in Visual Studio):

1. Open `FBXExportModule.vcxproj`
2. Select **Release | Win32**
3. Build Solution (`Ctrl+Shift+B`)
4. Copy `Release\FBXExportModule.dll` to `D:\UDK\Custom\Binaries\Win32\`

### Step 4: Rebuild Scripts with Native Binding

```powershell
cd D:\UDK\Custom\Binaries\Win32
.\UDK.exe make
```

Should see `NativeFBXExportCommandlet` compile successfully.

### Step 5: Test Native FBX Export

```powershell
# Create test export directory
New-Item -ItemType Directory -Force -Path "D:\Export\Test"

# Test export (replace with real asset)
.\UDK.exe NativeFBXExportCommandlet UTGame.TestMesh D:\Export\Test\TestMesh.fbx
```

---

## Complete Workflow Example

Here's a complete workflow for exporting a package:

```powershell
cd D:\UDK\Custom\Binaries\Win32

# Step 1: Discover what's in the package
.\UDK.exe DiscoverPackageCommandlet MyLevel
# Output shows all meshes, materials, textures, etc.

# Step 2: Validate specific assets
.\UDK.exe ValidateExportReadinessCommandlet `
    MyLevel.Mesh1 `
    MyLevel.Mesh2 `
    MyLevel.Mesh3
# Shows any issues that might prevent export

# Step 3: Get detailed mesh information
.\UDK.exe ExportStaticMeshMaterialsCommandlet `
    MyLevel.Mesh1 `
    MyLevel.Mesh2 `
    MyLevel.Mesh3
# Shows LODs, materials, UV channels, collision

# Step 4: Export to FBX (if native module is built)
.\UDK.exe NativeFBXExportCommandlet `
    MyLevel.Mesh1 D:\Export\MyLevel\Mesh1.fbx `
    MyLevel.Mesh2 D:\Export\MyLevel\Mesh2.fbx `
    MyLevel.Mesh3 D:\Export\MyLevel\Mesh3.fbx

# Step 5: Import into UE4/5 using the UDK Import Plugin!
```

---

## Verification Commands

### Check if commandlets are installed:

```powershell
cd D:\UDK\Custom\Binaries\Win32

# Should list all commandlets including ours
.\UDK.exe -help | Select-String "Export"
.\UDK.exe -help | Select-String "Validate"
.\UDK.exe -help | Select-String "Discover"
```

### Check if native DLL is loaded:

```powershell
# Check if DLL exists
Test-Path "D:\UDK\Custom\Binaries\Win32\FBXExportModule.dll"

# If true, DLL is in the right place
```

### Test each commandlet:

```powershell
# 1. Discovery
.\UDK.exe DiscoverPackageCommandlet UTGame

# 2. Validation
.\UDK.exe ValidateExportReadinessCommandlet UTGame.Default_Archetype

# 3. Mesh info export
.\UDK.exe ExportStaticMeshMaterialsCommandlet UTGame.Default_StaticMesh

# 4. Native FBX (if built)
.\UDK.exe NativeFBXExportCommandlet UTGame.TestMesh D:\Export\Test.fbx
```

---

## Troubleshooting Reference

### "Commandlet not found"
```powershell
# Solution: Rebuild UDK scripts
cd D:\UDK\Custom\Binaries\Win32
.\UDK.exe make -full
```

### "Failed to bind to DLL"
```powershell
# Check DLL exists
Test-Path "D:\UDK\Custom\Binaries\Win32\FBXExportModule.dll"

# If false, rebuild native module
cd D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule
.\Build.bat
```

### "Failed to load package/asset"
```powershell
# Use discovery to find correct names
.\UDK.exe DiscoverPackageCommandlet PackageName
```

### "Export fails silently"
```powershell
# Run with verbose logging
.\UDK.exe NativeFBXExportCommandlet Asset Path -VERBOSE

# Check validation first
.\UDK.exe ValidateExportReadinessCommandlet Asset
```

---

## Directory Structure After Setup

```
D:\UDK\Custom\
├── Binaries\Win32\
│   ├── UDK.exe
│   ├── FBXExportModule.dll  ← Native DLL (if built)
│   └── ...
├── Development\Src\
│   └── UDKPluginExport\
│       ├── Classes\
│       │   ├── ValidateExportReadinessCommandlet.uc
│       │   ├── DiscoverPackageCommandlet.uc
│       │   ├── ExportStaticMeshMaterialsCommandlet.uc
│       │   ├── NativeFBXExportCommandlet.uc
│       │   └── BatchExportStaticMeshFBXCommandlet.uc
│       └── Native\
│           └── FBXExportModule\
│               ├── Inc\
│               ├── Src\
│               ├── FBXExportModule.vcxproj
│               ├── Build.bat
│               └── README.md
└── UDKGame\Config\
    └── DefaultEngineUDK.ini  ← Contains ModEditPackages=UDKPluginExport
```

---

## Next Steps

1. ✅ **Test all commandlets** with your actual UDK content
2. ✅ **Export some FBX files** using the native exporter
3. ✅ **Import into UE4/5** using the main UDK Import Plugin
4. 🎯 **Automate your workflow** with batch scripts

---

## Quick Reference Card

```powershell
# Working Directory
cd D:\UDK\Custom\Binaries\Win32

# Discover assets
.\UDK.exe DiscoverPackageCommandlet <PackageName>

# Validate assets  
.\UDK.exe ValidateExportReadinessCommandlet <Package.Asset>

# Get mesh details
.\UDK.exe ExportStaticMeshMaterialsCommandlet <Package.Mesh>

# Export to FBX (native)
.\UDK.exe NativeFBXExportCommandlet <Package.Mesh> <OutputPath.fbx>

# Rebuild scripts
.\UDK.exe make
```

---

**Ready? Start with Phase 1, then optionally add Phase 2 for FBX export!** 🚀

For detailed documentation:
- `Native/QUICKSTART.md` - Fast native FBX setup
- `Native/FBXExportModule/README.md` - Complete native module docs
- `UDKPluginExport/README.md` - All commandlet documentation
