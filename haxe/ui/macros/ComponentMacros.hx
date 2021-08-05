package haxe.ui.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.ComponentFieldMap;
import haxe.ui.core.LayoutClassMap;
import haxe.ui.core.TypeMap;
import haxe.ui.macros.helpers.FunctionBuilder;
import haxe.ui.parsers.ui.ComponentInfo;
import haxe.ui.parsers.ui.ComponentParser;
import haxe.ui.parsers.ui.LayoutInfo;
import haxe.ui.parsers.ui.resolvers.FileResourceResolver;
import haxe.ui.util.ExpressionUtil;
import haxe.ui.util.SimpleExpressionEvaluator;
import haxe.ui.util.StringUtil;
import haxe.ui.util.TypeConverter;

#if macro
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;
import sys.io.File;
#end

typedef NamedComponentDescription = {
    var generatedVarName:String;
    var type:String;
};

typedef ScriptData = {
    var generatedVarName:String;
    var eventName:String;
    var code:String;
}

typedef BindingData = {
    var generatedVarName:String;
    var varProp:String;
    var bindingExpr:String;
    var propType:String;
}

typedef LanguageBindingData = {
    var generatedVarName:String;
    var varProp:String;
    var bindingExpr:String;
}

typedef BuildData = {
    @:optional var namedComponents:Map<String, NamedComponentDescription>;
    @:optional var bindingExprs:Array<Expr>;
    @:optional var scripts:Array<ScriptData>;
    @:optional var bindings:Array<BindingData>;
    @:optional var languageBindings:Array<LanguageBindingData>;
    @:optional var params:Map<String, Dynamic>;
}

class ComponentMacros {
    macro public static function build(resourcePath:String, params:Expr = null, alias:String = null):Array<Field> {
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();

        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        if (builder.hasSuperClass("haxe.ui.core.Component") == false) {
            Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
        }

        if (builder.ctor == null) {
            Context.error("A class building component must have a constructor", Context.currentPos());
        }

        var originalRes = resourcePath;
        resourcePath = MacroHelpers.resolveFile(resourcePath);
        if (resourcePath == null || sys.FileSystem.exists(resourcePath) == false) {
            Context.error('UI markup file "${originalRes}" not found', Context.currentPos());
        }

        var codeBuilder = new CodeBuilder();
        var buildData:BuildData = {
            params: MacroHelpers.exprToMap(params)
        };
        var c:ComponentInfo = buildComponentFromFile(builder, codeBuilder, resourcePath, buildData, "this", false);
        var superClass:String = builder.superClass.t.toString();
        var rootType = ComponentClassMap.get(c.type);
        if (superClass != rootType) {
            //Context.warning("The super class of '" + builder.name + "' does not match the root node of '" + resourcePath + "' (" + superClass + " != " + rootType + ") - this may have unintended consequences", pos);
        }

        for (id in buildData.namedComponents.keys()) {
            var safeId:String = StringUtil.capitalizeHyphens(id);
            var varDescription = buildData.namedComponents.get(id);
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

        for (expr in buildData.bindingExprs) {
            codeBuilder.add(expr);
        }

        buildBindings(codeBuilder, buildData);
        buildLanguageBindings(codeBuilder, buildData);
        
        builder.ctor.add(codeBuilder, AfterSuper);

        return builder.fields;
    }

    macro public static function buildComponent(filePath:String, params:Expr = null):Expr {
        var builder = new CodeBuilder();
        var buildData:BuildData = {
            params: MacroHelpers.exprToMap(params)
        };
        buildComponentFromFile(null, builder, filePath, buildData, "rootComponent");
        buildBindings(builder, buildData, true);
        buildLanguageBindings(builder, buildData, true);
        builder.add(macro rootComponent);
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

    public static function buildComponentFromFile(classBuilder:ClassBuilder, builder:CodeBuilder, filePath:String, buildData:BuildData = null, rootVarName:String = "this", buildRoot:Bool = true):ComponentInfo {
        populateBuildData(buildData);        
        
        var f = MacroHelpers.resolveFile(filePath);
        if (f == null) {
            throw "Could not resolve: " + filePath;
        }

        Context.registerModuleDependency(Context.getLocalModule(), f);

        var fileContent:String = StringUtil.replaceVars(File.getContent(f), buildData.params);
        var c:ComponentInfo = ComponentParser.get(MacroHelpers.extension(f)).parse(fileContent, new FileResourceResolver(f, buildData.params), filePath);
        for (s in c.styles) {
            if (s.scope == "global") {
                builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{s.style}, "user"));
            }
        }

        if (buildRoot == true) {
            buildComponentNode(builder, c, 0, -1, buildData, false);
            builder.add(macro var $rootVarName = c0);
        }

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }
        if (classBuilder != null) {
            buildScriptFunctions(classBuilder, builder, buildData.namedComponents, fullScript);   
        } else {
            buildScriptFunctionForwardDeclarations(builder, fullScript);
        }
        
        var n = 0;
        for (child in c.children) {
            var componentId = "c" + n;
            var r = buildComponentFromInfo(builder, child, buildData, function(componentInfo:ComponentInfo, codeBuilder:CodeBuilder) {
                if (componentInfo.condition != null && SimpleExpressionEvaluator.evalCondition(componentInfo.condition) == false) {
                    return;
                }
                codeBuilder.add(macro $i{rootVarName}.addComponent($i{componentId}));
                for (scriptString in componentInfo.scriptlets) {
                    fullScript += scriptString;
                }
            }, n);
            n = r;
        }
        if (buildRoot == false) {
            assignComponentProperties(builder, c, rootVarName, buildData);
        }
        
        if (classBuilder == null) {
            buildScriptFunctions(classBuilder, builder, buildData.namedComponents, fullScript);   
        }

        builder.add(macro $i{rootVarName}.bindingRoot = true);
        
        return c;
    }

    private static function populateBuildData(buildData:BuildData) {
        if (buildData == null) {
            buildData = { };
        }
        if (buildData.namedComponents == null) {
            buildData.namedComponents = new Map<String, NamedComponentDescription>();
        }
        if (buildData.scripts == null) {
            buildData.scripts = [];
        }
        if (buildData.bindings == null) {
            buildData.bindings = [];
        }
        if (buildData.languageBindings == null) {
            buildData.languageBindings = [];
        }
        if (buildData.bindingExprs == null) {
            buildData.bindingExprs = [];
        }
        if (buildData.params == null) {
            buildData.params = new Map<String, Dynamic>();
        }
    }
    
    public static function buildComponentFromString(builder:CodeBuilder, source:String, buildData:BuildData = null, rootVarName:String = "this"):ComponentInfo {
        populateBuildData(buildData);
        
        source = StringUtil.replaceVars(source, buildData.params);
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
            var r = buildComponentFromInfo(builder, child, buildData, function(componentInfo:ComponentInfo, codeBuilder:CodeBuilder) {
                codeBuilder.add(macro $i{rootVarName}.addComponent($i{componentId}));
                for (scriptString in componentInfo.scriptlets) {
                    fullScript += scriptString;
                }
            }, n);
            n = r;
        }

        assignComponentProperties(builder, c, rootVarName, buildData);
        if (StringTools.trim(fullScript).length > 0) {
            builder.add(macro $i{rootVarName}.script = $v{fullScript});
        }
        builder.add(macro $i{rootVarName}.bindingRoot = true);
        return c;
    }

    private static function buildComponentFromInfo(builder:CodeBuilder, c:ComponentInfo, buildData:BuildData, cb:ComponentInfo->CodeBuilder->Void = null, firstId:Int = 0) {
        populateBuildData(buildData);
        ModuleMacros.populateClassMap();

        for (s in c.styles) {
            if (s.scope == "global") {
                builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{s.style}, "user"));
            }
        }

        var r = buildComponentNode(builder, c, firstId, -1, buildData);

        buildScriptHandlers(builder, buildData.namedComponents, buildData.scripts);
        
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
        expr = ExprTools.map(expr, replaceShortClassNames);
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
    
    private static function buildLanguageBindings(builder:CodeBuilder, buildData:BuildData, addLocalVars:Bool = false) {
        for (languageBinding in buildData.languageBindings) {
            assignLanguageBinding(builder, languageBinding, buildData.namedComponents, addLocalVars);
        }
    }
    
    private static function assignLanguageBinding(builder:CodeBuilder, languageBinding:LanguageBindingData, namedComponents:Map<String, NamedComponentDescription>, addLocalVars:Bool = false) {
        var fixedExpr = ExpressionUtil.stringToLanguageExpression(languageBinding.bindingExpr);
        if (StringTools.endsWith(fixedExpr, ";") == false) {
            fixedExpr += ";";
        }
        var varName = languageBinding.generatedVarName;
        var field = languageBinding.varProp;
        var expr = Context.parseInlineString("{" + fixedExpr + "}", Context.currentPos());
        
        var dependants:Map<String, Array<String>> = getDependants(expr);
        for (dependantName in dependants.keys()) {
            if (namedComponents.exists(dependantName) == false) {
                continue;
            }
            
            var generatedDependantName = namedComponents.get(dependantName).generatedVarName;
            var ifBuilder = new CodeBuilder(macro {
            });
            
            var propList = dependants.get(dependantName);
            for (dependantProp in propList) {
                ifBuilder.add(macro if (e.data == $v{dependantProp}) {
                    //haxe.ui.locale.LocaleManager.instance.refreshFor($i{varName});
                    haxe.ui.locale.LocaleManager.instance.refreshAll();
                });
            }
            
            builder.add(macro {
                $i{generatedDependantName}.registerEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, function(e:haxe.ui.events.UIEvent) {
                    $e{ifBuilder.expr}
                });
            });
        }
        
        builder.add(macro $i{varName}.$field = $e{expr});
        builder.add(macro haxe.ui.locale.LocaleManager.instance.registerComponent($i{varName}, $v{field}, function() {
            return $e{expr};
        }));
    }
    
    private static function buildBindings(builder:CodeBuilder, buildData:BuildData, addLocalVars:Bool = false) {
        for (binding in buildData.bindings) {
            assignBinding(builder, binding, buildData.namedComponents, addLocalVars);
        }
    }
    
    private static function buildScriptHandlers(builder:CodeBuilder, namedComponents:Map<String, NamedComponentDescription>, scripts:Array<ScriptData>) {
        // generate macro code for event handlers
        for (sh in scripts) {
            if (sh.eventName != null && sh.generatedVarName != null) {
                var fixedCode = sh.code;
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

                var expr = Context.parseInlineString(fixedCode, Context.currentPos());
                expr = ExprTools.map(expr, replaceThis);
                expr = ExprTools.map(expr, replaceShortClassNames);
                scriptBuilder.add(expr);
                // TODO: typed "event" param based on event name
                builder.add(macro $i{sh.generatedVarName}.registerEvent($v{event}, function(event) { $e{scriptBuilder.expr} }));
            }
        }
    }
    
    private static function replaceThis(e:Expr):Expr {
        return switch (e.expr) {
            case EConst(CIdent("this")):
                {expr: EConst(CIdent("__this__")), pos: e.pos };
            case _:
                ExprTools.map(e, replaceThis);
        }
    }
    
    private static function replaceShortClassNames(e:Expr):Expr {
        return switch (e.expr) {
            case ENew(t, params):
                var fullPath = t.pack.concat([t.name]).join(".");
                var registeredClass = ComponentClassMap.get(fullPath);
                var r = e;
                if (registeredClass != null) {
                    r = { expr: ENew({ pack: ["haxe", "ui", "components"], name: "Button", params: t.params, sub: t.sub}, params), pos: e.pos};
                }
                r;
            case _:
                ExprTools.map(e, replaceShortClassNames);
        }
    }
    
    // returns next free id
    private static function buildComponentNode(builder:CodeBuilder, c:ComponentInfo, id:Int, parentId:Int, buildData:BuildData, recurseChildren:Bool = true) {
        if (c.condition != null && SimpleExpressionEvaluator.evalCondition(c.condition) == false) {
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

        assignComponentProperties(builder, c, componentVarName, buildData);
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

        if (c.id != null && buildData.namedComponents != null && useNamedComponents == true) {
            var varDescription = {
                generatedVarName: componentVarName,
                type: className
            };
            buildData.namedComponents.set(c.id, varDescription);
        }

        var childId = id + 1;
        if (recurseChildren == true) {
            for (child in c.children) {
                var nc = buildData.namedComponents;
                if (useNamedComponents == false) {
                    nc = null;
                }
                childId = buildComponentNode(builder, child, childId, id, {
                    namedComponents: nc,
                    bindingExprs: buildData.bindingExprs,
                    bindings: buildData.bindings,
                    languageBindings: buildData.languageBindings,
                    scripts: buildData.scripts
                });
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

        var buildData = {
            namedComponents: new Map<String, NamedComponentDescription>(),
            bindingExprs: [],
            scripts: [],
            bindings: []
        }
        
        builder.add(macro var $layoutVarName = new $typePath());
        assignProperties(builder, layoutVarName, l.properties, buildData, null);

        if (id != 0) {
            builder.add(macro $i{"c" + (id)}.layout = $i{"l" + id});
        }
    }

    private static function assignComponentProperties(builder:CodeBuilder, c:ComponentInfo, componentVarName:String, buildData:BuildData) {
        if (c.id != null)                       assignField(builder, componentVarName, "id", c.id, buildData, c);
        if (c.left != null)                     assignField(builder, componentVarName, "left", c.left, buildData, c);
        if (c.top != null)                      assignField(builder, componentVarName, "top", c.top, buildData, c);
        if (c.width != null)                    assignField(builder, componentVarName, "width", c.width, buildData, c);
        if (c.height != null)                   assignField(builder, componentVarName, "height", c.height, buildData, c);
        if (c.percentWidth != null)             assignField(builder, componentVarName, "percentWidth", c.percentWidth, buildData, c);
        if (c.percentHeight != null)            assignField(builder, componentVarName, "percentHeight", c.percentHeight, buildData, c);
        if (c.contentWidth != null)             assignField(builder, componentVarName, "contentWidth", c.contentWidth, buildData, c);
        if (c.contentHeight != null)            assignField(builder, componentVarName, "contentHeight", c.contentHeight, buildData, c);
        if (c.percentContentWidth != null)      assignField(builder, componentVarName, "percentContentWidth", c.percentContentWidth, buildData, c);
        if (c.percentContentHeight != null)     assignField(builder, componentVarName, "percentContentHeight", c.percentContentHeight, buildData, c);
        if (c.text != null)                     assignField(builder, componentVarName, "text", c.text, buildData, c);
        if (c.styleNames != null)               assignField(builder, componentVarName, "styleNames", c.styleNames, buildData, c);
        if (c.style != null)                    assignField(builder, componentVarName, "styleString", c.styleString, buildData, c);

        assignProperties(builder, componentVarName, c.properties, buildData, c);
    }

    // We'll re-use the same code for properties and components
    // certain things dont actually apply to layouts (namely "ComponentFieldMap", "on" and "${")
    // but they shouldnt cause any issues with layouts and the reuse is useful
    private static function assignProperties(builder:CodeBuilder, varName:String, properties:Map<String, String>, buildData:BuildData, c:ComponentInfo) {
        for (propName in properties.keys()) {
            var propValue = properties.get(propName);
            propName = ComponentFieldMap.mapField(propName);
            var propExpr = macro $v{TypeConverter.convertFrom(propValue)};

            if (StringTools.startsWith(propName, "on")) {
                buildData.scripts.push({
                    generatedVarName: varName,
                    eventName: propName,
                    code: propValue
                });
            } else if (Std.string(propValue).indexOf("${") != -1) {
                buildData.bindings.push({
                    generatedVarName: varName,
                    varProp: propName,
                    bindingExpr: propValue,
                    propType: TypeMap.getTypeInfo(c.resolvedClassName, propName)
                });
            } else {
                builder.add(macro $i{varName}.$propName = $propExpr);
            }
        }
    }

    private static function assignField(builder:CodeBuilder, varName:String, field:String, value:Any, buildData:BuildData, c:ComponentInfo) {
        var stringValue = Std.string(value);
        if (stringValue.indexOf("${") != -1) {
            buildData.bindings.push({
                generatedVarName: varName,
                varProp: field,
                bindingExpr: value,
                propType: TypeMap.getTypeInfo(c.resolvedClassName, field)
            });
            
        } else if (stringValue.indexOf("{{") != -1 && stringValue.indexOf("}}") != -1) {
            buildData.languageBindings.push({
                generatedVarName: varName,
                varProp: field,
                bindingExpr: value,
            });
            builder.add(macro $i{varName}.$field = $v{value});
        } else {
            builder.add(macro $i{varName}.$field = $v{value});
        }
    }
    
    private static function assignBinding(builder:CodeBuilder, bindingData:BindingData, namedComponents:Map<String, NamedComponentDescription>, addLocalVars:Bool = false) {
        var bindingExpr = bindingData.bindingExpr;
        var varName = bindingData.generatedVarName;
        var varProp = bindingData.varProp;
        var propType = bindingData.propType;
        
        if (propType == "String") {
            bindingExpr = StringTools.replace(bindingExpr, "'", "\"");
            bindingExpr = "'" + bindingExpr + "'";
        } else if (StringTools.startsWith(bindingExpr, "${") && StringTools.endsWith(bindingExpr, "}")) {
            bindingExpr = bindingExpr.substring(2, bindingExpr.length - 1);
        }
        var expr = Context.parseInlineString(bindingExpr, Context.currentPos());
        
        var dependants = getDependants(expr);
        var target = varName;
        for (dependantName in dependants.keys()) {
            if (namedComponents.exists(dependantName) == false) {
                continue;
            }
            
            var generatedDependantName = namedComponents.get(dependantName).generatedVarName;
            
            var ifBuilder = new CodeBuilder(macro {
            });
            
            var propList = dependants.get(dependantName);
            for (dependantProp in propList) {
                ifBuilder.add(macro if (e.data == $v{dependantProp}) {
                    $i{target}.$varProp = $e{expr};
                });
            }
            
            if (addLocalVars == true) {
                for (namedComponent in namedComponents.keys()) {
                    var namedComponentData = namedComponents.get(namedComponent);
                    ifBuilder.addToStart(macro var $namedComponent = $i{namedComponentData.generatedVarName});
                }
            }
            
            builder.add(macro {
                $i{generatedDependantName}.registerEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, function(e:haxe.ui.events.UIEvent) {
                    $e{ifBuilder.expr}
                });
            });
        }
    }
    
    private static function getDependants(expr:Expr):Map<String, Array<String>> {
        var dependants:Map<String, Array<String>> = new Map<String, Array<String>>();
        var iterateExprs = null;
        iterateExprs = function(e:Expr) {
            switch (e.expr) {
                case EField({ expr: EConst(CIdent(varName)), pos: _}, varField):
                    
                    var list = dependants.get(varName);
                    if (list == null) {
                        list = [];
                        dependants.set(varName, list);
                    }
                    if (list.indexOf(varField) == -1) {
                        list.push(varField);
                    }
                #if haxe4    
                case EConst(CString(s, _)):   
                #else
                case EConst(CString(s)):
                #end
                    var n1 = s.indexOf("${");
                    while (n1 != -1) {
                        var n2 = s.indexOf("}", n1);
                        var code = s.substring(n1 + 2, n2);
                        iterateExprs(Context.parseInlineString(code, Context.currentPos()));
                        n1 = s.indexOf("${", n2);
                    }
                case _:
                    ExprTools.iter(e, iterateExprs);
            }
        }
        iterateExprs(expr);
        return dependants;
    }
    #end
}