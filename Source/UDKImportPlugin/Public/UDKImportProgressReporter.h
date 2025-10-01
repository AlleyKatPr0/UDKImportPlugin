#pragma once

#include "CoreMinimal.h"

/**
 * Progress reporting interface for UDK import operations
 * Allows for UI feedback and cancellation support
 */
class UDKIMPORTPLUGIN_API FUDKImportProgressReporter
{
public:
	virtual ~FUDKImportProgressReporter() = default;

	/**
	 * Update progress with a message
	 * @param Message - Status message to display
	 * @param Progress - Progress value (0.0 to 1.0)
	 */
	virtual void UpdateProgress(const FText& Message, float Progress) = 0;

	/**
	 * Check if the operation should be cancelled
	 * @return true if cancellation was requested
	 */
	virtual bool IsCancelled() const = 0;

	/**
	 * Log a warning message
	 * @param Message - Warning message
	 */
	virtual void LogWarning(const FText& Message) = 0;

	/**
	 * Log an error message
	 * @param Message - Error message
	 */
	virtual void LogError(const FText& Message) = 0;
};

/**
 * Default progress reporter that logs to output
 */
class UDKIMPORTPLUGIN_API FUDKImportProgressReporterLog : public FUDKImportProgressReporter
{
public:
	virtual void UpdateProgress(const FText& Message, float Progress) override;
	virtual bool IsCancelled() const override { return false; }
	virtual void LogWarning(const FText& Message) override;
	virtual void LogError(const FText& Message) override;
};

/**
 * Progress reporter with Slate UI feedback
 * TODO: Implement with progress dialog for UE5
 */
class UDKIMPORTPLUGIN_API FUDKImportProgressReporterUI : public FUDKImportProgressReporter
{
public:
	FUDKImportProgressReporterUI();
	virtual ~FUDKImportProgressReporterUI();

	virtual void UpdateProgress(const FText& Message, float Progress) override;
	virtual bool IsCancelled() const override;
	virtual void LogWarning(const FText& Message) override;
	virtual void LogError(const FText& Message) override;

private:
	bool bCancelled;
	TArray<FText> Warnings;
	TArray<FText> Errors;
};
