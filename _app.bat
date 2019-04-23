@echo off

set _interval=5
set _processName=python.exe
set _processCmd=%CD%\_app.py
set _processTimeout=5

:LOOP
set /a isAlive=false

tasklist | find /C "%_processName%" > temp.txt
set /p num= < temp.txt
del /F temp.txt

if "%num%" == "0" (
python %_processCmd% | echo FOUND %_processName% in Running System %time%
choice /D y /t %_processTimeout% > nul
)

if "%num%" NEQ "0" echo STARTED

choice /D y /t %_interval% >nul

goto LOOP

