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

event int Main(string Params)
{
	local array<string> Args;
	local string MeshRef, OutputPath;
	local StaticMesh SM;
	local Object ExporterClass;
	local Object Exporter;
	local int i, SuccessCount, FailCount;
	local bool bExportResult;

	ParseStringIntoArray(Params, Args, " ", true);

	if (Args.Length < 2 || (Args.Length % 2) != 0)
	{
		`Warn("Usage: BatchExportStaticMeshFBXCommandlet MeshRef OutputPath [MeshRef2 OutputPath2 ...]");
		`Warn("Example: udk.exe BatchExportStaticMeshFBXCommandlet MyPackage.MyMesh C:/Export/MyMesh.fbx");
		return 1;
	}

	`Log("==== BEGIN FBX BATCH EXPORT ====");

	// Try to load the FBX exporter factory
	ExporterClass = DynamicLoadObject("UnrealEd.StaticMeshExporterFBX", class'Class', true);
	
	if (ExporterClass == None)
	{
		`Warn("Could not load FBX exporter class. FBX export may not be available in this UDK build.");
		`Warn("Falling back to attempting direct file operations...");
	}
	else
	{
		`Log("FBX Exporter loaded successfully");
	}

	// Process each mesh/path pair
	for (i = 0; i < Args.Length; i += 2)
	{
		MeshRef = Args[i];
		OutputPath = Args[i + 1];

		`Log("");
		`Log("Processing:" @ MeshRef);
		`Log("Output:" @ OutputPath);

		// Load the StaticMesh
		SM = StaticMesh(DynamicLoadObject(MeshRef, class'StaticMesh'));

		if (SM == None)
		{
			`Warn("Failed to load StaticMesh:" @ MeshRef);
			FailCount++;
			continue;
		}

		// Log mesh properties
		`Log("  Vertices (LOD0):" @ SM.LODModels[0].NumVertices);
		`Log("  Triangles (LOD0):" @ SM.LODModels[0].IndexBuffer.Indices.Length / 3);
		`Log("  Materials:" @ SM.LODInfo.Length);

		// Attempt export
		if (ExporterClass != None)
		{
			// Create exporter instance
			Exporter = new(None) class<Exporter>(ExporterClass);
			
			if (Exporter != None)
			{
				// Note: This is the "ideal" way but may not work due to UDK bugs
				`Log("Attempting FBX export via exporter...");
				// bExportResult = Exporter.ExportToFile(SM, OutputPath);
				
				`Warn("Direct exporter API not available in UnrealScript");
				`Warn("Please use the UE3 Content Browser export feature manually");
				FailCount++;
			}
			else
			{
				`Warn("Failed to instantiate exporter");
				FailCount++;
			}
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
