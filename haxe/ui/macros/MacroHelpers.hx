package haxe.ui.macros;

import haxe.ui.util.GenericConfig;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class MacroHelpers {
    private static var SKIP_PATTERNS:Array<String> = ["/lib/actuate/",
                                                      "/lib/lime/",
                                                      "/lib/openfl/",
                                                      "/lib/yaml/",
                                                      "/lib/hscript/",
                                                      "/haxe/std/",
                                                      "/.git"];

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

    public static function getConstructor(fields:Array<Field>) {
        return getFunction(fields, "new");
    }

    public static function getFunction(fields:Array<Field>, name:String) {
        var fn = null;
        for (f in fields) {
            if (f.name == name) {
                switch (f.kind) {
                    case FFun(f):
                            fn = f;
                        break;
                    default:
                }
            }
        }
        return fn;
    }

    public static function addFunction(name:String, e:Expr, access:Array<Access>, fields:Array<Field>, pos:Position):Void {
        var fn = switch (e).expr {
            case EFunction(_, f): f;
            case _: throw "false";
        }
        fields.push( { name : name, doc : null, meta : [], access : access, kind : FFun(fn), pos : pos } );
    }

    public static function getFieldsWithMeta(meta:String, fields:Array<Field>):Array<Field> {
        var arr:Array<Field> = new Array<Field>();

        for (f in fields) {
            if (hasMeta(f, meta)) {
                arr.push(f);
            }
        }

        return arr;
    }

    public static function hasMeta(f:Field, meta:String):Bool {
        return (getMeta(f, meta) != null);
    }

    public static function getMeta(f:Field, meta:String):MetadataEntry {
        var entry:MetadataEntry = null;
        for (m in f.meta) {
            if (m.name == meta || m.name == ":" + meta) {
                entry = m;
                break;
            }
        }
        return entry;
    }
    
    public static function hasMetaParam(meta:MetadataEntry, param:String):Bool {
        var has:Bool = false;
        for (p in meta.params) {
            switch (p.expr) {
                case EConst(CIdent(c)):
                    if (c == param) {
                        has = true;
                        break;
                    }
                case _:
            }
        }
        return has;
    }
    
    public static function insertLine(fn:{ expr : { pos : haxe.macro.Position, expr : haxe.macro.ExprDef } }, e:Expr, location:Int):Void {
        fn.expr = switch (fn.expr.expr) {
            case EBlock(el): macro $b{insertExpr(el, location, e)};
            case _: macro $b { insertExpr([fn.expr], location, e) }
        }
    }

    public static function insertExpr(arr:Array<Expr>, pos:Int, item:Expr):Array<Expr> {
        if (pos == -1) {
            arr.push(item);
        } else {
            arr.insert(pos, item);
        }
        return arr;
    }

    public static function hasInterface(t:haxe.macro.Type, interfaceRequired:String):Bool {
        var has:Bool = false;
        switch (t) {
                case TInst(t, _): {
                    while (t != null) {
                        for (i in t.get().interfaces) {
                            var interfaceName:String = i.t.toString();
                            if (interfaceName == interfaceRequired) {
                                has = true;
                                break;
                            }
                        }

                        if (has == false) {
                            if (t.get().superClass != null) {
                                t = t.get().superClass.t;
                            } else {
                                t = null;
                            }
                        } else {
                            break;
                        }
                    }
                }
                case _:
        }

        return has;
    }

    static function mkPath(name:String):TypePath {
        var parts = name.split('.');
        return {
            sub: null,
            params: [],
            name: parts.pop(),
            pack: parts
        }
    }

    static function mkType(s:String):ComplexType {
        return TPath(mkPath(s));
    }

    private static function getSuperClass(t:haxe.macro.Type) {
        var superClass = null;
        switch (t) {
                case TInst(t, _): {
                    superClass = t.get().superClass;
                }
                case _:
        }
        return superClass;
    }

    public static function getClassNameFromType(t:haxe.macro.Type):String {
        var className:String = "";
        switch (t) {
                case TAnonymous(t): className = t.toString();
                case TMono(t): className = t.toString();
                case TLazy(t): className = "";
                case TFun(t, _): className = t.toString();
                case TDynamic(t): className = "";
                case TInst(t, _): className = t.toString();
                case TEnum(t, _): className = t.toString();
                case TType(t, _): className = t.toString();
                case TAbstract(t, _): className = t.toString();
        }
        return className;
    }
    
    public static function skipPath(path:String):Bool {
        var skip:Bool = false;

        path = StringTools.replace(path, "\\", "/");

        for (s in SKIP_PATTERNS) {
            if (path.indexOf(s) != -1) {
                skip = true;
                break;
            }
        }

        return skip;
    }

    public static function resolveFile(file:String):String {
        var resolvedPath:String = null;
        if (sys.FileSystem.exists(file) == false) {
            var paths:Array<String> = Context.getClassPath();
            //paths.push("assets");

            for (path in paths) {
                path = path + "/" + file;
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
                        var temp:Array<haxe.macro.Type> = Context.getModule(pack + "." + name);
                        types = types.concat(temp);
                    }
                }
            }
        }

        return types;
    }

    public static function classNameFromType(t:haxe.macro.Type):String {
        var className:String = "";
        switch (t) {
                case TAnonymous(t): className = t.toString();
                case TMono(t): className = t.toString();
                case TLazy(t): className = "";
                case TFun(t, _): className = t.toString();
                case TDynamic(t): className = "";
                case TInst(t, _): className = t.toString();
                case TEnum(t, _): className = t.toString();
                case TType(t, _): className = t.toString();
                case TAbstract(t, _): className = t.toString();
        }

        var c = className.split(".");
        var name = c[c.length - 1];
        var module = moduleNameFromType(t);
        if (StringTools.endsWith(module, name) == false) {
            className = module + "." + name;
        }

        return className;
    }

    public static function moduleNameFromType(t:haxe.macro.Type):String {
        var moduleName:String = "";
        switch (t) {
            case TInst(t, _):
                moduleName = t.get().module;
            default:
        }
        return moduleName;
    }

    public static function addMeta(t:haxe.macro.Type, meta:String, pos:haxe.macro.Position) {
        switch (t) {
            case TInst(t, _):
                t.get().meta.add(meta, [], pos);
            default:
        }
    }

    public static function hasSuperClass(t:haxe.macro.Type, classRequired:String):Bool {
        var has:Bool = false;
        switch (t) {
                case TInst(t, _): {
                    if (t.toString() == classRequired) {
                        has = true;
                    } else {
                        while (t != null) {
                            if (t.get().superClass != null) {
                                if (t.toString() == classRequired) {
                                    has = true;
                                    break;
                                } else {
                                    t = t.get().superClass.t;
                                }
                            } else {
                                t = null;
                            }
                        }
                    }
                }
                case _:
        }

        return has;
    }

    public static function extension(path:String):String {
        if (path.indexOf(".") == -1) {
            return null;
        }
        var arr:Array<String> = path.split(".");
        var extension:String = arr[arr.length - 1];
        return extension;
    }

    public static function aliasType(source:String, target:String) {
        var pack = target.split(".");
        var name = pack.pop();

        var c = {
            pack : pack,
            name : name,
            pos : Context.currentPos(),
            meta : [],
            params : [],
            isExtern : false,
            kind : TDAlias(MacroHelpers.mkType(source)),
            fields : []
        }
        Context.defineType(c);
    }

    public static function buildGenericConfigCode(c:GenericConfig, name:String, v:Int = 0):String {
        var code:String = "";
        for (key in c.values.keys()) {
            code += 's${v}.values.set("${key}", "${c.values.get(key)}");\n';
        }
        for (sectionName in c.sections.keys()) {
            for (section in c.sections.get(sectionName)) {
                if (v == 0) {
                    code += 'var s1 = ${name}.addSection("${sectionName}");\n';
                } else {
                    code += 'var s${v + 1} = s${v}.addSection("${sectionName}");\n';
                }
                code += buildGenericConfigCode(section, name, v + 1);
            }
        }
        return code;
    }

    public static function scanClassPath(processFileFn:String->Bool, searchCriteria:Array<String> = null, skipHidden:Bool = true) {
        var paths:Array<String> = Context.getClassPath();
        var processedFiles:Array<String> = new Array<String>();
        while (paths.length != 0) {
            var path:String = paths[0];
            paths.remove(path);
            path = StringTools.replace(path, "\\", "/");

            if (MacroHelpers.skipPath(path) == true) {
                continue;
            }
            var pathArray:Array<String> = path.split("/");
            var lastPath:String = pathArray[pathArray.length - 1];
            if (StringTools.startsWith(lastPath, ".") && skipHidden == true) {
                continue;
            }

            if (sys.FileSystem.exists(path)) {
                if (sys.FileSystem.isDirectory(path)) {
                    var subDirs:Array<String> = sys.FileSystem.readDirectory(path);
                    var continueSearch = true;
                    for (subDir in subDirs) {
                        var fileName = subDir;
                        if (StringTools.endsWith(path, "/") == false && StringTools.endsWith(path, "\\") == false) {
                            subDir = path + "/" + subDir;
                        } else {
                            subDir = path + subDir;
                        }

                        if (sys.FileSystem.isDirectory(subDir) && StringTools.endsWith(subDir, "/cli") == false) {
                            subDir = StringTools.replace(subDir, "\\", "/");
                            paths.insert(0, subDir);
                        } else {
                            var file:String = subDir;
                            if (searchCriteria == null) {
                                if (processedFiles.indexOf(file) == -1) {
                                    continueSearch = !processFileFn(file);
                                    if (continueSearch == false) {
                                        processedFiles.push(file);
                                    }
                                } else {
                                    continueSearch = false;
                                }
                            } else {
                                var found:Bool = false;
                                for (s in searchCriteria) {
                                    if (StringTools.startsWith(fileName, s)) {
                                        found = true;
                                        break;
                                    }
                                }
                                if (found) {
                                    if (processedFiles.indexOf(file) == -1) {
                                        continueSearch = !processFileFn(file);
                                        if (continueSearch == false) {
                                            processedFiles.push(file);
                                        }
                                    } else {
                                        continueSearch = false;
                                    }
                                }
                            }
                        }

                        if (continueSearch == false) {
                            break;
                        }
                    }
                }
            }
        }
    }

    #end
}