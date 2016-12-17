package haxe.ui.parsers.ui.resolvers;

import haxe.ui.util.StringUtil;

#if (macro || sys)
import sys.io.File;
import sys.FileSystem;
#end

class FileResourceResolver extends ResourceResolver {
    private var _rootFile:String;
    private var _rootDir:String;

    public function new(rootFile:String, params:Map<String, Dynamic> = null) {
        super(params);
        _rootFile = rootFile;
        var arr:Array<String> = _rootFile.split("/");
        arr.pop();
        _rootDir = arr.join("/");
        if (arr.length > 1) {
            _rootDir += "/";
        }
    }

    #if (macro || sys)
    public override function getResourceData(r:String):String {
        var f:String = _rootDir + r;
        var data:String = null;
        if (FileSystem.exists(f)) {
            data = StringUtil.replaceVars(File.getContent(f), _params);
        }
        if (data == null) {
            trace("WARNING: Could not find file: " + f);
        }
        return data;
    }
    #end
}