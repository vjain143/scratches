@echo off
set SKAFFOLD_COMMAND=skaffold build

rem Run Skaffold build command
%SKAFFOLD_COMMAND%

rem Check the exit code of the Skaffold command
if %ERRORLEVEL% NEQ 0 (
    echo Error: Skaffold build failed with exit code %ERRORLEVEL%.
    rem Add any additional error handling steps here.
    rem For example, you might want to log the error or send a notification.
) else (
    echo Skaffold build completed successfully.
)
