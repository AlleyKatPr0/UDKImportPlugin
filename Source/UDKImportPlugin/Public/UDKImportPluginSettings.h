#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "UDKImportPluginSettings.generated.h"

/**
 * Settings for UDK Import Plugin
 * Accessible via Edit > Project Settings > Plugins > UDK Import
 */
UCLASS(config=EditorPerProjectUserSettings, meta=(DisplayName="UDK Import Settings"))
class UDKIMPORTPLUGIN_API UUDKImportPluginSettings : public UObject
{
	GENERATED_BODY()

public:
	UUDKImportPluginSettings();

	/** Default path to UDK installation directory */
	UPROPERTY(Config, EditAnywhere, Category = "Paths", meta = (DisplayName = "UDK Installation Path"))
	FDirectoryPath DefaultUDKPath;

	/** Default temporary directory for export operations */
	UPROPERTY(Config, EditAnywhere, Category = "Paths", meta = (DisplayName = "Temporary Export Path"))
	FDirectoryPath DefaultTempPath;

	/** Enable automatic StaticMesh export to OBJ format */
	UPROPERTY(Config, EditAnywhere, Category = "Export Options", meta = (DisplayName = "Auto Export Static Meshes"))
	bool bAutoExportStaticMeshes;

	/** Enable automatic conversion of OBJ to FBX using Autodesk FBX Converter */
	UPROPERTY(Config, EditAnywhere, Category = "Export Options", meta = (DisplayName = "Auto Convert OBJ to FBX"))
	bool bAutoConvertOBJToFBX;

	/** Path to Autodesk FBX Converter executable */
	UPROPERTY(Config, EditAnywhere, Category = "Tools", meta = (DisplayName = "FBX Converter Path", EditCondition = "bAutoConvertOBJToFBX"))
	FFilePath FBXConverterPath;

	/** Light intensity multiplier for UDK to UE4/5 conversion */
	UPROPERTY(Config, EditAnywhere, Category = "Conversion", meta = (DisplayName = "Light Intensity Multiplier", ClampMin = "0.1", ClampMax = "10000.0"))
	float LightIntensityMultiplier;

	/** Enable verbose logging for debugging import issues */
	UPROPERTY(Config, EditAnywhere, Category = "Debug", meta = (DisplayName = "Verbose Logging"))
	bool bVerboseLogging;

	/** Cache exported meshes between sessions */
	UPROPERTY(Config, EditAnywhere, Category = "Performance", meta = (DisplayName = "Cache Exported Meshes"))
	bool bCacheExportedMeshes;

	/** Maximum number of parallel asset import operations */
	UPROPERTY(Config, EditAnywhere, Category = "Performance", meta = (DisplayName = "Max Parallel Imports", ClampMin = "1", ClampMax = "16"))
	int32 MaxParallelImports;

	// Future expansion: Asset type filters
	UPROPERTY(Config, EditAnywhere, Category = "Asset Filters", meta = (DisplayName = "Import Static Meshes"))
	bool bImportStaticMeshes;

	UPROPERTY(Config, EditAnywhere, Category = "Asset Filters", meta = (DisplayName = "Import Materials"))
	bool bImportMaterials;

	UPROPERTY(Config, EditAnywhere, Category = "Asset Filters", meta = (DisplayName = "Import Textures"))
	bool bImportTextures;

	UPROPERTY(Config, EditAnywhere, Category = "Asset Filters", meta = (DisplayName = "Import Lights"))
	bool bImportLights;

	UPROPERTY(Config, EditAnywhere, Category = "Asset Filters", meta = (DisplayName = "Import Brushes"))
	bool bImportBrushes;

	// Future: UE5-specific options
	UPROPERTY(Config, EditAnywhere, Category = "UE5 Features", meta = (DisplayName = "Enable Nanite for Static Meshes", EditCondition = "false"))
	bool bEnableNanite;

	UPROPERTY(Config, EditAnywhere, Category = "UE5 Features", meta = (DisplayName = "Convert to Lumen Materials", EditCondition = "false"))
	bool bConvertToLumenMaterials;
};
