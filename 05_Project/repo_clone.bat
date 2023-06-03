@echo off
setlocal

:: Example usage:
::
:: clone_repo.bat https://github.com/example/source-repo.git https://github.com/example/destination-repo.git <github_personal_access_token>
:: ex.:
:: repo_clone.bat https://github.com/devilreraser/uw_repository_utils.git https://github.com/devilreraser/uw_repository_utils_cloned.git ghp_OTAbETGQXAXUJy5Jgb958wrcRfbwtq2Ltv9w
::
:: Replace "https://github.com/example/source-repo.git" with the actual URL of the source repository.
:: Replace "https://github.com/example/destination-repo.git" with the actual URL of the destination repository.
:: Replace <github_personal_access_token> with your actual GitHub personal access token ex: ghp_OTAbETGQXAXUJy5Jgb958wrcRfbwtq2Ltv9w.
:: If the token is not provided as a command-line argument, you will be prompted to enter it interactively.

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

:: Clone the source repository
git clone --recursive %source_repo% temp_repo
cd temp_repo

:: Get the repository name from the source URL
for %%i in ("%source_repo%") do set "repo_name=%%~ni"

:: Create a new repository on the destination remote using GitHub API
echo Creating new repository: %repo_name%
echo.
curl -X POST -H "Authorization: token %github_token%" -d "{\"name\":\"%repo_name%\"}" "https://api.github.com/user/repos"

:: Push the repository to the destination remote
echo Pushing repository to destination...
git remote set-url origin %destination_repo%
git push --all

:: Update the submodules
echo Updating submodules...
git submodule foreach --recursive git checkout master
git submodule foreach --recursive git pull

:: Clean up
cd ..
rmdir /s /q temp_repo

echo.
echo Repository and submodules cloned and pushed to the destination remote successfully!
endlocal
