@echo off
setlocal

REM Set the output directory where YAML files will be saved
set OUTPUT_DIR="kubernetes_yamls"

REM Create the output directory if it doesn't exist
mkdir %OUTPUT_DIR% 2>nul

REM Function to retrieve YAML definitions for a Kubernetes resource type and save them to a file
:retrieve_and_save_yaml
set RESOURCE_TYPE=%1
set RESOURCE_NAME=%2
set OUTPUT_FILE=%OUTPUT_DIR%\%RESOURCE_TYPE%_%RESOURCE_NAME%.yaml
echo Retrieving YAML for %RESOURCE_TYPE% %RESOURCE_NAME%...
kubectl get %RESOURCE_TYPE% %RESOURCE_NAME% -o yaml > %OUTPUT_FILE%
echo YAML for %RESOURCE_TYPE% %RESOURCE_NAME% saved to %OUTPUT_FILE%
exit /b

REM Function to retrieve and save YAML definitions for each resource type
:retrieve_and_save_resources
set RESOURCE_TYPE=%1
echo Retrieving and saving YAML for %RESOURCE_TYPE%s...
for /f "tokens=1" %%r in ('kubectl get %RESOURCE_TYPE% -o=name') do (
    set RESOURCE_NAME=%%r
    set RESOURCE_NAME=!RESOURCE_NAME:~13!
    call :retrieve_and_save_yaml %RESOURCE_TYPE% !RESOURCE_NAME!
)
echo %RESOURCE_TYPE%s YAML saved successfully.
exit /b

REM Call the function for each resource type
call :retrieve_and_save_resources statefulsets
call :retrieve_and_save_resources cronjobs
call :retrieve_and_save_resources jobs
call :retrieve_and_save_resources secrets
call :retrieve_and_save_resources configmaps
call :retrieve_and_save_resources persistentvolumes
call :retrieve_and_save_resources persistentvolumeclaims
call :retrieve_and_save_resources services
call :retrieve_and_save_resources networkpolicies
call :retrieve_and_save_resources deployments

echo All YAML files generated successfully.

endlocal
