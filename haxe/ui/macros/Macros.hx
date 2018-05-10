package haxe.ui.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Macros {
    #if macro
    
    macro public static function buildBindings():Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        var bindableFields:Array<Field> = MacroHelpers.getFieldsWithMeta("bindable", fields);
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

            var access:Array<Access> = [APrivate, AOverride];
            MacroHelpers.addFunction("getProperty", Context.parseInlineString(code, pos), access, fields, pos);

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
            var access:Array<Access> = [APrivate, AOverride];
            MacroHelpers.addFunction("setProperty", Context.parseInlineString(code, pos), access, fields, pos);
        }

        return fields;
    }

    macro public static function addClonable():Array<Field> {
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();
        if (MacroHelpers.hasInterface(Context.getLocalType(), "haxe.ui.core.IClonable") == false) {
            return fields;
        }

        function getFieldCloneCode(field:Field):String {
            var type:Null<ComplexType> = null;
            switch (field.kind) {
                case FProp(_, _, t, _):
                    type = t;

                case FVar(t, _):
                    type = t;

                default:
            }

            if (type != null) {
                switch (type) { // almost certainly a better way to be doing this
                    case TPath(typePath):
                        if(typePath.name == "String" || typePath.name == "Null") {
                            return "if (this." + field.name + " != null) { c." + field.name + " = this." + field.name + "; }\n";
                        }

                    default:
                }
            }

            return "c." + field.name + " = this." + field.name;
        }

        var currentCloneFn = MacroHelpers.getFunction(fields, "cloneComponent");
        var t:haxe.macro.Type = Context.getLocalType();
        var className:String = MacroHelpers.getClassNameFromType(t);
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
                for (f in MacroHelpers.getFieldsWithMeta("clonable", fields)) {
                    code += getFieldCloneCode(f) + ";\n";
                }

            } else {
                code += "var c:" + className + " = self();\n";
                for (f in MacroHelpers.getFieldsWithMeta("clonable", fields)) {
                    code += getFieldCloneCode(f) + ";\n";
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
            MacroHelpers.addFunction("cloneComponent", Context.parseInlineString(code, pos), access, fields, pos);
        } else {
            var n = 0;
            var code:String = "";
            if (useSelf == false) {
                code += "var c:" + className + " = cast super.cloneComponent()\n";
            } else {
                code += "var c:" + className + " = self()\n";
            }

            MacroHelpers.insertLine(currentCloneFn, Context.parseInlineString(code, pos), n++);

            for (f in MacroHelpers.getFieldsWithMeta("clonable", fields)) {
                code = getFieldCloneCode(f);
                MacroHelpers.insertLine(currentCloneFn, Context.parseInlineString(code, pos), n++);
            }

            if (useSelf == true) {
                MacroHelpers.insertLine(currentCloneFn, Context.parseInlineString("if (this.childComponents.length != c.childComponents.length) for (child in this.childComponents) c.addComponent(child.cloneComponent())", pos), n++);
            }

            MacroHelpers.insertLine(currentCloneFn, Context.parseInlineString("return c", pos), -1);
        }

        var code:String = "";
        code += "function():" + className + " {\n";
        code += "return new " + className + "();\n";
        code += "}\n";
        var access:Array<Access> = [APrivate];
        if (useSelf == false) {
            access.push(AOverride);
        }
        MacroHelpers.addFunction("self", Context.parseInlineString(code, pos), access, fields, pos);

        return fields;
    }

    public static function buildStyles():Array<Field> {
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();

        for (f in MacroHelpers.getFieldsWithMeta("style", fields)) {
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
            
            var kind = FProp("get", "set", type);
            if (MacroHelpers.hasMetaParam(MacroHelpers.getMeta(f, "style"), "writeonly")) {
                kind = FProp("null", "set", type);
            }
            

            fields.push({
                            name: name,
                            doc: null,
                            meta: meta,
                            access: [APublic],
                            kind: kind,
                            pos: haxe.macro.Context.currentPos()
                        });

            // add getter function
            if (MacroHelpers.hasMetaParam(MacroHelpers.getMeta(f, "style"), "writeonly") == false) {
                var code = "function ():" + typeName + " {\n";
                var defaultValue:Dynamic = null;
                if (typeName == "Float" || typeName == "Int") {
                    defaultValue = 0;
                } else if (typeName == "Bool") {
                    defaultValue = false;
                }
                code += "if (style == null || style." + name + " == null) {\n return " + defaultValue + ";\n }\n";
                code += "return style." + name + ";\n";
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
            }
            
            // add setter funtion
            var code = "function (value:" + typeName + "):" + typeName + " {\n";
            if (MacroHelpers.hasMetaParam(MacroHelpers.getMeta(f, "style"), "writeonly") == false) {
                code += "if (customStyle." + name + " == value) return value;\n";
            }
            code += "if (_style == null) _style = new Style();\n";
            code += "customStyle." + name + " = value;\n";
            code += "invalidateComponentStyle();\n";
            if (MacroHelpers.hasMetaParam(MacroHelpers.getMeta(f, "style"), "layout")) {
                code += "invalidateComponentLayout();\n";
            }
            if (MacroHelpers.hasMetaParam(MacroHelpers.getMeta(f, "style"), "layoutparent")) {
                code += "if (parentComponent != null) { parentComponent.invalidateComponentLayout(); };";
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

    #end
}
