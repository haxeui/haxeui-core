call haxelib run haxeui-core run android
call %ANDROID_HOME%/platform-tools/adb -d logcat System.out:I *:S
