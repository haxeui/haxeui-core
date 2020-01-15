@echo off
if %1 == debug (
	build\qt\::output::-debug.exe
    pause
) else (
	build\qt\::output::.exe
)
