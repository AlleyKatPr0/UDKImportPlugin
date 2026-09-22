#include "UDKImportPluginPrivatePCH.h"
#include "UDKImportProgressReporter.h"

DEFINE_LOG_CATEGORY_STATIC(LogUDKImportProgress, Log, All);

void FUDKImportProgressReporterLog::UpdateProgress(const FText& Message, float Progress)
{
	UE_LOG(LogUDKImportProgress, Log, TEXT("[%d%%] %s"), FMath::RoundToInt(Progress * 100.0f), *Message.ToString());
}

void FUDKImportProgressReporterLog::LogWarning(const FText& Message)
{
	UE_LOG(LogUDKImportProgress, Warning, TEXT("%s"), *Message.ToString());
}

void FUDKImportProgressReporterLog::LogError(const FText& Message)
{
	UE_LOG(LogUDKImportProgress, Error, TEXT("%s"), *Message.ToString());
}

// UI Reporter implementation
FUDKImportProgressReporterUI::FUDKImportProgressReporterUI()
	: bCancelled(false)
{
	GWarn->BeginSlowTask(LOCTEXT("UDKImportProgress", "Importing UDK content..."), true, false);
}

FUDKImportProgressReporterUI::~FUDKImportProgressReporterUI()
{
	GWarn->EndSlowTask();
}

void FUDKImportProgressReporterUI::UpdateProgress(const FText& Message, float Progress)
{
	UE_LOG(LogUDKImportProgress, Log, TEXT("[%d%%] %s"), FMath::RoundToInt(Progress * 100.0f), *Message.ToString());
	GWarn->StatusUpdate(FMath::RoundToInt(Progress * 100.0f), 100, Message);
	bCancelled = GWarn->ReceivedUserCancel();
}

bool FUDKImportProgressReporterUI::IsCancelled() const
{
	return bCancelled;
}

void FUDKImportProgressReporterUI::LogWarning(const FText& Message)
{
	UE_LOG(LogUDKImportProgress, Warning, TEXT("%s"), *Message.ToString());
	Warnings.Add(Message);
	GWarn->Logf(ELogVerbosity::Warning, TEXT("%s"), *Message.ToString());
}

void FUDKImportProgressReporterUI::LogError(const FText& Message)
{
	UE_LOG(LogUDKImportProgress, Error, TEXT("%s"), *Message.ToString());
	Errors.Add(Message);
	GWarn->Logf(ELogVerbosity::Error, TEXT("%s"), *Message.ToString());
}
