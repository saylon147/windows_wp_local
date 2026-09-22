@echo off
setlocal EnableDelayedExpansion

for %%F in (*.jpg *.jpeg *.png *.webp) do (
    for /f "tokens=1" %%H in ('certutil -hashfile "%%F" SHA256 ^| findstr /r /v "hash CertUtil"') do (
        set "hash=%%H"
    )

    if defined hash (
        if /i not "%%~nF"=="!hash!" (
            if exist "!hash!%%~xF" (
                echo [SKIP] %%F - same hash already exists
            ) else (
                echo [RENAME] %%F
                echo       -^> !hash!%%~xF
                ren "%%F" "!hash!%%~xF"
            )
        )
    )
)

echo.
echo Done.
pause