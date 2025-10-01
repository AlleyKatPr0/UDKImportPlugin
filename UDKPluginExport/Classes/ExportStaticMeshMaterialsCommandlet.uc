/**
 * Enhanced commandlet for exporting StaticMesh material and LOD information
 * Usage: udk.exe ExportStaticMeshMaterialsCommandlet Package.MeshName Package.MeshName2 ...
 * 
 * Improvements:
 * - Exports LOD information
 * - Exports UV channel count
 * - Exports collision information
 * - Better error handling
 * - JSON-style structured output for easier parsing
 */
class ExportStaticMeshMaterialsCommandlet extends Commandlet;

function string FullName(Object O)
{
	local string Url;
	local string ClassName;

	if (O == None)
	{
		return "None";
	}

	ClassName = string(O.Class);
	Url = string(O.Name);

	O = O.Outer;
	while (O != None)
	{
		Url = O.Name $ "." $ Url;
		O = O.Outer;
	}

	return ClassName $ "'" $ Url$ "'";
}

event int Main(string Params)
{
	local array<string> References;
	local StaticMesh SM;
	local StaticMeshComponent SMC;
	local int i, j;
	local int SuccessCount, FailCount;

	ParseStringIntoArray(Params, References, " ", true);

	if (References.Length == 0)
	{
		`Warn("No StaticMesh references provided");
		return 1;
	}

	`Log("==== BEGIN STATICMESH EXPORT ====");
	`Log("Exporting" @ References.Length @ "StaticMesh(es)");

	SMC = new (self) class'StaticMeshComponent';

	for (i = 0; i < References.Length; ++i)
	{
		`Log("Processing:" @ References[i]);
		
		SM = StaticMesh(DynamicLoadObject(References[i], class'StaticMesh'));
		
		if (SM == None)
		{
			`Warn("Failed to load:" @ References[i]);
			FailCount++;
			continue;
		}

		// Export mesh metadata
		`Log("MESH_START:" @ References[i]);
		`Log("  LOD_COUNT:" @ SM.LODModels.Length);
		
		// Export material slots
		SMC.SetStaticMesh(SM);
		`Log("  MATERIAL_COUNT:" @ SMC.GetNumElements());
		
		for (j = 0; j < SMC.GetNumElements(); ++j)
		{
			`Log("  MATERIAL[" $ j $ "]:" @ FullName(SMC.GetMaterial(j)));
		}

		// Export LOD info
		for (j = 0; j < SM.LODModels.Length; ++j)
		{
			`Log("  LOD[" $ j $ "].VERTICES:" @ SM.LODModels[j].NumVertices);
			`Log("  LOD[" $ j $ "].TRIANGLES:" @ SM.LODModels[j].IndexBuffer.Indices.Length / 3);
		}

		// Export UV channel count (from LOD 0)
		if (SM.LODModels.Length > 0)
		{
			`Log("  UV_CHANNELS:" @ SM.LODModels[0].VertexBuffer.NumTexCoords);
		}

		// Export collision information
		if (SM.BodySetup != None)
		{
			`Log("  COLLISION.BOX_ELEMS:" @ SM.BodySetup.AggGeom.BoxElems.Length);
			`Log("  COLLISION.SPHERE_ELEMS:" @ SM.BodySetup.AggGeom.SphereElems.Length);
			`Log("  COLLISION.CONVEX_ELEMS:" @ SM.BodySetup.AggGeom.ConvexElems.Length);
		}

		`Log("MESH_END:" @ References[i]);
		SuccessCount++;
	}

	`Log("==== END STATICMESH EXPORT ====");
	`Log("Success:" @ SuccessCount @ "Failed:" @ FailCount);

	return (FailCount > 0) ? 1 : 0;
}

defaultproperties
{
	LogToConsole=true
}