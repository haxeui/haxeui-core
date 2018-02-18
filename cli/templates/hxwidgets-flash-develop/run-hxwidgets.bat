@echo off
if %1 == debug (
	build\hxwidgets\::output::-debug.exe
    pause
) else (
	build\hxwidgets\::output::.exe
)
