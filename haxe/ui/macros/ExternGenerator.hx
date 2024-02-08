package haxe.ui.macros;

import haxe.macro.Expr.TypeParam;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import haxe.macro.ExprTools;
import haxe.macro.Type;

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
        generateExterns(types);
    }

    private static function useType(fullPath:String):Bool {
        if (fullPath.startsWith("haxe.ui")) {
            return true;
        }
        return false;
    }

    private static function generateExterns(types:Array<Type>) {
        var modules:Map<String, Array<Type>> = [];

        function addType(module:String, type:Type) {
            var types = modules.get(module);
            if (types == null) {
                types = [];
                modules.set(module, types);
            }
            types.push(type);
        }

        for (t in types) {
            switch (t) {
                case TInst(classType, params):
                    if (!classType.get().isPrivate && useType(classType.toString())) {
                        addType(classType.get().module, t);
                    }
                case TAbstract(abstractType, params):
                    if (!abstractType.get().isPrivate && useType(abstractType.toString())) {
                        addType(abstractType.get().module, t);
                    }
                case TEnum(enumType, params):    
                    if (!enumType.get().isPrivate && useType(enumType.toString())) {
                        addType(enumType.get().module, t);
                    }
                case TType(defType, params):    
                    if (!defType.get().isPrivate && useType(defType.toString())) {
                        addType(defType.get().module, t);
                    }
                case _:
                    trace("UNKNOWN: ", t);
            }
        }


        for (module in modules.keys()) {
            generateModule(module, modules.get(module));
        }

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
        copyOriginal("haxe.ui.util.Variant");
        copyOriginal("haxe.ui.util.Listener");
        copyOriginal("haxe.ui.Backend");
        copyBackendOriginal("haxe.ui.backend.BackendImpl");
        copyOriginal("haxe.ui.layouts.LayoutFactory");
        copyOriginal("haxe.ui.data.DataSourceFactory");
        //copyOriginal("haxe.ui.core.IEventDispatcher");
        copyOriginals("haxe.ui.constants");

        var moduleSourcePath = Path.normalize(rootDir() + "/haxe/ui/module.xml");
        var moduleDestPath = Path.normalize(outputPath + "/haxe/ui/module.xml");
        File.copy(moduleSourcePath, moduleDestPath);
    }

    private static function generateModule(module:String, types:Array<Type>) {
        //trace(module);
        var sb = new StringBuf();
        sb.add('// generated file\n');
        sb.add('package ');
        sb.add(extractPackage({module: module}));
        sb.add(';');
        sb.add('\n\n');

        for (t in types) {
            switch (t) {
                case TInst(classType, params):
                    if (classType.get().isInterface) {
                        generateInterface(classType.get(), sb);
                    } else {
                        generateExternClass(classType.get(), sb);
                    }
                case TAbstract(abstractType, params):
                    generateAbstract(abstractType.get(), sb);
                case TEnum(enumType, params):    
                    generateEnum(enumType.get(), sb);
                case TType(defType, params):    
                    generateTypeDef(defType.get(), sb);
                case _:
                    trace("UNKNOWN: ", t);
            }
        }

        var filename = Path.normalize(outputPath + "/" + module.replace(".", "/") + ".hx");
        writeFile(filename, sb);
    }

    private static function generateExternClass(classType:ClassType, sb:StringBuf) {
        var fullName = buildFullName(classType);
        if (fullName == "haxe.ui.backend.ComponentBase") {
            sb.add('@:build(haxe.ui.macros.Macros.buildBehaviours())\n');
            sb.add('@:autoBuild(haxe.ui.macros.Macros.buildBehaviours())\n');
            sb.add('@:build(haxe.ui.macros.Macros.build())\n');
            sb.add('@:autoBuild(haxe.ui.macros.Macros.build())\n');
        }

        if (classType.isPrivate) {
            sb.add('private ');
        }
        sb.add('extern ');
        sb.add('class ');
        sb.add(buildName(classType));

        if (classType.superClass != null) {
            sb.add(' extends ');
            sb.add(buildName(classType.superClass.t.get(), true));
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

        sb.add(' {');
        sb.add('\n');

        if (classType.constructor != null) {
            generateClassField(classType, classType.constructor.get(), sb);
        }
        for (f in classType.fields.get()) {
            generateClassField(classType, f, sb);
        }
        for (f in classType.statics.get()) {
            generateClassField(classType, f, sb, true);
        }

        sb.add('}');
        sb.add('\n\n');
    }

    private static function generateInterface(classType:ClassType, sb:StringBuf) {
        sb.add('interface ');
        sb.add(buildName(classType));

        if (classType.superClass != null) {
            sb.add(' extends ');
            sb.add(buildName(classType.superClass.t.get(), true));
        }

        if (classType.interfaces != null && classType.interfaces.length > 0) {
            for (i in classType.interfaces) {
                sb.add(' implements ');
                sb.add(i.t.toString());
            }
        }

        sb.add(' {');
        sb.add('\n');

        if (classType.constructor != null) {
            generateClassField(classType, classType.constructor.get(), sb);
        }
        for (f in classType.fields.get()) {
            if (f.name.startsWith("get_") || f.name.startsWith("set_")) {
                continue;
            }
            generateClassField(classType, f, sb);
        }
        for (f in classType.statics.get()) {
            if (f.name.startsWith("get_") || f.name.startsWith("set_")) {
                continue;
            }
            generateClassField(classType, f, sb, true);
        }

        sb.add('}');
        sb.add('\n\n');
    }

    private static function generateClassField(classType:{module:String, name:String}, field:ClassField, sb:StringBuf, isStatic:Bool = false, allowMethods:Bool = true, allowGettersSetters:Bool = true) {
        if (field.name.startsWith("_")) {
            return;
        }

        switch (field.kind) {
            case FVar(AccNormal, AccNormal) | FVar(AccNormal, AccNo) | FVar(AccInline, AccNever) | FVar(AccNormal, AccNever): // var
                generateVar(field.name, buildFullName(classType), field.type, sb, isStatic, !field.isPublic);

            case FVar(AccCall, AccCall) | FVar(AccNormal, AccCall): // get / set
                if (allowGettersSetters) {
                    generateGetterSetter(field.name, buildFullName(classType), field.type, sb, isStatic, !field.isPublic);
                } else {
                    generateVar(field.name, buildFullName(classType), field.type, sb, isStatic, !field.isPublic);
                }

            case FVar(AccNo, AccCall): // null / set
                if (allowGettersSetters) {
                    generateSetter(field.name, buildFullName(classType), field.type, sb, isStatic, !field.isPublic);
                } else {
                    generateVar(field.name, buildFullName(classType), field.type, sb, isStatic, !field.isPublic);
                }

            case FVar(AccCall, AccNo) | FVar(AccCall, AccNever): // set / null
                if (allowGettersSetters) {
                    generateGetter(field.name, buildFullName(classType), field.type, sb, isStatic, !field.isPublic);
                } else {
                    generateVar(field.name, buildFullName(classType), field.type, sb, isStatic, !field.isPublic);
                }

            case FMethod(k):
                if (allowMethods) {
                    generateMethod(field.name, buildFullName(classType), field.type, field.params, k, sb, isStatic, !field.isPublic);
                }
            case _:    
        }
    }

    private static function generateAbstract(abstractType:AbstractType, sb:StringBuf) {
        if (abstractType.meta.has(":enum")) {
            sb.add('enum ');
        }
        sb.add('abstract ');
        sb.add(buildName(abstractType));
        
        sb.add('(');
        sb.add(typeToString(abstractType.type));
        sb.add(') ');

        if (abstractType.from.length > 0) {
            var list = [];
            for (f in abstractType.from) {
                if (f.field != null) {
                    continue;
                }
                list.push('from ' + typeToString(f.t));
            }
            sb.add(list.join(' '));
            sb.add(' ');
        }

        if (abstractType.to.length > 0) {
            var list = [];
            for (f in abstractType.to) {
                list.push('to ' + typeToString(f.t));
            }
            sb.add(list.join(' '));
            sb.add(' ');
        }
        
        sb.add('{');
        sb.add('\n');

        if (abstractType.impl != null) {
            var classType = abstractType.impl.get();
            for (f in classType.statics.get()) {
                generateClassField(classType, f, sb, true, false, false);
            }
        }

        sb.add('}');
        sb.add('\n\n');
    }

    private static function generateEnum(enumType:EnumType, sb:StringBuf) {
        sb.add('enum ');
        sb.add(buildName(enumType));

        sb.add(' {');
        sb.add('\n');

        for (name in enumType.names) {
            sb.add('    ');
            sb.add(name);
            sb.add(';');
            sb.add('\n');
        }

        sb.add('}');
        sb.add('\n\n');
    }

    private static function generateTypeDef(defType:DefType, sb:StringBuf) {
        sb.add('typedef ');
        sb.add(buildName(defType));

        sb.add(' = {');
        sb.add('\n');

        switch (defType.type) {
            case TAnonymous(a):
                for (f in a.get().fields) {
                    generateClassField({module: defType.module, name: f.name}, f, sb);
                }
            case _:
        }

        sb.add('}');
        sb.add('\n\n');
    }

    private static function generateVar(name:String, className:String, type:Type, sb:StringBuf, isStatic:Bool = false, isPrivate:Bool = false) {
        sb.add('    ');
        if (isPrivate) {
            sb.add('private ');
        } else {
            sb.add('public ');
        }
        if (isStatic) {
            sb.add('static ');
        }
        sb.add('var ');
        sb.add(name);

        sb.add(':');
        sb.add(typeToString(type, [name, className]));

        sb.add(";");
        sb.add("\n");
    }

    private static function generateGetter(name:String, className:String, type:Type, sb:StringBuf, isStatic:Bool = false, isPrivate:Bool = false) {
        sb.add('    ');
        if (isPrivate) {
            sb.add('private ');
        } else {
            sb.add('public ');
        }
        if (isStatic) {
            sb.add('static ');
        }
        sb.add('var ');
        sb.add(name);
        sb.add('(get, null)');


        sb.add(':');
        sb.add(typeToString(type, [name, className]));

        sb.add(";");
        sb.add("\n");
    }

    private static function generateSetter(name:String, className:String, type:Type, sb:StringBuf, isStatic:Bool = false, isPrivate:Bool = false) {
        sb.add('    ');
        if (isPrivate) {
            sb.add('private ');
        } else {
            sb.add('public ');
        }
        if (isStatic) {
            sb.add('static ');
        }
        sb.add('var ');
        sb.add(name);
        sb.add('(null, set)');


        sb.add(':');
        sb.add(typeToString(type, [name, className]));

        sb.add(";");
        sb.add("\n");
    }

    private static function generateGetterSetter(name:String, className:String, type:Type, sb:StringBuf, isStatic:Bool = false, isPrivate:Bool = false) {
        sb.add('    ');
        if (isPrivate) {
            sb.add('private ');
        } else {
            sb.add('public ');
        }
        if (isStatic) {
            sb.add('static ');
        }
        sb.add('var ');
        sb.add(name);
        sb.add('(get, set)');


        sb.add(':');
        sb.add(typeToString(type, [name, className]));

        sb.add(";");
        sb.add("\n");
    }

    private static function generateMethod(name:String, className:String, type:Type, params:Array<TypeParameter>, k:MethodKind, sb:StringBuf, isStatic:Bool = false, isPrivate:Bool = false) {
        var methodArgs = null;
        var methodReturn = null;
        switch (type) {
            case TFun(args, ret):
                methodArgs = args;
                methodReturn = ret;
            case _:   
        }

        sb.add('    ');
        if (isPrivate) {
            sb.add('private ');
        } else {
            sb.add('public ');
        }
        if (isStatic) {
            sb.add('static ');
        }
        sb.add('function ');
        sb.add(name);

        sb.add(buildTypeParams(params));

        sb.add('(');
        var argList = [];
        var n = 0;
        for (arg in methodArgs) {
            if (arg.name == "_") {
                argList.push("arg" + n + ":Any");
                continue;
            }
            if (arg.opt) {
                argList.push('?${arg.name}:' + typeToString(arg.t, [name, className]));
            } else {
                argList.push('${arg.name}:' + typeToString(arg.t, [name, className]));
            }
            n++;
        }
        sb.add(argList.join(", "));
        sb.add(')');

        sb.add(':');
        sb.add(typeToString(methodReturn, [name, className]));
        sb.add(";");
        sb.add("\n");
    }

    private static function typeToString(type:Type, replacements:Array<String> = null) {
        if (replacements == null) {
            replacements = [];
        }

        replacements.push("StdTypes");

        var s = TypeTools.toString(type);
        switch (type) {
            case TInst(t, params):
                var classType = t.get();
                s = buildFullName(classType);
                var paramList = [];
                if (params.length > 0) {
                    for (p in params) {
                        paramList.push(typeToString(p, replacements));
                    }
                }
                if (paramList.length > 0) {
                    s += "<";
                    s += paramList.join(", ");
                    s += ">";
                }
            case TAbstract(t, params):
                var abstractType = t.get();
                s = buildFullName(abstractType);
                //s = t.toString();
                var paramList = [];
                if (params.length > 0) {
                    for (p in params) {
                        paramList.push(typeToString(p, replacements));
                    }
                }
                if (paramList.length > 0) {
                    s += "<";
                    s += paramList.join(", ");
                    s += ">";
                }
            case TType(t, params):    
                var typeType = t.get();
                s = buildFullName(typeType);
                //s = t.toString();
                var paramList = [];
                if (params.length > 0) {
                    for (p in params) {
                        paramList.push(typeToString(p, replacements));
                    }
                }
                if (paramList.length > 0) {
                    s += "<";
                    s += paramList.join(", ");
                    s += ">";
                }
            case _:
        }
        if (replacements != null) {
            for (r in replacements) {
                if (r != "validators" && r != "behaviours") { // filty hack
                    s = s.replace(r + ".", "");
                }
            }
        }
        return s;
    }

    ////////////////////////////////////////////////////////////////////////////////////
    // util functions
    ////////////////////////////////////////////////////////////////////////////////////
    private static function writeFile(filename:String, data:StringBuf) {
        var stringData = data.toString();
        var parts = filename.split("/");
        parts.pop();
        var path = parts.join("/");
        FileSystem.createDirectory(path);
        File.saveContent(filename, stringData);
    }

    private static function buildName(type:{module:String, name:String, params:Array<TypeParameter>}, full:Bool = false):String {
        var sb = new StringBuf();
        if (full) {
             sb.add(buildFullName(type));
        } else {
            sb.add(type.name);
        }
        sb.add(buildTypeParams(type.params));
        return sb.toString();
    }

    private static function buildTypeParams(params:Array<TypeParameter>) {
        if (params == null || params.length == 0) {
            return "";
        }

        var sb = new StringBuf();
        sb.add('<');
        var list = [];
        for (p in params) {
            if (p.defaultType != null) {
                list.push(p.name + ":" + TypeTools.toString(p.defaultType));
            } else {
                list.push(p.name);
            }
        }
        sb.add(list.join(", "));
        sb.add('>');
        return sb.toString();
    }

    private static function buildFullName(info:{module:String, name:String}):String {
        var fullName = info.module;
        if (!fullName.endsWith(info.name)) {
            fullName += "." + info.name;
        }
        return fullName;
    }

    private static function extractPackage(info:{module:String}):String {
        var pack = info.module.split(".");
        pack.pop();
        return pack.join(".");
    }

    ////////////////////////////////////////////////////////////////////////////////////
    // path functions
    ////////////////////////////////////////////////////////////////////////////////////
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

    ////////////////////////////////////////////////////////////////////////////////////
    // copy functions
    ////////////////////////////////////////////////////////////////////////////////////
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

    #end    
}