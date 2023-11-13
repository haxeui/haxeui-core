package haxe.ui.macros;

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
            /*
            if (classInfo.hasSuperClass("haxe.ui.backend.ComponentBase")) {
                switch (t) {
                    case TInst(classType, params):
                        generateExtern(classType.get());
                    case _:
                }
            } else if (classInfo.hasSuperClass("haxe.ui.backend.EventImpl")) {
                switch (t) {
                    case TInst(classType, params):
                        generateExtern(classType.get());
                    case _:
                }
            }
            */
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
    }

    private static function generateExternClass(classType:ClassType) {
        var fields = classType.fields.get();

        var fullName = classType.pack.join(".") + "." + classType.name;

        var sb = new StringBuf();
        sb.add('package ');
        sb.add(classType.pack.join("."));
        sb.add(';\n\n');

        sb.add('extern class ');
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
        }

        sb.add(' {\n');

        if (classType.constructor != null) {
            sb.add('    ');
            sb.add('public ');
            sb.add('function ');
            sb.add('new');
            sb.add('(');
            /*
            switch (classType.constructor.get().kind) {
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
            */
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

                    sb.add('    ');
                    sb.add('private function set_');
                    sb.add(f.name);
                    sb.add('(value:');
                    sb.add(TypeTools.toString(f.type));
                    sb.add('):');
                    sb.add(TypeTools.toString(f.type));
                    sb.add(';\n');

                    sb.add("\n");

                case FVar(AccCall, AccNo) | FVar(AccCall, AccNever): // set / null
                    sb.add('    ');
                    sb.add('public var ');
                    sb.add(f.name);
                    sb.add('(get, null):');
                    sb.add(TypeTools.toString(f.type));
                    sb.add(';\n');

                    sb.add('    ');
                    sb.add('private function get_');
                    sb.add(f.name);
                    sb.add('():');
                    sb.add(TypeTools.toString(f.type));
                    sb.add(';\n');

                    sb.add("\n");

                case FMethod(k):    
                    //trace("    method", f.name);
                    sb.add('    ');
                    sb.add('public ');
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
                    /*
                    switch (f.type) {
                        case _:
                            if (f.name == "cloneComponent")
                            trace(f.type);
                    }
                    //sb.add(TypeTools.toString(f.type));
                    */

                    /*
                    if (f.name == "cloneComponent") {
                        trace(f);
                    }
                    */
                    sb.add(";");
                    sb.add("\n\n");
                case _:
                    trace("UNSUPPORTED: " + f.name, f);
            }
        }
        
        sb.add('}\n');

        var filename = buildFileNameForExternClass(classType);
        //trace(">>>>>>>>>>> ", filename);
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