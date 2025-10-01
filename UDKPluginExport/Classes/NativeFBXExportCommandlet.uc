/**
 * Native FBX export commandlet using C++ DLL
 * 
 * This commandlet calls into a native DLL that properly exports FBX files
 * by directly accessing UDK's StaticMeshExporterFBX C++ class.
 * 
 * The UnrealScript-only approach fails because UDK doesn't expose the
 * export API to UnrealScript. This native solution bypasses that limitation.
 * 
 * Usage: udk.exe NativeFBXExportCommandlet Package.MeshName OutputPath [Package.MeshName2 OutputPath2 ...]
 * 
 * Example:
 *   udk.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/MyMesh.fbx
 * 
 * Batch Example:
 *   udk.exe NativeFBXExportCommandlet ^
 *       MyPackage.Mesh1 D:/Export/Mesh1.fbx ^
 *       MyPackage.Mesh2 D:/Export/Mesh2.fbx ^
 *       MyPackage.Mesh3 D:/Export/Mesh3.fbx
 * 
 * Requirements:
 *   - FBXExportModule.dll must be in UDK/Binaries/Win32/
 *   - Build the native module first (see Native/FBXExportModule/README.md)
 */
class NativeFBXExportCommandlet extends Commandlet
    DLLBind(FBXExportModule);

/**
 * Export a single StaticMesh to FBX format
 * Native function implemented in FBXExportModule.dll
 * 
 * @param MeshPath - Full object path (e.g., "MyPackage.MyMesh")
 * @param OutputPath - Full file system path (e.g., "D:/Export/MyMesh.fbx")
 * @return true if export succeeded
 */
native static function bool ExportStaticMeshToFBX(string MeshPath, string OutputPath);

/**
 * Batch export multiple StaticMeshes to FBX format
 * Native function implemented in FBXExportModule.dll
 * 
 * @param ParamString - Pipe-separated string: "Mesh1|Path1|Mesh2|Path2|..."
 * @return 0 if all exports succeeded, non-zero if any failed
 */
native static function int BatchExportStaticMeshesToFBX(string ParamString);

event int Main(string Params)
{
    local array<string> Args;
    local string ParamString;
    local int i, Result;

    ParseStringIntoArray(Params, Args, " ", true);

    if (Args.Length < 2 || (Args.Length % 2) != 0)
    {
        `Warn("");
        `Warn("========================================");
        `Warn("  Native FBX Export Commandlet");
        `Warn("========================================");
        `Warn("");
        `Warn("Usage:");
        `Warn("  udk.exe NativeFBXExportCommandlet MeshRef OutputPath [MeshRef2 OutputPath2 ...]");
        `Warn("");
        `Warn("Examples:");
        `Warn("  Single mesh:");
        `Warn("    udk.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/MyMesh.fbx");
        `Warn("");
        `Warn("  Multiple meshes:");
        `Warn("    udk.exe NativeFBXExportCommandlet ^");
        `Warn("        MyPackage.Mesh1 D:/Export/Mesh1.fbx ^");
        `Warn("        MyPackage.Mesh2 D:/Export/Mesh2.fbx");
        `Warn("");
        `Warn("Requirements:");
        `Warn("  - FBXExportModule.dll must be in UDK/Binaries/Win32/");
        `Warn("  - Build the native module first (see Native/FBXExportModule/)");
        `Warn("");
        return 1;
    }

    `Log("Native FBX Export Commandlet");
    `Log("Processing" @ (Args.Length / 2) @ "mesh(es)");

    // Build parameter string for native function (pipe-separated)
    for (i = 0; i < Args.Length; i++)
    {
        if (i > 0)
            ParamString $= "|";
        ParamString $= Args[i];
    }

    // Call native batch export
    Result = BatchExportStaticMeshesToFBX(ParamString);

    if (Result == 0)
    {
        `Log("");
        `Log("All exports completed successfully!");
    }
    else
    {
        `Warn("");
        `Warn("Some exports failed. Check output above for details.");
    }

    return Result;
}

defaultproperties
{
    LogToConsole=true
}
