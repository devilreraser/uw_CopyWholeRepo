@echo off
setlocal

:: Example usage:
::
:: repo_clone.bat https://github.com/your-username/source-repo.git https://github.com/your-username/destination-repo.git your_github_token C:\path\to\temp\directory
:: ex.:
:: repo_clone.bat https://github.com/devilreraser/fw_nRF_SPI_BLE.git https://github.com/devilreraser/fw_nRF_SPI_BLE_cloned.git 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 ..\..
::
:: Replace "https://github.com/your-username/source-repo.git" with the actual URL of the source repository.
:: Replace "https://github.com/your-username/destination-repo.git" with the actual URL of the destination repository.
:: Replace "your_github_token" with your actual GitHub personal access token, e.g., ghp_OTAbETGQXAXUJy5Jgb958wrcRfbwtq2Ltv9w.
:: Replace "C:\path\to\temp\directory" with the actual path where the temporary directory should be created.
:: If any of the parameters are not provided as command-line arguments, you will be prompted to enter them interactively.

:: Check if source repository URL is provided as a command-line argument
if "%~1"=="" (
    set /p source_repo=Enter the source repository URL:
) else (
    set "source_repo=%~1"
)

:: Check if destination repository URL is provided as a command-line argument
if "%~2"=="" (
    set /p destination_repo=Enter the destination repository URL:
) else (
    set "destination_repo=%~2"
)

:: Check if GitHub personal access token is provided as a command-line argument
if "%~3"=="" (
    set /p github_token=Enter your GitHub personal access token:
) else (
    set "github_token=%~3"
)

:: Check if temporary directory path is provided as a command-line argument
if "%~4"=="" (
    set /p temp_dir=Enter the temporary directory path:
) else (
    set "temp_dir=%~4"
)

:: Get the repository name from the source URL
for %%i in ("%source_repo%") do set "source_repo_name=%%~ni"

:: Check if the source repository is already cloned
if exist "%temp_dir%\%source_repo_name%" (
    echo Source repository already cloned.

    :: Change to the source repository directory
    cd "%temp_dir%\%source_repo_name%"

    :: Check if the cloned repository has uncommitted changes
    git diff-index --quiet HEAD --
    if not errorlevel 1 (
        echo The cloned repository has uncommitted changes. Aborting.
        exit /b 1
    )
) else (
    :: Create the temporary directory
    mkdir "%temp_dir%"

    :: Clone the source repository
    echo Cloning the source repository...
    git clone --recursive "%source_repo%" "%temp_dir%\%source_repo_name%"

    :: Change to the source repository directory
    cd "%temp_dir%\%source_repo_name%"
)

:: Get the repository name from the destination URL
for %%i in ("%destination_repo%") do set "destination_repo_name=%%~ni"

:: Create a new repository on the destination remote using GitHub API
echo Creating new repository: %destination_repo_name%
echo.
curl -X POST -H "Authorization: token %github_token%" -d "{\"name\":\"
