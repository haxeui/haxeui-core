package haxe.ui.macros;

#if macro
import haxe.macro.Type.ClassType;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ui.macros.helpers.CodeBuilder;
import haxe.ui.util.GenericConfig;
#end

typedef ClassPathEntry = {
    var base:String;
    var path:String;
    var priority:Int;
}

class MacroHelpers {
    #if macro
    public static function exprToMap(params:Expr):Map<String, Dynamic> {
        if (params == null) {
            return null;
        }

        var map:Map<String, Dynamic> = new Map<String, Dynamic>();
        switch (params.expr) {
            case EObjectDecl(x):
                for (y in x) {
                    switch (y.expr.expr) {
                        case EConst(CString(z)) | EConst(CInt(z))  | EConst(CFloat(z))  | EConst(CIdent(z)) :
                            map.set(y.field, z);
                        case _:
                    }
                }
            case _:
        }
        return map;
    }

    public static function exprToArray(params:Expr):Array<Any> {
        if (params == null) {
            return null;
        }
        
        var array = new Array<Any>();
        switch (params.expr) {
            case EArrayDecl(values):
                for (v in values) {
                    switch (v.expr) {
                        case EConst(CString(z)) | EConst(CInt(z))  | EConst(CFloat(z))  | EConst(CIdent(z)) :
                            array.push(z);
                        case _:    
                    }
                }
            case _:    
        }
        return array;
    }
    
    public static function resolveFile(file:String):String {
        var resolvedPath:String = null;
        if (sys.FileSystem.exists(file) == false) {
            var paths:Array<String> = Context.getClassPath();
            //paths.push("assets");

            for (path in paths) {
                path = haxe.io.Path.normalize(path + "/" + file);
                if (sys.FileSystem.exists(path)) {
                    resolvedPath = path;
                    break;
                }
            }
        } else {
            resolvedPath = file;
        }
        return resolvedPath;
    }

    public static function typesFromClassOrPackage(className:String, pack:String):Array<haxe.macro.Type> {
        var types:Array<haxe.macro.Type> = null;
        if (className != null) {
            types = Context.getModule(className);
        } else if (pack != null) {
            types = MacroHelpers.typesFromPackage(pack);
        }
        return types;
    }

    public static function typesFromPackage(pack:String):Array<haxe.macro.Type> {
        var types:Array<haxe.macro.Type> = new Array<haxe.macro.Type>();

        var paths:Array<String> = Context.getClassPath();
        var arr:Array<String> = pack.split(".");
        for (path in paths) {
            var dir:String = path + arr.join("/");
            if (!sys.FileSystem.exists(dir) || !sys.FileSystem.isDirectory(dir)) {
                continue;
            }

            var files:Array<String> = sys.FileSystem.readDirectory(dir);
            if (files != null) {
                for (file in files) {
                    if (StringTools.endsWith(file, ".hx") && !StringTools.startsWith(file, ".")) {
                        var name:String = file.substr(0, file.length - 3);
                        try {
                            var temp:Array<haxe.macro.Type> = Context.getModule(pack + "." + name);
                            types = types.concat(temp);
                        } catch (e:Dynamic) { }
                    }
                }
            }
        }

        return types;
    }

    public static function extension(path:String):String {
        if (path.indexOf(".") == -1) {
            return null;
        }
        var arr:Array<String> = path.split(".");
        var extension:String = arr[arr.length - 1];
        return extension;
    }

    public static function buildGenericConfigCode(builder:CodeBuilder, c:GenericConfig, name:String, depth:Int = 0) {
        for (key in c.values.keys()) {
            var sectionVar = 'section${depth}';
            var value = c.values.get(key);
            builder.add(macro $i{sectionVar}.values.set($v{key}, $v{value}));
        }

        for (sectionName in c.sections.keys()) {
            for (section in c.sections.get(sectionName)) {
                if (depth == 0) {
                    var sectionVar = 'section${depth + 1}';
                    builder.add(macro var $sectionVar = $i{name}.addSection($v{sectionName}));
                } else {
                    var sectionVar = 'section${depth + 1}';
                    var parentSectionVar = 'section${depth}';
                    builder.add(macro var $sectionVar = $i{parentSectionVar}.addSection($v{sectionName}));
                }

                buildGenericConfigCode(builder, section, name, depth + 1);
            }
        }
    }

    public static var classPathCache:Array<ClassPathEntry> = null;
    private static var primaryClassPathExceptions:Array<EReg> = [];
    private static var secondaryClassPathExceptions:Array<EReg> = [];
    private static function loadClassPathExclusions(filePath:String) {
        #if classpath_scan_verbose
        Sys.println("classpath cache: loading classpath exclusions from '" + filePath + "'");
        #end

        var contents = sys.io.File.getContent(filePath);
        var lines = contents.split("\n");
        for (line in lines) {
            line = StringTools.trim(line);
            if (line.length == 0 || StringTools.startsWith(line, ";")) {
                continue;
            }

            #if classpath_scan_verbose
                Sys.println("    " + line);
            #end

            primaryClassPathExceptions.push(new EReg(line, "gm"));
            secondaryClassPathExceptions.push(new EReg(line, "gm"));
        }
    }

    private static function buildClassPathCache() {
        if (classPathCache != null) {
            return;
        }

        #if haxeui_macro_times
        var stopTimer = Context.timer("MacroHelpers.buildClassPathCache");
        #end

        classPathCache = [];
        var paths:Array<String> = Context.getClassPath();
        for (path in paths) {
            if (StringTools.trim(path).length == 0) {
                path = Sys.getCwd();
            }
            path = StringTools.trim(path + "/classpath.exclusions");
            path = Path.normalize(path);
            if (sys.FileSystem.exists(path)) {
                loadClassPathExclusions(path);
            }
        }

        for (path in paths) {
            if (StringTools.trim(path).length == 0) {
                path = Sys.getCwd();
            }
            var originalPath = path;
            path = StringTools.trim(path);
            path = Path.normalize(path);
            var exclude = false;
            for (r in primaryClassPathExceptions) {
                if (r.match(path) == true) {
                    exclude = true;
                    break;
                }
            }
            if (exclude == true) {
                continue;
            }
            cacheClassPathEntries(path, classPathCache, originalPath);
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    private static function cacheClassPathEntries(path:String, array:Array<ClassPathEntry>, base:String) {
        path = StringTools.trim(path);
        if (path.length == 0) {
            #if classpath_scan_verbose
            Sys.println("classpath cache: skipping 0 length path");
            #end
            return;
        }
        path = Path.normalize(path);

        var exclude = false;
        for (r in secondaryClassPathExceptions) {
            if (r.match(path) == true) {
                exclude = true;
                break;
            }
        }
        if (exclude == true || ! sys.FileSystem.exists(path)) {
            #if classpath_scan_verbose            
            Sys.println("classpath cache: excluding '" + path + "'");
            #end
            return;
        }

        var contents = sys.FileSystem.readDirectory(path);
        for (item in contents) {
            item = StringTools.trim(item);
            if (item.length == 0) {
                continue;
            }
            var fullPath = Path.normalize(path + "/" + item);
            if (sys.FileSystem.exists(fullPath) == false) {
                continue;
            }
            var isDir = sys.FileSystem.isDirectory(fullPath);
            if (isDir == true && StringTools.startsWith(item, ".") == false) {
                if (exclude == false) {
                    cacheClassPathEntries(fullPath, array, base);
                }
            } else if (isDir == false) {
                #if classpath_scan_verbose
                Sys.println("classpath cache: adding '" + fullPath + "' (cache size: " + array.length + ")");
                #end    
                array.push({
                    base: base,
                    path: fullPath,
                    priority: 0
                });
            }
        }

    }

    public static function scanClassPath(processFileFn:String->String->Bool, searchCriteria:Array<String> = null) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("MacroHelpers.scanClassPath");
        #end

        buildClassPathCache();
        for (entry in classPathCache) {
            #if classpath_scan_verbose
            Sys.println("  looking for '" + searchCriteria + "' in '" + entry.path + "'");
            #end
            
            var parts = entry.path.split("/");
            var fileName = parts[parts.length - 1];
            if (searchCriteria == null) {
                processFileFn(entry.path, entry.base);
            } else {
                var found:Bool = false;
                for (s in searchCriteria) {
                    if (StringTools.startsWith(fileName, s)) {
                        found = true;
                        break;
                    }
                }
                if (found == true) {
                    processFileFn(entry.path, entry.base);
                }
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    public static function shouldBuildExtension(classType:ClassType, extension:String):Bool {
        var hasRequiredInterface = false;
        for (i in classType.interfaces) {
            if (i.t.toString() == extension) {
                hasRequiredInterface = true;
                break;
            }
        }

        if (!hasRequiredInterface) {
            return false;
        }

        var s = classType.superClass;
        while (s != null) {
            for (i in s.t.get().interfaces) {
                if (i.t.toString() == extension) {
                    return false;
                }
            }

            s = s.t.get().superClass;
        }

        return true;
    }

    #end
}