package test.android;

import runs.ProcessRun;
import test.Test;

class AndroidTest extends Test {
    public override function execute(params:Params) {
        new BuildRun("android").execute(params);

        var ANDROID_HOME = Sys.getEnv("ANDROID_HOME");

        var r = new ProcessRun(['${ANDROID_HOME}/platform-tools/adb', '-d', 'logcat', 'System.out:I', '*:S']);
        r.execute(params);
    }
}