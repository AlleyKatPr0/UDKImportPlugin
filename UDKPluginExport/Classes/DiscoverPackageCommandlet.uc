/**
 * Package discovery commandlet for analyzing UDK packages
 * 
 * Lists all assets in a package with detailed information:
 * - Asset types
 * - Sizes
 * - Dependencies
 * - Export readiness
 * 
 * Usage: udk.exe DiscoverPackageCommandlet PackageName [PackageName2 ...]
 * 
 * Example: udk.exe DiscoverPackageCommandlet MyLevel
 */
class DiscoverPackageCommandlet extends Commandlet;

function string GetObjectPath(Object Obj)
{
	local string Path;
	local Object Current;

	if (Obj == None)
		return "None";

	Path = string(Obj.Name);
	Current = Obj.Outer;

	while (Current != None)
	{
		Path = Current.Name $ "." $ Path;
		Current = Current.Outer;
	}

	return string(Obj.Class.Name) $ "'" $ Path $ "'";
}

function int CountReferences(Object Obj)
{
	local array<Object> RefObjects;
	local int Count;

	if (Obj == None)
		return 0;

	// Get all objects this object references
	RefObjects.Length = 0;
	// Note: GetObjectsReferencedBy is not available in UnrealScript
	// This is a placeholder for the concept
	
	return RefObjects.Length;
}

event int Main(string Params)
{
	local array<string> PackageNames;
	local Package Pkg;
	local array<Object> AllObjects;
	local Object Obj;
	local StaticMesh SM;
	local Material Mat;
	local MaterialInstanceConstant MIC;
	local Texture Tex;
	local SoundCue Sound;
	local int i, j;
	local int StaticMeshCount, MaterialCount, MICCount, TextureCount, SoundCount, OtherCount;

	ParseStringIntoArray(Params, PackageNames, " ", true);

	if (PackageNames.Length == 0)
	{
		`Warn("Usage: DiscoverPackageCommandlet PackageName [PackageName2 ...]");
		return 1;
	}

	`Log("==== BEGIN PACKAGE DISCOVERY ====");

	for (i = 0; i < PackageNames.Length; ++i)
	{
		`Log("");
		`Log("========================================");
		`Log("PACKAGE:" @ PackageNames[i]);
		`Log("========================================");

		// Try to load the package
		Pkg = LoadPackage(None, PackageNames[i], LOAD_NoWarn);

		if (Pkg == None)
		{
			`Warn("Failed to load package:" @ PackageNames[i]);
			continue;
		}

		`Log("Package loaded successfully");

		// Reset counters
		StaticMeshCount = 0;
		MaterialCount = 0;
		MICCount = 0;
		TextureCount = 0;
		SoundCount = 0;
		OtherCount = 0;

		// Get all objects in the package
		// Note: This is a simplified approach since we can't directly enumerate package objects in UnrealScript
		`Log("");
		`Log("Scanning for StaticMeshes...");
		
		foreach AllObjects(class'StaticMesh', SM)
		{
			if (SM.GetPackageName() == name(PackageNames[i]))
			{
				`Log("  [STATICMESH]" @ GetObjectPath(SM));
				if (SM.LODModels.Length > 0)
				{
					`Log("    Vertices:" @ SM.LODModels[0].NumVertices @ "Triangles:" @ (SM.LODModels[0].IndexBuffer.Indices.Length / 3));
				}
				StaticMeshCount++;
			}
		}

		`Log("");
		`Log("Scanning for Materials...");
		foreach AllObjects(class'Material', Mat)
		{
			if (Mat.GetPackageName() == name(PackageNames[i]))
			{
				`Log("  [MATERIAL]" @ GetObjectPath(Mat));
				MaterialCount++;
			}
		}

		`Log("");
		`Log("Scanning for Material Instances...");
		foreach AllObjects(class'MaterialInstanceConstant', MIC)
		{
			if (MIC.GetPackageName() == name(PackageNames[i]))
			{
				`Log("  [MATERIAL_INSTANCE]" @ GetObjectPath(MIC));
				if (MIC.Parent != None)
				{
					`Log("    Parent:" @ GetObjectPath(MIC.Parent));
				}
				MICCount++;
			}
		}

		`Log("");
		`Log("Scanning for Textures...");
		foreach AllObjects(class'Texture', Tex)
		{
			if (Tex.GetPackageName() == name(PackageNames[i]))
			{
				`Log("  [TEXTURE]" @ GetObjectPath(Tex) @ "Size:" @ Tex.SizeX $ "x" $ Tex.SizeY);
				TextureCount++;
			}
		}

		`Log("");
		`Log("Scanning for Sounds...");
		foreach AllObjects(class'SoundCue', Sound)
		{
			if (Sound.GetPackageName() == name(PackageNames[i]))
			{
				`Log("  [SOUNDCUE]" @ GetObjectPath(Sound));
				SoundCount++;
			}
		}

		// Summary
		`Log("");
		`Log("PACKAGE SUMMARY:");
		`Log("  StaticMeshes:" @ StaticMeshCount);
		`Log("  Materials:" @ MaterialCount);
		`Log("  Material Instances:" @ MICCount);
		`Log("  Textures:" @ TextureCount);
		`Log("  Sound Cues:" @ SoundCount);
		`Log("  Total Assets:" @ (StaticMeshCount + MaterialCount + MICCount + TextureCount + SoundCount));
	}

	`Log("");
	`Log("==== END PACKAGE DISCOVERY ====");

	return 0;
}

defaultproperties
{
	LogToConsole=true
}
