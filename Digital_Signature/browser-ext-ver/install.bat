@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Get the extension ID from the first parameter
SET EXT_ID=%1
IF "%EXT_ID%"=="" (
  ECHO Extension ID parameter is required.
  ECHO Usage: install.bat your-extension-id
  EXIT /B 1
)

:: Set variables for the needed paths
SET HOST_NAME=gov.va.leaf.digsign
SET HOST_PATH=%LOCALAPPDATA%\Google\Chrome\NativeMessagingHosts
SET APP_PATH=%LOCALAPPDATA%\VA\DigSign

:: If needed directories don't exist, create them.
IF NOT EXIST "%HOST_PATH%" mkdir "%HOST_PATH%"
IF NOT EXIST "%APP_PATH%" mkdir "%APP_PATH%"

:: Copy middleware to the correct location
ECHO Copying executable to %APP_PATH%...
COPY /Y "digsign_host.exe" "%APP_PATH%\" || (
  ECHO Failed to copy executable.
  EXIT /B 1
)

:: Create absolute path to executable (no environment variables as those can be finiky depending on browser)
SET APP_FULL_PATH=%APP_PATH%\digsign_host.exe
SET APP_FULL_PATH=!APP_FULL_PATH:\=\\!

:: Create the manifest file that tells the browser how to create the link between web-app and middleware.
ECHO Create manifest file with provided extension id.
(
ECHO {
ECHO   "name": "%HOST_NAME%",
ECHO   "description": "Digital Signature Native Messaging Host",
ECHO   "path": "%APP_FULL_PATH%",
ECHO   "type": "stdio",
ECHO   "allowed_origins": [
ECHO     "chrome-extension://%EXT_ID%/"
ECHO   ]
ECHO }
) > "%HOST_PATH%\%HOST_NAME%.json"

:: Add registry key in HKEY_CURRENT_USER (doesn't require admin)
ECHO Adding registry key in HKEY_CURRENT_USER...
REG ADD "HKEY_CURRENT_USER\SOFTWARE\Google\Chrome\NativeMessagingHosts\%HOST_NAME%" /ve /t REG_SZ /d "%HOST_PATH%\%HOST_NAME%.json" /f
IF %ERRORLEVEL% NEQ 0 (
  ECHO ERROR: Failed to add registry key. The native messaging host will not work.
  EXIT /B 1
) ELSE (
  ECHO Registry key added successfully.
)

ECHO Digital Signature installation completed for Chrome with extension ID: %EXT_ID%
ECHO.
ECHO Manifest file installed in: %HOST_PATH%\%HOST_NAME%.json
ECHO Executable installed in: %APP_PATH%\digsign_host.exe
ECHO Registry key added to: HKEY_CURRENT_USER\SOFTWARE\Google\Chrome\NativeMessagingHosts\%HOST_NAME%
ECHO.
ECHO Please restart Chrome for changes to take effect.

ENDLOCAL