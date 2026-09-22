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

    rem Skip this BAT file itself
    if /i not "%%~nxF"=="%~nx0" (

        rem Only process files
        if not "%%~aF:~0,1"=="d" (

            set "hash="

            for /f "tokens=1" %%H in (
                'certutil -hashfile "%%F" SHA256 ^| findstr /r /v "hash CertUtil"'
            ) do (
                set "hash=%%H"
            )

            if defined hash (

                findstr /b /i /c:"!hash!|" "%HASHLIST%" >nul

                if !errorlevel! equ 0 (

                    echo [DUPLICATE] %%F

                    call :GetSafeName "%%~nF" "%%~xF"

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
exit /b


:GetSafeName

set "BASENAME=%~1"
set "EXT=%~2"

set "TARGET=%DUPDIR%\%BASENAME%%EXT%"

if not exist "%TARGET%" exit /b

set /a N=1

:TryNextName

set "TARGET=%DUPDIR%\%BASENAME%_%N%%EXT%"

if exist "%TARGET%" (
    set /a N+=1
    goto TryNextName
)

exit /b