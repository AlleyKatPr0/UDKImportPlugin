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
	// TODO: Create progress dialog for UE5
	// Can use SNotificationItem for non-modal feedback
}

FUDKImportProgressReporterUI::~FUDKImportProgressReporterUI()
{
	// TODO: Close progress dialog
}

void FUDKImportProgressReporterUI::UpdateProgress(const FText& Message, float Progress)
{
	// Log to output as well
	UE_LOG(LogUDKImportProgress, Log, TEXT("[%d%%] %s"), FMath::RoundToInt(Progress * 100.0f), *Message.ToString());
	
	// TODO: Update progress dialog
}

bool FUDKImportProgressReporterUI::IsCancelled() const
{
	return bCancelled;
}

void FUDKImportProgressReporterUI::LogWarning(const FText& Message)
{
	UE_LOG(LogUDKImportProgress, Warning, TEXT("%s"), *Message.ToString());
	Warnings.Add(Message);
	
	// TODO: Display in progress dialog
}

void FUDKImportProgressReporterUI::LogError(const FText& Message)
{
	UE_LOG(LogUDKImportProgress, Error, TEXT("%s"), *Message.ToString());
	Errors.Add(Message);
	
	// TODO: Display in progress dialog
}
