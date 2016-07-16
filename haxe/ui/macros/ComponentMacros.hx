package haxe.ui.macros;

import haxe.ui.core.ComponentClassMap;
import haxe.ui.parsers.modules.Module;
import haxe.ui.parsers.ui.ComponentInfo;
import haxe.ui.parsers.ui.ComponentParser;
import haxe.ui.parsers.ui.resolvers.FileResourceResolver;
import haxe.ui.util.StringUtil;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.rtti.Meta;
import sys.FileSystem;
import sys.io.File;
#end

class ComponentMacros {
    macro public static function build(resourcePath:String, alias:String = null):Array<Field> {
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();

        var ctor = MacroHelpers.getConstructor(fields);
        if (MacroHelpers.hasSuperClass(Context.getLocalType(), "haxe.ui.core.Component") == false) {
            Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
        }

        if (ctor == null) Context.error("A class building component must have a constructor", Context.currentPos());

        var originalRes = resourcePath;
        resourcePath = MacroHelpers.resolveFile(resourcePath);
        if (resourcePath == null || sys.FileSystem.exists(resourcePath) == false) {
            Context.error('UI markup file "${originalRes}" not found', Context.currentPos());
        }

        ModuleMacros.populateClassMap();

        var namedComponents:Map<String, String> = new Map<String, String>();
        var code:String = buildComponentSource(resourcePath, namedComponents);
        code = "addComponent(" + code + ")";
        //code += "this.addClass('custom-component');";
        //trace(code);

        var e:Expr = Context.parseInlineString(code, Context.currentPos());
        var n:Int = 1;
        ctor.expr = switch(ctor.expr.expr) {
            case EBlock(el): macro $b{MacroHelpers.insertExpr(el, n, e)};
            case _: macro $b { MacroHelpers.insertExpr([ctor.expr], n, e) }
        }

        n++;
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

        var resolvedClass:String = "" + Context.getLocalClass();
        if (alias == null) {
            alias = resolvedClass.substr(resolvedClass.lastIndexOf(".") + 1, resolvedClass.length);
        }
        alias = alias.toLowerCase();

        var e:Expr = Context.parseInlineString('this.addClass("custom-component")', Context.currentPos());
        ctor.expr = switch(ctor.expr.expr) {
            case EBlock(el): macro $b{MacroHelpers.insertExpr(el, n, e)};
            case _: macro $b { MacroHelpers.insertExpr([ctor.expr], n, e) }
        }

        var e:Expr = Context.parseInlineString('this.addClass("${alias}-container")', Context.currentPos());
        ctor.expr = switch(ctor.expr.expr) {
            case EBlock(el): macro $b{MacroHelpers.insertExpr(el, n, e)};
            case _: macro $b { MacroHelpers.insertExpr([ctor.expr], n, e) }
        }

        ComponentClassMap.register(alias, resolvedClass);

        return fields;
    }

    macro public static function buildComponent(filePath:String):Expr {
        return Context.parseInlineString(buildComponentSource(filePath), Context.currentPos());
    }

    #if macro
    public static function buildComponentSource(filePath:String, namedComponents:Map<String, String> = null):String {
        var f = MacroHelpers.resolveFile(filePath);
        if (f == null) {
            throw "Could not resolve: " + filePath;
        }

        var c:ComponentInfo = ComponentParser.get(MacroHelpers.extension(f)).parse(File.getContent(f), new FileResourceResolver(f));
        //trace(c);

        var code:String = "function() {\n";
        for (styleString in c.styles) {
            code += "haxe.ui.Toolkit.styleSheet.addRules('" + styleString + "');\n";
        }

        code += buildComponentCode(c, 0, namedComponents);
        code += assignBindings(c.bindings);

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }
        code += "c0.script = '" + fullScript + "';\n";

        code += "return c0;\n";
        code += "}()\n";

        //trace(code);
        return code;
    }

    private static function buildComponentCode(c:ComponentInfo, id:Int, namedComponents:Map<String, String>):String {
        var className:String = ComponentClassMap.get(c.type);
        if (className == null) {
            trace("WARNING: no class found for component: " + c.type);
            return "";
        }

        var s = 'var c${id} = new ${className}();\n';
        //if (c.composite != null)      s += 'c${id}.composite = ${c.composite};\n';
        //s += 'c${id}.build();\n';
        if (c.id != null)               s += 'c${id}.id = "${c.id}";\n';
        if (c.left != null)             s += 'c${id}.left = ${c.left};\n';
        if (c.top != null)              s += 'c${id}.top = ${c.top};\n';
        if (c.width != null)            s += 'c${id}.width = ${c.width};\n';
        if (c.height != null)           s += 'c${id}.height = ${c.height};\n';
        if (c.percentWidth != null)     s += 'c${id}.percentWidth = ${c.percentWidth};\n';
        if (c.percentHeight != null)    s += 'c${id}.percentHeight = ${c.percentHeight};\n';
        if (c.text != null)             s += 'c${id}.text = "${c.text}";\n';
        if (c.styleNames != null)       s += 'c${id}.styleNames = "${c.styleNames}";\n';
        if (c.style != null)            s += 'c${id}.styleString = "${c.styleString}";\n';
        for (propName in c.properties.keys()) {
            var propValue = c.properties.get(propName);
            if (propValue == "true" || propValue == "yes" || propValue == "false" || propValue == "no") {
                propValue = '${propValue == "true" || propValue == "yes"}';
            } else if (Std.parseInt(propValue) != null) {
                propValue = '${Std.parseInt(propValue)}';
            } else {
                propValue = '"${propValue}"';
            }

            if (StringTools.startsWith(propName, "on")) {
                s += 'c${id}.addScriptEvent("${propName}", ${propValue});\n';
            } else {
                s += 'c${id}.${propName} = ${propValue};\n';
            }
        }

        if (c.id != null && namedComponents != null) {
            namedComponents.set(c.id, className);
        }

        for (child in c.children) {
            s += buildComponentCode(child, id + 1, namedComponents);
        }

        if (id != 0) {
            s += 'c${id - 1}.addComponent(c${id});\n';
        }

        return s;
    }

    private static function assignBindings(bindings:Array<ComponentBindingInfo>):String {
        var s = "";
        for (b in bindings) {
            var source:Array<String> = b.source.split(".");
            var target:Array<String> = b.target.split(".");
            var transform:String = b.transform;
            if (transform != null) {
                transform = '"${transform}"';
            }
            var targetProp = target[1];
            if (targetProp != null) {
                targetProp = '"${targetProp}"';
            }
            var sourceProp = source[1];
            if (sourceProp != null) {
                sourceProp = '"${sourceProp}"';
            }

            s += 'var source = c0.findComponent("${source[0]}", null, true);\n';
            s += 'var target = c0.findComponent("${target[0]}", null, true);\n';
            s += 'if (source != null && target != null)\n';
            s += '  source.addBinding(target, ${transform}, ${targetProp}, ${sourceProp});\n';
            s += 'else\n';
            s += '  c0.addDeferredBinding("${target[0]}", "${source[0]}", ${transform}, ${targetProp}, ${sourceProp});\n';
        }
        return s;
    }
    #end
}