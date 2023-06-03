@echo off
setlocal

:: Example usage:
::
:: repo_clone.bat https://github.com/your-username/source-repo.git https://github.com/your-username/destination-repo.git your_github_token temp_directory
:: ex.:
:: repo_clone.bat https://github.com/devilreraser/fw_nRF_SPI_BLE.git https://github.com/devilreraser/fw_nRF_SPI_BLE_clone.git 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 ..\..
::
:: Replace "https://github.com/your-username/source-repo.git" with the actual URL of the source repository.
:: Replace "https://github.com/your-username/destination-repo.git" with the actual URL of the destination repository.
:: Replace "your_github_token" with your actual GitHub personal access token, e.g., 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.
:: Replace "temp_directory" with the relative path where the destination directory should be created.
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
    set /p repo_dir_relative=Enter the relative path where the destination directory should be created:
) else (
    set "repo_dir_relative=%~4"
)

:: Get the full path of the directory where the batch file is located
for %%I in ("%~dp0.") do set "batch_dir=%%~fI"

:: Create the full destination directory path
set "repo_dir=%batch_dir%\%repo_dir_relative%"

:: Enter the destination directory
cd /d "%repo_dir%"

:: Get the repository name from the source URL
for %%i in ("%source_repo%") do set "source_repo_name=%%~ni"

:: Get the repository name from the destination URL
for %%i in ("%destination_repo%") do set "destination_repo_name=%%~ni"

:: Check if the source repository is already cloned
if exist "%repo_dir%\%source_repo_name%" (
    echo Source repository already cloned.

    :: Change to the source repository directory
    cd "%source_repo_name%"

    :: Check if the cloned repository has uncommitted changes
    git diff-index --quiet HEAD --
    if not %errorlevel%==0 (
        echo.
        echo The cloned repository has uncommitted changes. Aborting.
        exit /b 1
    )
) else (
    :: Clone the source repository
    echo Cloning the source repository...
    git clone --recursive "%source_repo%" "%repo_dir%\%source_repo_name%"

    :: Change to the source repository directory
    cd "%source_repo_name%"
)

:: Create a new repository on the destination remote using GitHub API
echo.
echo Creating new repository: %destination_repo_name%
curl -X POST -H "Authorization: token %github_token%" -d "{\"name\":\"%destination_repo_name%\"}" "https://api.github.com/user/repos"

:: Push the repository to the destination remote
echo.
echo Pushing repository to destination...
git remote add destination "%destination_repo%"
git push --all destination

:: Update the submodules
echo.
echo Updating submodules...
git submodule update --init --recursive

echo.
echo Repository and submodules cloned and pushed to the destination remote successfully!
endlocal
