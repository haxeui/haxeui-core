package haxe.ui.macros;

import haxe.macro.Context;
import haxe.macro.TypeTools;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.ui.macros.helpers.ClassBuilder;

using StringTools;

/*
 current usage: --macro haxe.ui.macros.ExternGenerator.generate('output/path/to/externs')
 
 if you want to generate externs for everything, use:
 
--macro include('haxe.ui.components')
--macro include('haxe.ui.containers')
--macro include('haxe.ui.containers.dialogs')
--macro include('haxe.ui.containers.menus')
--macro include('haxe.ui.containers.properties')
*/

class ExternGenerator {
    #if macro
    private static var outputPath:String;
    
    public static function generate(outputPath:String = null) {
        if (outputPath == null) {
            outputPath = "externs";
        }
        ExternGenerator.outputPath = outputPath;
        haxe.macro.Context.onGenerate(onTypesGenerated);
    }

    private static function onTypesGenerated(types:Array<Type>) {
        generateComponentExterns(types);
    }

    private static function generateComponentExterns(types:Array<Type>) {
        for (t in types) {
            var classInfo = new ClassBuilder(t);
            switch (t) {
                case TInst(classType, params):
                    if (classType.toString().startsWith("haxe.ui")) {
                        generateExternClass(classType.get());
                    }
                case TAbstract(t, params):
                    if (t.toString().startsWith("haxe.ui")) {
                        generateExternAbstract(t.get());
                    }
                case TEnum(t, params):    
                    if (t.toString().startsWith("haxe.ui")) {
                        generateExternEnum(t.get());
                    }
                case TType(t, params):    
                    if (t.toString().startsWith("haxe.ui")) {
                        generateExternType(t.get());
                    }
                case _:
                    trace("UNKNOWN: ", t);
            }
        }

        /*
        writeEmptyClass("haxe.ui.backend.ComponentSurface");
        writeEmptyClass("haxe.ui.backend.EventImpl");
        */
        // were going to copy the originals here so macros will work with the externs
        copyOriginals("haxe.ui.macros");
        copyOriginals("haxe.ui.parsers");
        copyOriginal("haxe.ui.core.ComponentClassMap");
        copyOriginal("haxe.ui.core.ComponentFieldMap");
        copyOriginal("haxe.ui.core.TypeMap");
        copyOriginal("haxe.ui.util.EventInfo");
        copyOriginal("haxe.ui.util.StringUtil");
        copyOriginal("haxe.ui.util.TypeConverter");
        copyOriginal("haxe.ui.util.SimpleExpressionEvaluator");
        copyOriginal("haxe.ui.util.RTTI");
        copyOriginal("haxe.ui.util.ExpressionUtil");
        copyOriginal("haxe.ui.util.Defines");
        copyOriginal("haxe.ui.util.GenericConfig");
        copyOriginal("haxe.ui.Backend");
        copyBackendOriginal("haxe.ui.backend.BackendImpl");
        copyOriginal("haxe.ui.layouts.LayoutFactory");
        copyOriginal("haxe.ui.data.DataSourceFactory");
        copyOriginals("haxe.ui.constants");

        var moduleSourcePath = Path.normalize(rootDir() + "/haxe/ui/module.xml");
        var moduleDestPath = Path.normalize(outputPath + "/haxe/ui/module.xml");
        File.copy(moduleSourcePath, moduleDestPath);
    }

    private static function rootDir():String {
        var root = Path.normalize(Context.resolvePath("haxe/ui/Toolkit.hx"));
        var parts = root.split("/");
        parts.pop();
        parts.pop();
        parts.pop();
        return Path.normalize(parts.join("/"));
    }

    private static function backendRootDir():String {
        var root = Path.normalize(Context.resolvePath("haxe/ui/backend/ToolkitOptions.hx"));
        var parts = root.split("/");
        parts.pop();
        parts.pop();
        parts.pop();
        parts.pop();
        return Path.normalize(parts.join("/"));
    }

    private static function copyOriginals(pkg:String) {
        var fullSourcePath = Path.normalize(rootDir() + "/" + pkg.replace(".", "/"));
        var fullDestPath = Path.normalize(outputPath + "/" + pkg.replace(".", "/"));
        copyDir(fullSourcePath, fullDestPath);
    }

    private static function copyOriginal(className:String) {
        var fullSourcePath = Path.normalize(rootDir() + "/" + className.replace(".", "/") + ".hx");
        var fullDestPath = Path.normalize(outputPath + "/" + className.replace(".", "/") + ".hx");
        File.copy(fullSourcePath, fullDestPath);
    }

    private static function copyBackendOriginal(className:String) {
        var fullSourcePath = Path.normalize(backendRootDir() + "/" + className.replace(".", "/") + ".hx");
        var fullDestPath = Path.normalize(outputPath + "/" + className.replace(".", "/") + ".hx");
        File.copy(fullSourcePath, fullDestPath);
    }

    public static function copyDir(source:String, dest:String) {
        if (!FileSystem.exists(dest)) {
            FileSystem.createDirectory(dest);
        }
        var contents = FileSystem.readDirectory(source);
        for (item in contents) {
            var fullSourcePath = Path.normalize(source + "/" + item);
            var fullDestPath = Path.normalize(dest + "/" + item);
            if (FileSystem.isDirectory(fullSourcePath)) {
                copyDir(fullSourcePath, fullDestPath);
            } else {
                File.copy(fullSourcePath, fullDestPath);
            }
        }
    }

    private static function generateExternClass(classType:ClassType) {
        var fields = classType.fields.get();

        var fullName = classType.pack.join(".") + "." + classType.name;

        var sb = new StringBuf();
        sb.add('package ');
        sb.add(classType.pack.join("."));
        sb.add(';\n\n');

        if (fullName == "haxe.ui.backend.ComponentBase") {
            sb.add('@:build(haxe.ui.macros.Macros.build())\n');
            sb.add('@:autoBuild(haxe.ui.macros.Macros.build())\n');
        }

        if (classType.isInterface) {
            sb.add('interface ');
        } else {
            sb.add('extern class ');
        }
        sb.add(classType.name);
        if (classType.params != null && classType.params.length > 0) {
            sb.add('<');
            var ps = [];
            for (p in classType.params) {
                if (p.defaultType != null) {
                    ps.push(p.name + ":" + TypeTools.toString(p.defaultType));
                } else {
                    ps.push(p.name);
                }
            }
            sb.add(ps.join(", "));
            sb.add('>');
        }


        if (classType.superClass != null) {
            sb.add(' extends ');
            sb.add(classType.superClass.t.toString());
            var superClass = classType.superClass.t.get();
            if (superClass.params != null && superClass.params.length > 0) {
                sb.add('<');
                var ps = [];
                for (p in superClass.params) {
                    ps.push(p.name);
                }
                sb.add(ps.join(", "));
                sb.add('>');
            }
        }

        if (classType.interfaces != null && classType.interfaces.length > 0) {
            for (i in classType.interfaces) {
                sb.add(' implements ');
                sb.add(i.t.toString());
                if (i.t.toString() == "haxe.ui.core.IClonable") {
                    sb.add('<');
                    sb.add(fullName);
                    sb.add('>');
                }
            }
        }

        sb.add(' {\n');

        if (classType.constructor != null) {
            sb.add('    ');
            sb.add('public ');
            sb.add('function ');
            sb.add('new');
            sb.add('(');
            sb.add(')');
            sb.add(';');
            sb.add('\n\n');
        }

        for (f in fields) {
            if (f.isPublic == false) {
                continue;
            }

            switch (f.kind) {
                case FVar(AccCall, AccCall) | FVar(AccNormal, AccCall): // get / set
                    sb.add('    ');
                    sb.add('public var ');
                    sb.add(f.name);
                    sb.add('(get, set):');
                    sb.add(TypeTools.toString(f.type));
                    sb.add(';\n');

                    if (!classType.isInterface) {
                        sb.add('    ');
                        sb.add('private function get_');
                        sb.add(f.name);
                        sb.add('():');
                        sb.add(TypeTools.toString(f.type));
                        sb.add(';\n');

                        sb.add('    ');
                        sb.add('private function set_');
                        sb.add(f.name);
                        sb.add('(value:');
                        sb.add(TypeTools.toString(f.type));
                        sb.add('):');
                        sb.add(TypeTools.toString(f.type));
                        sb.add(';\n');
                    }


                    sb.add("\n");
                    
                case FVar(AccNormal, AccNormal) | FVar(AccNormal, AccNo): // var
                    sb.add('    ');
                    sb.add('public var ');
                    sb.add(f.name);
                    sb.add(':');
                    sb.add(TypeTools.toString(f.type).replace(fullName + ".", ""));
                    sb.add(';\n');

                case FVar(AccNo, AccCall): // null / set
                    sb.add('    ');
                    sb.add('public var ');
                    sb.add(f.name);
                    sb.add('(null, set):');
                    sb.add(TypeTools.toString(f.type));
                    sb.add(';\n');

                    if (!classType.isInterface) {
                        sb.add('    ');
                        sb.add('private function set_');
                        sb.add(f.name);
                        sb.add('(value:');
                        sb.add(TypeTools.toString(f.type));
                        sb.add('):');
                        sb.add(TypeTools.toString(f.type));
                        sb.add(';\n');
                    }

                    sb.add("\n");

                case FVar(AccCall, AccNo) | FVar(AccCall, AccNever): // set / null
                    sb.add('    ');
                    sb.add('public var ');
                    sb.add(f.name);
                    sb.add('(get, null):');
                    sb.add(TypeTools.toString(f.type));
                    sb.add(';\n');

                    if (!classType.isInterface) {
                        sb.add('    ');
                        sb.add('private function get_');
                        sb.add(f.name);
                        sb.add('():');
                        sb.add(TypeTools.toString(f.type));
                        sb.add(';\n');
                    }

                    sb.add("\n");

                case FMethod(k):    
                    //trace("    method", f.name);
                    sb.add('    ');
                    if (classType.isInterface && (f.name.startsWith("get_") || f.name.startsWith("set_"))) {
                        sb.add('private ');
                    } else {
                        sb.add('public ');
                    }
                    sb.add('function ');
                    sb.add(f.name);
                    if (f.params != null && f.params.length > 0) {
                        sb.add('<');
                        var ps = [];
                        for (p in f.params) {
                            if (p.defaultType != null) {
                                ps.push(p.name + ":" + TypeTools.toString(p.defaultType));
                            } else {
                                ps.push(p.name);
                            }
                        }
                        sb.add(ps.join(", "));
                        sb.add('>');
                    }

                    sb.add('(');
                    switch (f.type) {
                        case TFun(args, ret):
                            var argList = [];
                            for (a in args) {
                                if (a.opt) {
                                    argList.push("?" + a.name + ":" + TypeTools.toString(a.t).replace(f.name + ".", "").replace(fullName + ".", ""));
                                } else {
                                    argList.push(a.name + ":" + TypeTools.toString(a.t).replace(f.name + ".", "").replace(fullName + ".", ""));
                                }
                            }
                            sb.add(argList.join(", "));
                        case _:
                    }
                    sb.add(')');

                    sb.add(':');
                    switch (f.type) {
                        case TFun(args, ret):
                            sb.add(TypeTools.toString(ret).replace(f.name + ".", "").replace(fullName + ".", ""));
                        case _:
                            trace(f.type);
                    }
                    sb.add(";");
                    sb.add("\n\n");
                case _:
                    trace("UNSUPPORTED: " + f.name, f);
            }
        }
        
        sb.add('}\n');

        var filename = buildFileNameForExternClass(classType);
        writeFile(filename, sb);
    }

    private static function generateExternAbstract(t:AbstractType) {
        var sb = new StringBuf();
        sb.add('package ');
        sb.add(t.pack.join("."));
        sb.add(';\n\n');

        sb.add('abstract ');
        sb.add(t.name);
        if (t.params != null && t.params.length > 0) {
            sb.add('<');
            var ps = [];
            for (p in t.params) {
                if (p.defaultType != null) {
                    ps.push(p.name + ":" + TypeTools.toString(p.defaultType));
                } else {
                    ps.push(p.name);
                }
            }
            sb.add(ps.join(", "));
            sb.add('>');
        }
        if (t.type != null) {
            sb.add('(');
            sb.add(TypeTools.toString(t.type));
            sb.add(')');
        }
        if (t.from != null) {
            for (f in t.from) {
                if (f.field != null) {
                    continue;
                }
                sb.add(' from ');
                sb.add(TypeTools.toString(f.t));
            }
        }
        if (t.to != null) {
            for (f in t.to) {
                if (f.field != null) {
                    continue;
                }
                sb.add(' to ');
                sb.add(TypeTools.toString(f.t));
            }
        }

        sb.add(' {\n');

        sb.add('}\n');

        var filename = buildFileNameForExternAbstract(t);
        writeFile(filename, sb);
    }

    private static function generateExternEnum(t:EnumType) {
        var sb = new StringBuf();
        sb.add('package ');
        sb.add(t.pack.join("."));
        sb.add(';\n\n');

        sb.add('enum ');
        sb.add(t.name);

        sb.add(' {\n');

        sb.add('}\n');

        var filename = buildFileNameForExternEnum(t);
        writeFile(filename, sb);
    }

    private static function generateExternType(t:DefType) {
        var sb = new StringBuf();
        sb.add('package ');
        sb.add(t.pack.join("."));
        sb.add(';\n\n');

        sb.add('typedef ');
        sb.add(t.name);
        sb.add(' =');

        sb.add(' {\n');

        sb.add('}\n');

        var filename = buildFileNameForExternType(t);
        writeFile(filename, sb);
    }

    private static function writeEmptyClass(fullName:String) {
        var pack = fullName.split(".");
        var name = pack.pop();
        var sb = new StringBuf();

        sb.add('package ');
        sb.add(pack.join("."));
        sb.add(';\n\n');

        sb.add('extern class ');
        sb.add(name);
        sb.add(' {\n');

        /*
        sb.add('    ');
        sb.add('public function new();');
        sb.add('\n');
        */

        sb.add('}\n');

        var filename = Path.normalize(outputPath + "/" + fullName.replace(".", "/") + ".hx");
        writeFile(filename, sb);
    }

    private static function writeFile(filename:String, data:StringBuf) {
        var parts = filename.split("/");
        parts.pop();
        var path = parts.join("/");
        FileSystem.createDirectory(path);
        File.saveContent(filename, data.toString());
    }

    private static function buildFileNameForExternClass(classType:ClassType):String {
        var finalPack = [];
        for (p in classType.pack) {
            finalPack.push(p);
        }
        finalPack.push(classType.name);

        var s = Path.normalize(outputPath + "/" + finalPack.join("/") + ".hx");
        return s;
    }

    private static function buildFileNameForExternAbstract(t:AbstractType):String {
        var finalPack = [];
        for (p in t.pack) {
            finalPack.push(p);
        }
        finalPack.push(t.name);

        var s = Path.normalize(outputPath + "/" + finalPack.join("/") + ".hx");
        return s;
    }

    private static function buildFileNameForExternEnum(t:EnumType):String {
        var finalPack = [];
        for (p in t.pack) {
            finalPack.push(p);
        }
        finalPack.push(t.name);

        var s = Path.normalize(outputPath + "/" + finalPack.join("/") + ".hx");
        return s;
    }

    private static function buildFileNameForExternType(t:DefType):String {
        var finalPack = [];
        for (p in t.pack) {
            finalPack.push(p);
        }
        finalPack.push(t.name);

        var s = Path.normalize(outputPath + "/" + finalPack.join("/") + ".hx");
        return s;
    }
    #end    
}