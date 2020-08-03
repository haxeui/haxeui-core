package haxe.ui.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;
import haxe.ui.macros.helpers.CodePos;
import haxe.ui.macros.helpers.FieldBuilder;
import haxe.ui.util.StringUtil;
import haxe.ui.macros.ComponentMacros.NamedComponentDescription;
import haxe.macro.ExprTools;
#end

class Macros {
    #if macro

    macro static function build():Array<Field> {
        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        
        if (builder.hasClassMeta(["xml"])) {
            buildFromXmlMeta(builder);
        }
        
        if (builder.hasClassMeta(["composite"])) {
            buildComposite(builder);
        }

        buildEvents(builder);
        
        return builder.fields;
    }
    
    static function buildFromXmlMeta(builder:ClassBuilder) {
        if (builder.hasSuperClass("haxe.ui.core.Component") == false) {
            Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
        }
        
        if (builder.constructor == null) {
            Context.error("A class building component must have a constructor", Context.currentPos());
        }
        
        var xml = builder.getClassMetaValue("xml");
        var namedComponents:Map<String, NamedComponentDescription> = new Map<String, NamedComponentDescription>();
        var codeBuilder = new CodeBuilder();
        var bindingExprs:Array<Expr> = [];
        ComponentMacros.buildComponentFromString(codeBuilder, xml, namedComponents, bindingExprs);
        codeBuilder.add(macro
            addComponent(c0)
        );
        
        for (id in namedComponents.keys()) {
            var safeId:String = StringUtil.capitalizeHyphens(id);
            var info:NamedComponentDescription = namedComponents.get(id);
            builder.addVar(safeId, TypeTools.toComplexType(Context.getType(info.type)));
            codeBuilder.add(macro
                $i{safeId} = $i{info.generatedVarName}
            );
        }
        
        for (expr in bindingExprs) {
            codeBuilder.add(expr);
        }
        
        builder.constructor.add(codeBuilder, AfterSuper);
    }
    
    static function buildComposite(builder:ClassBuilder) {
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
    }

    static function buildEvents(builder:ClassBuilder) {
        for (f in builder.getFieldsWithMeta("event")) {
            f.remove();
            var eventExpr = f.getMetaValueExpr("event");
            var varName = '__${f.name}';
            builder.addVar(varName, f.type);
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
    }
    
    static function buildStyles(builder:ClassBuilder) {
        for (f in builder.getFieldsWithMeta("style")) {
            f.remove();
            
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
            //getter.addMeta(":clonable");
            getter.addMeta(":dox", [macro group = "Style properties"]);
            
            var codeBuilder = new CodeBuilder(macro {
                if ($p{["customStyle", f.name]} == value) {
                    return value;
                }
                if (_style == null) {
                    _style = {};
                }
                $p{["customStyle", f.name]} = value;
                invalidateComponentStyle();
                return value;
            });
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
            var setter = builder.addSetter(f.name, f.type, codeBuilder.expr);
        }
    }

    private static function buildPropertyBinding(builder:ClassBuilder, f:FieldBuilder, variable:Expr, field:String) {
        var hasGetter = builder.findFunction("get_" + f.name) != null;
        var hasSetter = builder.findFunction("set_" + f.name) != null;
        
        if (hasGetter == false && hasSetter == false) {
            f.remove();
        }

        var variable = ExprTools.toString(variable);
        if (hasGetter == false) {
            builder.addGetter(f.name, f.type, macro {
                var c = findComponent($v{variable});
                if (c == null) {
                    trace("WARNING: no child component found: " + $v{variable});
                    return Reflect.getProperty(c, $v{field});
                }
                var fieldIndex = Type.getInstanceFields(Type.getClass(c)).indexOf("get_" + $v{field});
                if (fieldIndex == -1) {
                    trace("WARNING: no component getter found: " + $v{field});
                    return Reflect.getProperty(c, $v{field});
                }
                return Reflect.getProperty(c, $v{field});
            });
        }
        
        if (hasSetter == false) {
            builder.addSetter(f.name, f.type, macro {
                if (value != $i{f.name}) {
                    var c = findComponent($v{variable});
                    if (c == null) {
                        trace("WARNING: no child component found: " + $v{variable});
                        return value;
                    }
                    var fieldIndex = Type.getInstanceFields(Type.getClass(c)).indexOf("set_" + $v{field});
                    if (fieldIndex == -1) {
                        trace("WARNING: no component setter found: " + $v{field});
                        return value;
                    }
                    Reflect.setProperty(c, $v{field}, value);
                }
                return value;
            });
        }
        
        if (f.expr != null) {
            builder.constructor.add(macro
                $i{f.name} = $e{f.expr}
            , AfterSuper);
        }
        
        if (hasSetter == true) {
            builder.constructor.add(macro {
                $i{variable}.registerEvent(haxe.ui.events.UIEvent.CHANGE, function(e) {
                    $i{f.name} = Reflect.getProperty($i{variable}, $v{field});
                });
            });
        }
    }
    
    static function buildBindings(builder:ClassBuilder) {
        for (f in builder.getFieldsWithMeta("bindable")) {
            var setFn = builder.findFunction("set_" + f.name);
            if (setFn != null) {
                setFn.add(macro
                    haxe.ui.binding.BindingManager.instance.componentPropChanged(cast this, $v{f.name})
                );
            }
        }
        
        var bindFields = builder.getFieldsWithMeta("bind");
        if (bindFields.length > 0) {
            if (builder.hasSuperClass("haxe.ui.core.Component") == false) {
                Context.error("Must have a superclass of haxe.ui.core.Component", Context.currentPos());
            }
            
            if (builder.constructor == null) {
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
                            builder.constructor.add(macro {
                                @:pos(component.pos)
                                var c:haxe.ui.core.Component = ${component};
                                if (c != null) {
                                    c.registerEvent($event, $i{f.name});
                                } else {
                                    trace("WARNING: could not find component to regsiter event (" + $v{ExprTools.toString(component)} + ")");
                                }
                            }, AfterSuper);
                        default:
                            haxe.macro.Context.error("Unsupported bind format, expected bind(component.field) or bind(component, event)", meta.pos);
                    }
                }
            }
        }
    }
    
    static function buildClonable(builder:ClassBuilder) {
        var useSelf:Bool = (builder.fullPath == "haxe.ui.core.ComponentContainer");
        
        var cloneFn = builder.findFunction("cloneComponent");
        if (cloneFn == null) { // add new clone fn
            var access:Array<Access> = [APublic];
            if (useSelf == false) {
                access.push(AOverride);
            }
            cloneFn = builder.addFunction("cloneComponent", builder.path, access);
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
                cloneFn.add(macro
                    if ($p{["this", f.name]} != null) $p{["c", f.name]} = $p{["this", f.name]}
                , Pos(n));
            } else {
                cloneFn.add(macro
                    $p{["c", f.name]} = $p{["this", f.name]}
                , Pos(n));
            }
            n++;
        }
        cloneFn.add(macro {
            if (this.childComponents.length != c.childComponents.length) {
                for (child in this.childComponents) {
                    c.addComponent(child.cloneComponent());
                }
            }
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
                }, builder.path, access);
            } else {
                builder.addFunction("self", macro {
                    return new $typePath($a{constructorArgExprs});
                }, builder.path, access);
            }
        }
    }
    
    #if ((haxe_ver < 4) || haxeui_heaps)
    // TODO: this is a really ugly haxe3 hack / workaround - once haxe4 stabalises this *MUST* be removed - its likely brittle and ill conceived!
    public static var _cachedFields:Map<String, Array<Field>> = new Map<String, Array<Field>>();
    #end
    static function buildBehaviours():Array<Field> {
        var builder = new ClassBuilder(haxe.macro.Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        var registerBehavioursFn = builder.findFunction("registerBehaviours");
        if (registerBehavioursFn == null) {
            registerBehavioursFn = builder.addFunction("registerBehaviours", macro {
                super.registerBehaviours();
            }, [APrivate, AOverride]);
        }
        
        var valueField = builder.getFieldMetaValue("value");
        var resolvedValueField = null;
        for (f in builder.getFieldsWithMeta("behaviour")) {
            f.remove();
            if (builder.hasField(f.name, true) == false) { // check to see if it already exists, possibly in a super class
                var newField:FieldBuilder = null;
                if (f.isDynamic == true) { // add a getter that can return dynamic
                    newField = builder.addGetter(f.name, f.type, macro {
                        return behaviours.getDynamic($v{f.name});
                    }, f.access);
                } else { // add a normal (Variant) getter
                    newField = builder.addGetter(f.name, f.type, macro {
                        return behaviours.get($v{f.name});
                    }, f.access);
                }
                
                if (f.name == valueField) {
                    if (f.isDynamic == true) {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter but let the binding manager know that the value has changed
                            behaviours.set($v{f.name}, haxe.ui.util.Variant.fromDynamic(value));
                            haxe.ui.binding.BindingManager.instance.componentPropChanged(this, "value");
                            return value;
                        }, f.access);
                    } else {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter but let the binding manager know that the value has changed
                            behaviours.set($v{f.name}, value);
                            haxe.ui.binding.BindingManager.instance.componentPropChanged(this, "value");
                            return value;
                        }, f.access);
                    }
                    resolvedValueField = newField;
                } else {
                    if (f.isDynamic == true) {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter
                            behaviours.set($v{f.name}, haxe.ui.util.Variant.fromDynamic(value));
                            return value;
                        }, f.access);
                    } else {
                        newField = builder.addSetter(f.name, f.type, macro { // add a normal (Variant) setter
                            behaviours.set($v{f.name}, value);
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
            var arg0 = '${f.getArgName(0)}';
            if (f.isVoid == true) {
                f.set(macro {
                    behaviours.call($v{f.name}, $i{arg0});
                });
            } else {
                f.set(macro {
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
            if (resolvedValueField != null && resolvedValueField.isVariant) {
                builder.addGetter(f.name, macro: Dynamic, macro {
                    return haxe.ui.util.Variant.toDynamic($i{propName});
                }, false, true);
                
                builder.addSetter(f.name, macro: Dynamic, macro {
                    $i{propName} = haxe.ui.util.Variant.fromDynamic(value);
                    haxe.ui.binding.BindingManager.instance.componentPropChanged(this, $v{propName});
                    return value;
                }, false, true);
            } else {
                builder.addGetter(f.name, macro: Dynamic, macro {
                    return $i{propName};
                }, false, true);
                
                builder.addSetter(f.name, macro: Dynamic, macro {
                    $i{propName} = value;
                    haxe.ui.binding.BindingManager.instance.componentPropChanged(this, $v{propName});
                    return value;
                }, false, true);
            }
        }
        
        //buildEvents(builder);
        buildStyles(builder);
        buildBindings(builder);
        
        if (builder.hasInterface("haxe.ui.core.IClonable")) {
            buildClonable(builder);
        }

        #if ((haxe_ver < 4) || haxeui_heaps)        
        // TODO: this is a really ugly haxe3 hack / workaround - once haxe4 stabalises this *MUST* be removed - its likely brittle and ill conceived!
        _cachedFields.set(builder.fullPath, builder.fields);
        #end

        return builder.fields;
    }
    
    static function buildData():Array<Field> {
        var builder = new ClassBuilder(haxe.macro.Context.getBuildFields(), Context.getLocalType(), Context.currentPos());
        
        for (f in builder.vars) {
            builder.removeVar(f.name);
            
            var name = '_${f.name}';
            builder.addVar(name, f.type);
            var newField = builder.addGetter(f.name, f.type, macro {
                return $i{name};
            });
            var newField = builder.addSetter(f.name, f.type, macro {
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
        
        return builder.fields;
    }
    
    #end
}
