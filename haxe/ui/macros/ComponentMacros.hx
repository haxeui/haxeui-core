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

#if macro
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;
import sys.FileSystem;
import sys.io.File;
#end

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
        
        var namedComponents:Map<String, String> = new Map<String, String>();
        var codeBuilder = new CodeBuilder();
        buildComponentFromFile(codeBuilder, resourcePath, namedComponents, MacroHelpers.exprToMap(params));
        codeBuilder.add(macro
            addComponent(c0)
        );
        
        for (id in namedComponents.keys()) {
            var safeId:String = StringUtil.capitalizeHyphens(id);
            var cls:String = namedComponents.get(id);
            builder.addVar(safeId, TypeTools.toComplexType(Context.getType(cls)));
            codeBuilder.add(macro
                $i{safeId} = findComponent($v{id}, $p{cls.split(".")}, true)
            );
        }
        
        var resolvedClass:String = "" + Context.getLocalClass();
        if (alias == null) {
            alias = resolvedClass.substr(resolvedClass.lastIndexOf(".") + 1, resolvedClass.length);
        }
        alias = alias.toLowerCase();
        ComponentClassMap.register(alias, resolvedClass);
        
        codeBuilder.add(macro this.addClass("custom-component"));
        var aliasClassName = alias + "-component";
        codeBuilder.add(macro this.addClass($v{aliasClassName}));
        
        builder.constructor.add(codeBuilder, 1);
        
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
    
    public static function buildComponentFromFile(builder:CodeBuilder, filePath:String, namedComponents:Map<String, String> = null, params:Map<String, Dynamic> = null) {
        var f = MacroHelpers.resolveFile(filePath);

        Context.registerModuleDependency(Context.getLocalModule(), f);

        if (f == null) {
            throw "Could not resolve: " + filePath;
        }

        var fileContent:String = StringUtil.replaceVars(File.getContent(f), params);
        var c:ComponentInfo = ComponentParser.get(MacroHelpers.extension(f)).parse(fileContent, new FileResourceResolver(f, params));
        buildComponentFromInfo(builder, c, namedComponents, params);
    }
    
    public static function buildComponentFromString(builder:CodeBuilder, source:String, namedComponents:Map<String, String> = null, params:Map<String, Dynamic> = null) {
        source = StringUtil.replaceVars(source, params);
        var c:ComponentInfo = ComponentParser.get("xml").parse(source);
        buildComponentFromInfo(builder, c, namedComponents, params);
    }
    
    private static function buildComponentFromInfo(builder:CodeBuilder, c:ComponentInfo, namedComponents:Map<String, String> = null, params:Map<String, Dynamic> = null) {
        ModuleMacros.populateClassMap();
        
        if (namedComponents == null) {
            namedComponents = new Map<String, String>();
        }
        
        for (styleString in c.styles) {
            builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{styleString}, "user"));
        }
        
        buildComponentNode(builder, c, 0, -1, namedComponents);
        
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
    
    private static function buildComponentNode(builder:CodeBuilder, c:ComponentInfo, id:Int, parentId:Int, namedComponents:Map<String, String>) {
        if (c.condition != null && new ConditionEvaluator().evaluate(c.condition) == false) {
            return;
        }
        
        var className:String = ComponentClassMap.get(c.type);
        if (className == null) {
            Context.warning("no class found for component: " + c.type, Context.currentPos());
            return;
        }
        
        var classInfo = new ClassBuilder(Context.getModule(className)[0]);
        if (classInfo.hasDirectInterface("haxe.ui.core.IDirectionalComponent")) {
            var direction = c.direction;
            if (direction == null) {
                direction = "horizontal"; // default to horizontal
            }
            var directionalClassName = ComponentClassMap.get(direction + c.type);
            if (directionalClassName == null) {
                trace("WARNING: no direction class found for component: " + c.type + " (" + (direction + c.type.toLowerCase()) + ")");
                return;
            }
            
            className = directionalClassName;
        }
        
        var typePath = {
            var split = className.split(".");
            { name: split.pop(), pack: split }
        };
        var componentVarName = 'c${id}';

        builder.add(macro var $componentVarName = new $typePath());
        
        if (c.id != null)                       assignField(builder, componentVarName, "id", c.id);
        if (c.left != null)                     assignField(builder, componentVarName, "left", c.left);
        if (c.top != null)                      assignField(builder, componentVarName, "top", c.top);
        if (c.width != null)                    assignField(builder, componentVarName, "width", c.width);
        if (c.height != null)                   assignField(builder, componentVarName, "height", c.height);
        if (c.percentWidth != null)             assignField(builder, componentVarName, "percentWidth", c.percentWidth);
        if (c.percentHeight != null)            assignField(builder, componentVarName, "percentHeight", c.percentHeight);
        if (c.contentWidth != null)             assignField(builder, componentVarName, "contentWidth", c.contentWidth);
        if (c.contentHeight != null)            assignField(builder, componentVarName, "contentHeight", c.contentHeight);
        if (c.percentContentWidth != null)      assignField(builder, componentVarName, "percentContentWidth", c.percentContentWidth);
        if (c.percentContentHeight != null)     assignField(builder, componentVarName, "percentContentHeight", c.percentContentHeight);
        if (c.text != null)                     assignField(builder, componentVarName, "text", c.text);
        if (c.styleNames != null)               assignField(builder, componentVarName, "styleNames", c.styleNames);
        if (c.style != null)                    assignField(builder, componentVarName, "styleString", c.styleString);
        if (c.layout != null)                   buildLayoutCode(builder, c.layout, id);
        
        assignProperties(builder, componentVarName, c.properties);
        
        if (classInfo.hasInterface("haxe.ui.core.IDataComponent") == true && c.data != null) {
            var ds = new haxe.ui.data.DataSourceFactory<Dynamic>().fromString(c.dataString, haxe.ui.data.ArrayDataSource);
            var dsVarName = 'ds${id}';
            builder.add(macro var $dsVarName = new haxe.ui.data.ArrayDataSource<Dynamic>());
            for (i in 0...ds.size) {
                var item = ds.get(i);
                builder.add(macro $i{dsVarName}.add($v{item}));
            }
            builder.add(macro ($i{componentVarName} : haxe.ui.core.IDataComponent).dataSource = $i{dsVarName});
        }

        if (c.id != null && namedComponents != null) {
            namedComponents.set(c.id, className);
        }
        
        var childId = id + 1;
        for (child in c.children) {
            buildComponentNode(builder, child, childId, id, namedComponents);
            childId++;
        }
        
        if (parentId != -1) {
            builder.add(macro $i{"c" + (parentId)}.addComponent($i{componentVarName}));
        }
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
        var numberEReg:EReg = ~/^-?\d+(\.(\d+))?$/;
        for (propName in properties.keys()) {
            var propValue = properties.get(propName);
            propName = ComponentFieldMap.mapField(propName);
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
    
    private static inline function assignField(builder:CodeBuilder, varName:String, field:String, value:Any) {
        if (Std.string(value).indexOf("${") != -1) {
            builder.add(macro haxe.ui.binding.BindingManager.instance.add($i{varName}, $v{field}, $v{value}));
        }
        
        builder.add(macro $i{varName}.$field = $v{value});
    }
    #end
}