package haxe.ui.macros;


#if macro
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.macros.ComponentMacros.BuildData;
import haxe.ui.macros.ComponentMacros.NamedComponentDescription;
import haxe.ui.macros.ModuleMacros;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;
import haxe.ui.macros.helpers.CodePos;
import haxe.ui.macros.helpers.FieldBuilder;
import haxe.ui.util.EventInfo;
import haxe.ui.util.RTTI;
import haxe.ui.util.StringUtil;
import haxe.ui.util.TypeConverter;

using StringTools;

#end

@:access(haxe.ui.macros.ComponentMacros)
class Macros {
    #if macro

    macro static function buildEvent():Array<Field> {
        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        #if haxeui_expose_all
        builder.addMeta(":expose");
        #end

        #if macro_times_verbose
        var stopComponentTimer = Context.timer(builder.fullPath);
        #end
        #if haxeui_macro_times
        var stopTimer = Context.timer("build event");
        #end

        for (f in builder.fields) {
            if ((f.access.indexOf(AInline) != -1 || f.access.indexOf(AFinal) != -1) && f.access.indexOf(AStatic) != -1) {
                switch (f.kind) {
                    case FVar(t, e):
                        var eventName = ExprTools.toString(e);
                        eventName = StringTools.replace(eventName, "\"", "");
                        eventName = StringTools.replace(eventName, "'", "");
                        eventName = eventName.toLowerCase();
                        eventName = StringTools.replace(eventName, "eventtype.name(", "");
                        eventName = StringTools.replace(eventName, ")", "");
                        EventInfo.nameToType.set(eventName, builder.fullPath);
                        EventInfo.nameToType.set("on" + eventName, builder.fullPath);
                    case _:
                }
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
        #if macro_times_verbose
        stopComponentTimer();
        #end

        return builder.fields;
    }
    
    macro static function build():Array<Field> {
        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        #if haxeui_expose_all
        builder.addMeta(":expose");
        #end

        #if macro_times_verbose
        var stopComponentTimer = Context.timer(builder.fullPath);
        #end
        #if haxeui_macro_times
        var stopTimer = Context.timer("build component");
        #end

        ModuleMacros.loadModules();

        ComponentClassMap.register(builder.name, builder.fullPath);

        if (builder.hasClassMeta(["xml"])) {
            buildFromXmlMeta(builder);
        }

        if (builder.hasClassMeta(["composite"])) {
            buildComposite(builder);
        }

        buildEvents(builder);
        applyProperties(builder);
        addPropertiesToRTTI(builder);
        
        #if haxeui_macro_times
        stopTimer();
        #end
        #if macro_times_verbose
        stopComponentTimer();
        #end

        return builder.fields;
    }

    static function addConstructor(builder:ClassBuilder) {
        if (builder.ctor == null) {
            builder.addFunction("new", macro { super(); });
        }
    }
    
    static function applyProperties(builder:ClassBuilder) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("apply properties");
        #end

        var propPrefix = builder.fullPath.toLowerCase();
        if (ModuleMacros.properties.exists(propPrefix + ".style")) {
            var styleNames = ModuleMacros.properties.get(propPrefix + ".style");
            var createDefaultsFn = builder.findFunction("createDefaults");
            if (createDefaultsFn == null) {
                createDefaultsFn = builder.addFunction("createDefaults", macro {
                    super.createDefaults();
                }, null, null, [AOverride, APrivate]);
            }
            for (n in styleNames.split(" ")) {
                if (StringTools.trim(n).length == 0) {
                    continue;
                }
                createDefaultsFn.add(macro addClass($v{n}));
            }
        } else {
            for (key in ModuleMacros.properties.keys()) {
                if (key.startsWith(propPrefix)) {
                    var createDefaultsFn = builder.findFunction("createDefaults");
                    if (createDefaultsFn == null) {
                        createDefaultsFn = builder.addFunction("createDefaults", macro {
                            super.createDefaults();
                        }, null, null, [AOverride, APrivate]);
                    }
                    var propName = key.split(".").pop();
                    var propValue = ModuleMacros.properties.get(key);
                    var convertedPropValue = TypeConverter.convertFrom(propValue);
                    createDefaultsFn.add(macro $i{propName} = $v{convertedPropValue});
                }
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    static function addPropertiesToRTTI(builder:ClassBuilder) {
        for (f in builder.fields) {
            if (f.access.indexOf(APrivate) != -1 || f.access.indexOf(AStatic) != -1) {
                continue;
            }
            if (f.name == "value") {
                continue;
            }
            var isBehaviour = false;
            for (m in f.meta) {
                if (m.name == ":behaviour") {
                    isBehaviour = true;
                    break;
                }
            }
            if (isBehaviour) {
                continue;
            }
            var t = switch (f.kind) {
                case FVar(t, _): t;
                case FProp(_, _, t, _): t;
                case _: null;
            }

            if (t != null) {
                var allowed = switch (t) {
                    case TFunction(args, ret): false;
                    case _: true;
                }
                if (allowed) {
                    RTTI.addClassProperty(builder.fullPath, f.name, ComplexTypeTools.toString(t));
                }
            }
        }
    }
    
    static function buildFromXmlMeta(builder:ClassBuilder) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("build from xml meta");
        #end

        #if !haxeui_dont_impose_base_class
        if (builder.hasSuperClass("haxe.ui.core.Component") == false) {
            Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
        }
        #end

        addConstructor(builder);
        if (builder.ctor == null) {
            Context.error("A class building component must have a constructor", Context.currentPos());
        }

        var xml:String = builder.getClassMetaValue("xml");
        if (xml.indexOf("@:markup") != -1) { // means it was xml without quotes, lets extract and clean it up a little
            xml = xml.replace("@:markup", "").trim();
            xml = xml.substr(1, xml.length - 2);
            #if (haxe_ver <= 4.2)
            xml = xml.replace("\\r", "\r");
            xml = xml.replace("\\n", "\n");
            #end
            xml = xml.replace("\\\"", "\"");
            xml = xml.replace("\\'", "'");
        }
        var codeBuilder = new CodeBuilder();
        var buildData:BuildData = { };
        ComponentMacros.buildComponentFromStringCommon(codeBuilder, xml, buildData, "this", false, builder);

        for (id in buildData.namedComponents.keys()) {
            var safeId:String = StringUtil.capitalizeHyphens(id);
            var info:NamedComponentDescription = buildData.namedComponents.get(id);
            builder.addVar(safeId, TypeTools.toComplexType(Context.getType(info.type)));
            codeBuilder.add(macro
                $i{safeId} = $i{info.generatedVarName}
            );
        }

        for (expr in buildData.bindingExprs) {
            codeBuilder.add(expr);
        }

        ComponentMacros.buildBindings(codeBuilder, buildData);
        ComponentMacros.buildLanguageBindings(codeBuilder, buildData);
        // TODO: namespace shouldnt always be default
        ComponentClassMap.register("urn::haxeui::org/" + builder.name, builder.fullPath);
        
        builder.ctor.add(codeBuilder, AfterSuper);

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    static function buildComposite(builder:ClassBuilder) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("build composite");
        #end

        var registerCompositeFn = builder.findFunction("registerComposite");
        if (registerCompositeFn == null) {
            registerCompositeFn = builder.addFunction("registerComposite", macro {
                super.registerComposite();
            }, [APrivate, AOverride]);
        }

        for (param in builder.getClassMetaValues("composite")) {
            // probably a better way to do this
            if (Std.string(param).indexOf("Event") != -1) {
                registerCompositeFn.add(macro
                    _internalEventsClass = $p{param.split(".")}
                );
            } else if (Std.string(param).indexOf("Builder") != -1) {
                registerCompositeFn.add(macro
                    _compositeBuilderClass = $p{param.split(".")}
                );
            } else if (Std.string(param).indexOf("Layout") != -1) {
                registerCompositeFn.add(macro
                    _defaultLayoutClass = $p{param.split(".")}
                );
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    static function buildEvents(builder:ClassBuilder) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("build events");
        #end

        for (f in builder.getFieldsWithMeta("event")) {
            f.remove();
            if (builder.hasFieldSuper(f.name)) {
                continue;
            }
            var eventExpr = f.getMetaValueExpr("event");
            var varName = '_internal__${f.name}';
            builder.addVar(varName, f.type, null, null, [{name: ":noCompletion", pos: Context.currentPos()}]);
            var setter = builder.addSetter(f.name, f.type, macro {
                if ($i{varName} != null) {
                    unregisterEvent($e{eventExpr}, $i{varName});
                    $i{varName} = null;
                }
                if (value != null) {
                    $i{varName} = value;
                    registerEvent($e{eventExpr}, value);
                }
                return value;
            });
            setter.addMeta(":dox", [macro group = "Event related properties and methods"]);
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    static function buildStyles(builder:ClassBuilder) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("build styles");
        #end

        for (f in builder.getFieldsWithMeta("style")) {
            f.remove();
            RTTI.addClassProperty(builder.fullPath, f.name, ComplexTypeTools.toString(f.type));

            var defaultValue:Dynamic = null;
            if (f.isNumeric == true) {
                defaultValue = 0;
            } else if (f.isBool == true) {
                defaultValue = false;
            }

            var getter = builder.addGetter(f.name, f.type, macro {
                if ($p{["customStyle", f.name]} != null) {
                    return $p{["customStyle", f.name]};
                }
                if (style == null || $p{["style", f.name]} == null) {
                    return $v{defaultValue};
                }
                return $p{["style", f.name]};
            });
            getter.addMeta(":style");
            getter.addMeta(":keep");
            //getter.addMeta(":clonable");
            getter.addMeta(":dox", [macro group = "Style properties"]);

            var codeBuilder = new CodeBuilder(macro {
                if ($p{["customStyle", f.name]} == value) {
                    return value;
                }
                if (_style == null) {
                    _style = {};
                }
                if (value == null) {
                    $p{["customStyle", f.name]} = null;
                } else {
                    $p{["customStyle", f.name]} = value;
                }
                return value;
            });
            
            if (f.name == "borderColor") {
                codeBuilder.add(macro {
                    customStyle.borderTopColor = value;
                    customStyle.borderLeftColor = value;
                    customStyle.borderBottomColor = value;
                    customStyle.borderRightColor = value;
                });
            } else if (f.name == "borderSize") {
                codeBuilder.add(macro {
                    customStyle.borderTopSize = value;
                    customStyle.borderLeftSize = value;
                    customStyle.borderBottomSize = value;
                    customStyle.borderRightSize = value;
                });
            }
            codeBuilder.add(macro invalidateComponentStyle());
            
            if (f.hasMetaParam("style", "layout")) {
                codeBuilder.add(macro
                    invalidateComponentLayout()
                );
            }
            if (f.hasMetaParam("style", "layoutparent")) {
                codeBuilder.add(macro
                    if (parentComponent != null) parentComponent.invalidateComponentLayout()
                );
            }
            builder.addSetter(f.name, f.type, codeBuilder.expr);
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    private static function buildPropertyBinding(builder:ClassBuilder, f:FieldBuilder, variable:Expr, field:String) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("build property binding");
        #end

        var hasField = builder.hasField(f.name, true);
        var hasGetter = builder.findFunction("get_" + f.name) != null;
        var hasSetter = builder.findFunction("set_" + f.name) != null;

        if (hasGetter == false && hasSetter == false) {
            f.remove();
        }

        var variable = ExprTools.toString(variable);
        if (hasGetter == false) {
            builder.addGetter(f.name, f.type, macro {
                return $i{variable}.$field;
            }, null, !hasField, hasField);
        }

        if (hasSetter == false) {
            builder.addSetter(f.name, f.type, macro {
                $i{variable}.$field = value;
                return value;
            }, null, !hasField, hasField);
        }

        if (f.expr != null) {
            addConstructor(builder);
            builder.ctor.add(macro $i{f.name} = $e{f.expr}, AfterSuper);
        }

        if (hasSetter == true) {
            builder.ctor.add(macro {
                $i{variable}.registerEvent(haxe.ui.events.UIEvent.CHANGE, function(e) {
                    $i{f.name} = Reflect.getProperty($i{variable}, $v{field});
                });
            });
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    static function buildBindings(builder:ClassBuilder) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("build bindings");
        #end

        for (f in builder.getFieldsWithMeta("bindable")) {
            var setFn = builder.findFunction("set_" + f.name);
            RTTI.addClassProperty(builder.fullPath, f.name, ComplexTypeTools.toString(f.type));
        }

        var bindFields = builder.getFieldsWithMeta("bind");
        if (bindFields.length > 0) {
            #if !haxeui_dont_impose_base_class
            if (builder.hasSuperClass("haxe.ui.core.Component") == false) {
                Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
            }
            #end

            addConstructor(builder);
            if (builder.ctor == null) {
                Context.error("A class building component must have a constructor", Context.currentPos());
            }

            for (f in bindFields) {
                for (n in 0...f.getMetaCount("bind")) { // single method can be bound to multiple events
                    var meta = f.getMetaByIndex("bind", n);
                    switch (meta.params) {
                        case [{expr: EField(variable, field), pos: pos}]: // one param, lets assume binding to component prop
                            buildPropertyBinding(builder, f, variable, field);
                        case [param1]:
                            buildPropertyBinding(builder, f, param1, "value"); // input component that has value
                        case [component, event]: // two params, lets assume event binding
                            builder.ctor.add(macro @:pos(component.pos) {
                                if (${component} != null) {
                                    ${component}.registerEvent($event, $i{f.name});
                                } else {
                                    trace("WARNING: could not find event dispatcher to register event (" + $v{ExprTools.toString(component)} + ")");
                                }
                            }, End);
                        default:
                            haxe.macro.Context.error("Unsupported bind format, expected bind(component.field) or bind(component, event)", meta.pos);
                    }
                }
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    static function buildClonable(builder:ClassBuilder) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("build clonable");
        #end
        
        var useSelf:Bool = (builder.fullPath == "haxe.ui.backend.ComponentBase");

        var cloneFn = builder.findFunction("cloneComponent");
        if (cloneFn == null) { // add new clone fn
            var access:Array<Access> = [APublic];
            if (useSelf == false) {
                access.push(AOverride);
            }
            cloneFn = builder.addFunction("cloneComponent", builder.complexType, access);
        }

        var cloneLineExpr = null;
        var typePath = TypeTools.toComplexType(builder.type);
        if (useSelf == false) {
            cloneLineExpr = macro var c:$typePath = cast super.cloneComponent();
        } else {
            cloneLineExpr = macro var c:$typePath = self();
        }
        cloneFn.add(cloneLineExpr, CodePos.Start);

        var n = 1;
        for (f in builder.getFieldsWithMeta("clonable")) {
            if (f.isNullable == true) {
                cloneFn.add(macro if ($p{["this", f.name]} != null) $p{["c", f.name]} = $p{["this", f.name]}, Pos(n));
            } else {
                cloneFn.add(macro $p{["c", f.name]} = $p{["this", f.name]}, Pos(n));
            }
            n++;
        }
        cloneFn.add(macro {
            if (this.childComponents.length != c.childComponents.length) {
                for (child in this.childComponents) {
                    c.addComponent(child.cloneComponent());
                }
            }
            
            postCloneComponent(cast c);
        });
        cloneFn.add(macro return c);

        var hasOverriddenSelf = (builder.findFunction("self") != null);

        var constructorArgExprs = null;
        if (hasOverriddenSelf == false) {
            var hasConstructorArgs = false;
            var constuctor = builder.findFunction("new");
            if (constuctor != null) {
                hasConstructorArgs = (constuctor.argCount > 0);
                if (hasConstructorArgs == true) {
                    constructorArgExprs = [];
                    for (arg in constuctor.fn.args) {
                        var varName = "_constructorParam_" + arg.name;
                        builder.addVar(varName, arg.type, null, null, [{name: ":noCompletion", pos: Context.currentPos()}]);
                        constructorArgExprs.push(macro this.$varName);
                    }
                }
            }

            // add "self" function
            var access:Array<Access> = [APrivate];
            if (useSelf == false) {
                access.push(AOverride);
            }
            var typePath = builder.typePath;
            if (constructorArgExprs == null) {
                builder.addFunction("self", macro {
                    return new $typePath();
                }, builder.complexType, access);
            } else {
                builder.addFunction("self", macro {
                    return new $typePath($a{constructorArgExprs});
                }, builder.complexType, access);
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    static function buildBehaviours():Array<Field> {
        if (Context.getLocalClass().get().isExtern) {
            return null;
        }

        var builder = new ClassBuilder(haxe.macro.Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        #if macro_times_verbose
        var stopComponentTimer = Context.timer(builder.fullPath);
        #end
        #if haxeui_macro_times
        var stopTimer = Context.timer("build behaviours");
        #end

        var registerBehavioursFn = builder.findFunction("registerBehaviours");
        if (registerBehavioursFn == null) {
            registerBehavioursFn = builder.addFunction("registerBehaviours", macro {
                super.registerBehaviours();
            }, [APrivate, AOverride]);
        }

        var valueField = builder.getFieldMetaValue("value");
        var resolvedValueField = null;
        var fields = builder.getFieldsWithMeta("behaviour");

        // lets find the value field first, so we know we have it
        for (f in fields) {
            if (f.name == valueField) {
                resolvedValueField = f;
                break;
            }
        }

        for (f in fields) {
            RTTI.addClassProperty(builder.fullPath, f.name, ComplexTypeTools.toString(f.type));
            if (f.name == valueField) {
                RTTI.addClassProperty(builder.fullPath, "value", ComplexTypeTools.toString(f.type));
            }
            
            f.remove();
            var defVal:Dynamic = null;
            if (f.isBool) {
                defVal = false;
            } else if (f.isNumeric) {
                defVal = 0;
            }
            if (builder.hasField(f.name, true) == false) { // check to see if it already exists, possibly in a super class
                var newField:FieldBuilder = null;
                if (f.isDynamic == true) { // add a getter that can return dynamic
                    newField = builder.addGetter(f.name, f.type, macro {
                        if (behaviours == null) {
                            return $v{defVal};
                        }
                        return behaviours.getDynamic($v{f.name});
                    }, f.access);
                } else if (f.isComponent) {
                    newField = builder.addGetter(f.name, f.type, macro {
                        if (behaviours == null) {
                            return $v{defVal};
                        }
                        return cast behaviours.get($v{f.name}).toComponent();
                    }, f.access);
                } else { // add a normal (Variant) getter
                    newField = builder.addGetter(f.name, f.type, macro {
                        if (behaviours == null) {
                            return $v{defVal};
                        }
                        return behaviours.get($v{f.name});
                    }, f.access);
                }

                if (f.name == valueField) {
                    if (f.isDynamic == true) {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter but let the binding manager know that the value has changed
                            behaviours.setDynamic($v{f.name}, value);
                            dispatch(new haxe.ui.events.UIEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, $v{f.name}));
                            dispatch(new haxe.ui.events.UIEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, "value"));
                            return value;
                        }, f.access);
                    } else {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter but let the binding manager know that the value has changed
                            behaviours.set($v{f.name}, value);
                            dispatch(new haxe.ui.events.UIEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, $v{f.name}));
                            dispatch(new haxe.ui.events.UIEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, "value"));
                            return value;
                        }, f.access);
                    }
                    resolvedValueField = newField;
                } else {
                    if (f.isDynamic == true) {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter
                            behaviours.setDynamic($v{f.name}, value);
                            dispatch(new haxe.ui.events.UIEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, $v{f.name}));
                            return value;
                        }, f.access);
                    } else if (f.isString == true) {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter
                            switch (Type.typeof(value)) {
                                case TClass(String):
                                    if (value != null && value.indexOf("{{") != -1 && value.indexOf("}}") != -1) {
                                        haxe.ui.locale.LocaleManager.instance.registerComponent(cast this, $v{f.name}, value);
                                        return value;
                                    }
                                case _:    
                            }
                            if (behaviours == null) {
                                behaviours = new haxe.ui.behaviours.Behaviours(cast this);
                                this.registerBehaviours();
                            }
                            behaviours.set($v{f.name}, value);
                            dispatch(new haxe.ui.events.UIEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, $v{f.name}));
                            return value;
                        }, f.access);
                    } else {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter
                            if (behaviours == null) {
                                return value;
                            }
                            behaviours.set($v{f.name}, value);
                            dispatch(new haxe.ui.events.UIEvent(haxe.ui.events.UIEvent.PROPERTY_CHANGE, $v{f.name}));
                            return value;
                        }, f.access);
                    }
                }

                newField.doc = f.doc;
                newField.addMeta(":behaviour");
                newField.addMeta(":bindable");
                newField.mergeMeta(f.meta, ["behaviour"]);
            }

            if (f.getMetaValueExpr("behaviour", 1) == null) {
                registerBehavioursFn.add(macro
                    behaviours.register($v{f.name}, $p{f.getMetaValueString("behaviour", 0).split(".")})
                );
            } else {
                registerBehavioursFn.add(macro
                    behaviours.register($v{f.name}, $p{f.getMetaValueString("behaviour", 0).split(".")}, $e{f.getMetaValueExpr("behaviour", 1)})
                );
            }
        }

        for (f in builder.findFunctionsWithMeta("call")) {
            var defVal:Dynamic = null;
            if (f.isBool) {
                defVal = false;
            } else if (f.isNumeric) {
                defVal = 0;
            }
            var arg0 = '${f.getArgName(0)}';
            if (f.isVoid == true) {
                f.set(macro {
                    if (behaviours == null) {
                        return;
                    }
                    behaviours.call($v{f.name}, $i{arg0});
                });
            } else if (f.returnsComponent) { // special case for component calls, we will conver the variant to a component and then cast it
                f.set(macro {
                    return cast behaviours.call($v{f.name}, $i{arg0}).toComponent();
                });
            } else {
                f.set(macro {
                    if (behaviours == null) {
                        return $v{defVal};
                    }
                    return behaviours.call($v{f.name}, $i{arg0});
                });
            }

            if (f.getMetaValueExpr("call", 1) == null) {
                registerBehavioursFn.add(macro
                    behaviours.register($v{f.name}, $p{f.getMetaValueString("call", 0).split(".")})
                );
            } else {
                registerBehavioursFn.add(macro
                    behaviours.register($v{f.name}, $p{f.getMetaValueString("call", 0).split(".")}, $e{f.getMetaValueExpr("call", 1)})
                );
            }
        }

        for (f in builder.getFieldsWithMeta("value")) {
            f.remove();

            var propName = f.getMetaValueString("value");
            if (resolvedValueField != null && (resolvedValueField.isVariant || 
                                               resolvedValueField.isString ||
                                               resolvedValueField.isNumeric ||
                                               resolvedValueField.isBool)) {
                builder.addGetter(f.name, macro: Dynamic, macro {
                    return $i{propName};
                }, false, true);

                if (resolvedValueField.isString) {
                    builder.addSetter(f.name, macro: Dynamic, macro {
                        switch (Type.typeof(value)) {
                            case TEnum(haxe.ui.util.Variant.VariantType):
                                var v:haxe.ui.util.Variant = value;
                                $i{propName} = v;
                            case TInt | TFloat | TBool:
                                $i{propName} = Std.string(value);
                            case _:
                                $i{propName} = value;
                        }

                        return value;
                    }, false, true);
                } else if (resolvedValueField.isFloat) {
                    builder.addSetter(f.name, macro: Dynamic, macro {
                        switch (Type.typeof(value)) {
                            case TEnum(haxe.ui.util.Variant.VariantType):
                                var v:haxe.ui.util.Variant = value;
                                $i{propName} = v;
                            case TClass(String):
                                $i{propName} = Std.parseFloat(value);
                            case TBool:
                                $i{propName} = (value == true) ? 1 : 0;
                            case _:
                                $i{propName} = value;
                        }

                        return value;
                    }, false, true);
                } else if (resolvedValueField.isInt) {
                    builder.addSetter(f.name, macro: Dynamic, macro {
                        switch (Type.typeof(value)) {
                            case TEnum(haxe.ui.util.Variant.VariantType):
                                var v:haxe.ui.util.Variant = value;
                                $i{propName} = v;
                            case TClass(String):
                                $i{propName} = Std.parseInt(value);
                            case TBool:
                                $i{propName} = (value == true) ? 1 : 0;
                            case _:
                                $i{propName} = value;
                        }

                        return value;
                    }, false, true);
                } else if (resolvedValueField.isBool) {
                    builder.addSetter(f.name, macro: Dynamic, macro {
                        switch (Type.typeof(value)) {
                            case TEnum(haxe.ui.util.Variant.VariantType):
                                var v:haxe.ui.util.Variant = value;
                                $i{propName} = v;
                            case TInt | TFloat:
                                $i{propName} = (value == 1);
                            case TClass(String):
                                $i{propName} = (value == "true" || value == "1");
                            case _:
                                $i{propName} = value;
                        }

                        return value;
                    }, false, true);
                } else if (resolvedValueField.isVariant) {
                    builder.addSetter(f.name, macro: Dynamic, macro {
                        $i{propName} = haxe.ui.util.Variant.fromDynamic(value);
                        return value;
                    }, false, true);
                }
            } else {
                var getterExpr = macro this.$propName;
                var setterExpr = macro this.$propName = value;
                var parts = propName.split(".");
                if (parts.length > 1) {
                    propName = parts[1];
                    getterExpr = macro $i{parts[0]}.$propName;
                    setterExpr = macro $i{parts[0]}.$propName = value;
                }
                builder.addGetter(f.name, macro: Dynamic, macro {
                    return $e{getterExpr};
                }, false, true);

                builder.addSetter(f.name, macro: Dynamic, macro {
                    this.$propName = value;
                    return value;
                }, false, true);
            }
        }

        // lets set the super class for this class so RTTI works for super classes
        var superClass = builder.superClass;
        if (superClass != null) {
            var superFullPath = superClass.t.get().pack.join(".") + "." + superClass.t.get().name;
            RTTI.setSuperClass(builder.fullPath, superFullPath);
        }
        
        //buildEvents(builder);
        buildStyles(builder);
        buildBindings(builder);

        if (builder.hasInterface("haxe.ui.core.IClonable") && !builder.isAbstractClass) {
            buildClonable(builder);
        }

        RTTI.save();
        
        #if haxeui_macro_times
        stopTimer();
        #end
        #if macro_times_verbose
        stopComponentTimer();
        #end

        return builder.fields;
    }

    static function buildData():Array<Field> {
        var builder = new ClassBuilder(haxe.macro.Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        builder.addMeta(":keep");
        builder.addMeta(":keepSub");
        #if macro_times_verbose
        var stopComponentTimer = Context.timer(builder.fullPath);
        #end
        #if haxeui_macro_times
        var stopTimer = Context.timer("build behaviours");
        #end

        var constructorArgs:Array<FunctionArg> = [];
        var constructorExprs:Array<Expr> = [];
        for (f in builder.vars) {
            if (f.isStatic) {
                continue;
            }
            var fieldName = f.name;
            builder.removeVar(fieldName);
            var optional = f.hasMeta(":optional");
            constructorArgs.push({name: fieldName, type: f.type, value: f.expr, opt: optional});
            constructorExprs.push(macro this.$fieldName = $i{fieldName});

            var name = '_${fieldName}';
            builder.addVar(name, f.type, null, null, [{name: ":noCompletion", pos: Context.currentPos()}, {name: ":optional", pos: Context.currentPos()}]);
            var newField = builder.addGetter(fieldName, f.type, macro {
                return $i{name};
            });
            var newField = builder.addSetter(fieldName, f.type, macro {
                if (value == $i{name}) {
                    return value;
                }
                $i{name} = value;
                if (onDataSourceChanged != null) {
                    onDataSourceChanged();
                }
                return value;
            });
            newField.addMeta(":isVar");
            //builder.addVar(f.name, f.type, null, null, [{name: ":isVar", pos: Context.currentPos()}]);
        }

        builder.addVar("onDataSourceChanged", macro: Void->Void, macro null);

        if (!builder.hasFunction("new")) {
            builder.addFunction("new", macro {
                $b{constructorExprs}
            }, constructorArgs);
        }


        #if haxeui_macro_times
        stopTimer();
        #end
        #if macro_times_verbose
        stopComponentTimer();
        #end

        return builder.fields;
    }

    #end
}
