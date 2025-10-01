@echo off
REM ========================================
REM  FBXExportModule Multi-Platform Build
REM ========================================
REM
REM Builds FBXExportModule for both Win32 and x64 platforms
REM
REM Usage:
REM   Build_Both.bat           - Build both platforms
REM   Build_Both.bat Win32     - Build Win32 only
REM   Build_Both.bat x64       - Build x64 only
REM
REM ========================================

setlocal enabledelayedexpansion

REM Parse command line
set PLATFORM=%1
if "%PLATFORM%"=="" set PLATFORM=both

echo.
echo ========================================
echo   FBXExportModule Build Script
echo ========================================
echo.

REM Configuration
set UDK_PATH=D:\UDK\Custom
set PROJECT_FILE=FBXExportModule_x64.vcxproj
set BUILD_CONFIG=Release

echo Configuration:
echo   UDK Path: %UDK_PATH%
echo   Project: %PROJECT_FILE%
echo   Build Config: %BUILD_CONFIG%
echo   Platform: %PLATFORM%
echo.

REM Check if UDK exists
if not exist "%UDK_PATH%" (
    echo ERROR: UDK path not found: %UDK_PATH%
    echo.
    echo Please edit this script and set the correct UDK_PATH variable
    pause
    exit /b 1
)

REM Find MSBuild
set MSBUILD_PATH=

echo Searching for Visual Studio...
echo.

REM Try VS 2022
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe
    echo Found: Visual Studio 2022 Community
    goto :found_msbuild
)
if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe
    echo Found: Visual Studio 2022 Professional
    goto :found_msbuild
)
if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe
    echo Found: Visual Studio 2022 Enterprise
    goto :found_msbuild
)

REM Try VS 2019
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe
    echo Found: Visual Studio 2019 Community
    goto :found_msbuild
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe
    echo Found: Visual Studio 2019 Professional
    goto :found_msbuild
)

REM Try VS 2017
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe
    echo Found: Visual Studio 2017 Community
    goto :found_msbuild
)

REM Try VS 2015
if exist "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe
    echo Found: Visual Studio 2015
    goto :found_msbuild
)

REM Try VS 2013
if exist "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe
    echo Found: Visual Studio 2013
    goto :found_msbuild
)

REM Try VS 2012
if exist "C:\Program Files (x86)\MSBuild\4.0\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files (x86)\MSBuild\4.0\Bin\MSBuild.exe
    echo Found: Visual Studio 2012
    goto :found_msbuild
)

REM Try VS 2010
if exist "C:\Program Files (x86)\MSBuild\3.5\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files (x86)\MSBuild\3.5\Bin\MSBuild.exe
    echo Found: Visual Studio 2010
    goto :found_msbuild
)

echo ERROR: Could not find MSBuild.exe
echo.
echo Please install Visual Studio (2010 or later) or run this script
echo from a Visual Studio Developer Command Prompt
echo.
pause
exit /b 1

:found_msbuild
echo MSBuild: %MSBUILD_PATH%
echo.

REM Build tracking
set BUILD_FAILED=0
set WIN32_BUILT=0
set X64_BUILT=0

REM Determine what to build
if /i "%PLATFORM%"=="Win32" goto :build_win32
if /i "%PLATFORM%"=="x64" goto :build_x64
if /i "%PLATFORM%"=="both" goto :build_both

echo ERROR: Invalid platform specified. Use: Win32, x64, or both
pause
exit /b 1

:build_both
call :build_win32
call :build_x64
goto :summary

:build_win32
echo.
echo ========================================
echo   Building Win32 (32-bit)
echo ========================================
echo.

"%MSBUILD_PATH%" "%PROJECT_FILE%" /p:Configuration=%BUILD_CONFIG% /p:Platform=Win32 /t:Rebuild /v:minimal

if errorlevel 1 (
    echo.
    echo ERROR: Win32 build failed
    set BUILD_FAILED=1
    goto :eof
)

REM Check if DLL exists
set DLL_SOURCE_32=Release\FBXExportModule.dll
if not exist "%DLL_SOURCE_32%" (
    echo ERROR: Win32 DLL not found at: %DLL_SOURCE_32%
    set BUILD_FAILED=1
    goto :eof
)

REM Deploy Win32 DLL
set UDK_BINARIES_32=%UDK_PATH%\Binaries\Win32
if exist "%UDK_BINARIES_32%" (
    echo.
    echo Deploying Win32 DLL...
    copy /Y "%DLL_SOURCE_32%" "%UDK_BINARIES_32%\FBXExportModule.dll"
    if errorlevel 1 (
        echo WARNING: Failed to copy Win32 DLL
    ) else (
        echo SUCCESS: Win32 DLL deployed to %UDK_BINARIES_32%
        set WIN32_BUILT=1
    )
) else (
    echo WARNING: UDK Win32 binaries folder not found: %UDK_BINARIES_32%
    echo Please copy %DLL_SOURCE_32% manually
)

goto :eof

:build_x64
echo.
echo ========================================
echo   Building x64 (64-bit)
echo ========================================
echo.

REM Check if UDK has 64-bit support
set UDK_BINARIES_64=%UDK_PATH%\Binaries\Win64
if not exist "%UDK_BINARIES_64%" (
    echo.
    echo ========================================
    echo   NOTICE: No 64-bit UDK Detected
    echo ========================================
    echo.
    echo Your UDK installation does not have a Win64 binaries folder.
    echo.
    echo Standard UDK releases are 32-bit only. To use 64-bit you need:
    echo   - A custom UDK build with 64-bit support
    echo   - UE3 source license with 64-bit editor
    echo.
    echo Skipping x64 build...
    echo.
    goto :eof
)

"%MSBUILD_PATH%" "%PROJECT_FILE%" /p:Configuration=%BUILD_CONFIG% /p:Platform=x64 /t:Rebuild /v:minimal

if errorlevel 1 (
    echo.
    echo ERROR: x64 build failed
    set BUILD_FAILED=1
    goto :eof
)

REM Check if DLL exists
set DLL_SOURCE_64=x64\Release\FBXExportModule.dll
if not exist "%DLL_SOURCE_64%" (
    echo ERROR: x64 DLL not found at: %DLL_SOURCE_64%
    set BUILD_FAILED=1
    goto :eof
)

REM Deploy x64 DLL
echo.
echo Deploying x64 DLL...
copy /Y "%DLL_SOURCE_64%" "%UDK_BINARIES_64%\FBXExportModule.dll"
if errorlevel 1 (
    echo WARNING: Failed to copy x64 DLL
) else (
    echo SUCCESS: x64 DLL deployed to %UDK_BINARIES_64%
    set X64_BUILT=1
)

goto :eof

:summary
echo.
echo ========================================
echo   BUILD SUMMARY
echo ========================================
echo.

if %BUILD_FAILED%==1 (
    echo Status: FAILED
    echo.
    echo One or more builds failed. Check the output above for errors.
    pause
    exit /b 1
)

echo Status: SUCCESS
echo.

if %WIN32_BUILT%==1 (
    echo [✓] Win32 DLL built and deployed
)

if %X64_BUILT%==1 (
    echo [✓] x64 DLL built and deployed
)

echo.
echo ========================================
echo   Next Steps
echo ========================================
echo.
echo 1. Rebuild UDK scripts:
echo    cd %UDK_PATH%\Binaries\Win32
echo    UDK.exe make
echo.
echo 2. Test Win32 version:
echo    cd %UDK_PATH%\Binaries\Win32
echo    UDK.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/Mesh.fbx
echo.

if %X64_BUILT%==1 (
    echo 3. Test x64 version:
    echo    cd %UDK_PATH%\Binaries\Win64
    echo    UDK.exe NativeFBXExportCommandlet MyPackage.MyMesh D:/Export/Mesh.fbx
    echo.
)

pause
endlocal
