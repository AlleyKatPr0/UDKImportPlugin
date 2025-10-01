#include "UDKImportPluginPrivatePCH.h"
#include "SUDKImportScreen.h"
#include "ToolMenus.h"

// Version-specific style access
#if ENGINE_MAJOR_VERSION >= 5
	#define STYLE_SET_NAME FAppStyle::GetAppStyleSetName()
	#define GET_BRUSH(name) FAppStyle::GetBrush(name)
#else
	#define STYLE_SET_NAME FEditorStyle::GetStyleSetName()
	#define GET_BRUSH(name) FEditorStyle::GetBrush(name)
#endif

#define LOCTEXT_NAMESPACE "UDKImportPlugin"

class FUDKImportPlugin : public IUDKImportPlugin
{
private:
	/** IModuleInterface implementation */
	virtual void StartupModule() override;
	virtual void ShutdownModule() override;

	/** Add the menu extension for summoning the UDK Import tools */
	void RegisterMenus();

	/** Summon UDK Import page to front */
	void SummonUDKImport();

	/** ID name for the plugins editor major tab */
	static const FName UDKImportPluginTabName;
};

IMPLEMENT_MODULE(FUDKImportPlugin, UDKImportPlugin)

const FName FUDKImportPlugin::UDKImportPluginTabName(TEXT("UDKImportPlugin"));

void FUDKImportPlugin::StartupModule()
{
	// This code can run with content commandlets. Slate is not initialized with commandlets and the below code will fail.
	if (!IsRunningCommandlet())
	{
		// Register menus after editor is initialized
		UToolMenus::RegisterStartupCallback(FSimpleMulticastDelegate::FDelegate::CreateRaw(this, &FUDKImportPlugin::RegisterMenus));
	}
}

void FUDKImportPlugin::RegisterMenus()
{
	// Owner for cleanup
	FToolMenuOwnerScoped OwnerScoped(this);

	// Add menu entry to Help menu
	UToolMenu* Menu = UToolMenus::Get()->ExtendMenu("LevelEditor.MainMenu.Help");
	if (Menu)
	{
		FToolMenuSection& Section = Menu->FindOrAddSection("HelpBrowse");
		Section.AddMenuEntry(
			"UDKImport",
			LOCTEXT("UDKImportMenuEntryTitle", "UDK Import"),
			LOCTEXT("UDKImportMenuEntryToolTip", "Opens up a tool for importing UDK maps."),
			FSlateIcon(STYLE_SET_NAME, "LevelEditor.Tutorials"),
			FUIAction(FExecuteAction::CreateRaw(this, &FUDKImportPlugin::SummonUDKImport))
		);
	}
}

void FUDKImportPlugin::SummonUDKImport()
{
	const FText UDKImportWindowTitle = LOCTEXT("UDKImportWindowTitle", "UDK Map importation tool");

	TSharedPtr<SWindow> UDKImportWindow =
		SNew(SWindow)
		.Title(UDKImportWindowTitle)
		.ClientSize(FVector2D(600.f, 150.f))
		.SupportsMaximize(false).SupportsMinimize(false)
		.SizingRule(ESizingRule::FixedSize)
		[
			SNew(SUDKImportScreen)
		];

	FSlateApplication::Get().AddWindow(UDKImportWindow.ToSharedRef());
}

void FUDKImportPlugin::ShutdownModule()
{
	// Unregister menus
	UToolMenus::UnRegisterStartupCallback(this);
	UToolMenus::UnregisterOwner(this);

	// Unregister the tab spawner
	FGlobalTabmanager::Get()->UnregisterTabSpawner(UDKImportPluginTabName);
}

#undef LOCTEXT_NAMESPACE
#undef STYLE_SET_NAME
#undef GET_BRUSH