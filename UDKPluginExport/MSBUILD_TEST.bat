@echo off
setlocal

rem -----------------------------------------------------------------------------
rem Build_MSBuild.bat
rem msbuild-friendly build script that finds vcvarsall (via vswhere or common paths)
rem and builds FBXExportModule.vcxproj for Win32 and x64. Logs to Build_MSBuild.log.
rem Usage: Build_MSBuild.bat [--deploy-to-UDK "D:\UDK\Custom"]
rem -----------------------------------------------------------------------------

set SCRIPT_DIR=%~dp0
set PROJ=%SCRIPT_DIR%FBXExportModule.vcxproj
set LOG=%SCRIPT_DIR%Build_MSBuild.log
set UDK_DEPLOY_PATH=
set MSBUILD=msbuild.exe
set BUILD_OK=1

rem Optional deploy argument
if /I "%~1"=="--deploy-to-UDK" (
    if "%~2"=="" (
        echo ERROR: missing UDK path for --deploy-to-UDK >> "%LOG%"
        echo Usage: Build_MSBuild.bat [--deploy-to-UDK "D:\UDK\Custom"]
        exit /b 2
    )
    set UDK_DEPLOY_PATH=%~2
)

echo Building FBXExportModule - log: %LOG%
echo Start Time: %date% %time% > "%LOG%"

rem try to locate vswhere
set VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
if exist "%VSWHERE%" (
    for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2^>nul`) do (
        set VS_INSTALL=%%i
    )
)

rem possible vcvars candidates (if vswhere not found or didn't return)
if defined VS_INSTALL (
    set VCVARS_CAND=%VS_INSTALL%\VC\Auxiliary\Build\vcvarsall.bat
) else (
    set VCVARS_CAND=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat;%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat;%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat;%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat;%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat;%ProgramFiles(x86)%\Microsoft Visual Studio\14.0\VC\vcvarsall.bat
)

set VCVARS=
for %%P in (%VCVARS_CAND%) do (
    if exist "%%~P" (
        set VCVARS=%%~P
        goto :FOUND_VCVARS
    )
)
:FOUND_VCVARS
if not defined VCVARS (
    echo ERROR: Could not find vcvarsall.bat. Ensure Visual Studio or Build Tools are installed. >> "%LOG%"
    echo Looked for vswhere and common VS Build Tools locations.
    exit /b 3
)

echo Found vcvarsall: %VCVARS% >> "%LOG%"

rem helper to run msbuild and capture status
:BuildPlatform
rem %1 = vcvars arg (x86 / amd64 / x86_x64 etc)
rem %2 = Platform string for msbuild (Win32 or x64)
set VCVARS_ARG=%1
set MSPLATFORM=%2

echo ---------------------------- >> "%LOG%"
echo Building %PROJ% Platform=%MSPLATFORM% using vcvars "%VCVARS_ARG%" >> "%LOG%"
call "%VCVARS%" %VCVARS_ARG% >nul 2>&1
if errorlevel 1 (
    echo ERROR: vcvars call failed for %VCVARS_ARG% >> "%LOG%"
    set BUILD_OK=0
    goto :BUILD_DONE_PLATFORM
)

rem prefer msbuild from PATH; if missing, try to locate it under VS install
where %MSBUILD% >nul 2>&1
if errorlevel 1 (
    rem try in VS_INSTALL\MSBuild\Current\Bin\MSBuild.exe
    if defined VS_INSTALL (
        if exist "%VS_INSTALL%\MSBuild\Current\Bin\MSBuild.exe" (
            set MSBUILD=%VS_INSTALL%\MSBuild\Current\Bin\MSBuild.exe
        ) else if exist "%VS_INSTALL%\MSBuild\15.0\Bin\MSBuild.exe" (
            set MSBUILD=%VS_INSTALL%\MSBuild\15.0\Bin\MSBuild.exe
        )
    )
)

echo Running: "%MSBUILD%" "%PROJ%" /t:Build /p:Configuration=Release /p:Platform=%MSPLATFORM% >> "%LOG%"
"%MSBUILD%" "%PROJ%" /t:Build /p:Configuration=Release /p:Platform=%MSPLATFORM% /clp:Summary /m >> "%LOG%" 2>&1
if errorlevel 1 (
    echo ERROR: msbuild failed for Platform=%MSPLATFORM% >> "%LOG%"
    set BUILD_OK=0
) else (
    echo SUCCESS: Build succeeded for Platform=%MSPLATFORM% >> "%LOG%"
)

:BUILD_DONE_PLATFORM
exit /b 0

rem Build Win32
call :BuildPlatform x86 Win32

rem Build x64 (use amd64 arg for newer toolsets)
call :BuildPlatform amd64 x64

rem final status
if "%BUILD_OK%"=="1" (
    echo All builds succeeded >> "%LOG%"
) else (
    echo One or more builds FAILED. Check %LOG% for details >> "%LOG%"
)

echo End Time: %date% %time% >> "%LOG%"

rem Optional deploy: copy built DLLs to UDK Binaries if path provided
if defined UDK_DEPLOY_PATH (
    echo Deploying DLLs to %UDK_DEPLOY_PATH% >> "%LOG%"
    set DLL_NAME=FBXExportModule.dll
    if exist "%SCRIPT_DIR%..\..\..\..\Binaries\Win32\%DLL_NAME%" (
        copy /Y "%SCRIPT_DIR%..\..\..\..\Binaries\Win32\%DLL_NAME%" "%UDK_DEPLOY_PATH%\Binaries\Win32\" >> "%LOG%" 2>&1
    ) else (
        rem try default output path next to project (adjust if your vcxproj uses different OutDir)
        if exist "%SCRIPT_DIR%..\..\..\Binaries\Win32\%DLL_NAME%" copy /Y "%SCRIPT_DIR%..\..\..\Binaries\Win32\%DLL_NAME%" "%UDK_DEPLOY_PATH%\Binaries\Win32\" >> "%LOG%" 2>&1
    )
    if exist "%SCRIPT_DIR%..\..\..\..\Binaries\Win64\%DLL_NAME%" (
        copy /Y "%SCRIPT_DIR%..\..\..\..\Binaries\Win64\%DLL_NAME%" "%UDK_DEPLOY_PATH%\Binaries\Win64\" >> "%LOG%" 2>&1
    ) else (
        if exist "%SCRIPT_DIR%..\..\..\Binaries\x64\%DLL_NAME%" copy /Y "%SCRIPT_DIR%..\..\..\Binaries\x64\%DLL_NAME%" "%UDK_DEPLOY_PATH%\Binaries\Win64\" >> "%LOG%" 2>&1
    )
    echo Deployment complete >> "%LOG%"
)

if "%BUILD_OK%"=="1" (
    echo Build completed successfully. See %LOG%
    exit /b 0
) else (
    echo Build finished with errors. See %LOG%
    exit /b 1
)