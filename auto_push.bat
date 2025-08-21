@echo off
cd /d "C:\Users\varsh\OneDrive\Desktop\MKV\Projects"

:loop
REM -----------------------------
REM Create .gitkeep in empty folders
REM -----------------------------
for /d /r %%F in (*) do (
    dir /b "%%F" | findstr . >nul
    if errorlevel 1 (
        if not exist "%%F\.gitkeep" (
            echo.>"%%F\.gitkeep"
            echo Created .gitkeep in %%F
        )
    )
)

REM -----------------------------
REM Stage all changes
REM -----------------------------
git add .

REM -----------------------------
REM Commit only if there are changes
REM -----------------------------
git diff --cached --quiet
IF ERRORLEVEL 1 (
    git commit -m "Auto update on %date% %time%"
    git push origin main
    echo Changes pushed at %time%
) ELSE (
    echo No changes to push at %time%
)

REM -----------------------------
REM Wait 60 seconds and loop
REM -----------------------------
timeout /t 60 >nul
goto loop
