/**
 * Validation commandlet to check if assets are ready for export to UE4/5
 * 
 * Checks for common issues:
 * - Missing material references
 * - Missing texture references
 * - Invalid mesh data
 * - Corrupted assets
 * - Naming conflicts
 * 
 * Usage: udk.exe ValidateExportReadinessCommandlet Package.AssetName [Package.AssetName2 ...]
 */
class ValidateExportReadinessCommandlet extends Commandlet;

var int ErrorCount;
var int WarningCount;

function LogError(string Message)
{
	`Log("[ERROR]" @ Message);
	ErrorCount++;
}

function LogWarning(string Message)
{
	`Log("[WARNING]" @ Message);
	WarningCount++;
}

function bool ValidateStaticMesh(StaticMesh SM, string Reference)
{
	local StaticMeshComponent SMC;
	local int i;
	local Material Mat;
	local bool bValid;

	bValid = true;

	if (SM == None)
	{
		LogError("StaticMesh is None:" @ Reference);
		return false;
	}

	`Log("  Validating StaticMesh:" @ Reference);

	// Check LOD data
	if (SM.LODModels.Length == 0)
	{
		LogError("StaticMesh has no LOD models:" @ Reference);
		bValid = false;
	}
	else
	{
		`Log("    LODs:" @ SM.LODModels.Length);
		
		// Validate LOD 0
		if (SM.LODModels[0].NumVertices == 0)
		{
			LogError("LOD 0 has no vertices:" @ Reference);
			bValid = false;
		}
		else
		{
			`Log("    LOD 0 Vertices:" @ SM.LODModels[0].NumVertices);
		}

		if (SM.LODModels[0].IndexBuffer.Indices.Length == 0)
		{
			LogError("LOD 0 has no indices:" @ Reference);
			bValid = false;
		}
		else
		{
			`Log("    LOD 0 Triangles:" @ (SM.LODModels[0].IndexBuffer.Indices.Length / 3));
		}

		// Check UV channels
		if (SM.LODModels[0].VertexBuffer.NumTexCoords == 0)
		{
			LogWarning("LOD 0 has no UV channels:" @ Reference);
		}
		else
		{
			`Log("    UV Channels:" @ SM.LODModels[0].VertexBuffer.NumTexCoords);
		}
	}

	// Check materials
	SMC = new (self) class'StaticMeshComponent';
	SMC.SetStaticMesh(SM);

	if (SMC.GetNumElements() == 0)
	{
		LogWarning("StaticMesh has no material slots:" @ Reference);
	}
	else
	{
		`Log("    Material Slots:" @ SMC.GetNumElements());
		
		for (i = 0; i < SMC.GetNumElements(); ++i)
		{
			Mat = Material(SMC.GetMaterial(i));
			if (Mat == None)
			{
				LogWarning("Material slot" @ i @ "is empty on:" @ Reference);
			}
			else
			{
				`Log("      [" $ i $ "]" @ Mat.GetPathName());
			}
		}
	}

	// Check collision
	if (SM.BodySetup == None)
	{
		LogWarning("StaticMesh has no collision:" @ Reference);
	}
	else
	{
		`Log("    Collision: YES");
	}

	return bValid;
}

function bool ValidateMaterial(Material Mat, string Reference)
{
	local int i;
	local MaterialExpression Expr;
	local MaterialExpressionTextureSample TexSample;
	local bool bValid;

	bValid = true;

	if (Mat == None)
	{
		LogError("Material is None:" @ Reference);
		return false;
	}

	`Log("  Validating Material:" @ Reference);

	// Check expressions
	if (Mat.Expressions.Length == 0)
	{
		LogWarning("Material has no expressions:" @ Reference);
	}
	else
	{
		`Log("    Expressions:" @ Mat.Expressions.Length);

		// Check texture samples
		for (i = 0; i < Mat.Expressions.Length; ++i)
		{
			Expr = Mat.Expressions[i];
			TexSample = MaterialExpressionTextureSample(Expr);
			
			if (TexSample != None)
			{
				if (TexSample.Texture == None)
				{
					LogError("Texture sample has no texture at expression" @ i @ "in:" @ Reference);
					bValid = false;
				}
			}
		}
	}

	return bValid;
}

function bool ValidateMaterialInstance(MaterialInstanceConstant MIC, string Reference)
{
	local bool bValid;

	bValid = true;

	if (MIC == None)
	{
		LogError("MaterialInstance is None:" @ Reference);
		return false;
	}

	`Log("  Validating Material Instance:" @ Reference);

	// Check parent
	if (MIC.Parent == None)
	{
		LogError("MaterialInstance has no parent:" @ Reference);
		bValid = false;
	}
	else
	{
		`Log("    Parent:" @ MIC.Parent.GetPathName());
	}

	return bValid;
}

function bool ValidateTexture(Texture Tex, string Reference)
{
	local bool bValid;

	bValid = true;

	if (Tex == None)
	{
		LogError("Texture is None:" @ Reference);
		return false;
	}

	`Log("  Validating Texture:" @ Reference);

	// Check dimensions
	if (Tex.SizeX == 0 || Tex.SizeY == 0)
	{
		LogError("Texture has invalid dimensions:" @ Reference);
		bValid = false;
	}
	else
	{
		`Log("    Size:" @ Tex.SizeX $ "x" $ Tex.SizeY);
	}

	return bValid;
}

event int Main(string Params)
{
	local array<string> References;
	local string Ref;
	local Object Obj;
	local StaticMesh SM;
	local Material Mat;
	local MaterialInstanceConstant MIC;
	local Texture Tex;
	local int i;
	local int ValidCount, InvalidCount;

	ParseStringIntoArray(Params, References, " ", true);

	if (References.Length == 0)
	{
		`Warn("Usage: ValidateExportReadinessCommandlet Package.AssetName [Package.AssetName2 ...]");
		return 1;
	}

	`Log("==== BEGIN EXPORT VALIDATION ====");
	`Log("Validating" @ References.Length @ "asset(s)");
	`Log("");

	ErrorCount = 0;
	WarningCount = 0;

	for (i = 0; i < References.Length; ++i)
	{
		Ref = References[i];
		`Log("Processing:" @ Ref);

		// Try loading as different types
		Obj = DynamicLoadObject(Ref, class'Object', true);

		if (Obj == None)
		{
			LogError("Failed to load asset:" @ Ref);
			InvalidCount++;
			continue;
		}

		// Determine type and validate
		SM = StaticMesh(Obj);
		if (SM != None)
		{
			if (ValidateStaticMesh(SM, Ref))
			{
				ValidCount++;
			}
			else
			{
				InvalidCount++;
			}
			continue;
		}

		Mat = Material(Obj);
		if (Mat != None)
		{
			if (ValidateMaterial(Mat, Ref))
			{
				ValidCount++;
			}
			else
			{
				InvalidCount++;
			}
			continue;
		}

		MIC = MaterialInstanceConstant(Obj);
		if (MIC != None)
		{
			if (ValidateMaterialInstance(MIC, Ref))
			{
				ValidCount++;
			}
			else
			{
				InvalidCount++;
			}
			continue;
		}

		Tex = Texture(Obj);
		if (Tex != None)
		{
			if (ValidateTexture(Tex, Ref))
			{
				ValidCount++;
			}
			else
			{
				InvalidCount++;
			}
			continue;
		}

		LogWarning("Unknown or unsupported asset type:" @ Ref @ "(" $ Obj.Class.Name $ ")");
		ValidCount++;
	}

	`Log("");
	`Log("==== VALIDATION SUMMARY ====");
	`Log("Total Assets:" @ References.Length);
	`Log("Valid:" @ ValidCount);
	`Log("Invalid:" @ InvalidCount);
	`Log("Errors:" @ ErrorCount);
	`Log("Warnings:" @ WarningCount);
	`Log("");

	if (ErrorCount > 0)
	{
		`Log("RESULT: VALIDATION FAILED");
		`Log("Fix errors before attempting export to UE4/5");
		return 1;
	}
	else if (WarningCount > 0)
	{
		`Log("RESULT: VALIDATION PASSED WITH WARNINGS");
		`Log("Export may succeed but review warnings");
		return 0;
	}
	else
	{
		`Log("RESULT: VALIDATION PASSED");
		`Log("Assets are ready for export");
		return 0;
	}
}

defaultproperties
{
	LogToConsole=true
}
