@echo off
REM Build and Deploy FBXExportModule for UDK
REM This script automates the build and deployment process

echo ========================================
echo  FBXExportModule Build Script
echo ========================================
echo.

REM Configuration
set UDK_PATH=D:\UDK\Custom
set MODULE_PATH=%~dp0
set BUILD_CONFIG=Release
set PLATFORM=Win32

echo Configuration:
echo   UDK Path: %UDK_PATH%
echo   Module Path: %MODULE_PATH%
echo   Build Config: %BUILD_CONFIG%
echo   Platform: %PLATFORM%
echo.

REM Check if UDK path exists
if not exist "%UDK_PATH%" (
    echo ERROR: UDK path not found: %UDK_PATH%
    echo Please edit this script and set the correct UDK_PATH
    pause
    exit /b 1
)

REM Check if Visual Studio is available
where msbuild >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: MSBuild not found. Please ensure Visual Studio is installed
    echo and run this from a Visual Studio Developer Command Prompt
    pause
    exit /b 1
)

echo Step 1: Building FBXExportModule.dll...
echo.

REM Build the project
msbuild "%MODULE_PATH%FBXExportModule.vcxproj" /p:Configuration=%BUILD_CONFIG% /p:Platform=%PLATFORM% /v:minimal

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo Step 2: Deploying DLL to UDK...
echo.

REM Check if DLL was built
set DLL_PATH=%MODULE_PATH%%BUILD_CONFIG%\FBXExportModule.dll
if not exist "%DLL_PATH%" (
    echo ERROR: Built DLL not found at: %DLL_PATH%
    pause
    exit /b 1
)

REM Copy DLL to UDK binaries
set TARGET_PATH=%UDK_PATH%\Binaries\Win32\FBXExportModule.dll
copy /Y "%DLL_PATH%" "%TARGET_PATH%"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to copy DLL to UDK binaries
    pause
    exit /b 1
)

echo DLL deployed successfully to: %TARGET_PATH%
echo.

echo Step 3: Rebuilding UDK scripts...
echo.

REM Rebuild UDK scripts
cd /d "%UDK_PATH%\Binaries\Win32"
UDK.exe make

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo WARNING: UDK script rebuild failed or had errors
    echo The DLL is deployed but you may need to rebuild scripts manually
    echo.
)

echo.
echo ========================================
echo  BUILD COMPLETE
echo ========================================
echo.
echo The native FBX export module is now ready to use!
echo.
echo Usage:
echo   cd %UDK_PATH%\Binaries\Win32
echo   UDK.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/MyMesh.fbx
echo.
echo Press any key to exit...
pause >nul
