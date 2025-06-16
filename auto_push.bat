@echo off
cd /d "C:\Users\varsh\OneDrive\Desktop\MKV\Projects"

:loop
git add .

REM Only commit if there are staged changes
git diff --cached --quiet
IF ERRORLEVEL 1 (
    git commit -m "Auto update on %date% %time%"
    git push origin main
    echo Changes pushed at %time%
) ELSE (
    echo No changes to push at %time%
)

timeout /t 60 >nul
goto loop