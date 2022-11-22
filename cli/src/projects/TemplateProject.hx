package projects;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class TemplateEntry {
    public function new() {
    }

    public var src:String;
    public var dst:String;
    public var binary:Bool = false;
    public var system:Bool = false;
    @:optional @:default(true) public var expandVars:Bool = true;
}

class TemplateProject extends Project {
    public var templates:Array<TemplateEntry> = [];

    public function new() {
        super();
    }

    public override function execute(params:Map<String, String>) {
        super.execute(params);

        var cwd = Sys.getCwd();

        for (t in templates) {
            var src = '${cwd}/cli/templates/${name}/${expandString(t.src, params)}';
            if (t.system == true) {
                src = expandString(t.src, params);
            }
            if (isExtensionBinary(src)) {
                t.binary = true;
            }
            var dst = expandString(t.dst, params);
            copyTemplate(src, dst, params, t.binary, t.expandVars);
        }
    }

    private static function isExtensionBinary(path:String) {
        if (path.endsWith(".png") || path.endsWith(".bmp") || path.endsWith(".gif") || path.endsWith(".jpg") || path.endsWith("jpeg") || path.endsWith(".ico") || path.endsWith(".icns")) {
            return true;
        }
        return false;
    }

    public static function copyTemplate(src:String, dst:String, vars:Map<String, String> = null, binary:Bool = false, expandVars:Bool = true) {
        var params:Dynamic = {};
        for (k in vars.keys()) {
            Reflect.setField(params, k, vars.get(k));
        }
        var env = Sys.environment();
        for (k in env.keys()) {
            Reflect.setField(params, k, env.get(k));
        }

        src = Path.normalize(src);
        dst = Path.normalize(dst);
        var force = (vars.exists("force") && vars.get("force") == "true");

        if (FileSystem.exists(src) == false) {
            if (binary == true) {
                throw 'Could not find binary file "${src}"';
            } else {
                throw 'Could not find template file "${src}"';
            }
        }

        if (FileSystem.exists(dst) == false || force == true) {
            if (binary == true) {
                Util.log('\t- Copying "${src}" to "${dst}" (as binary)');
            } else {
                Util.log('\t- Copying "${src}" to "${dst}"');
            }

            if (binary == false) {
                var content = File.getContent(src);

                if (expandVars) {
                    var t = new haxe.Template(content);
                    content = t.execute(params);
                }

                File.saveContent(dst, content);
            } else {
                File.copy(src, dst);
            }
        } else {
            Util.log('\t- Skipping "${dst}"');
        }
    }

}