UDK Import Plugin for Unreal Engine (4.27 — 5.6+)
=================================================

UDKImportPlugin is an editor plugin that helps migrate maps and assets from the Unreal Development Kit (UDK) into Unreal Engine 4.27 up through UE5.6+. It focuses on practical, repeatable import workflows for static geometry, materials, textures, and lights while integrating enhanced UDK-side commandlets to produce useful export metadata.

Quick summary
- Purpose: Migrate UDK maps and assets into UE4/UE5 projects.
- Primary targets: Brushes, StaticMeshes, Materials, Textures, PointLights, SpotLights.
- Supported engines: UE 4.27 — UE 5.6+ (modern API usage).
- Platforms: Windows, macOS, Linux (editor must run on platform-specific supported builds).

Key features
- Parses UDK T3D maps and material data to recreate assets and material setups.
- Integrates UDK-side commandlets that export mesh metadata (LODs, UVs, material slots, collision).
- Automatic OBJ export fallback from UDK; prefers FBX when available for higher-quality mesh import.
- UI: Editor tool accessible via Help > UDK Import and Project Settings > Plugins > UDK Import Plugin.
- Progress reporting and configuration via plugin settings.

Known limitations
- Brush CSG order is not preserved; manual reordering of brushes is usually required.
- UDK batch FBX export is unreliable; the plugin exports OBJ by default. Convert OBJ→FBX externally (Autodesk FBX Converter 2013 (32-bit) recommended) or export FBX manually from the UDK Content Browser.
- Some complex map constructs or custom UDK-only features may not import cleanly.

Prerequisites
- Unreal Engine 4.27 — 5.6+ project.
- If you rely on automated OBJ→FBX conversion: Autodesk FBX Converter 2013 (32-bit).
- UDK installation with Development/Make support to build commandlets (if you will use provided UDK commandlets).

UDK commandlet integration (recommended)
1. Copy UDKPluginExport into your UDK source:
   - Place the folder at: UDKPath/Development/Src/UDKPluginExport
2. Add to DefaultEngineUDK.ini:
   - Under [UnrealEd.EditorEngine] add: ModEditPackages=UDKPluginExport
3. Build UDK commandlets:
   - Run: UDKPath/Binaries/Win32/UDK.exe make

Available UDK commandlets (bundled)
- ExportStaticMeshMaterialsCommandlet
  - Exports mesh metadata (material assignments, LODs, UV channels, collision).
  - Example usage: UDK.exe ExportStaticMeshMaterialsCommandlet Package.MeshName
- ValidateExportReadinessCommandlet (new)
  - Performs pre-export checks for missing materials, invalid meshes, broken refs.
  - Example: UDK.exe ValidateExportReadinessCommandlet Package.AssetName
- DiscoverPackageCommandlet (new)
  - Lists assets contained in a package to aid planning.
  - Example: UDK.exe DiscoverPackageCommandlet PackageName
- BatchExportStaticMeshFBXCommandlet (experimental)
  - Attempts automated FBX export (UDK FBX export is known to be flaky).
  - Example: UDK.exe BatchExportStaticMeshFBXCommandlet Package.Mesh OutputPath.fbx
Note: Manual FBX export via the Content Browser is generally more reliable.

Plugin installation (UE project)
1. Create MyProject/Plugins if missing.
2. Clone or copy this repo into: MyProject/Plugins/UDKImportPlugin
3. Regenerate project files: Right‑click .uproject → Generate Visual Studio project files.
4. Open the project; the editor will build the plugin.
5. Enable: Edit → Plugins → Import → UDK Import Plugin. Restart the editor.
6. Access: Help → UDK Import or Project Settings → Plugins → UDK Import Plugin.

Typical import workflow
1. Configure plugin
   - Set UDK path, temporary export folder (default: ExportedMeshes), and FBX/import options in the plugin settings or the UI.
2. Run a first parse
   - Run importer to parse T3D files and produce an export list and logs. Inspect Output Log or Saved/Logs/<Project>.log.
3. Export StaticMeshes from UDK (manual)
   - In ExportedMeshes you'll see package folders with OBJ + metadata. Export higher-quality FBX from the UDK Content Browser into those same package folders. The importer prefers FBX over OBJ.
   - Tip for batch UI export: use a keyboard macro such as {TAB}{f}{ENTER}.
4. Re-run importer
   - With FBX files present the importer will prefer them and import better mesh geometry.
5. Troubleshoot
   - Check filenames/paths against the log. If FBX fails, re-export from UDK or convert the OBJ with Autodesk FBX Converter and place the FBX beside the OBJ/metadata.

Tips and best practices
- Start the import into a new empty map — the plugin does not create a map automatically.
- Do not clear the ExportedMeshes temporary folder unless UDK packages change or the plugin is updated.
- Save exported FBX files alongside OBJ/metadata to avoid repeated exports.
- Use the UDK commandlets to validate and discover package contents before bulk export.
- Keep an eye on the output log for missing asset references and required manual steps.

Extending and development notes
- Parser classes live under Source/UDKImportPlugin/Private (e.g., T3DLevelParser.*, T3DMaterialParser.*). Add new asset types by implementing a parser in Private and registering it in T3DLevelParser.
- UI code is in SUDKImportScreen.*.
- Plugin entry points: UDKImportPlugin.cpp and UDKImportPlugin.Build.cs.
- Settings and progress reporting are implemented in UDKImportPluginSettings.* and UDKImportProgressReporter.* (introduced in v2.0).

License
This project is distributed under the GNU General Public License; it is provided AS IS without warranty of merchantability or fitness for a particular purpose. See the license text in the repository for details.

Contact and docs
- See the repository README and the UDKPluginExport/README.md for in-depth commandlet usage and debugging tips.
- For build/install questions, consult the top-level README and the included copilot instructions.

