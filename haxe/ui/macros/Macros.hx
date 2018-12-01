package haxe.ui.macros;
import haxe.ui.util.StringUtil;


#if macro
import haxe.macro.Type;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.Ref;
import haxe.macro.TypeTools;
import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Macros {
    #if macro
    
    macro public static function buildComposite():Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        if ((Context.getLocalClass().get().meta.has(":composite") == false && Context.getLocalClass().get().meta.has("composite") == false)
            && (Context.getLocalClass().get().meta.has(":xml") == false && Context.getLocalClass().get().meta.has("xml") == false)) {
            return fields;
        }
        
        var meta = null;
        if (Context.getLocalClass().get().meta.has(":xml") == true) {
            meta = Context.getLocalClass().get().meta.extract(":xml");
        } else if (Context.getLocalClass().get().meta.has("xml") == true) {
            meta = Context.getLocalClass().get().meta.extract("xml");
        }
        if (meta != null) {
            var m = null;
            for (t in meta) {
                if (t.name == "xml" || t.name == ":xml") {
                    m = t;
                    break;
                }
            }
            
            var ctor = MacroHelpers.getConstructor(fields);
            if (MacroHelpers.hasSuperClass(Context.getLocalType(), "haxe.ui.core.Component") == false) {
                Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
            }

            if (ctor == null) Context.error("A class building component must have a constructor", Context.currentPos());
            
            var xml = ExprTools.toString(m.params[0]);
            xml = StringTools.trim(xml.substring(1, xml.length - 1));
            xml = StringTools.replace(xml, "\\n", "");
            xml = StringTools.replace(xml, "\\r", "");
            xml = StringTools.replace(xml, "\\\"", "\"");
            xml = StringTools.replace(xml, "\\'", "'");

            ModuleMacros.populateClassMap();
            
            var namedComponents:Map<String, String> = new Map<String, String>();
            var expr = ComponentMacros.buildComponentFromString([], xml, namedComponents, null);
            switch (expr.expr) {
                case EBlock(el): el.push(Context.parseInlineString("addComponent(c0)", pos));
                case _: 
            }
            
            var currentCreateChildrenFn = MacroHelpers.getFunction(fields, "createChildren");
            if (currentCreateChildrenFn != null) {
                MacroHelpers.appendLine(currentCreateChildrenFn, expr);
            } else {
                var code:String = "";
                code += "function() {\n";
                code += "super.createChildren();\n";
                code += ExprTools.toString(expr);
                code += "}";
                
                var access:Array<Access> = [APrivate, AOverride];
                MacroHelpers.addFunction("createChildren", Context.parseInlineString(code, pos), access, fields, pos);
            }
            
            var n = 1;
            for (id in namedComponents.keys()) {
                var safeId:String = StringUtil.capitalizeHyphens(id);
                var cls:String = namedComponents.get(id);
                var classArray:Array<String> = cls.split(".");
                var className = classArray.pop();
                var ttype = TPath( { pack : classArray, name : className, params : [], sub : null } );
                fields.push( { name : safeId, doc : null, meta : [], access : [APublic], kind : FVar(ttype, null), pos : pos } );

                var e:Expr = Context.parseInlineString('this.${safeId} = findComponent("${id}", ${cls}, true)', Context.currentPos());
                ctor.expr = switch(ctor.expr.expr) {
                    case EBlock(el): macro $b{MacroHelpers.insertExpr(el, n, e)};
                    case _: macro $b { MacroHelpers.insertExpr([ctor.expr], n, e) }
                }
            }
        }
        
        
        var meta = null;
        if (Context.getLocalClass().get().meta.has(":composite") == true) {
            meta = Context.getLocalClass().get().meta.extract(":composite");
        } else if (Context.getLocalClass().get().meta.has("composite") == true) {
            meta = Context.getLocalClass().get().meta.extract("composite");
        }
        
        if (meta != null) {
            var m = null;
            for (t in meta) {
                if (t.name == "composite" || t.name == ":composite") {
                    m = t;
                    break;
                }
            }
            
            var currentRegisterCompositeFn = MacroHelpers.getFunction(fields, "registerComposite");
            if (currentRegisterCompositeFn != null) {
                for (p in m.params) {
                    var s = ExprTools.toString(p);
                    
                    // probably a better way to do this
                    if (s.indexOf("Event") != -1) {
                        MacroHelpers.appendLine(currentRegisterCompositeFn, Context.parseInlineString('_internalEventsClass = ${ExprTools.toString(p)}', pos));
                    } else if (s.indexOf("Builder") != -1) {
                        MacroHelpers.appendLine(currentRegisterCompositeFn, Context.parseInlineString('_compositeBuilderClass = ${ExprTools.toString(p)}', pos));
                    } else if (s.indexOf("Layout") != -1) {
                        MacroHelpers.appendLine(currentRegisterCompositeFn, Context.parseInlineString('_defaultLayoutClass = ${ExprTools.toString(p)}', pos));
                    }
                }
            } else {
                var code:String = "";
                code += "function() {\n";
                code += "super.registerComposite();\n";

                for (p in m.params) {
                    var s = ExprTools.toString(p);
                    
                    // probably a better way to do this
                    if (s.indexOf("Event") != -1) {
                        code += '_internalEventsClass = ${ExprTools.toString(p)};\n';
                    } else if (s.indexOf("Builder") != -1) {
                        code += '_compositeBuilderClass = ${ExprTools.toString(p)};\n';
                    } else if (s.indexOf("Layout") != -1) {
                        code += '_defaultLayoutClass = ${ExprTools.toString(p)};\n';
                    }
                }
                
                code += "}";
                
                var access:Array<Access> = [APrivate, AOverride];
                MacroHelpers.addFunction("registerComposite", Context.parseInlineString(code, pos), access, fields, pos);
            }
        }
        return fields;
    }
    
    macro public static function buildBindings():Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();

        var bindableFields:Array<Field> = MacroHelpers.getFieldsWithMeta("bindable", fields);
        if (bindableFields.length != 0) {
            for (f in bindableFields) {
                var setFn = MacroHelpers.getFunction(fields, "set_" + f.name);
                if (setFn != null) {
                    switch (setFn.expr.expr) {
                        case EBlock(exprs):
                            var code = 'haxe.ui.binding.BindingManager.instance.componentPropChanged(this, "${f.name}")';
                            exprs.insert(exprs.length - 1, Context.parseInlineString(code, pos)); 
                        case _:
                            trace(setFn.expr);
                    }
                }
            }
        }

        var bindFields:Array<Field> = MacroHelpers.getFieldsWithMeta("bind", fields);
        if (bindFields.length != 0) {
            // TODO: think about generating a constructor if there isnt one already
            var ctor = MacroHelpers.getConstructor(fields);
            if (MacroHelpers.hasSuperClass(Context.getLocalType(), "haxe.ui.core.Component") == false) {
                Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
            }

            if (ctor == null) {
                Context.error("A class building component must have a constructor", Context.currentPos());
            }
            
            var n = 1;
            for (f in bindFields) {
                fields.remove(f);
                
                var metaParam = ExprTools.toString(MacroHelpers.getMeta(f, "bind").params[0]);
                var variable:String = metaParam.split(".")[0];
                var field:String = metaParam.split(".")[1];
                if (field == null) {
                    field = "value";
                }
                
                var defaultValue:String = null;
                var type = null;
                switch (f.kind) {
                    case FVar(t, e):
                        type = t;
                        if (e != null) {
                            defaultValue = ExprTools.toString(e);
                        }
                    case _:
                }
                
                var kind = FProp("get", "set", type);
                fields.push({
                    name: f.name,
                    doc: null,
                    meta: f.meta,
                    access: f.access,
                    kind: kind,
                    pos: haxe.macro.Context.currentPos()
                });
                
                var typeName = MacroHelpers.complexTypeToString(type);
                
                // add getter function
                var code = "function ():" + typeName + " {\n";
                code += "return Reflect.getProperty(findComponent('" + variable + "'), '" + field + "');\n";
                code += "}";
                var fnGetter = switch (Context.parseInlineString(code, haxe.macro.Context.currentPos()) ).expr {
                    case EFunction(_, f): f;
                    case _: throw "false";
                }
                fields.push({
                    name: "get_" + f.name,
                    doc: null,
                    meta: [],
                    access: [APrivate],
                    kind: FFun(fnGetter),
                    pos: haxe.macro.Context.currentPos()
                });
                
                // add setter funtion
                var code = "function (value:" + typeName + "):" + typeName + " {\n";
                code += "if (value != get_" + f.name + "()) {\n";
                code += "  Reflect.setProperty(findComponent('" + variable + "'), '" + field + "', value);\n";
                code += "}\n";
                code += "return value;\n";
                code += "}";

                var fnSetter = switch (Context.parseInlineString(code, haxe.macro.Context.currentPos()) ).expr {
                    case EFunction(_, f): f;
                    case _: throw "false";
                }
                fields.push({
                    name: "set_" + f.name,
                    doc: null,
                    meta: [],
                    access: [APrivate],
                    kind: FFun(fnSetter),
                    pos: haxe.macro.Context.currentPos()
                });
                
                /*
                var e:Expr = Context.parseInlineString("haxe.ui.binding.BindingManager.instance.add(this, '" + f.name + "', '')", Context.currentPos());
                ctor.expr = switch(ctor.expr.expr) {
                    case EBlock(el): macro $b{MacroHelpers.insertExpr(el, n, e)};
                    case _: macro $b { MacroHelpers.insertExpr([ctor.expr], n, e) }
                }
                n++;
                */
                if (defaultValue != null) {
                    var e:Expr = Context.parseInlineString("" + f.name + " = " + defaultValue, Context.currentPos());
                    ctor.expr = switch(ctor.expr.expr) {
                        case EBlock(el): macro $b{MacroHelpers.insertExpr(el, -1, e)};
                        case _: macro $b { MacroHelpers.insertExpr([ctor.expr], -1, e) }
                    }
                    n++;
                }
                
            }
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
                            return "if (this." + field.name + " != null) { c." + field.name + " = this." + field.name + "; }";
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

        className = className.split(".").pop(); // TODO: ensure this works as expected and clean up if it does, pretty sure it does
        
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

    public static function buildBehaviours():Array<Field> {
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();
        
        var behaviours:Array<Dynamic> = [];
        
        var valueFields = MacroHelpers.getFieldsWithMeta("value", fields);
        var valueField = null;
        if (valueFields != null && valueFields.length > 0) {
            valueField = ExprTools.toString(MacroHelpers.getMeta(valueFields[0], "value").params[0]);
        }
        
        for (f in MacroHelpers.getFieldsWithMeta("behaviour", fields)) {
            fields.remove(f);
            
            var type:ComplexType = null;
            switch (f.kind) {
                case FVar(f, _): {
                    type = f;
                }
                case _:
            }
            var typeName:String = MacroHelpers.complexTypeToString(type);
            if (TypeTools.findField(Context.getLocalClass().get(), f.name) == null) {
                var kind = FProp("get", "set", type);
                
                // add getter/setter property
                var meta = [];
                meta.push( { name: ":behaviour", pos: pos, params: [] } );
                meta.push( { name: ":bindable", pos: pos, params: [] } );
                for (m in f.meta) {
                    if (m.name != ":behaviour" && m.name != "behaviour" ) {
                        meta.push(m);
                    }
                }
                
                fields.push({
                    name: f.name,
                    doc: null,
                    meta: meta,
                    access: f.access,
                    kind: kind,
                    pos: haxe.macro.Context.currentPos()
                });
                // add getter function
                var code = "function ():" + typeName + " {\n";
                if (typeName == "Dynamic") {
                    code += "return behaviourGetDynamic('" + f.name + "');\n";
                } else {
                    code += "return behaviourGet('" + f.name + "');\n";
                }
                code += "}";
                var fnGetter = switch (Context.parseInlineString(code, haxe.macro.Context.currentPos()) ).expr {
                    case EFunction(_, f): f;
                    case _: throw "false";
                }
                fields.push({
                    name: "get_" + f.name,
                    doc: null,
                    meta: [],
                    access: [APrivate],
                    kind: FFun(fnGetter),
                    pos: haxe.macro.Context.currentPos()
                });
                     
                // add setter funtion
                var code = "function (value:" + typeName + "):" + typeName + " {\n";
                code += "behaviourSet('" + f.name + "', value);\n";
                if (f.name == valueField) {
                    code += "haxe.ui.binding.BindingManager.instance.componentPropChanged(this, 'value');\n";
                }
                code += "return value;\n";
                code += "}";

                var fnSetter = switch (Context.parseInlineString(code, haxe.macro.Context.currentPos()) ).expr {
                    case EFunction(_, f): f;
                    case _: throw "false";
                }
                fields.push({
                    name: "set_" + f.name,
                    doc: null,
                    meta: [],
                    access: [APrivate],
                    kind: FFun(fnSetter),
                    pos: haxe.macro.Context.currentPos()
                });
            }
            
            
            // lets dump info into an array and we'll modify the createDefaults at the end            
            var orginalMeta = MacroHelpers.getMeta(f, "behaviour");
            var btype = ExprTools.toString(orginalMeta.params[0]);
            var bparam = null;
            if (orginalMeta.params.length > 1) {
                bparam = ExprTools.toString(orginalMeta.params[1]);
            }
            
            behaviours.push({
               name: f.name,
               btype: btype,
               bparam: bparam
            });
        }
        
        for (f in MacroHelpers.getFieldsWithMeta("call", fields)) {
            var fn = MacroHelpers.getFunction(fields, f.name);
            var arg0 = "null";
            var void = true;
            switch (f.kind) {
                case FFun(f):
                    if (f.args.length > 0) {
                        arg0 = f.args[0].name;
                    }
                    switch (f.ret) {
                        case TPath(p):
                            void = (p.name == "Void");
                        case _:   
                    }
                case _:
            }
            
            if (void == true) {
                fn.expr = macro {
                    behaviourCall($v{f.name}, $i{arg0});
                };
            } else {
                fn.expr = macro {
                    return behaviourCall($v{f.name}, $i{arg0});
                };
            }
            
            // lets dump info into an array and we'll modify the createDefaults at the end            
            var orginalMeta = MacroHelpers.getMeta(f, "call");
            var btype = ExprTools.toString(orginalMeta.params[0]);
            var bparam = null;
            if (orginalMeta.params.length > 1) {
                bparam = ExprTools.toString(orginalMeta.params[1]);
            }

            behaviours.push({
               name: f.name,
               btype: btype,
               bparam: bparam
            });
        }
        
        if (behaviours.length > 0) {
            // lets modify the registerBehaviours function
            
            var parts = [];
            for (b in behaviours) {
                if (b.bparam == null) {
                    parts.push('behaviours.register("${b.name}", ${b.btype})');
                } else {
                    parts.push('behaviours.register("${b.name}", ${b.btype}, ${b.bparam})');
                }
            }
            
            var registerBehavioursFn = MacroHelpers.getFunction(fields, "registerBehaviours");
            if (registerBehavioursFn == null) {
                var code = "function() {\n";
                code += 'super.registerBehaviours();\n';
                for (line in parts) {
                    code += '${line};\n';
                }
                code += "}\n";
                MacroHelpers.addFunction("registerBehaviours", Context.parseInlineString(code, pos), [APrivate, AOverride], fields, pos);
            } else {
                for (line in parts) {
                    MacroHelpers.insertLine(registerBehavioursFn, Context.parseInlineString('${line}', pos), -1);    
                }
            }
        }
        
        for (f in MacroHelpers.getFieldsWithMeta("value", fields)) {
            fields.remove(f);
            var meta:MetadataEntry = MacroHelpers.getMeta(f, "value");
            var param:String = ExprTools.toString(meta.params[0]);

            // add getter function
            var code = "function ():Any {\n";
            code += "return " + param + ";\n";
            code += "}";
            var fnGetter = switch (Context.parseInlineString(code, haxe.macro.Context.currentPos()) ).expr {
                case EFunction(_, f): f;
                case _: throw "false";
            }
            fields.push({
                name: "get_" + f.name,
                doc: null,
                meta: [],
                access: [APrivate, AOverride],
                kind: FFun(fnGetter),
                pos: haxe.macro.Context.currentPos()
            });
            
            // add setter funtion
            var code = "function (value:Any):Any {\n";
            //code += "super.set_" + f.name + "(value);\n";
            code += "" + param + " = value;\n";
            code += "haxe.ui.binding.BindingManager.instance.componentPropChanged(this, '" + f.name + "');\n";
            code += "return value;\n";
            code += "}";

            var fnSetter = switch (Context.parseInlineString(code, haxe.macro.Context.currentPos()) ).expr {
                case EFunction(_, f): f;
                case _: throw "false";
            }
            fields.push({
                name: "set_" + f.name,
                doc: null,
                meta: [],
                access: [APrivate, AOverride],
                kind: FFun(fnSetter),
                pos: haxe.macro.Context.currentPos()
            });
        }
        
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
                code += "if (customStyle." + name + " != " + defaultValue + ") return customStyle." + name + ";\n";
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
            code += "if (_style == null) _style = new haxe.ui.styles.Style();\n";
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
