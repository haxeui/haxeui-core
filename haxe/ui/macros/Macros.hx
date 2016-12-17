package haxe.ui.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Macros {
    #if macro
    //private static var SKIP_PATTERNS = ["/lib/actuate/", "/lib/lime/", "/lib/openfl/", "/haxe/std/"];
    //private static var _modules:Array<Module2> = new Array<Module2>();

    //private static var _componentClasses:Map<String, String> = new Map<String, String>();

    macro public static function buildBindings():Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        var bindableFields:Array<Field> = getFieldsWithMeta("bindable", fields);
        if (bindableFields.length != 0) {
            // build get property
            var code:String = "";
            code += "function(name:String):haxe.ui.util.Variant {\n";
            code += "switch (name) {\n";
            for (f in bindableFields) {
                code += "case '" + f.name + "': return this." + f.name + ";";
            }
            code += "}\n";
            code += "return super.getProperty(name);";
            code += "}\n";

            var access:Array<Access> = [APublic, AOverride];
            addFunction("getProperty", Context.parseInlineString(code, pos), access, fields, pos);

            // build set property
            var code = "";
            code += "function(name:String, v:haxe.ui.util.Variant):haxe.ui.util.Variant {\n";
            code += "switch (name) {\n";
            for (f in bindableFields) {
                code += "case '" + f.name + "': return this." + f.name + " = v;\n";
            }
            code += "}\n";
            code += "return super.setProperty(name, v);";
            code += "}\n";
            var access:Array<Access> = [APublic, AOverride];
            addFunction("setProperty", Context.parseInlineString(code, pos), access, fields, pos);
        }

        return fields;
    }

    macro public static function addClonable():Array<Field> {
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();
        if (hasInterface(Context.getLocalType(), "haxe.ui.core.IClonable") == false) {
            return fields;
        }

        var currentCloneFn = getFunction("cloneComponent", fields);
        var t:haxe.macro.Type = Context.getLocalType();
        var className:String = getClassNameFromType(t);
        var filePath = StringTools.replace(className, ".", "/");
        filePath = "src/" + filePath + ".hx";
        pos = Context.makePosition( { min: 0, max:0, file: filePath});

        var useSelf:Bool = false;
        if (className == "haxe.ui.core.Component") {
            useSelf = true;
        }

        var n1:Int = className.indexOf("_");
        if (n1 != -1) {
            var n2:Int = className.indexOf(".", n1);
            className = className.substr(0, n1) + className.substr(n2 + 1, className.length);
        }

        if (currentCloneFn == null) {
            var code:String = "";
            code += "function():" + className + " {\n";

            if (useSelf == false) {
                code += "var c:" + className + " = cast super.cloneComponent();\n";
                for (f in getFieldsWithMeta("clonable", fields)) {
                    code += "c." + f.name + " = this." + f.name + ";\n";
                }

            } else {
                code += "var c:" + className + " = self();\n";
                for (f in getFieldsWithMeta("clonable", fields)) {
                    code += "c." + f.name + " = this." + f.name + ";\n";
                }

                code += "if (this.childComponents.length != c.childComponents.length) for (child in this.childComponents) c.addComponent(child.cloneComponent());\n";
            }
            code += "return c;\n";
            code += "}\n";

            //trace(code);

            var access:Array<Access> = [APublic];
            if (useSelf == false) {
                access.push(AOverride);
            }
            addFunction("cloneComponent", Context.parseInlineString(code, pos), access, fields, pos);
        } else {
            var n = 0;
            var code:String = "";
            if (useSelf == false) {
                code += "var c:" + className + " = cast super.cloneComponent()\n";
            } else {
                code += "var c:" + className + " = self()\n";
            }

            insertLine(currentCloneFn, Context.parseInlineString(code, pos), n++);

            for (f in getFieldsWithMeta("clonable", fields)) {
                code = "c." + f.name + " = this." + f.name + "";
                insertLine(currentCloneFn, Context.parseInlineString(code, pos), n++);
            }

            if (useSelf == true) {
                insertLine(currentCloneFn, Context.parseInlineString("if (this.childComponents.length != c.childComponents.length) for (child in this.childComponents) c.addComponent(child.cloneComponent())", pos), n++);
            }

            insertLine(currentCloneFn, Context.parseInlineString("return c", pos), -1);
        }

        var code:String = "";
        code += "function():" + className + " {\n";
        code += "return new " + className + "();\n";
        code += "}\n";
        var access:Array<Access> = [APrivate];
        if (useSelf == false) {
            access.push(AOverride);
        }
        addFunction("self", Context.parseInlineString(code, pos), access, fields, pos);

        return fields;
    }
    #end

    /*
    macro public static function buildComponent_OLD(filePath:String):Expr {
        _componentClasses.set("absolute", "haxe.ui.containers.Absolute");
        _componentClasses.set("vbox", "haxe.ui.containers.VBox");
        _componentClasses.set("hbox", "haxe.ui.containers.HBox");
        _componentClasses.set("textfield", "haxe.ui.components.TextField");
        _componentClasses.set("button", "haxe.ui.components.Button");
        _componentClasses.set("label", "haxe.ui.components.Label");
        _componentClasses.set("image", "haxe.ui.components.Image");
        _componentClasses.set("vscroll", "haxe.ui.components.VScroll");
        _componentClasses.set("hscroll", "haxe.ui.components.HScroll");
        _componentClasses.set("scrollview", "haxe.ui.containers.ScrollView");
        _componentClasses.set("checkbox", "haxe.ui.components.CheckBox");
        _componentClasses.set("optionbox", "haxe.ui.components.OptionBox");
        _componentClasses.set("component", "haxe.ui.core.Component");
        _componentClasses.set("hprogress", "haxe.ui.components.HProgress");
        _componentClasses.set("vprogress", "haxe.ui.components.VProgress");
        _componentClasses.set("hslider", "haxe.ui.components.HSlider");
        _componentClasses.set("vslider", "haxe.ui.components.VSlider");
        _componentClasses.set("tabbar", "haxe.ui.components.TabBar");
        _componentClasses.set("tabview", "haxe.ui.containers.TabView");

        #if haxeui_no_scrollview
            _componentClasses.remove("scrollview");
        #end

        var f = resolveFile_OLD(filePath);
        if (f == null) {
            throw "Could not resolve: " + filePath;
        }

        var contents:String = sys.io.File.getContent(f);
        var xml:Xml = Xml.parse(contents);

        var code:String = "function() {\n";

        objectId = 0;
        code += buildComponentNode_OLD(xml.firstElement());
        //code += assignBindings(xml.firstElement());
        code += "return c0;\n";
        code += "}()\n";

        //trace(code);
        return Context.parseInlineString(code, Context.currentPos());
    }
    */

    #if macro
    /*
    private static function assignBindings_OLD(node:Xml):String {
        var s = "";
        var nodeName:String = node.nodeName;
        if (nodeName == "bind") {
            var source:Array<String> = node.get("source").split(".");
            var target:Array<String> = node.get("target").split(".");
            var transform:String = node.get("transform");
            if (transform != null) {
                transform = "'" + transform + "'";
            }
            var targetProp = target[1];
            if (targetProp != null) {
                targetProp = "'" + targetProp + "'";
            }
            var sourceProp = source[1];
            if (sourceProp != null) {
                sourceProp = "'" + sourceProp + "'";
            }
            s = "var temp = c0.findChild('" + source[0] + "', null, true);";
            s += "if (temp != null) c0.findChild('" + source[0] + "', null, true).addBinding(c0.findChild('" + target[0] + "', null, true), " + transform + ", " + targetProp + ", " + sourceProp + ");\n";
        }


        for (child in node.elementsNamed("bind")) {
            s += assignBindings_OLD(child);
        }

        return s;
    }

    private static var objectId:Int = 0;
    private static function buildComponentNode_OLD(node:Xml, parentId:Int = -1):String {
        var s = "";

        var nodeName:String = node.nodeName;
        if (nodeName == "script") {
            var scriptValue = node.firstChild().nodeValue;
            scriptValue = StringTools.replace(scriptValue, "\"", "\\\"");
            return "c" + parentId + ".script = \"" + scriptValue + "\";\n";
        }
        if (nodeName == "style") {
            var styleString = node.firstChild().nodeValue;
            return "haxe.ui.Toolkit.styleSheet.addRules('" + styleString + "');\n";
        }
        var className:String = _componentClasses.get(nodeName);
        if (className == null) {
            return "";
        }

        var id = objectId;
        s += "var c" + id + ":" + className + " = new " + className + "();\n";
        //s += "c" + id + ".addBinding;\n";
        for (attr in node.attributes()) {
            var value = node.get(attr);
            if (attr != "text" && attr != "style" && StringTools.endsWith(value, "%") == true) {
                value = "" + Std.parseInt(value);
                attr = "percent" + StringUtil.capitalizeFirstLetter(attr);
            } else  if (attr != "text" && Std.parseInt(value) != null) {
                value = "" + Std.parseInt(value);
            } else if (value == "true" || value == "yes" || value == "false" || value == "no") {
                value = "" + (value == "true" || value == "yes");
            } else if (StringTools.startsWith(attr, "on") == false) {
                value = "'" + value + "'";
            }
            if (attr == "style") {
                attr = "styleString";
            }
            if (StringTools.startsWith(attr, "on")) {
                s += "c" + id + ".addScriptEvent('" + attr + "', \"" + value + "\");\n";
            } else {
                s += "c" + id + "." + attr + " = " + value + ";\n";
            }
        }

        if (parentId != -1) {
            s += "c" + parentId + ".addComponent(c" + id + ");\n";
        }

        objectId++;

        for (child in node.elements()) {
            s += buildComponentNode_OLD(child, id);
        }

        return s;
    }

    private static function resolveFile_OLD(file:String):String {
        var resolvedPath:String = null;
        if (sys.FileSystem.exists(file) == false) {
            var paths:Array<String> = Context.getClassPath();
            paths.push("assets");

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
    */
    #end

    /*
    macro public static function processModules_OLD():Expr {
        var code:String = "function() {\n";

        loadModules_OLD();

        for (m in _modules) {
            for (r in m.resourceEntries) {
                var resolvedPath = Context.resolvePath(r.path);
                addResources_OLD(resolvedPath, resolvedPath, r.prefix);
            }

            for (t in m.themeEntries) {
                if (t.parent != null) {
                    code += "haxe.ui.themes.ThemeManager.instance.getTheme('" + t.name + "').parent = '" + t.parent + "';\n";
                }
                for (r in t.styles) {
                    code += "haxe.ui.themes.ThemeManager.instance.addStyleResource('" + t.name + "', '" + r + "');\n";
                }
            }
        }

        code += "}()\n";
        //trace(code);
        return Context.parseInlineString(code, Context.currentPos());
    }
    */

    #if macro
    /*
    private static function addResources_OLD(path:String, base:String, prefix) {
        var contents:Array<String> = sys.FileSystem.readDirectory(path);
        for (f in contents) {
            var file = path + "/" + f;
            if (sys.FileSystem.isDirectory(file)) {
                addResources_OLD(file, base, prefix);
            } else {
                var relativePath = prefix + StringTools.replace(file, base, "");
                Context.addResource(relativePath, File.getBytes(file));
                //trace("Added resource '" + relativePath + "'");
            }
        }
    }

    private static var _modulesLoaded:Bool = false;
    public static function loadModules_OLD():Void {
        if (_modulesLoaded == true) {
            return;
        }

        var paths:Array<String> = Context.getClassPath();
        while (paths.length != 0) {
            var path:String = paths[0];
            paths.remove(path);
            path = StringTools.replace(path, "\\", "/");
            var use = true;
            for (s in SKIP_PATTERNS) {
                if (path.indexOf(s) != -1) {
                    use = false;
                    break;
                }
            }

            if (use == false) {
                continue;
            }

            if (sys.FileSystem.exists(path)) {
                if (sys.FileSystem.isDirectory(path)) {
                    var subDirs:Array<String> = sys.FileSystem.readDirectory(path);
                    for (subDir in subDirs) {
                        if (StringTools.endsWith(path, "/") == false && StringTools.endsWith(path, "\\") == false) {
                            subDir = path + "/" + subDir;
                        } else {
                            subDir = path + subDir;
                        }

                        if (sys.FileSystem.isDirectory(subDir)) {
                            paths.insert(0, subDir);
                        } else {
                            var file:String = subDir;
                            if (StringTools.endsWith(file, "module.xml")) {
                                processModule_OLD(file);
                            }
                        }
                    }
                }
            }
        }

        _modulesLoaded = true;
    }

    private static function processModule_OLD(file:String):Void {
        var xml:Xml = Xml.parse(sys.io.File.getContent(file));
        var m:Module2 = new Module2();
        m.fromXML(xml.firstElement());
        _modules.push(m);
    }
    */

    public static function buildStyles():Array<Field> {
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();

        for (f in getFieldsWithMeta("style", fields)) {
            var name = f.name;
            f.name = "_" + name;
            f.access = [APrivate];
            var type:ComplexType = null;
            switch (f.kind) {
                case FVar(f, _): {
                    type = f;
                }
                case _:
            }
            var typeName:String = null;
            var subType:String = null;
            switch (type) { // almost certainly a better way to be doing this
                case TPath(type): {
                    typeName = "";
                    if (type.pack.length > 0) {
                        typeName += type.pack.join(".") + ".";
                    }
                    if (type.params != null && type.params.length == 1) {
                        switch (type.params[0]) {
                            case TPType(p):
                                switch (p) {
                                    case TPath(tp):
                                        subType = tp.name;
                                    case _:
                                }
                            case _:
                        }
                    }
                    if (subType == null) {
                        typeName += type.name;
                    } else {
                        typeName += type.name + '<${subType}>';
                    }
                }
                case _:
            }

            // add getter/setter property
            var meta = [];
            meta.push( { name: ":style", pos: pos, params: [] } );
            meta.push( { name: ":clonable", pos: pos, params: [] } );

            var params:Array<Expr> = [];
            params.push({expr: Context.parseInlineString('group="Style properties"', pos).expr, pos:pos});
            meta.push( { name: ":dox", pos: pos, params: params } );
            fields.push({
                            name: name,
                            doc: null,
                            meta: meta,
                            access: [APublic],
                            kind: FProp("get", "set", type),
                            pos: haxe.macro.Context.currentPos()
                        });

            // add getter function
            var code = "function ():" + typeName + " {\n";
            if (getClassNameFromType(Context.getLocalType()) != "haxe.ui.styles.Style") {
                var defaultValue:Dynamic = null;
                if (typeName == "Float" || typeName == "Int") {
                    defaultValue = 0;
                } else if (typeName == "Bool") {
                    defaultValue = false;
                }
                if (defaultValue != null || subType != null) {
                    code += "if (style == null || style." + name + " == null) {\n return " + defaultValue + ";\n }\n";
                }
                code += "return style." + name + ";\n";
            } else {
                code += "return " + f.name + ";\n";
            }
            code += "}";
            var fnGetter = switch (Context.parseInlineString(code, haxe.macro.Context.currentPos()) ).expr {
                case EFunction(_, f): f;
                case _: throw "false";
            }
            fields.push({
                            name: "get_" + name,
                            doc: null,
                            meta: [],
                            access: [APrivate],
                            kind: FFun(fnGetter),
                            pos: haxe.macro.Context.currentPos()

                        });

            // add setter funtion
            var code = "function (value:" + typeName + "):" + typeName + " {\n";
            if (getClassNameFromType(Context.getLocalType()) == "haxe.ui.styles.Style") {
                code += "" + f.name + " = value;\n";
            } else {
                code += "if (customStyle." + name + " == value) return value;\n";
                code += "customStyle." + name + " = value;\n";
                code += "invalidateStyle();\n";
            }
            code += "return value;\n";
            code += "}";

            var fnSetter = switch (Context.parseInlineString(code, haxe.macro.Context.currentPos()) ).expr {
                case EFunction(_, f): f;
                case _: throw "false";
            }
            fields.push({
                            name: "set_" + name,
                            doc: null,
                            meta: [],
                            access: [APrivate],
                            kind: FFun(fnSetter),
                            pos: haxe.macro.Context.currentPos()

                        });
        }

        return fields;
    }

    private static function insertLine(fn:{ expr : { pos : haxe.macro.Position, expr : haxe.macro.ExprDef } }, e:Expr, location:Int):Void {
        fn.expr = switch (fn.expr.expr) {
            case EBlock(el): macro $b{insertExpr(el, location, e)};
            case _: macro $b { insertExpr([fn.expr], location, e) }
        }
    }

    private static function insertExpr(arr:Array<Expr>, pos:Int, item:Expr):Array<Expr> {
        if (pos == -1) {
            arr.push(item);
        } else {
            arr.insert(pos, item);
        }
        return arr;
    }

    private static function addFunction(name:String, e:Expr, access:Array<Access>, fields:Array<Field>, pos:Position):Void {
        var fn = switch (e).expr {
            case EFunction(_, f): f;
            case _: throw "false";
        }
        fields.push( { name : name, doc : null, meta : [], access : access, kind : FFun(fn), pos : pos } );
    }

    private static function getFunction(name:String, fields:Array<Field>) {
        var fn = null;
        for (f in fields) {
            if (f.name == name) {
                switch (f.kind) {
                    case FFun(f):
                            fn = f;
                        break;
                    default:
                }
                break;
            }
        }
        return fn;
    }

    private static function getFieldsWithMeta(meta:String, fields:Array<Field>):Array<Field> {
        var arr:Array<Field> = new Array<Field>();

        for (f in fields) {
            if (hasMeta(f, meta)) {
                arr.push(f);
            }
        }

        return arr;
    }

    private static function hasMeta(f:Field, meta:String):Bool {
        var has:Bool = false;
        for (m in f.meta) {
            if (m.name == meta || m.name == ":" + meta) {
                has = true;
                break;
            }
        }
        return has;
    }

    private static function hasInterface(t:haxe.macro.Type, interfaceRequired:String):Bool {
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

    private static function getClassNameFromType(t:haxe.macro.Type):String {
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

    /*
    macro public static function buildBackendTypes_OLD():Expr {
        //haxe.macro.Context.registerModuleDependency("haxe.ui.Capabilities", "noexist");
        Backends2.loadBackends();
        var backend = Backends2.firstBackend;
        if (backend == null) {
            throw "Backend2 config not found";
        }

        for (classEntry in backend.classEntries) {
            var source:String = classEntry.source;
            var target:String = classEntry.target;
            //trace("replacing '" + target + "' with '" + source + "'");

            var pack = target.split(".");
            var name = pack.pop();

            var c = {
                pack : pack,
                name : name,
                pos : Context.currentPos(),
                meta : [],
                params : [],
                isExtern : false,
                kind : TDAlias(mkType(source)),
                fields : []
            }
            Context.defineType(c);

        }

        return macro null;
    }
    */
    #end
}
