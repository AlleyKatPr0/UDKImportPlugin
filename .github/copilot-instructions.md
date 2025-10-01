# Copilot Instructions for UDKImportPlugin

## Project Overview
- **UDKImportPlugin** is an Unreal Engine 4 editor module for migrating maps and assets from Unreal Development Kit (UDK) to UE4, primarily for Stargate Network and Stargate No Limits teams.
- Major features: migration of Brushes, StaticMeshes, Materials, Textures, PointLights, SpotLights.
- Limitations: Brush CSG order is lost; StaticMeshes auto-export as OBJ (not valid FBX from UDK), requiring manual conversion to FBX using Autodesk FBX Converter 2013 (32-bit).

## Architecture & Key Files
- **Source/UDKImportPlugin/**: Main plugin code
  - `T3DLevelParser.*`, `T3DMaterialParser.*`, `T3DMaterialInstanceConstantParser.*`, `T3DParser.*`: Parsers for UDK T3D map and material formats
  - `SUDKImportScreen.*`: UI for import tool
  - `UDKImportPlugin.cpp`, `UDKImportPlugin.Build.cs`: Plugin entry and build config
  - `UDKImportPluginSettings.*`: Plugin configuration system (NEW in v2.0)
  - `UDKImportProgressReporter.*`: Progress reporting infrastructure (NEW in v2.0)
- **UDKPluginExport/**: UDK-side commandlets for exporting asset information
  - `ExportStaticMeshMaterialsCommandlet.uc`: Enhanced material/LOD/collision export
  - `ValidateExportReadinessCommandlet.uc`: Pre-export validation (NEW)
  - `DiscoverPackageCommandlet.uc`: Package asset discovery (NEW)
  - `BatchExportStaticMeshFBXCommandlet.uc`: Experimental FBX export (NEW)
  - `README.md`: Comprehensive commandlet documentation
- **Resources/**: Plugin icon

## Developer Workflows
- **UDK Commandlet Setup**: Copy `UDKPluginExport` to `UDKPath/Development/Src`, update `DefaultEngineUDK.ini` (`ModEditPackages=UDKPluginExport`), run `UDK.exe make` to build commandlets.
- **UDK Commandlet Usage**:
  - `ValidateExportReadinessCommandlet`: Check assets before export for issues
  - `DiscoverPackageCommandlet`: List all assets in a package for migration planning
  - `ExportStaticMeshMaterialsCommandlet`: Export mesh metadata (LODs, materials, collision)
  - See `UDKPluginExport/README.md` for full commandlet documentation
- **Plugin Installation**: Place in `MyProject/Plugins/UDKImportPlugin`, generate Visual Studio project, build via UE4/5 editor startup, activate in Plugin Manager.
- **Compatibility**: Updated for UE 4.27-5.6+ with modern APIs (ToolMenus, FAppStyle/FEditorStyle version guards, PCHUsageMode)
- **Import Workflow**:
  1. Use UDK commandlets to validate and discover assets
  2. Configure tool in UE4/5 (via UI or Project Settings)
  3. Run import, check logs for errors
  4. Manually export StaticMeshes from UDK as FBX (auto-exported OBJ is fallback)
  5. Rerun import after FBX export
- **Manual Steps**: Use UDK Content Browser to export assets as FBX. Keyboard macro `{TAB}{f}{ENTER}` recommended for batch export.
- **Temporary Directory**: `ExportedMeshes` folder is reused between runs; only clear if UDK packages change or after plugin update.

## Patterns & Conventions
- **Parsing**: All UDK asset and map parsing logic is in `Private/` parser classes; follow their structure for new asset types.
- **UI**: Import tool UI logic is in `SUDKImportScreen.*`.
- **Error Handling**: Check logs after each import run; most errors relate to missing FBX files or brush order.
- **External Tools**: Autodesk FBX Converter 2013 (32-bit) is required for OBJ to FBX conversion.

## Integration Points
- **UDK**: Requires custom commandlet for static mesh material info
- **UE4**: Plugin integrates via standard UE4 plugin system; entry point is `UDKImportPlugin.cpp`

## Example: Adding a New Asset Type
- Create a new parser class in `Private/` (e.g., `T3DNewAssetParser.cpp/h`)
- Register and invoke from main import logic in `T3DLevelParser.cpp`

---

For questions about build, install, or asset export, see `README.md`.
