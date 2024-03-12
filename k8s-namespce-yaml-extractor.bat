@echo off
setlocal

REM Set the output directory where YAML files will be saved
set OUTPUT_DIR="kubernetes_yamls"

REM Create the output directory if it doesn't exist
mkdir %OUTPUT_DIR% 2>nul

REM Function to retrieve YAML definitions for a Kubernetes resource type and save them to a file
:retrieve_and_save_yaml
set RESOURCE_TYPE=%1
set OUTPUT_FILE=%OUTPUT_DIR%\%RESOURCE_TYPE%.yaml
echo Retrieving YAML for %RESOURCE_TYPE%...
kubectl get %RESOURCE_TYPE% -o yaml > %OUTPUT_FILE%
echo YAML for %RESOURCE_TYPE% saved to %OUTPUT_FILE%
exit /b

REM Call the function for each Kubernetes resource type
call :retrieve_and_save_yaml deployments
call :retrieve_and_save_yaml statefulsets
call :retrieve_and_save_yaml cronjobs
call :retrieve_and_save_yaml jobs
call :retrieve_and_save_yaml secrets
call :retrieve_and_save_yaml configmaps
call :retrieve_and_save_yaml persistentvolumes
call :retrieve_and_save_yaml persistentvolumeclaims
call :retrieve_and_save_yaml services
call :retrieve_and_save_yaml networkpolicies

echo All YAML files generated successfully.

endlocal
