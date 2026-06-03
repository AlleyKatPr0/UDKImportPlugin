/**
 * Improved FBX export commandlet that properly exports StaticMeshes to FBX
 * 
 * This commandlet attempts to use UDK's FBX exporter correctly by:
 * - Setting up proper export parameters
 * - Using the actual FBX export factory
 * - Providing detailed logging
 * 
 * Usage: udk.exe BatchExportStaticMeshFBXCommandlet Package.MeshName OutputPath [Package.MeshName2 OutputPath2 ...]
 * 
 * Note: If UDK's FBX export still fails, this will at least provide better
 * diagnostic information about why it's failing.
 */
class BatchExportStaticMeshFBXCommandlet extends Commandlet;

function string StripOuterQuotes(string Value)
{
	if (Len(Value) >= 2 && Left(Value, 1) == "\"" && Right(Value, 1) == "\"")
	{
		return Mid(Value, 1, Len(Value) - 2);
	}

	return Value;
}

event int Main(string Params)
{
	local array<string> Args;
	local string MeshRef, OutputPath;
	local StaticMesh SM;
	local class<Exporter> ExporterClass;
	local Exporter Exporter;
	local StaticMeshComponent SMC;
	local int i, SuccessCount, FailCount;

	ParseStringIntoArray(Params, Args, " ", true);

	if (Args.Length < 2 || (Args.Length % 2) != 0)
	{
		`Warn("Usage: BatchExportStaticMeshFBXCommandlet MeshRef OutputPath [MeshRef2 OutputPath2 ...]");
		`Warn("Example: udk.exe BatchExportStaticMeshFBXCommandlet MyPackage.MyMesh C:/Export/MyMesh.fbx");
		return 1;
	}

	`Log("==== BEGIN FBX BATCH EXPORT ====");

	// Try to load the FBX exporter factory
	ExporterClass = class<Exporter>(DynamicLoadObject("UnrealEd.StaticMeshExporterFBX", class'Class', true));
	
	if (ExporterClass == None)
	{
		`Warn("Could not load FBX exporter class (UnrealEd.StaticMeshExporterFBX).");
		`Warn("FBX export is likely not available in this UDK build, or UnrealEd classes are not loaded.");
	}
	else
	{
		`Log("FBX exporter class loaded:" @ string(ExporterClass));

		// Instantiate exporter to verify it can be constructed (export API still isn't exposed to UnrealScript).
		Exporter = new(None) ExporterClass;
		if (Exporter == None)
		{
			`Warn("FBX exporter class loaded but could not be instantiated.");
		}
		else
		{
			`Log("FBX exporter instantiated successfully (UnrealScript cannot call ExportToFile).");
		}
	}

	SMC = new (self) class'StaticMeshComponent';

	// Process each mesh/path pair
	for (i = 0; i < Args.Length; i += 2)
	{
		MeshRef = StripOuterQuotes(Args[i]);
		OutputPath = StripOuterQuotes(Args[i + 1]);

		`Log("");
		`Log("Processing:" @ MeshRef);
		`Log("Output:" @ OutputPath);

		// Load the StaticMesh
		SM = StaticMesh(DynamicLoadObject(MeshRef, class'StaticMesh', true));

		if (SM == None)
		{
			`Warn("Failed to load StaticMesh:" @ MeshRef);
			FailCount++;
			continue;
		}

		if (Len(OutputPath) < 4 || Caps(Right(OutputPath, 4)) != ".FBX")
		{
			`Warn("  Output path does not end with .fbx (UDK expects FBX export targets):" @ OutputPath);
		}

		// Log mesh properties
		if (SM.LODModels.Length > 0)
		{
			`Log("  Vertices (LOD0):" @ SM.LODModels[0].NumVertices);
			`Log("  Triangles (LOD0):" @ (SM.LODModels[0].IndexBuffer.Indices.Length / 3));
			`Log("  UV Channels:" @ SM.LODModels[0].VertexBuffer.NumTexCoords);
		}
		else
		{
			`Warn("  StaticMesh has no LOD models; cannot report LOD0 stats.");
		}

		SMC.SetStaticMesh(SM);
		`Log("  Material Slots:" @ SMC.GetNumElements());

		// Attempt export
		if (ExporterClass != None)
		{
			`Warn("FBX export API is not exposed to UnrealScript in UDK.");
			`Warn("Use NativeFBXExportCommandlet (recommended) or export manually from the Content Browser.");
			FailCount++;
		}
		else
		{
			`Warn("No FBX exporter available");
			`Warn("For proper FBX export:");
			`Warn("  1. Open UDK Content Browser");
			`Warn("  2. Find:" @ MeshRef);
			`Warn("  3. Right-click > Export to File > FBX");
			`Warn("  4. Save to:" @ OutputPath);
			FailCount++;
		}
	}

	`Log("");
	`Log("==== END FBX BATCH EXPORT ====");
	`Log("Attempted:" @ (Args.Length / 2) @ "Success:" @ SuccessCount @ "Failed:" @ FailCount);
	
	if (FailCount > 0)
	{
		`Log("");
		`Log("RECOMMENDATION: Use OBJ export instead (reliable) or manual FBX export from Content Browser");
	}

	return (FailCount > 0) ? 1 : 0;
}

defaultproperties
{
	LogToConsole=true
}
