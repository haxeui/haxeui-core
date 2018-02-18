package haxe.ui.macros;

import haxe.ui.core.ComponentClassMap;
import haxe.ui.parsers.ui.ComponentInfo;
import haxe.ui.parsers.ui.ComponentParser;
import haxe.ui.parsers.ui.resolvers.FileResourceResolver;
import haxe.ui.scripting.ConditionEvaluator;
import haxe.ui.util.StringUtil;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
#end

class ComponentMacros {
    macro public static function build(resourcePath:String, params:Expr = null, alias:String = null):Array<Field> {
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
        var code:Expr = buildComponentSource([], resourcePath, namedComponents, MacroHelpers.exprToMap(params));
        var e:Expr = macro addComponent($code);
        //code += "this.addClass('custom-component');";
        //trace(code);

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

    macro public static function buildComponent(filePath:String, params:Expr = null):Expr {
        ModuleMacros.populateClassMap();

        return buildComponentSource([], filePath, null, MacroHelpers.exprToMap(params));
    }

    #if macro
    public static function buildComponentSource(code:Array<Expr>, filePath:String, namedComponents:Map<String, String> = null, params:Map<String, Dynamic> = null):Expr {
        var f = MacroHelpers.resolveFile(filePath);
        if (f == null) {
            throw "Could not resolve: " + filePath;
        }

        var fileContent:String = StringUtil.replaceVars(File.getContent(f), params);
        var c:ComponentInfo = ComponentParser.get(MacroHelpers.extension(f)).parse(fileContent, new FileResourceResolver(f, params));
        //trace(c);

        for (styleString in c.styles) {
            code.push(macro haxe.ui.Toolkit.styleSheet.addRules($v{styleString}));
        }

        buildComponentCode(code, c, 0, namedComponents);
        assignBindings(code, c.bindings);

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }
        code.push(macro c0.script = $v{fullScript});
        code.push(macro c0);

        return macro @:pos(Context.currentPos()) $b{code};
    }

    private static function buildComponentCode(code:Array<Expr>, c:ComponentInfo, id:Int, namedComponents:Map<String, String>) {
        if (c.condition != null && new ConditionEvaluator().evaluate(c.condition) == false) {
            return;
        }

        var className:String = ComponentClassMap.get(c.type.toLowerCase());
        if (className == null) {
            trace("WARNING: no class found for component: " + c.type);
            return;
        }

        var numberEReg:EReg = ~/^\d+(\.(\d+))?$/;
        var type = Context.getModule(className)[0];
        //trace(className + " = " + MacroHelpers.hasInterface(type, "haxe.ui.core.IDataComponent"));

        var componentVarName = 'c${id}';
        var typePath = {
            var split = className.split(".");
            { name: split.pop(), pack: split }
        };
        inline function add(e:Expr) {
            code.push(e);
        }
        inline function assign(field:String, value:Dynamic) {
            add(macro $i{componentVarName}.$field = $v{value});
        }
        add(macro var $componentVarName = new $typePath());

        for (child in c.children) {
            buildComponentCode(code, child, id + 1, namedComponents);
        }

        if (c.id != null)                       assign("id", c.id);
        if (c.left != null)                     assign("left", c.left);
        if (c.top != null)                      assign("top", c.top);
        if (c.width != null)                    assign("width", c.width);
        if (c.height != null)                   assign("height", c.height);
        if (c.percentWidth != null)             assign("percentWidth", c.percentWidth);
        if (c.percentHeight != null)            assign("percentHeight", c.percentHeight);
        if (c.contentWidth != null)             assign("contentWidth", c.contentWidth);
        if (c.contentHeight != null)            assign("contentHeight", c.contentHeight);
        if (c.percentContentWidth != null)      assign("percentContentWidth", c.percentContentWidth);
        if (c.percentContentHeight != null)     assign("percentContentHeight", c.percentContentHeight);
        if (c.text != null)                     assign("text", c.text);
        if (c.styleNames != null)               assign("styleNames", c.styleNames);
        if (c.style != null)                    assign("styleString", c.styleString);
        if (c.layoutName != null)               assign("layoutName", c.layoutName);
        for (propName in c.properties.keys()) {
            var propValue = c.properties.get(propName);
            var propExpr = if (propValue == "true" || propValue == "yes" || propValue == "false" || propValue == "no") {
                macro $v{propValue == "true" || propValue == "yes"};
            } else {
                if(numberEReg.match(propValue)) {
                    if(numberEReg.matched(2) != null) {
                        macro $v{Std.parseFloat(propValue)};
                    } else {
                        macro $v{Std.parseInt(propValue)};
                    }
                } else {
                    macro $v{propValue};
                }
            }

            if (StringTools.startsWith(propName, "on")) {
                add(macro $i{componentVarName}.addScriptEvent($v{propName}, $propExpr));
            } else {
                add(macro $i{componentVarName}.$propName = $propExpr);
            }
        }

        if (MacroHelpers.hasInterface(type, "haxe.ui.core.IDataComponent") == true && c.data != null) {
            add(macro ($i{componentVarName} : haxe.ui.core.IDataComponent).dataSource = new haxe.ui.data.DataSourceFactory<Dynamic>().fromString($v{c.dataString}, haxe.ui.data.ArrayDataSource));
        }

        if (c.id != null && namedComponents != null) {
            namedComponents.set(c.id, className);
        }

        if (id != 0) {
            add(macro $i{"c" + (id - 1)}.addComponent($i{"c" + id}));
        }
    }

    private static function assignBindings(code:Array<Expr>, bindings:Array<ComponentBindingInfo>) {
        for (b in bindings) {
            var source:Array<String> = b.source.split(".");
            var target:Array<String> = b.target.split(".");
            var transform:String = b.transform;
            var targetProp = target[1];
            var sourceProp = source[1];
            code.push(macro var source = c0.findComponent($v{source[0]}, null, true));
            code.push(macro var target = c0.findComponent($v{target[0]}, null, true));
            code.push(macro
                if (source != null && target != null)
                    source.addBinding(target, $v{transform}, $v{targetProp}, $v{sourceProp});
                else
                    c0.addDeferredBinding($v{target[0]}, $v{source[0]}, $v{transform}, $v{targetProp}, $v{sourceProp})
            );
        }
    }
    #end
}