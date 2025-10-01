# 64-bit (x64) Support for FBXExportModule

## Overview

The FBXExportModule now supports both **32-bit (Win32)** and **64-bit (x64)** platforms!

---

## Do I Need 64-bit?

### Standard UDK (Most Users)
**Standard UDK releases are 32-bit only.** If you downloaded UDK from Epic's website (2009-2015), you only need the Win32 version.

**Check your UDK:**
```powershell
# Does this folder exist?
D:\UDK\Custom\Binaries\Win64
```

- ❌ **No Win64 folder** → You have standard UDK (32-bit only)
- ✅ **Win64 folder exists** → You have 64-bit support!

### Who Needs 64-bit?

You need x64 support if you have:

1. **Custom UDK Build** - Compiled UDK yourself with 64-bit support
2. **UE3 Source License** - Full Unreal Engine 3 licensees
3. **Modified UDK** - Custom engine build with 64-bit editor
4. **Rocket/Launcher UDK** - Late UDK versions with optional 64-bit

---

## Building Both Platforms

### Option 1: Automatic Build (Recommended)

Use the new `Build_Both.bat` script:

```powershell
cd D:\UDK\Custom\Development\Src\UDKPluginExport\Native\FBXExportModule

# Build both Win32 and x64
.\Build_Both.bat

# Or build specific platform
.\Build_Both.bat Win32    # 32-bit only
.\Build_Both.bat x64      # 64-bit only
```

The script will:
- ✅ Auto-detect Visual Studio
- ✅ Build both platforms
- ✅ Copy DLLs to correct folders
- ✅ Warn if x64 is not supported
- ✅ Show clear next steps

### Option 2: Manual Build

#### Using Visual Studio GUI:

1. Open `FBXExportModule_x64.vcxproj` in Visual Studio
2. Select **Release | Win32** → Build
3. Select **Release | x64** → Build
4. Copy DLLs:
   - `Release\FBXExportModule.dll` → `D:\UDK\Custom\Binaries\Win32\`
   - `x64\Release\FBXExportModule.dll` → `D:\UDK\Custom\Binaries\Win64\`

#### Using Command Line:

```powershell
# Win32
msbuild FBXExportModule_x64.vcxproj /p:Configuration=Release /p:Platform=Win32

# x64
msbuild FBXExportModule_x64.vcxproj /p:Configuration=Release /p:Platform=x64
```

---

## Project Files

### For 32-bit Only:
- **`FBXExportModule.vcxproj`** - Original Win32-only project
- **`Build.bat`** - Original Win32-only build script

### For 32-bit + 64-bit:
- **`FBXExportModule_x64.vcxproj`** - Multi-platform project (Win32 + x64)
- **`Build_Both.bat`** - Multi-platform build script

**Choose one:**
- Standard UDK → Use original files
- 64-bit UDK → Use `_x64` versions

---

## Technical Differences

### Preprocessor Defines

| Platform | Define |
|----------|--------|
| Win32    | `WIN32` |
| x64      | `WIN64` |

### Library Paths

| Platform | Path |
|----------|------|
| Win32    | `D:\UDK\Custom\Binaries\Win32` |
| x64      | `D:\UDK\Custom\Binaries\Win64` |

### Pointer Size

| Platform | Size |
|----------|------|
| Win32    | 4 bytes (32-bit pointers) |
| x64      | 8 bytes (64-bit pointers) |

### UDK Headers

The same UDK header files work for both:
- `Core\Inc`
- `Engine\Inc`
- `UnrealEd\Inc`

UDK's `TCHAR`, `INT`, `UBOOL` types automatically adjust for platform.

---

## Usage

### Win32 (32-bit)

```powershell
cd D:\UDK\Custom\Binaries\Win32
.\UDK.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/Mesh.fbx
```

### x64 (64-bit)

```powershell
cd D:\UDK\Custom\Binaries\Win64
.\UDK.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/Mesh.fbx
```

**Important:** Use the correct `UDK.exe` for each platform!

---

## Troubleshooting

### "Win64 folder not found"

**Standard UDK is 32-bit only.** This is expected. Use Win32 version:

```powershell
cd D:\UDK\Custom\Binaries\Win32
.\UDK.exe NativeFBXExportCommandlet ...
```

### "Core.lib not found" (x64 build)

Your UDK doesn't have 64-bit libraries. Options:

1. **Use Win32 only** (recommended for standard UDK)
2. **Compile UDK with 64-bit support** (requires source)
3. **Get 64-bit UDK build** from your engine provider

### "Module loaded but symbol not found"

**ABI mismatch!** The DLL was built with a different compiler than UDK.

**Solutions:**
- Try Visual Studio 2010/2012 (matches UDK's build)
- Ensure platform matches (Win32 DLL in Win32 folder, x64 DLL in Win64 folder)
- Rebuild with `/MT` instead of `/MD` if CRT mismatch

### x64 build fails with "cannot open Core.lib"

Edit `FBXExportModule_x64.vcxproj` and verify paths:

```xml
<!-- Check this section for x64 Release -->
<ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
  <Link>
    <AdditionalLibraryDirectories>D:\UDK\Custom\Binaries\Win64;...</AdditionalLibraryDirectories>
  </Link>
</ItemDefinitionGroup>
```

Make sure:
- Path points to your UDK installation
- `Core.lib`, `Engine.lib`, `UnrealEd.lib` exist in that folder
- Libraries are 64-bit versions (check file size - x64 libs are larger)

---

## Visual Studio Compatibility

### Recommended (Best ABI Match):
- **Visual Studio 2010** - UDK's native compiler
- **Visual Studio 2012** - Close compatibility

### Should Work:
- **Visual Studio 2013-2019** - Usually compatible
- **Visual Studio 2022** - Likely works (simple interface)

### If Crashes Occur:
Fall back to VS 2010/2012 for guaranteed compatibility.

---

## Performance

### Win32 vs x64 Performance

| Aspect | Win32 | x64 |
|--------|-------|-----|
| **Speed** | Baseline | ~5-10% faster |
| **Memory** | 2GB limit | 4GB+ available |
| **Large Meshes** | May fail (out of memory) | Handles easily |
| **Compatibility** | Universal | Requires 64-bit UDK |

**Recommendation:**
- Small/medium meshes → Win32 is fine
- Large meshes (>100K tris) → x64 helps
- Standard UDK → Win32 only option

---

## Build Output

### Successful Build

```
Building Win32 (32-bit)
✓ Build succeeded
✓ Deployed: D:\UDK\Custom\Binaries\Win32\FBXExportModule.dll

Building x64 (64-bit)
✓ Build succeeded
✓ Deployed: D:\UDK\Custom\Binaries\Win64\FBXExportModule.dll
```

### Standard UDK (No x64 Support)

```
Building Win32 (32-bit)
✓ Build succeeded
✓ Deployed: D:\UDK\Custom\Binaries\Win32\FBXExportModule.dll

Building x64 (64-bit)
⚠ NOTICE: No 64-bit UDK Detected
⚠ Skipping x64 build (standard UDK is 32-bit only)
```

---

## Summary

### Standard UDK Users (Most People)
- ✅ Use `Build.bat` or `FBXExportModule.vcxproj`
- ✅ Win32 version is all you need
- ✅ Works perfectly for all assets

### Custom/64-bit UDK Users
- ✅ Use `Build_Both.bat` or `FBXExportModule_x64.vcxproj`
- ✅ Build both Win32 and x64
- ✅ Get performance benefits for large assets

---

## Quick Decision Matrix

| Your UDK | Project File | Build Script |
|----------|--------------|--------------|
| Standard UDK<br>(no Win64 folder) | `FBXExportModule.vcxproj` | `Build.bat` |
| Custom UDK<br>(has Win64 folder) | `FBXExportModule_x64.vcxproj` | `Build_Both.bat` |
| UE3 Source License | `FBXExportModule_x64.vcxproj` | `Build_Both.bat` |

---

Still not sure? **Check if you have `D:\UDK\Custom\Binaries\Win64`:**

- **No** → Use Win32-only files
- **Yes** → Use x64 files for both platforms

**When in doubt, just run `Build_Both.bat` - it will figure it out! 🎯**
