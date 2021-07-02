@echo off
if %1 == debug (
	build\raylib\::output::-debug.exe
    pause
) else (
	build\raylib\::output::.exe
)
