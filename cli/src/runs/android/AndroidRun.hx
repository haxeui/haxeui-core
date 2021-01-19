package runs.android;

import runs.Run;

class AndroidRun extends Run {
    public override function execute(params:Params) {
        var ANDROID_HOME = Sys.getEnv("ANDROID_HOME");

        var r1 = new ProcessRun(['${ANDROID_HOME}/platform-tools/adb', 'install', '-r', 'build/android/app/build/outputs/apk/debug/app-debug.apk']);
//        var r1 = new ProcessRun(['${ANDROID_HOME}/platform-tools/adb', '-d', 'install', '-r', 'build/android/app/build/outputs/apk/release/app-release-unsigned.apk']);
        r1.execute(params);

        var r2 = new ProcessRun(['${ANDROID_HOME}/platform-tools/adb', 'shell', 'am', 'start', '-n', 'haxe.ui.backend.android/haxe.ui.backend.android.MainActivity']);
        r2.execute(params);
    }
}