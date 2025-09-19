package haxe.ui.macros;


#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.ComponentFieldMap;
import haxe.ui.core.TypeMap;
import haxe.ui.macros.ModuleMacros;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;
import haxe.ui.macros.helpers.FunctionBuilder;
import haxe.ui.parsers.ui.ComponentInfo;
import haxe.ui.parsers.ui.ComponentParser;
import haxe.ui.parsers.ui.LayoutInfo;
import haxe.ui.parsers.ui.ValidatorInfo;
import haxe.ui.parsers.ui.resolvers.FileResourceResolver;
import haxe.ui.util.EventInfo;
import haxe.ui.util.ExpressionUtil;
import haxe.ui.util.SimpleExpressionEvaluator;
import haxe.ui.util.StringUtil;
import haxe.ui.util.TypeConverter;
import sys.io.File;

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
#end

@:access(haxe.ui.macros.Macros)
class ComponentMacros {
    @:deprecated("'haxe.ui.macros.ComponentMacros.build' is deprecated, use 'haxe.ui.ComponentBuilder.build' instead")
    macro public static function build(resourcePath:String, params:Expr = null):Array<Field> {
        return buildCommon(resourcePath, params);
    }
    
    @:deprecated("'haxe.ui.macros.ComponentMacros.buildComponent' is deprecated, use 'haxe.ui.ComponentBuilder.fromFile' instead")
    macro public static function buildComponent(filePath:String, params:Expr = null):Expr {
        return buildComponentCommon(filePath, params);
    }

    @:deprecated("'haxe.ui.macros.ComponentMacros.buildComponentFromString' is deprecated, use 'haxe.ui.ComponentBuilder.fromString' instead")
    macro public  static function buildComponentFromString(source:String, params:Expr = null):Expr {
        return buildFromStringCommon(source, params);
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

    macro public static function cascadeStylesTo(id:Expr, styleProperties:Expr = null, recursiveFind:Null<Bool> = null):Expr {
        if (styleProperties == null) {
            return macro null;
        }
        
        var stylePropertiesArray = MacroHelpers.exprToArray(styleProperties);
        if (stylePropertiesArray == null || stylePropertiesArray.length == 0) {
            return macro null;
        }

        var builder = new CodeBuilder();
        if (recursiveFind != null) {
            builder.add(macro var c = _component.findComponent($e{id}, haxe.ui.core.Component, $v{recursiveFind}));
        } else {
            builder.add(macro var c = _component.findComponent($e{id}, haxe.ui.core.Component));
        }
        var propertyExprs = [];
        for (prop in stylePropertiesArray) {
            propertyExprs.push(macro {
                if (style.$prop != null  && c.customStyle.$prop != style.$prop) {
                    c.customStyle.$prop = style.$prop;
                    invalidate = true;
                }
            });
        }
        
        builder.add(macro if (c != null) {
            var invalidate = false;
            
            $b{propertyExprs}
            
            if (invalidate == true) {
                c.invalidateComponentStyle();
            }
        });
        
        return builder.expr;
    }
    
    macro public static function cascadeStylesToList(componentType:Expr, styleProperties:Expr = null):Expr {
        if (styleProperties == null) {
            return macro null;
        }
        
        var stylePropertiesArray = MacroHelpers.exprToArray(styleProperties);
        if (stylePropertiesArray == null || stylePropertiesArray.length == 0) {
            return macro null;
        }
        
        var builder = new CodeBuilder();
        builder.add(macro var list = _component.findComponents($e{componentType}, 0xffffff));
        
        var propertyExprs = [];
        for (prop in stylePropertiesArray) {
            propertyExprs.push(macro {
                if (style.$prop != null && c.customStyle.$prop != style.$prop) {
                    c.customStyle.$prop = style.$prop;
                    invalidate = true;
                }
            });
        }
        
        builder.add(macro for (c in list) {
            var invalidate = false;
            
            $b{propertyExprs}
            
            if (invalidate == true) {
                c.invalidateComponentStyle();
            }
        });
        
        return builder.expr;
    }
    
    #if macro
    private static function buildFromStringCommon(source:String, params:Expr = null):Expr {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.buildFromStringCommon");
        #end

        var builder = new CodeBuilder();
        var buildData:BuildData = {
            params: MacroHelpers.exprToMap(params)
        };
        buildComponentFromStringCommon(builder, source, buildData, "rootComponent", true);
        buildBindings(builder, buildData, true);
        buildLanguageBindings(builder, buildData, true);
        builder.add(macro rootComponent);

        #if haxeui_macro_times
        stopTimer();
        #end

        return builder.expr;
    }
    
    private static function buildComponentCommon(filePath:String, params:Expr = null):Expr {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.buildComponentCommon");
        #end

        var builder = new CodeBuilder();
        var buildData:BuildData = {
            params: MacroHelpers.exprToMap(params)
        };
        buildComponentFromFile(null, builder, filePath, buildData, "rootComponent");
        buildBindings(builder, buildData, true);
        buildLanguageBindings(builder, buildData, true);
        builder.add(macro rootComponent);

        #if haxeui_macro_times
        stopTimer();
        #end

        return builder.expr;
    }
    
    private static function buildCommon(resourcePath:String, params:Expr = null):Array<Field> {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.buildCommon");
        #end

        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();

        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        #if !haxeui_dont_impose_base_class
        if (builder.hasSuperClass("haxe.ui.core.Component") == false) {
            Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
        }
        #end

        Macros.addConstructor(builder);
        if (builder.ctor == null) {
            Context.error("A class building component must have a constructor", Context.currentPos());
        }

        var originalRes = resourcePath;
        resourcePath = MacroHelpers.resolveFile(resourcePath);
        if (resourcePath == null) { // we couldnt find it relative to classpath roots, let see about relative to this class
            var relativePath = haxe.io.Path.normalize(builder.pkg.join("/") + "/" + originalRes);
            resourcePath = MacroHelpers.resolveFile(relativePath);
        }
        if (resourcePath == null || sys.FileSystem.exists(resourcePath) == false) {
            Context.error('UI markup file "${originalRes}" not found', Context.currentPos());
        }

        var codeBuilder = new CodeBuilder();
        var buildData:BuildData = {
            params: MacroHelpers.exprToMap(params)
        };
        var c:ComponentInfo = buildComponentFromFile(builder, codeBuilder, resourcePath, buildData, "this", false);
        var superClass:String = builder.superClass.t.toString();
        var rootType = ModuleMacros.resolveComponentClass(c.type, c.namespace);
        #if !haxeui_dont_impose_base_class
        if (haxe.ui.util.RTTI.hasSuperClass(builder.fullPath, rootType) == false) {
            Context.warning('The class hierarchy of "${builder.fullPath}" does not contain the root node of "${resourcePath}" (${rootType}) - this may have unintended consequences', pos);
        }
        #else
        builder.ctor.add(macro applyRootLayout($v{c.type}));
        #end

        for (id in buildData.namedComponents.keys()) {
            var safeId:String = StringUtil.capitalizeHyphens(id);
            if (safeId == "new") {
                Context.error("'new' is a reserved word and cannot be used to name variables / components (" + resourcePath + ")", Context.currentPos());
            }
            var varDescription = buildData.namedComponents.get(id);
            var cls:String = varDescription.type;
            if (!builder.hasVar(safeId)) {
                builder.addVar(safeId, TypeTools.toComplexType(Context.getType(cls)));
            }
            codeBuilder.add(macro
                $i{safeId} = $i{varDescription.generatedVarName}
            );
        }

        var resolvedClass:String = "" + Context.getLocalClass();
        var alias = resolvedClass.substr(resolvedClass.lastIndexOf(".") + 1, resolvedClass.length).toLowerCase();
        ComponentClassMap.register(alias, resolvedClass);

        for (expr in buildData.bindingExprs) {
            codeBuilder.add(expr);
        }

        buildBindings(codeBuilder, buildData);
        buildLanguageBindings(codeBuilder, buildData);
        var bindFields = builder.getFieldsWithMeta("bind");
        for (f in bindFields) {
            for (n in 0...f.getMetaCount("bind")) { // single method can be bound to multiple events
                var meta = f.getMetaByIndex("bind", n);
                switch (meta.params) {
                    case [{expr: EField(variable, field), pos: pos}]: // one param, lets assume binding to component prop
                        Macros.buildPropertyBinding(builder, f, variable, field);
                    case [param1]:
                        Macros.buildPropertyBinding(builder, f, param1, "value"); // input component that has value
                }
                
            }
        }
        
        builder.ctor.add(codeBuilder, AfterSuper);

        #if haxeui_macro_times
        stopTimer();
        #end

        return builder.fields;
    }

    private static function buildComponentFromFile(classBuilder:ClassBuilder, builder:CodeBuilder, filePath:String, buildData:BuildData = null, rootVarName:String = "this", buildRoot:Bool = true):ComponentInfo {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.buildComponentFromFile");
        #end

        populateBuildData(buildData);        
        
        var f = MacroHelpers.resolveFile(filePath);
        if (f == null) {
            throw "Could not resolve: " + filePath + "(cwd: " + Sys.getCwd() + ", classpath: " + Context.getClassPath() + ")";
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
        if (fullScript.length > 0) {
            if (classBuilder != null) {
                buildScriptFunctions(classBuilder, builder, buildData.namedComponents, fullScript);   
            } else {
                buildScriptFunctionForwardDeclarations(builder, fullScript);
            }
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
        
        buildScriptHandlers(builder, buildData.namedComponents, buildData.scripts);
        if (buildRoot == false) {
            if (classBuilder.hasInterface("haxe.ui.core.IDataComponent") == true && c.data != null) {
                buildDataSourceCode(builder, c, 'ds_root', "this");
            }

            buildData.scripts = [];
            assignComponentProperties(builder, c, rootVarName, buildData);
            if (c.layout != null) {
                buildLayoutCode(builder, c, rootVarName);
            }
            buildScriptHandlers(builder, buildData.namedComponents, buildData.scripts);
        }
        
        if (classBuilder == null) {
            buildScriptFunctions(classBuilder, builder, buildData.namedComponents, fullScript);   
        }

        builder.add(macro $i{rootVarName}.bindingRoot = true);
       
        #if haxeui_macro_times
        stopTimer();
        #end

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
    
    private static function buildComponentFromStringCommon(builder:CodeBuilder, source:String, buildData:BuildData = null, rootVarName:String = "this", buildRoot:Bool = false, classBuilder:ClassBuilder = null):ComponentInfo {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.buildComponentFromStringCommon");
        #end

        populateBuildData(buildData);
        
        source = StringUtil.replaceVars(source, buildData.params);
        var c:ComponentInfo = ComponentParser.get("xml").parse(source);
        #if haxeui_dont_impose_base_class
        builder.add(macro applyRootLayout($v{c.type}));
        #end

        for (s in c.styles) {
            if (s.scope == "global") {
                builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{s.style}, "user"));
            }
        }

        if (buildRoot == true) {
            buildComponentNode(builder, c, 0, -1, buildData, false);
            builder.add(macro var $rootVarName = c0);
        }

        if (c.layout != null) {
            buildLayoutCode(builder, c, rootVarName);
        }
        
        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
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

        buildScriptHandlers(builder, buildData.namedComponents, buildData.scripts);
        if (classBuilder != null && classBuilder.hasInterface("haxe.ui.core.IDataComponent") == true && c.data != null) {
            buildDataSourceCode(builder, c, 'ds_root', rootVarName);
        }
        assignComponentProperties(builder, c, rootVarName, buildData);
        
        builder.add(macro $i{rootVarName}.bindingRoot = true);

        #if haxeui_macro_times
        stopTimer();
        #end

        return c;
    }

    private static function buildComponentFromInfo(builder:CodeBuilder, c:ComponentInfo, buildData:BuildData, cb:ComponentInfo->CodeBuilder->Void = null, firstId:Int = 0) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.buildComponentFromInfo");
        #end

        populateBuildData(buildData);

        for (s in c.styles) {
            if (s.scope == "global") {
                builder.add(macro haxe.ui.Toolkit.styleSheet.parse($v{s.style}, "user"));
            }
        }

        var r = buildComponentNode(builder, c, firstId, -1, buildData);
        
        if (cb != null) {
            cb(c, builder);
        }

        #if haxeui_macro_times
        stopTimer();
        #end

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
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.buildScriptFunctions");
        #end

        var replaceOverride = new EReg("(override).*function", "gm");
        script = replaceOverride.map(script, function(r) {
            return StringTools.replace(r.matched(0), "override", "@:override");
        });
        var replacePrivate = new EReg("(private).*function", "gm");
        script = replacePrivate.map(script, function(r) {
            return StringTools.replace(r.matched(0), "private", "@:private");
        });
        var replaceGetSet = new EReg("var .*(get|set).*;", "gm");
        script = replaceGetSet.map(script, function(r) {
            var s = r.matched(0);
            var n1 = s.indexOf("(");
            var n2 = s.indexOf(")");
            var before = s.substr(0, n1);
            var after = s.substr(n2 + 1);
            var middle = s.substr(n1, n2);
            var modified = before + after;
            if (middle.indexOf("get") != -1) {
                modified = "@:get " + modified;
            }
            if (middle.indexOf("set") != -1) {
                modified = "@:set " + modified;
            }
            return modified;
        });

        var expr = Context.parseInlineString("{" + script + "}", Context.currentPos());
        expr = ExprTools.map(expr, replaceShortClassNames);
        expr = ExprTools.map(expr, replaceInternalShortNames);
        switch (expr.expr) {
            case EBlock(exprs):
                for (e in exprs) {
                    buildScriptFunctionsFromExpr(e, classBuilder, builder, namedComponents, null);
                }
            case _:
                trace("unsupported " + expr);
                
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }
    
    private static function buildScriptFunctionsFromExpr(e:Expr, classBuilder:ClassBuilder, builder:CodeBuilder, namedComponents:Map<String, NamedComponentDescription>, metas:Array<MetadataEntry>) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.buildScriptFunctionsFromExpr");
        #end

        switch (e.expr) {
            case EMeta(s, e):
                if (metas == null) {
                    metas = [];
                }
                metas.push(s);
                buildScriptFunctionsFromExpr(e, classBuilder, builder, namedComponents, metas);
            #if haxe4
            case EFunction(kind, f):
                switch (kind) {
                    case FNamed(name, inlined):
                        if (classBuilder != null) {
                            var access = [APublic];
                            if (metas != null) {
                                for (m in metas) {
                                    if (m.name == ":private" || m.name == "private") {
                                        access.remove(APublic);
                                        access.push(APrivate);
                                    }
                                    if (m.name == ":override" || m.name == "override") {
                                        access.push(AOverride);
                                    }
                                }
                            }
                            classBuilder.addFunction(name, f.expr, f.args, f.ret, access);
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
                        var get = null;
                        var set = null;
                        if (metas != null) {
                            for (m in metas) {
                                if (m.name == ":get" || m.name == "get") {
                                    get = "get";
                                }
                                if (m.name == ":set" || m.name == "set") {
                                    set = "set";
                                }
                            }
                        }
                        if (get == null && set == null) {
                            classBuilder.addVar(v.name, vtype, v.expr);
                        } else {
                            classBuilder.addProp(v.name, vtype, v.expr, get, set);
                        }
                    } else {
                        if (v.expr != null) {
                            builder.add(macro $i{v.name} = $e{v.expr});
                        }
                    }
                }
            case _:
                trace("unsupported " + e);
        }
        #if haxeui_macro_times
        stopTimer();
        #end
    }

    private static function buildLanguageBindings(builder:CodeBuilder, buildData:BuildData, addLocalVars:Bool = false) {
        for (languageBinding in buildData.languageBindings) {
            assignLanguageBinding(builder, languageBinding, buildData.namedComponents, addLocalVars);
        }
    }
    
    private static function assignLanguageBinding(builder:CodeBuilder, languageBinding:LanguageBindingData, namedComponents:Map<String, NamedComponentDescription>, addLocalVars:Bool = false) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.assignLanguageBinding");
        #end

        var fixedExpr = ExpressionUtil.stringToLanguageExpression(languageBinding.bindingExpr);
        if (StringTools.endsWith(fixedExpr, ";") == false) {
            fixedExpr += ";";
        }
        var varName = languageBinding.generatedVarName;
        var field = languageBinding.varProp;
        var expr = Context.parseInlineString("{" + fixedExpr + "}", Context.currentPos());
        var exprBuilder = new CodeBuilder(expr);
        
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
            
            if (addLocalVars == true) {
                for (namedComponent in namedComponents.keys()) {
                    var namedComponentData = namedComponents.get(namedComponent);
                    ifBuilder.addToStart(macro var $namedComponent = $i{namedComponentData.generatedVarName});
                    exprBuilder.addToStart(macro var $namedComponent = $i{namedComponentData.generatedVarName});
                }
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

        #if haxeui_macro_times
        stopTimer();
        #end
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
                
                var expr = Context.parseInlineString(fixedCode, Context.currentPos());
                var usedVars = [];
                expr = ExprTools.map(expr, replaceThis);
                expr = ExprTools.map(expr, replaceShortClassNames);
                expr = ExprTools.map(expr, replaceInternalShortNames);
                expr = ExprTools.map(expr, findVars.bind(usedVars));
                
                for (namedComponent in namedComponents.keys()) {
                    var details = namedComponents.get(namedComponent);
                    var safeId:String = StringUtil.capitalizeHyphens(namedComponent);
                    if (safeId == "new") {
                        Context.error("'new' is a reserved word and cannot be used to name variables / components", Context.currentPos());
                    }
                    if (usedVars.indexOf(safeId) == -1) {
                        continue;
                    }
                    scriptBuilder.add(macro var $safeId = $i{details.generatedVarName});
                }

                scriptBuilder.add(expr);
                var eventType = "haxe.ui.events.UIEvent";
                if (EventInfo.nameToType.exists(sh.eventName)) {
                    eventType = EventInfo.nameToType.get(sh.eventName);
                }
                var eventTypeParts = eventType.split(".");
                var eventTypeName = eventTypeParts.pop();
                var eventComplexType = ComplexType.TPath({pack: eventTypeParts, name: eventTypeName});
                builder.add(macro $i{sh.generatedVarName}.registerEvent($v{event}, function(event:$eventComplexType) { $e{scriptBuilder.expr} }));
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
    
    private static function findVars(list:Array<String>, e:Expr):Expr {
        switch (e.expr) {
            case EConst(CIdent(name)):
                list.push(name);
            case _:    
        }
        return ExprTools.map(e, findVars.bind(list));
    }
    
    private static function replaceShortClassNames(e:Expr):Expr {
        return switch (e.expr) {
            case ENew(t, params):
                var fullPath = t.pack.concat([t.name]).join(".");
                var registeredClass = ModuleMacros.resolveComponentClass(fullPath);
                var r = e;
                if (registeredClass != null) {
                    r = { expr: ENew({ pack: ["haxe", "ui", "components"], name: "Button", params: t.params, sub: t.sub}, params), pos: e.pos};
                }
                r;
            case _:
                ExprTools.map(e, replaceShortClassNames);
        }
    }
    
    private static function replaceInternalShortNames(e:Expr):Expr {
        return switch (e.expr) {
            case EConst(CIdent(s)):
                var r = e;
                if (s == "theme") {
                    r = macro haxe.ui.themes.ThemeManager.instance;
                }
                r;
            case _:
                ExprTools.map(e, replaceInternalShortNames);
        }
    }

    // returns next free id
    private static function buildComponentNode(builder:CodeBuilder, c:ComponentInfo, id:Int, parentId:Int, buildData:BuildData, recurseChildren:Bool = true) {
        #if macro_times_verbose
        var stopTimer = Context.timer("ComponentMacros.buildComponentNode");
        #end

        if (c.condition != null && SimpleExpressionEvaluator.evalCondition(c.condition) == false) {
            #if macro_times_verbose
            stopTimer();
            #end
            return id;
        }

        var className = ModuleMacros.resolveComponentClass(c.type, c.namespace);
        if (className == null) {
            #if macro_times_verbose
            stopTimer();
            #end
            Sys.println("WARNING: no class found for component '" + c.type + "' in '" + c.filename + "'");
            return id;
        }

        //var classInfo = new ClassBuilder(Context.getModule(className)[0]);
        var classInfo = new ClassBuilder(Context.getType(className));
        var useNamedComponents = true;
        if (classInfo.hasSuperClass("haxe.ui.core.ItemRenderer")) { // we dont really want to create variable instances of contents of item renderers
            useNamedComponents = false;
        }
        if (classInfo.hasDirectInterface("haxe.ui.core.IDirectionalComponent")) {
            var direction = c.direction;
            if (direction == null) {
                direction = "horizontal"; // default to horizontal
            }
            var directionalClassName = ModuleMacros.resolveComponentClass(direction + c.type, c.namespace);
            if (directionalClassName == null) {
                trace("WARNING: no directional class found for component: " + c.type + " (" + (direction + c.type.toLowerCase()) + ")");
                #if macro_times_verbose
                stopTimer();
                #end
                return id;
            }

            var directionalClassInfo = new ClassBuilder(Context.getModule(directionalClassName)[0]); // we want to use get getModule (and therefore create a ref) to ensure macro order is determinate
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
            buildLayoutCode(builder, c, componentVarName);
        }

        if (classInfo.hasInterface("haxe.ui.core.IDataComponent") == true && c.data != null) {
            buildDataSourceCode(builder, c, 'ds${id}', componentVarName);
        }

        if (c.validators != null) {
            buildValidatorCode(builder, c.validators, id);
        }

        if (c.id != null && buildData.namedComponents != null && useNamedComponents == true) {
            var rootComponentInfo = c.findRootComponent();
            var rootClassName = ModuleMacros.resolveComponentClass(rootComponentInfo.type, rootComponentInfo.namespace);
            var rootClassInfo = new ClassBuilder(Context.getModule(rootClassName)[0]);
            if (rootClassInfo.hasField(c.id, true) == false) {
                var varDescription = {
                    generatedVarName: componentVarName,
                    type: className
                };
                buildData.namedComponents.set(c.id, varDescription);
            } else {
                if (classInfo.hasSuperClass("haxe.ui.components.Column") == false) {
                    trace('WARNING: skipped adding a member variable (${c.id}) that conflicted with a property found on root component (${rootClassName})');
                }
            }
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
        
        #if macro_times_verbose
        stopTimer();
        #end

        return childId;
    }

    private static function buildDataSourceCode(builder:CodeBuilder, c:ComponentInfo, dsVarName:String, componentVarName:String) {
        var items = new haxe.ui.data.DataSourceFactory<Dynamic>().fromStringToArray(c.dataString);
        builder.add(macro var $dsVarName = new haxe.ui.data.ArrayDataSource<Dynamic>());
        for (item in items) {
            var hasExpression:Bool = false;
            // lets first find out if any of the items are expressions
            for (f in Reflect.fields(item)) {
                var v = Std.string(Reflect.field(item, f));
                if (StringTools.startsWith(v, "${") && StringTools.endsWith(v, "}")) {
                    hasExpression = true;
                    break;
                }
            }
            
            if (hasExpression) {
                builder.add(macro var __item:Dynamic = {} );
                for (f in Reflect.fields(item)) {
                    var v = Reflect.field(item, f);
                    var stringValue = Std.string(v);
                    if (StringTools.startsWith(stringValue, "${") && StringTools.endsWith(stringValue, "}")) {
                        stringValue = stringValue.substring(2, stringValue.length - 1);
                        var expr = Context.parseInlineString(stringValue, Context.currentPos());
                        builder.add(macro __item.$f = $e{expr});
                    } else {
                        builder.add(macro __item.$f = $v{v});
                    }
                }
                builder.add(macro $i{dsVarName}.add($i{"__item"}));
            } else {
                builder.add(macro $i{dsVarName}.add($v{item}));
            }
        }
        builder.add(macro ($i{componentVarName} : haxe.ui.core.IDataComponent).dataSource = $i{dsVarName});
    }
    
    private static function buildLayoutCode(builder:CodeBuilder, c:ComponentInfo, componentVarName:String) {
        var l = c.layout;
        var layoutVarName = 'layout_${componentVarName}';
        var buildData = {
            namedComponents: new Map<String, NamedComponentDescription>(),
            bindingExprs: [],
            scripts: [],
            bindings: []
        }
        
        var layoutName = l.type.toLowerCase();
        var layoutClass = haxe.ui.layouts.LayoutFactory.lookupClass(layoutName);
        if (layoutClass == null) {
            Sys.println("WARNING: layout '" + l.type + "' not found for '" + c.type + "' in '" + c.filename + "'");
            return;
        }
        var parts = layoutClass.split(".");
        var typePath = {
            name: parts.pop(),
            pack: parts
        }
        builder.add(macro var $layoutVarName = new $typePath());
        assignProperties(builder, layoutVarName, l.properties, buildData, null);
        builder.add(macro $i{componentVarName}.layout = $i{layoutVarName});
    }

    private static var _nextValidatorId = 0;
    private static function buildValidatorCode(builder:CodeBuilder, validators:Array<ValidatorInfo>, id:Int) {
        if (validators.length == 0) {
            return;
        }

        var validatorExprs:Array<Expr> = [];
        var validatorAssignExprs:Array<Expr> = [];
        for (validator in validators) {
            var type = validator.type;
            var validatorId = 'validator${_nextValidatorId}';
            validatorExprs.push(macro @:mergeBlock {
                var $validatorId = haxe.ui.validators.ValidatorManager.instance.createValidator($v{type});
            });
            if (validator.properties != null) {
                for (propertyName in validator.properties.keys()) {
                    var propertyValue = validator.properties.get(propertyName);
                    var convertedPropertyValue = TypeConverter.convertFrom(propertyValue);
                    validatorExprs.push(macro $i{validatorId}.setProperty($v{propertyName}, $v{convertedPropertyValue}));
                }
            }
            validatorAssignExprs.push(macro $i{validatorId});
            _nextValidatorId++;
        }
        if (id != -1) {
            for (e in validatorExprs) {
                builder.add(e);
            }
            builder.add(macro $i{"c" + (id)}.validators = $a{validatorAssignExprs});
            builder.add(macro @:privateAccess $i{"c" + (id)}.validators.component = $i{"c" + (id)});
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

            if (StringTools.startsWith(propName, "on")) {
                if (propValue != null && StringTools.trim(propValue).length > 0) {
                    buildData.scripts.push({
                        generatedVarName: varName,
                        eventName: propName.toLowerCase(),
                        code: propValue
                    });
                }
            } else if (Std.string(propValue).indexOf("${") != -1) {
                buildData.bindings.push({
                    generatedVarName: varName,
                    varProp: propName,
                    bindingExpr: propValue,
                    propType: TypeMap.getTypeInfo(c.resolvedClassName, propName)
                });
            } else {
                if (c != null && c.resolvedClassName != null) {
                    var propType = null;
                    var propInfo = haxe.ui.util.RTTI.getClassProperty(c.resolvedClassName, propName);
                    if (propInfo != null) {
                        propType = propInfo.propertyType;
                    }
                    //var propExpr = macro $v{TypeConverter.convertTo(TypeConverter.convertFrom(propValue), propType)};
                    if (propType != null) {
                        var pos = Context.currentPos();
                        var propExpr = macro @:pos(pos) $v{TypeConverter.convertTo(propValue, propType)};
                        builder.add(macro $i{varName}.$propName = $propExpr);
                    } else {
                        var pos = Context.currentPos();
                        var propExpr = macro @:pos(pos) $v{TypeConverter.convertFrom(propValue)};
                        builder.add(macro $i{varName}.$propName = $propExpr);
                    }
                } else {
                    
                    var propExpr = macro $v{TypeConverter.convertFrom(propValue)};
                    builder.add(macro $i{varName}.$propName = $propExpr);
                }
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
        #if haxeui_macro_times
        var stopTimer = Context.timer("ComponentMacros.assignBinding");
        #end

        var bindingExpr = bindingData.bindingExpr;
        var varName = bindingData.generatedVarName;
        var varProp = bindingData.varProp;
        var propType = bindingData.propType;
        
        if (StringTools.startsWith(bindingExpr, "${") && StringTools.endsWith(bindingExpr, "}")) {
            bindingExpr = bindingExpr.substring(2, bindingExpr.length - 1);
        } else if (bindingExpr.indexOf("${") != -1) {
            trace("ERROR: property value " + varProp +" contains \"${\" string, if you want to use code it must start with a \"${\" and end with with a \"}\"");
        }
        var expr = Context.parseInlineString(bindingExpr, Context.currentPos());
        expr = ExprTools.map(expr, replaceInternalShortNames);
        
        var dependants = getDependants(expr);
        var target = varName;
        var dependantCount = 0;
        for (dependantName in dependants.keys()) {
            if (namedComponents.exists(dependantName) == false) {
                continue;
            }
            
            var generatedDependantName = namedComponents.get(dependantName).generatedVarName;
            
            var ifBuilder = new CodeBuilder(macro {
            });
            
            var propList = dependants.get(dependantName);
            var initialExprs:Array<Expr> = [];
            for (dependantProp in propList) {
                if (propType == "string") {
                    var expr = macro $i{target}.$varProp = Std.string($e{expr});
                    initialExprs.push(expr);
                    ifBuilder.add(macro if (e.data == $v{dependantProp}) {
                        ${expr};
                    });
                } else if (propType == "bool") {
                    var expr = macro $i{target}.$varProp = Std.string($e{expr}) == "true" || Std.string($e{expr}) == "1";
                    initialExprs.push(expr);
                    ifBuilder.add(macro if (e.data == $v{dependantProp}) {
                        ${expr}
                    });
                } else if (propType == "float") {
                    var expr = macro $i{target}.$varProp = Std.parseFloat(Std.string($e{expr}));
                    initialExprs.push(expr);
                    ifBuilder.add(macro if (e.data == $v{dependantProp}) {
                        ${expr}
                    });
                } else if (propType == "int") {
                    var expr = macro $i{target}.$varProp = Std.parseInt(Std.string($e{expr}));
                    initialExprs.push(expr);
                    ifBuilder.add(macro if (e.data == $v{dependantProp}) {
                        ${expr}
                    });
                } else {
                    var expr = macro $i{target}.$varProp = $e{expr};
                    initialExprs.push(expr);
                    ifBuilder.add(macro if (e.data == $v{dependantProp}) {
                        ${expr}
                    });
                }
            }
            
            if (addLocalVars == true) {
                for (namedComponent in namedComponents.keys()) {
                    var namedComponentData = namedComponents.get(namedComponent);
                    ifBuilder.addToStart(macro var $namedComponent = $i{namedComponentData.generatedVarName});
                }
            }
            
            for (expr in initialExprs) {
                builder.add(macro ${expr});
            }
            builder.add(macro {
                $i{generatedDependantName}.registerEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, function(e:haxe.ui.events.UIEvent) {
                    $e{ifBuilder.expr}
                });
            });
            
            dependantCount++;
        }
        
        for (dependantName in dependants.keys()) {
            if (dependantName == "theme") { // special case for themes - may need to expand on this for other parts of core
                builder.add(macro {
                    var theme = haxe.ui.themes.ThemeManager.instance;
                    haxe.ui.themes.ThemeManager.instance.registerEvent(haxe.ui.events.ThemeEvent.THEME_CHANGED, function(_) {
                        $i{target}.$varProp = $e{expr};
                    });
                    $i{target}.$varProp = $e{expr};
                });
            }
        }
        
        if (dependantCount == 0) {
            if (propType == "string") {
                builder.add(macro $i{target}.$varProp = Std.string($e{expr}));
            } else {
                builder.add(macro $i{target}.$varProp = $e{expr});
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
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
