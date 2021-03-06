package haxe.ui.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.ComponentFieldMap;
import haxe.ui.core.LayoutClassMap;
import haxe.ui.core.TypeMap;
import haxe.ui.macros.helpers.CodePos;
import haxe.ui.macros.helpers.FunctionBuilder;
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
import sys.io.File;
#end

typedef NamedComponentDescription = {
    generatedVarName:String,
    type:String
};

typedef ScriptHandlerDescription = {
    generatedVarName:String,
    eventName:String,
    code:String
}

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
        var c:ComponentInfo = buildComponentFromFile(builder, codeBuilder, resourcePath, namedComponents, bindingExprs, MacroHelpers.exprToMap(params), "this", false);
        var superClass:String = builder.superClass.t.toString();
        var rootType = ComponentClassMap.get(c.type);
        if (superClass != rootType) {
            //Context.warning("The super class of '" + builder.name + "' does not match the root node of '" + resourcePath + "' (" + superClass + " != " + rootType + ") - this may have unintended consequences", pos);
        }

        for (id in namedComponents.keys()) {
            var safeId:String = StringUtil.capitalizeHyphens(id);
            var varDescription = namedComponents.get(id);
            var cls:String = varDescription.type;
            builder.addVar(safeId, TypeTools.toComplexType(Context.getType(cls)));
            codeBuilder.add(macro
                $i{safeId} = $i{varDescription.generatedVarName}
            );
        }

        var resolvedClass:String = "" + Context.getLocalClass();
        if (alias == null) {
            alias = resolvedClass.substr(resolvedClass.lastIndexOf(".") + 1, resolvedClass.length);
        }
        alias = alias.toLowerCase();
        ComponentClassMap.register(alias, resolvedClass);

        for (expr in bindingExprs) {
            codeBuilder.add(expr);
        }

        builder.constructor.add(codeBuilder, AfterSuper);

        return builder.fields;
    }

    macro public static function buildComponent(filePath:String, params:Expr = null):Expr {
        var builder = new CodeBuilder();
        var namedComponents:Map<String, NamedComponentDescription> = new Map<String, NamedComponentDescription>();
        buildComponentFromFile(null, builder, filePath, namedComponents, MacroHelpers.exprToMap(params), "rootComponent");
        builder.add(macro rootComponent);
        trace(builder.toString());
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

    public static function buildComponentFromFile(classBuilder:ClassBuilder, builder:CodeBuilder, filePath:String, namedComponents:Map<String, NamedComponentDescription> = null, bindingExprs:Array<Expr> = null, params:Map<String, Dynamic> = null, rootVarName:String = "this", buildRoot:Bool = true):ComponentInfo {
        var f = MacroHelpers.resolveFile(filePath);
        if (f == null) {
            throw "Could not resolve: " + filePath;
        }

        Context.registerModuleDependency(Context.getLocalModule(), f);

        var fileContent:String = StringUtil.replaceVars(File.getContent(f), params);
        var c:ComponentInfo = ComponentParser.get(MacroHelpers.extension(f)).parse(fileContent, new FileResourceResolver(f, params), filePath);
        for (s in c.styles) {
            if (s.scope == "global") {
                builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{s.style}, "user"));
            }
        }

        var scriptHandlers:Array<ScriptHandlerDescription> = [];
        if (buildRoot == true) {
            buildComponentNode(builder, c, 0, -1, namedComponents, bindingExprs, scriptHandlers, false);
            builder.add(macro var $rootVarName = c0);
        }

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }
        if (classBuilder != null) {
            buildScriptFunctions(classBuilder, builder, namedComponents, fullScript);   
        } else {
            buildScriptFunctionForwardDeclarations(builder, fullScript);
        }
        
        var n = 0;
        for (child in c.children) {
            var componentId = "c" + n;
            var r = buildComponentFromInfo(builder, child, namedComponents, bindingExprs, params, function(componentInfo:ComponentInfo, codeBuilder:CodeBuilder) {
                codeBuilder.add(macro $i{rootVarName}.addComponent($i{componentId}));
                for (scriptString in componentInfo.scriptlets) {
                    fullScript += scriptString;
                }
            }, n);
            n = r;
        }
        if (buildRoot == false) {
            assignComponentProperties(builder, c, rootVarName, bindingExprs, scriptHandlers);
        }
        
        if (classBuilder == null) {
            buildScriptFunctions(classBuilder, builder, namedComponents, fullScript);   
        }
        
        /*
        if (StringTools.trim(fullScript).length > 0) {
            builder.add(macro $i{rootVarName}.script = $v{fullScript});
        }
        */
        builder.add(macro $i{rootVarName}.bindingRoot = true);
        
        return c;
    }

    public static function buildComponentFromString(builder:CodeBuilder, source:String, namedComponents:Map<String, NamedComponentDescription> = null, bindingExprs:Array<Expr> = null, params:Map<String, Dynamic> = null, rootVarName:String = "this"):ComponentInfo {
        source = StringUtil.replaceVars(source, params);
        var c:ComponentInfo = ComponentParser.get("xml").parse(source);
        for (s in c.styles) {
            if (s.scope == "global") {
                builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{s.style}, "user"));
            }
        }

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }

        var n = 0;
        for (child in c.children) {
            var componentId = "c" + n;
            var r = buildComponentFromInfo(builder, child, namedComponents, bindingExprs, params, function(componentInfo:ComponentInfo, codeBuilder:CodeBuilder) {
                codeBuilder.add(macro $i{rootVarName}.addComponent($i{componentId}));
                for (scriptString in componentInfo.scriptlets) {
                    fullScript += scriptString;
                }
            }, n);
            n = r;
        }
        var scriptHandlers:Array<ScriptHandlerDescription> = [];
        assignComponentProperties(builder, c, rootVarName, bindingExprs, scriptHandlers);
        if (StringTools.trim(fullScript).length > 0) {
            builder.add(macro $i{rootVarName}.script = $v{fullScript});
        }
        builder.add(macro $i{rootVarName}.bindingRoot = true);
        return c;
    }

    private static function buildComponentFromInfo(builder:CodeBuilder, c:ComponentInfo, namedComponents:Map<String, NamedComponentDescription> = null, bindingExprs:Array<Expr> = null, params:Map<String, Dynamic> = null, cb:ComponentInfo->CodeBuilder->Void = null, firstId:Int = 0) {
        ModuleMacros.populateClassMap();

        if (namedComponents == null) {
            namedComponents = new Map<String, NamedComponentDescription>();
        }

        for (s in c.styles) {
            if (s.scope == "global") {
                builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{s.style}, "user"));
            }
        }

        if (bindingExprs == null) {
            bindingExprs = [];
        }
        var scriptHandlers:Array<ScriptHandlerDescription> = [];
        var r = buildComponentNode(builder, c, firstId, -1, namedComponents, bindingExprs, scriptHandlers);

        buildScriptHandlers(builder, namedComponents, scriptHandlers);
        
        if (cb != null) {
            cb(c, builder);
        }

        return r;
    }

    private static function buildScriptFunctionForwardDeclarations(builder:CodeBuilder, script:String) {
        var expr = Context.parseInlineString("{" + script + "}", Context.currentPos());
        switch (expr.expr) {
            case EBlock(exprs):
                for (e in exprs) {
                    switch (e.expr) {
                        #if haxe4
                        case EFunction(kind, f):
                            switch (kind) {
                                case FNamed(name, inlined):
                                    builder.add(macro var $name = null);
                                case _:
                                    trace("unsupported " + kind);
                            }
                        #else
                        case EFunction(name, f):
                            builder.add(macro var $name = null);
                        #end
                        case EVars(vars):
                            for (v in vars) {
                                var varName = v.name;
                                builder.add(macro var $varName); 
                            }
                        case _:
                            trace("unsupported " + e);
                    }
                }
            case _:
                trace("unsupported " + expr);
                
        }
    }
    
    private static function buildScriptFunctions(classBuilder:ClassBuilder, builder:CodeBuilder, namedComponents:Map<String, NamedComponentDescription>, script:String) {
        var expr = Context.parseInlineString("{" + script + "}", Context.currentPos());
        switch (expr.expr) {
            case EBlock(exprs):
                for (e in exprs) {
                    switch (e.expr) {
                        #if haxe4
                        case EFunction(kind, f):
                            switch (kind) {
                                case FNamed(name, inlined):
                                    if (classBuilder != null) {
                                        classBuilder.addFunction(name, f.expr, f.args, f.ret);
                                    } else {
                                        var functionBuilder = new FunctionBuilder(null, f);
                                        if (namedComponents != null) {
                                            for (namedComponent in namedComponents.keys()) {
                                                var details = namedComponents.get(namedComponent);
                                                functionBuilder.addToStart(macro var $namedComponent = $i{details.generatedVarName});
                                            }
                                        }

                                        var anonFunc:Expr = {
                                            expr: EFunction(FAnonymous, functionBuilder.fn),
                                            pos: Context.currentPos()
                                        }
                                        builder.add(macro $i{name} = $e{anonFunc});
                                    }
                                case _:
                                    trace("unsupported " + kind);
                            }
                        #else
                        case EFunction(name, f):
                            if (classBuilder != null) {
                                classBuilder.addFunction(name, f.expr, f.args, f.ret);
                            } else {
                                var functionBuilder = new FunctionBuilder(null, f);
                                if (namedComponents != null) {
                                    for (namedComponent in namedComponents.keys()) {
                                        var details = namedComponents.get(namedComponent);
                                        functionBuilder.addToStart(macro var $namedComponent = $i{details.generatedVarName});
                                    }
                                }

                                /* TODO - not sure how to do this in 3.4.7
                                var anonFunc:Expr = {
                                    expr: EFunction(FAnonymous, functionBuilder.fn),
                                    pos: Context.currentPos()
                                }
                                builder.add(macro $i{name} = $e{anonFunc});
                                */
                            }
                        #end
                        case EVars(vars):
                            for (v in vars) {
                                if (classBuilder != null) {
                                    var vtype = v.type;
                                    if (vtype == null) {
                                        vtype = macro: Dynamic;
                                    }
                                    classBuilder.addVar(v.name, vtype, v.expr);
                                } else {
                                    if (v.expr != null) {
                                        builder.add(macro $i{v.name} = $e{v.expr});
                                    }
                                }
                            }
                        case _:
                            trace("unsupported " + e);
                    }
                }
            case _:
                trace("unsupported " + expr);
                
        }
    }
    
    private static function buildScriptHandlers(builder:CodeBuilder, namedComponents:Map<String, NamedComponentDescription>, scriptHandlers:Array<ScriptHandlerDescription>) {
        // generate macro code for event handlers
        for (sh in scriptHandlers) {
            if (sh.eventName != null && sh.generatedVarName != null) {
                var fixedCode = StringTools.replace(sh.code, "this.", "__this__.");
                if (StringTools.endsWith(fixedCode, ";") == false) {
                    fixedCode += ";";
                }
                fixedCode = "{" + fixedCode + "}";
                var event = sh.eventName.substr(2);
                var scriptBuilder = new CodeBuilder(macro {
                    var __this__ = $i{sh.generatedVarName};
                });
                
                for (namedComponent in namedComponents.keys()) {
                    var details = namedComponents.get(namedComponent);
                    scriptBuilder.add(macro var $namedComponent = $i{details.generatedVarName});
                }

                scriptBuilder.add(Context.parseInlineString(fixedCode, Context.currentPos()));
                // TODO: typed "event" param based on event name
                builder.add(macro $i{sh.generatedVarName}.registerEvent($v{event}, function(event) { $e{scriptBuilder.expr} }));
            }
        }
    }
    
    // returns next free id
    private static function buildComponentNode(builder:CodeBuilder, c:ComponentInfo, id:Int, parentId:Int, namedComponents:Map<String, NamedComponentDescription>, bindingExprs:Array<Expr>, scriptHandlers:Array<ScriptHandlerDescription>, recurseChildren:Bool = true) {
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
        c.resolvedClassName = className;

        var typePath = {
            var split = className.split(".");
            { name: split.pop(), pack: split }
        };
        var componentVarName = 'c${id}';

        builder.add(macro var $componentVarName = new $typePath());

        if (c.styles.length > 0) {
            builder.add(macro $i{componentVarName}.styleSheet = new haxe.ui.styles.StyleSheet());
            for (s in c.styles) {
                if (s.scope == "local") {
                    builder.add(macro $i{componentVarName}.styleSheet.parse($v{s.style}));
                }
            }
        }

        assignComponentProperties(builder, c, componentVarName, bindingExprs, scriptHandlers);
        if (c.layout != null) {
            buildLayoutCode(builder, c.layout, id);
        }

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

        if (c.id != null && namedComponents != null && useNamedComponents == true) {
            var varDescription = {
                generatedVarName: componentVarName,
                type: className
            };
            namedComponents.set(c.id, varDescription);
        }

        var childId = id + 1;
        if (recurseChildren == true) {
            for (child in c.children) {
                var nc = namedComponents;
                if (useNamedComponents == false) {
                    nc = null;
                }
                childId = buildComponentNode(builder, child, childId, id, nc, bindingExprs, scriptHandlers);
            }

            if (parentId != -1) {
                builder.add(macro $i{"c" + (parentId)}.addComponent($i{componentVarName}));
            }
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
        assignProperties(builder, layoutVarName, l.properties, []);

        if (id != 0) {
            builder.add(macro $i{"c" + (id)}.layout = $i{"l" + id});
        }
    }

    private static function assignComponentProperties(builder:CodeBuilder, c:ComponentInfo, componentVarName:String, bindingExprs:Array<Expr>, scriptHandlers:Array<ScriptHandlerDescription>) {
        if (c.id != null)                       assignField(builder, componentVarName, "id", c.id, bindingExprs, c);
        if (c.left != null)                     assignField(builder, componentVarName, "left", c.left, bindingExprs, c);
        if (c.top != null)                      assignField(builder, componentVarName, "top", c.top, bindingExprs, c);
        if (c.width != null)                    assignField(builder, componentVarName, "width", c.width, bindingExprs, c);
        if (c.height != null)                   assignField(builder, componentVarName, "height", c.height, bindingExprs, c);
        if (c.percentWidth != null)             assignField(builder, componentVarName, "percentWidth", c.percentWidth, bindingExprs, c);
        if (c.percentHeight != null)            assignField(builder, componentVarName, "percentHeight", c.percentHeight, bindingExprs, c);
        if (c.contentWidth != null)             assignField(builder, componentVarName, "contentWidth", c.contentWidth, bindingExprs, c);
        if (c.contentHeight != null)            assignField(builder, componentVarName, "contentHeight", c.contentHeight, bindingExprs, c);
        if (c.percentContentWidth != null)      assignField(builder, componentVarName, "percentContentWidth", c.percentContentWidth, bindingExprs, c);
        if (c.percentContentHeight != null)     assignField(builder, componentVarName, "percentContentHeight", c.percentContentHeight, bindingExprs, c);
        if (c.text != null)                     assignField(builder, componentVarName, "text", c.text, bindingExprs, c);
        if (c.styleNames != null)               assignField(builder, componentVarName, "styleNames", c.styleNames, bindingExprs, c);
        if (c.style != null)                    assignField(builder, componentVarName, "styleString", c.styleString, bindingExprs, c);

        assignProperties(builder, componentVarName, c.properties, scriptHandlers);
    }

    // We'll re-use the same code for properties and components
    // certain things dont actually apply to layouts (namely "ComponentFieldMap", "on" and "${")
    // but they shouldnt cause any issues with layouts and the reuse is useful
    private static function assignProperties(builder:CodeBuilder, varName:String, properties:Map<String, String>, scriptHandlers:Array<ScriptHandlerDescription>) {
        for (propName in properties.keys()) {
            var propValue = properties.get(propName);
            propName = ComponentFieldMap.mapField(propName);
            var propExpr = macro $v{TypeConverter.convertFrom(propValue)};

            if (StringTools.startsWith(propName, "on")) {
                //builder.add(macro $i{varName}.addScriptEvent($v{propName}, $propExpr));
                
                scriptHandlers.push({
                    generatedVarName: varName,
                    eventName: propName,
                    code: propValue
                });
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

    private static function assignField(builder:CodeBuilder, varName:String, field:String, value:Any, bindingExprs:Array<Expr>, c:ComponentInfo) {
        var stringValue = Std.string(value);
        if (stringValue.indexOf("${") != -1) {
            builder.add(macro haxe.ui.binding.BindingManager.instance.add($i{varName}, $v{field}, $v{value}));
            if (stringValue.indexOf("${") == 0 && stringValue.indexOf("}") == stringValue.length - 1) {
                var extractedValue = stringValue.substring(2, stringValue.length - 1);
                var e = Context.parse(extractedValue, Context.currentPos());
                var typeInfo = TypeMap.getTypeInfo(c.resolvedClassName, field);
                switch (typeInfo) {
                    case "String":
                        bindingExprs.push(macro $i{varName}.$field = "" + $e{e});
                    default:
                        bindingExprs.push(macro $i{varName}.$field = $e{e});
                }
            }
        } else if (stringValue.indexOf("{{") != -1 && stringValue.indexOf("}}") != -1) {
            builder.add(macro haxe.ui.binding.BindingManager.instance.addLanguageBinding($i{varName}, $v{field}, $v{value}));
        } else {
            builder.add(macro $i{varName}.$field = $v{value});
        }
    }
    #end
}