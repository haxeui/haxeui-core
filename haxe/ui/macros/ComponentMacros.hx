package haxe.ui.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.ComponentFieldMap;
import haxe.ui.core.LayoutClassMap;
import haxe.ui.parsers.ui.ComponentInfo;
import haxe.ui.parsers.ui.ComponentParser;
import haxe.ui.parsers.ui.LayoutInfo;
import haxe.ui.parsers.ui.resolvers.FileResourceResolver;
import haxe.ui.scripting.ConditionEvaluator;
import haxe.ui.util.StringUtil;
import haxe.ui.util.TypeConverter;

#if macro
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;
import sys.FileSystem;
import sys.io.File;
#end

typedef NamedComponentDescription = {
    generatedVarName:String,
    type:String
};

class ComponentMacros {
    macro public static function build(resourcePath:String, params:Expr = null, alias:String = null):Array<Field> {
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();

        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        if (builder.hasSuperClass("haxe.ui.core.Component") == false) {
            Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
        }
        
        if (builder.constructor == null) {
            Context.error("A class building component must have a constructor", Context.currentPos());
        }
        
        var originalRes = resourcePath;
        resourcePath = MacroHelpers.resolveFile(resourcePath);
        if (resourcePath == null || sys.FileSystem.exists(resourcePath) == false) {
            Context.error('UI markup file "${originalRes}" not found', Context.currentPos());
        }
        
        var namedComponents:Map<String, NamedComponentDescription> = new Map<String, NamedComponentDescription>();
        var codeBuilder = new CodeBuilder();
        var bindingExprs:Array<Expr> = [];
        buildComponentFromFile(codeBuilder, resourcePath, namedComponents, bindingExprs, MacroHelpers.exprToMap(params));
        
        for (id in namedComponents.keys()) {
            var safeId:String = StringUtil.capitalizeHyphens(id);
            var varDescription = namedComponents.get(id);
            var cls:String = varDescription.type;
            builder.addVar(safeId, TypeTools.toComplexType(Context.getType(cls)));
            codeBuilder.add(macro
                $i{safeId} = $i{varDescription.generatedVarName}
            );
        }
        codeBuilder.add(macro @:pos(pos)
            addComponent(c0)
        );

        var resolvedClass:String = "" + Context.getLocalClass();
        if (alias == null) {
            alias = resolvedClass.substr(resolvedClass.lastIndexOf(".") + 1, resolvedClass.length);
        }
        alias = alias.toLowerCase();
        ComponentClassMap.register(alias, resolvedClass);
        
        codeBuilder.add(macro this.addClass("custom-component"));
        var aliasClassName = alias + "-component";
        codeBuilder.add(macro this.addClass($v{aliasClassName}));
        
        for (expr in bindingExprs) {
            codeBuilder.add(expr);
        }
        
        builder.constructor.add(codeBuilder, AfterSuper);
        
        return builder.fields;
    }

    macro public static function buildComponent(filePath:String, params:Expr = null):Expr {
        var builder = new CodeBuilder();
        buildComponentFromFile(builder, filePath, null, MacroHelpers.exprToMap(params));
        return builder.expr;
    }

    macro public static function createInstance(filePath:String):Expr {
        var cls = ModuleMacros.createDynamicClass(filePath);

        var parts = cls.split(".");
        var name:String = parts.pop();
        var t:TypePath = {
            pack: parts,
            name: name
        }
        return macro new $t();
    }
    
    #if macro
    
    public static function buildComponentFromFile(builder:CodeBuilder, filePath:String, namedComponents:Map<String, NamedComponentDescription> = null, bindingExprs:Array<Expr> = null, params:Map<String, Dynamic> = null) {
        var f = MacroHelpers.resolveFile(filePath);

        Context.registerModuleDependency(Context.getLocalModule(), f);

        if (f == null) {
            throw "Could not resolve: " + filePath;
        }

        var fileContent:String = StringUtil.replaceVars(File.getContent(f), params);
        var c:ComponentInfo = ComponentParser.get(MacroHelpers.extension(f)).parse(fileContent, new FileResourceResolver(f, params));
        buildComponentFromInfo(builder, c, namedComponents, bindingExprs, params);
    }
    
    public static function buildComponentFromString(builder:CodeBuilder, source:String, namedComponents:Map<String, NamedComponentDescription> = null, bindingExprs:Array<Expr> = null, params:Map<String, Dynamic> = null) {
        source = StringUtil.replaceVars(source, params);
        var c:ComponentInfo = ComponentParser.get("xml").parse(source);
        buildComponentFromInfo(builder, c, namedComponents, bindingExprs, params);
    }
    
    private static function buildComponentFromInfo(builder:CodeBuilder, c:ComponentInfo, namedComponents:Map<String, NamedComponentDescription> = null, bindingExprs:Array<Expr> = null, params:Map<String, Dynamic> = null) {
        ModuleMacros.populateClassMap();
        
        if (namedComponents == null) {
            namedComponents = new Map<String, NamedComponentDescription>();
        }
        
        for (styleString in c.styles) {
            builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{styleString}, "user"));
        }

        if (bindingExprs == null) {
            bindingExprs = [];
        }
        buildComponentNode(builder, c, 0, -1, namedComponents, bindingExprs);
        
        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }
        
        if (StringTools.trim(fullScript).length > 0) {
            builder.add(macro c0.script = $v{fullScript});
        }
        builder.add(macro c0.bindingRoot = true);
        builder.add(macro c0);
    }

    // returns next free id
    private static function buildComponentNode(builder:CodeBuilder, c:ComponentInfo, id:Int, parentId:Int, namedComponents:Map<String, NamedComponentDescription>, bindingExprs:Array<Expr>) {
        if (c.condition != null && new ConditionEvaluator().evaluate(c.condition) == false) {
            return id;
        }
        
        var className:String = ComponentClassMap.get(c.type);
        if (className == null) {
            Context.warning("no class found for component: " + c.type, Context.currentPos());
            return id;
        }
        
        var classInfo = new ClassBuilder(Context.getModule(className)[0]);
        var useNamedComponents = true;
        if (classInfo.hasSuperClass("haxe.ui.core.ItemRenderer")) { // we dont really want to create variable instances of contents of item renderers
            useNamedComponents = false;
        }
        if (classInfo.hasDirectInterface("haxe.ui.core.IDirectionalComponent")) {
            var direction = c.direction;
            if (direction == null) {
                direction = "horizontal"; // default to horizontal
            }
            var directionalClassName = ComponentClassMap.get(direction + c.type);
            if (directionalClassName == null) {
                trace("WARNING: no direction class found for component: " + c.type + " (" + (direction + c.type.toLowerCase()) + ")");
                return id;
            }
            
            className = directionalClassName;
        }
        
        var typePath = {
            var split = className.split(".");
            { name: split.pop(), pack: split }
        };
        var componentVarName = 'c${id}';

        builder.add(macro var $componentVarName = new $typePath());
        
        if (c.id != null)                       assignField(builder, componentVarName, "id", c.id, bindingExprs);
        if (c.left != null)                     assignField(builder, componentVarName, "left", c.left, bindingExprs);
        if (c.top != null)                      assignField(builder, componentVarName, "top", c.top, bindingExprs);
        if (c.width != null)                    assignField(builder, componentVarName, "width", c.width, bindingExprs);
        if (c.height != null)                   assignField(builder, componentVarName, "height", c.height, bindingExprs);
        if (c.percentWidth != null)             assignField(builder, componentVarName, "percentWidth", c.percentWidth, bindingExprs);
        if (c.percentHeight != null)            assignField(builder, componentVarName, "percentHeight", c.percentHeight, bindingExprs);
        if (c.contentWidth != null)             assignField(builder, componentVarName, "contentWidth", c.contentWidth, bindingExprs);
        if (c.contentHeight != null)            assignField(builder, componentVarName, "contentHeight", c.contentHeight, bindingExprs);
        if (c.percentContentWidth != null)      assignField(builder, componentVarName, "percentContentWidth", c.percentContentWidth, bindingExprs);
        if (c.percentContentHeight != null)     assignField(builder, componentVarName, "percentContentHeight", c.percentContentHeight, bindingExprs);
        if (c.text != null)                     assignField(builder, componentVarName, "text", c.text, bindingExprs);
        if (c.styleNames != null)               assignField(builder, componentVarName, "styleNames", c.styleNames, bindingExprs);
        if (c.style != null)                    assignField(builder, componentVarName, "styleString", c.styleString, bindingExprs);
        if (c.layout != null)                   buildLayoutCode(builder, c.layout, id);
        
        assignProperties(builder, componentVarName, c.properties);
        
        if (classInfo.hasInterface("haxe.ui.core.IDataComponent") == true && c.data != null) {
            var ds = new haxe.ui.data.DataSourceFactory<Dynamic>().fromString(c.dataString, haxe.ui.data.ListDataSource);
            var dsVarName = 'ds${id}';
            builder.add(macro var $dsVarName = new haxe.ui.data.ListDataSource<Dynamic>());
            for (i in 0...ds.size) {
                var item = ds.get(i);
                builder.add(macro $i{dsVarName}.add($v{item}));
            }
            builder.add(macro ($i{componentVarName} : haxe.ui.core.IDataComponent).dataSource = $i{dsVarName});
        }

        if (c.id != null && namedComponents != null && useNamedComponents == true) {
            var varDescription = {
                generatedVarName: componentVarName,
                type: className
            };
            namedComponents.set(c.id, varDescription);
        }
        
        var childId = id + 1;
        for (child in c.children) {
            var nc = namedComponents;
            if (useNamedComponents == false) {
                nc = null;
            }
            childId = buildComponentNode(builder, child, childId, id, nc, bindingExprs);
        }
        
        if (parentId != -1) {
            builder.add(macro $i{"c" + (parentId)}.addComponent($i{componentVarName}));
        }
        return childId;
    }

    private static function buildLayoutCode(builder:CodeBuilder, l:LayoutInfo, id:Int) {
        var className:String = LayoutClassMap.get(l.type.toLowerCase());
        if (className == null) {
            Context.warning("no class found for layout: " + l.type, Context.currentPos());
            return;
        }
        
        var layoutVarName = 'l${id}';
        var typePath = {
            var split = className.split(".");
            { name: split.pop(), pack: split }
        };
        
        builder.add(macro var $layoutVarName = new $typePath());
        assignProperties(builder, layoutVarName, l.properties);
        
        if (id != 0) {
            builder.add(macro $i{"c" + (id)}.layout = $i{"l" + id});
        }
    }
    
    // We'll re-use the same code for properties and components
    // certain things dont actually apply to layouts (namely "ComponentFieldMap", "on" and "${")
    // but they shouldnt cause any issues with layouts and the reuse is useful
    private static function assignProperties(builder:CodeBuilder, varName:String, properties:Map<String, String>) {
        for (propName in properties.keys()) {
            var propValue = properties.get(propName);
            propName = ComponentFieldMap.mapField(propName);
            var propExpr = macro $v{TypeConverter.convert(propValue)};

            if (StringTools.startsWith(propName, "on")) {
                builder.add(macro $i{varName}.addScriptEvent($v{propName}, $propExpr));
            } else if (Std.string(propValue).indexOf("${") != -1) {
                builder.add(macro haxe.ui.binding.BindingManager.instance.add($i{varName}, $v{propName}, $v{propValue}));
                // Basically, if you try to apply a bound variable to something that isnt
                // a string, then we cant assign it as normal, ie:
                //     c5.selectedIndex = ${something}
                // but, if we skip it, then you can use non-existing xml attributes in the xml (eg: fakeComponentProperty)
                // and they will go unchecked and you wont get an error. This is a way around that, so it essentially generates
                // the following expr:
                //     c5.fakeComponentProperty = c5.fakeComponentProperty
                // which will result in a compile time error
                builder.add(macro $i{varName}.$propName = $i{varName}.$propName);
            } else {
                builder.add(macro $i{varName}.$propName = $propExpr);
            }
        }
    }
    
    private static function assignField(builder:CodeBuilder, varName:String, field:String, value:Any, bindingExprs:Array<Expr>) {
        var stringValue = Std.string(value);
        if (stringValue.indexOf("${") != -1) {
            builder.add(macro haxe.ui.binding.BindingManager.instance.add($i{varName}, $v{field}, $v{value}));
            if (stringValue.indexOf("${") == 0 && stringValue.indexOf("}") == stringValue.length - 1) {
                var extractedValue = stringValue.substring(2, stringValue.length - 1);
                var e = Context.parse(extractedValue, Context.currentPos());
                bindingExprs.push(macro $i{varName}.$field = cast $e{e});
            }
        } else {
            builder.add(macro $i{varName}.$field = $v{value});
        }
    }
    #end
}