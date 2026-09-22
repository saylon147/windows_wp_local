@echo off
setlocal EnableDelayedExpansion

cd /d "%~dp0"

set "DUPDIR=_duplicates"

if not exist "%DUPDIR%" mkdir "%DUPDIR%"

echo ========================================
echo Checking duplicate files...
echo Folder: %CD%
echo ========================================
echo.

set "HASHLIST=%TEMP%\duplicate_hash_%RANDOM%_%RANDOM%.txt"
type nul > "%HASHLIST%"

for %%F in (*) do (
    if /i not "%%~nxF"=="%~nx0" (
        if not "%%~aF:~0,1"=="d" (

            set "hash="

            for /f "tokens=1" %%H in ('certutil -hashfile "%%F" SHA256 ^| findstr /r /v "hash CertUtil"') do (
                set "hash=%%H"
            )

            if defined hash (
                findstr /b /i /c:"!hash!|" "%HASHLIST%" >nul

                if !errorlevel! equ 0 (
                    echo [DUPLICATE] %%F

                    set "TARGET=%DUPDIR%\%%~nxF"

                    if exist "!TARGET!" (
                        set /a N=1

                        :CHECK_NAME
                        set "TARGET=%DUPDIR%\%%~nF_!N!%%~xF"

                        if exist "!TARGET!" (
                            set /a N+=1
                            goto CHECK_NAME
                        )
                    )

                    move "%%F" "!TARGET!" >nul

                    echo             -^> !TARGET!
                    echo.
                ) else (
                    echo !hash!^|%%F>>"%HASHLIST%"
                    echo [KEEP]      %%F
                )
            )
        )
    )
)

del "%HASHLIST%" >nul 2>&1

echo.
echo ========================================
echo Finished.
echo Duplicate files moved to:
echo %CD%\%DUPDIR%
echo ========================================
pause