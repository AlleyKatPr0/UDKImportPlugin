/**
 * FBXExportModule - Native C++ Implementation
 * 
 * This module provides reliable FBX export by directly accessing UDK's
 * native StaticMeshExporterFBX class, bypassing UnrealScript limitations.
 */

#include "Engine.h"
#include "UnrealEd.h"
#include "FBXExportModule.h"

// Forward declarations
class UStaticMeshExporterFBX;

/**
 * Export a single StaticMesh to FBX format
 */
extern "C" FBXEXPORT_API UBOOL ExportStaticMeshToFBX(const TCHAR* MeshPath, const TCHAR* OutputPath)
{
    if (!MeshPath || !OutputPath)
    {
        wprintf(TEXT("ERROR: Invalid parameters (NULL pointer)\n"));
        return FALSE;
    }

    wprintf(TEXT("Loading StaticMesh: %s\n"), MeshPath);

    // Load the StaticMesh
    UStaticMesh* StaticMesh = LoadObject<UStaticMesh>(NULL, MeshPath, NULL, LOAD_None, NULL);
    
    if (!StaticMesh)
    {
        wprintf(TEXT("ERROR: Failed to load StaticMesh: %s\n"), MeshPath);
        return FALSE;
    }

    wprintf(TEXT("StaticMesh loaded successfully\n"));
    wprintf(TEXT("  Vertices (LOD0): %d\n"), StaticMesh->LODModels.Num() > 0 ? StaticMesh->LODModels(0).NumVertices : 0);
    wprintf(TEXT("  LODs: %d\n"), StaticMesh->LODModels.Num());

    // Find the FBX exporter class
    UClass* ExporterClass = FindObject<UClass>(ANY_PACKAGE, TEXT("StaticMeshExporterFBX"));
    
    if (!ExporterClass)
    {
        wprintf(TEXT("ERROR: Could not find StaticMeshExporterFBX class\n"));
        wprintf(TEXT("This UDK build may not support FBX export\n"));
        return FALSE;
    }

    // Create exporter instance
    UExporter* Exporter = ConstructObject<UExporter>(ExporterClass);
    
    if (!Exporter)
    {
        wprintf(TEXT("ERROR: Failed to create FBX exporter instance\n"));
        return FALSE;
    }

    wprintf(TEXT("FBX Exporter created\n"));

    // Ensure output directory exists
    FString OutputDir = FFilename(OutputPath).GetPath();
    GFileManager->MakeDirectory(*OutputDir, TRUE);

    // Create output file
    FArchive* OutputFile = GFileManager->CreateFileWriter(OutputPath, 0);
    
    if (!OutputFile)
    {
        wprintf(TEXT("ERROR: Failed to create output file: %s\n"), OutputPath);
        wprintf(TEXT("  Check directory exists and write permissions\n"));
        return FALSE;
    }

    wprintf(TEXT("Output file created: %s\n"), OutputPath);

    // Perform the export
    wprintf(TEXT("Exporting to FBX...\n"));
    
    UBOOL bSuccess = FALSE;
    
    // Try binary export first (preferred)
    bSuccess = Exporter->ExportBinary(
        StaticMesh,
        NULL,
        *OutputFile,
        TEXT("FBX"),
        0
    );

    // Cleanup
    OutputFile->Close();
    delete OutputFile;

    if (bSuccess)
    {
        // Verify file was created and has content
        INT FileSize = GFileManager->FileSize(OutputPath);
        if (FileSize > 0)
        {
            wprintf(TEXT("SUCCESS: Exported %s to %s (%d bytes)\n"), MeshPath, OutputPath, FileSize);
        }
        else
        {
            wprintf(TEXT("WARNING: Export completed but file is empty\n"));
            bSuccess = FALSE;
        }
    }
    else
    {
        wprintf(TEXT("ERROR: Export failed for %s\n"), MeshPath);
        wprintf(TEXT("  This may be due to:\n"));
        wprintf(TEXT("  - Corrupted mesh data\n"));
        wprintf(TEXT("  - Missing material references\n"));
        wprintf(TEXT("  - UDK FBX exporter bugs\n"));
    }

    return bSuccess;
}

/**
 * Batch export multiple StaticMeshes to FBX format
 */
extern "C" FBXEXPORT_API INT BatchExportStaticMeshesToFBX(const TCHAR* ParamString)
{
    if (!ParamString)
    {
        wprintf(TEXT("ERROR: Invalid parameters (NULL pointer)\n"));
        return 1;
    }

    TArray<FString> Params;
    FString(ParamString).ParseIntoArray(&Params, TEXT("|"), TRUE);
    
    if (Params.Num() < 2 || (Params.Num() % 2) != 0)
    {
        wprintf(TEXT("ERROR: Invalid parameter count (must be even)\n"));
        wprintf(TEXT("Format: MeshPath1|OutputPath1|MeshPath2|OutputPath2|...\n"));
        return 1;
    }
    
    INT SuccessCount = 0;
    INT FailCount = 0;
    
    wprintf(TEXT("\n"));
    wprintf(TEXT("========================================\n"));
    wprintf(TEXT("  NATIVE FBX BATCH EXPORT\n"));
    wprintf(TEXT("========================================\n"));
    wprintf(TEXT("Exporting %d mesh(es)\n\n"), Params.Num() / 2);
    
    for (INT i = 0; i < Params.Num(); i += 2)
    {
        if (i + 1 >= Params.Num())
            break;
            
        const FString& MeshPath = Params(i);
        const FString& OutputPath = Params(i + 1);
        
        wprintf(TEXT("----------------------------------------\n"));
        wprintf(TEXT("Mesh %d of %d\n"), (i / 2) + 1, Params.Num() / 2);
        wprintf(TEXT("  Input: %s\n"), *MeshPath);
        wprintf(TEXT("  Output: %s\n"), *OutputPath);
        wprintf(TEXT("\n"));
        
        if (ExportStaticMeshToFBX(*MeshPath, *OutputPath))
        {
            SuccessCount++;
        }
        else
        {
            FailCount++;
        }
        
        wprintf(TEXT("\n"));
    }
    
    wprintf(TEXT("========================================\n"));
    wprintf(TEXT("  EXPORT SUMMARY\n"));
    wprintf(TEXT("========================================\n"));
    wprintf(TEXT("Total: %d\n"), SuccessCount + FailCount);
    wprintf(TEXT("Success: %d\n"), SuccessCount);
    wprintf(TEXT("Failed: %d\n"), FailCount);
    wprintf(TEXT("========================================\n"));
    
    return (FailCount > 0) ? 1 : 0;
}

// DLL Entry Point
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        wprintf(TEXT("FBXExportModule loaded\n"));
        break;
    case DLL_PROCESS_DETACH:
        wprintf(TEXT("FBXExportModule unloaded\n"));
        break;
    }
    return TRUE;
}
