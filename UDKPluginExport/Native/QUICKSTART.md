# Quick Start Guide - Native FBX Export

This guide will get you up and running with native FBX export from UDK in under 10 minutes.

## Your Setup

- **UDK Installation**: `D:\UDK\Custom`
- **Plugin Location**: GitHub workspace

---

## Step-by-Step Setup

### 1. Copy Module to UDK (Do This First!)

Open PowerShell and run:

```powershell
# Create directory structure
New-Item -ItemType Directory -Force -Path "D:\UDK\Custom\Development\Src\UDKPluginExport\Native"

# Copy the entire FBXExportModule folder
Copy-Item -Recurse -Force `
    "path\to\UDKImportPlugin\UDKPluginExport\Native\FBXExportModule" `
    "D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule"

# Copy the UnrealScript commandlet
Copy-Item -Force `
    "path\to\UDKImportPlugin\UDKPluginExport\Classes\NativeFBXExportCommandlet.uc" `
    "D:\UDK\Custom\Development\Src\UDKPluginExport\Classes\NativeFBXExportCommandlet.uc"
```

### 2. Build the Native DLL

**Option A: Automated Build (Easiest)**

```powershell
cd D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule

# Run from Visual Studio Developer Command Prompt
.\Build.bat
```

**Option B: Manual Build in Visual Studio**

1. Open `D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule\FBXExportModule.vcxproj`
2. Select **Release | Win32** configuration
3. Build Solution (`Ctrl+Shift+B`)
4. Copy `Release\FBXExportModule.dll` to `D:\UDK\Custom\Binaries\Win32\`

### 3. Rebuild UDK Scripts

```powershell
cd D:\UDK\Custom\Binaries\Win32
.\UDK.exe make
```

Look for output confirming `NativeFBXExportCommandlet` was compiled.

### 4. Test It!

```powershell
cd D:\UDK\Custom\Binaries\Win32

# Replace with a real mesh from your UDK content
.\UDK.exe NativeFBXExportCommandlet UTGame.YourMesh D:\Export\Test.fbx
```

---

## Verification Checklist

✅ **FBXExportModule.dll** exists in `D:\UDK\Custom\Binaries\Win32\`  
✅ **NativeFBXExportCommandlet.uc** compiled without errors  
✅ **Test export** produces a valid FBX file  

---

## Troubleshooting

### "Cannot find commandlet NativeFBXExportCommandlet"

**Problem**: UnrealScript wasn't compiled  
**Fix**:
```powershell
cd D:\UDK\Custom\Binaries\Win32
.\UDK.exe make -full
```

### "Failed to bind to DLL FBXExportModule"

**Problem**: DLL not found or wrong location  
**Fix**:
```powershell
# Check if DLL exists
Test-Path "D:\UDK\Custom\Binaries\Win32\FBXExportModule.dll"

# If false, copy it manually
Copy-Item "D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule\Release\FBXExportModule.dll" `
    "D:\UDK\Custom\Binaries\Win32\FBXExportModule.dll"
```

### Build Errors "Cannot find Engine.h"

**Problem**: Project can't find UDK headers  
**Fix**: Open `FBXExportModule.vcxproj` in text editor and verify paths:
```xml
<AdditionalIncludeDirectories>
    D:\UDK\Custom\Development\Src\Core\Inc;
    D:\UDK\Custom\Development\Src\Engine\Inc;
    D:\UDK\Custom\Development\Src\UnrealEd\Inc;
```

### "Export completed but file is empty"

**Problem**: Mesh has issues  
**Fix**: Run validation first:
```powershell
.\UDK.exe ValidateExportReadinessCommandlet UTGame.YourMesh
```

---

## Example Workflow

```powershell
# 1. Discover what's in your package
.\UDK.exe DiscoverPackageCommandlet MyLevel

# Output shows:
#   [STATICMESH] StaticMesh'MyLevel.Building'
#   [STATICMESH] StaticMesh'MyLevel.Rock'
#   [STATICMESH] StaticMesh'MyLevel.Tree'

# 2. Validate they're export-ready
.\UDK.exe ValidateExportReadinessCommandlet `
    MyLevel.Building `
    MyLevel.Rock `
    MyLevel.Tree

# 3. Export them all to FBX
.\UDK.exe NativeFBXExportCommandlet `
    MyLevel.Building D:\Export\Building.fbx `
    MyLevel.Rock D:\Export\Rock.fbx `
    MyLevel.Tree D:\Export\Tree.fbx

# 4. Import into UE4/5 using the plugin!
```

---

## Next Steps

Once FBX export is working:

1. **Integrate with Plugin**: The UDK Import Plugin can be updated to call this commandlet automatically
2. **Batch Processing**: Create scripts to export entire packages
3. **Automation**: Combine with discovery/validation commandlets for full pipeline

---

## Need Help?

Check the full documentation:
- `Native/FBXExportModule/README.md` - Complete technical documentation
- `UDKPluginExport/README.md` - All commandlet documentation
- `README.md` - Main plugin documentation

## Common Commands Reference

```powershell
# List all commandlets
.\UDK.exe -help

# Rebuild scripts
.\UDK.exe make

# Full rebuild
.\UDK.exe make -full

# Run with verbose logging
.\UDK.exe NativeFBXExportCommandlet YourMesh.fbx -VERBOSE
```

---

**Ready to build? Start with Step 1!** 🚀
