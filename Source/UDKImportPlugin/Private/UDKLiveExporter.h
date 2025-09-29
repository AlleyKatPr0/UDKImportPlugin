#pragma once

#include "CoreMinimal.h"
#include "UObject/ObjectMacros.h"
#include "UObject/UObjectGlobals.h"
#include "Engine/World.h"
#include "Engine/StaticMesh.h"
#include "Misc/Paths.h"
#include "Misc/FileHelper.h"
#include "Serialization/JsonWriter.h"
#include "Serialization/JsonSerializer.h"

/**
 * Minimal in-editor exporter scaffold for serializing the live UWorld scene to disk:
 * - writes a JSON manifest with actors, transforms, mesh refs
 * - writes simple binary blobs for meshes/textures (placeholder functions)
 *
 * Designed to be low-risk on the game thread (gathers references) and then
 * hand off heavier work or conversion to an external process.
 */
class FUDKLiveExporter
{
public:
	explicit FUDKLiveExporter(UWorld* InWorld, const FString& InOutDir = FString());
	~FUDKLiveExporter();

	/** Export the current level to OutDir. Returns true on success. */
	bool ExportLevel();

private:
	UWorld* World;
	FString OutDir;

	/** Helpers */
	bool EnsureOutDir() const;
	void CollectActors(TArray<TSharedPtr<FJsonValue>>& OutActorArray);
	TSharedPtr<FJsonObject> SerializeActor(AActor* Actor);
	bool ExportStaticMesh(UStaticMesh* StaticMesh, FString& OutMeshPath);
	bool WriteManifest(const TSharedPtr<FJsonObject>& RootObject);

	/** Binary exporters (placeholders: can be swapped for more complete binary formats) */
	bool SaveBinary(const FString& FilePath, const TArray<uint8>& Data);
};
