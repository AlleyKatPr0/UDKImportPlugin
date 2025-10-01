/**
 * FBXExportModule - Native C++ DLL for UDK FBX Export
 * 
 * This module provides reliable FBX export functionality by accessing
 * UDK's native StaticMeshExporterFBX class directly from C++.
 * 
 * UnrealScript cannot call these functions directly, so this DLL bridges
 * the gap using DLLBind.
 * 
 * Author: AlleyKatPr0
 * Based on UDK Import Plugin by Vincent (Speedy37) Rouille
 */

#pragma once

#ifdef FBXEXPORTMODULE_EXPORTS
#define FBXEXPORT_API __declspec(dllexport)
#else
#define FBXEXPORT_API __declspec(dllimport)
#endif

extern "C" {
    /**
     * Export a single StaticMesh to FBX format
     * 
     * @param MeshPath - Full UDK object path (e.g., "MyPackage.MyMesh")
     * @param OutputPath - Full file system path for output FBX (e.g., "D:/Export/MyMesh.fbx")
     * @return TRUE if export succeeded, FALSE otherwise
     */
    FBXEXPORT_API UBOOL ExportStaticMeshToFBX(const TCHAR* MeshPath, const TCHAR* OutputPath);
    
    /**
     * Batch export multiple StaticMeshes to FBX format
     * 
     * @param ParamString - Pipe-separated string: "Mesh1|Path1|Mesh2|Path2|..."
     * @return 0 if all exports succeeded, 1 if any failed
     */
    FBXEXPORT_API INT BatchExportStaticMeshesToFBX(const TCHAR* ParamString);
}
