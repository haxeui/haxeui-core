@echo off
if %1 == debug (
	build\winforms\bin\::output::-debug.exe
    pause
) else (
	build\winforms\bin\::output::.exe
)
