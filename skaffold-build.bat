@echo off

rem Run Skaffold build command
skaffold build

rem Check the error level to determine if the build was successful
if %ERRORLEVEL% NEQ 0 (
    rem Error handling based on the error level
    if %ERRORLEVEL% EQU 1 (
        echo Error: Docker build failed.
    ) else if %ERRORLEVEL% EQU 2 (
        echo Error: Failed to push images to the registry.
    ) else if %ERRORLEVEL% EQU 3 (
        echo Error: Skaffold configuration error.
    ) else (
        echo Unknown error occurred. Error level: %ERRORLEVEL%.
    )
    rem Add additional error handling steps here.
) else (
    echo Skaffold build completed successfully.
)


 It combines the idea of a quasar, representing immense energy and activity, with "federated," suggesting unity or collaboration among different components or entities within the system. This name implies a system that brings together various resources or entities in a coordinated and efficient manner, much like how a quasar emits energy across vast distances in the universe.
