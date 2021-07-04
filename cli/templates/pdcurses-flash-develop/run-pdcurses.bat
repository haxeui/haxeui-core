@echo off
if %1 == debug (
	build\pdcurses\::output::-debug.exe
    pause
) else (
	build\pdcurses\::output::.exe
)
