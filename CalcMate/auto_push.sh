#!/bin/bash
cd C:\Users\varsh\OneDrive\Desktop\MKV\CalcMate

while true; do
    git add .
    git commit -m "Auto update on $(date '+%Y-%m-%d %H:%M:%S')" > /dev/null 2>&1
    git push origin main > /dev/null 2>&1
    sleep 60  # Wait 60 seconds before repeating
done
