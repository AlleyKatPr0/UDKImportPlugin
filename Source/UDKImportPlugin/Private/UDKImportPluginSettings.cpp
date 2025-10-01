#include "UDKImportPluginPrivatePCH.h"
#include "UDKImportPluginSettings.h"

UUDKImportPluginSettings::UUDKImportPluginSettings()
	: bAutoExportStaticMeshes(true)
	, bAutoConvertOBJToFBX(false)
	, LightIntensityMultiplier(5000.0f)
	, bVerboseLogging(false)
	, bCacheExportedMeshes(true)
	, MaxParallelImports(4)
	, bImportStaticMeshes(true)
	, bImportMaterials(true)
	, bImportTextures(true)
	, bImportLights(true)
	, bImportBrushes(true)
	, bEnableNanite(false)
	, bConvertToLumenMaterials(false)
{
	// Set default paths
	DefaultTempPath.Path = FPaths::ProjectIntermediateDir() / TEXT("UDKImport");
	
	// Try to find FBX Converter
	FString ProgramFilesX86 = FPlatformMisc::GetEnvironmentVariable(TEXT("ProgramFiles(x86)"));
	if (!ProgramFilesX86.IsEmpty())
	{
		FString ConverterPath = ProgramFilesX86 / TEXT("Autodesk/FBX/FBX Converter/2013.3/bin/FbxConverter.exe");
		if (FPaths::FileExists(ConverterPath))
		{
			FBXConverterPath.FilePath = ConverterPath;
		}
	}
}
