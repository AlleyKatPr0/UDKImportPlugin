using UnrealBuildTool;
using System.IO;
 
public class UDKImportPlugin : ModuleRules
{
	public UDKImportPlugin(ReadOnlyTargetRules Target) : base(Target)
	{
		// PCH usage for compatibility with UE5
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
		
		// Faster compilation with unity builds
		bUseUnity = true;

		PublicDependencyModuleNames.AddRange(
			new string[] {
				"Core",
				"CoreUObject",
				"Engine",
				"InputCore",
				"Slate",
				"SlateCore"
			}
		);
		
		PrivateDependencyModuleNames.AddRange(
			new string[] {
				"UnrealEd",
				"LevelEditor",
				"AssetTools",
				"EditorSubsystem",
				"Projects",
				"ToolMenus",
				"EditorFramework",
				"PropertyEditor",
				"DesktopPlatform",
				"ContentBrowser"
			}
		);

		// Conditional module dependencies for different engine versions
		if (Target.Version.MajorVersion == 5)
		{
			// UE5-specific modules
			PrivateDependencyModuleNames.AddRange(
				new string[] {
					"EditorStyle"
				}
			);
		}
		else
		{
			// UE4-specific modules
			PrivateDependencyModuleNames.AddRange(
				new string[] {
					"EditorStyle"
				}
			);
		}
	}
}