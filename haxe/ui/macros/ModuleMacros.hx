package haxe.ui.macros;

import haxe.ui.core.ComponentClassMap;
import haxe.ui.parsers.modules.Module;
import haxe.ui.parsers.modules.ModuleParser;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
#end

class ModuleMacros {
    private static var _modules:Array<Module> = [];

    private static var _modulesProcessed:Bool;
    macro public static function processModules():Expr {
        if (_modulesProcessed == true) {
            return macro null;
        }

        var code:String = "(function() {\n";

        loadModules();
        for (m in _modules) {
            // add resources as haxe resources (plus prefix)
            for (r in m.resourceEntries) {
                if (r.path != null) {
                    var resolvedPath = null;
                    try {
                        resolvedPath = Context.resolvePath(r.path);
                    } catch (e:Dynamic) {
                        resolvedPath = haxe.io.Path.join([Sys.getCwd(), r.path]);
                    }
                    if (FileSystem.isDirectory(resolvedPath) && FileSystem.exists(resolvedPath)) {
                        addResources(resolvedPath, resolvedPath, r.prefix);
                    } else {
                        trace("WARNING: Could not find path " + resolvedPath);
                    }
                }
            }

            for (s in m.scriptletEntries) {
                var types:Array<haxe.macro.Type> = null;
                if (s.className != null) {
                    types = Context.getModule(s.className);
                } else if (s.classPackage != null) {
                    types = MacroHelpers.typesFromPackage(s.classPackage);
                }

                if (types != null) {
                    for (t in types) {
                        var skipRest = false;
                        var resolvedClass:String = MacroHelpers.classNameFromType(t);
                        var classAlias:String = s.classAlias;
                        if (classAlias == null) {
                            var parts = resolvedClass.split(".");
                            classAlias = parts[parts.length - 1];
                        } else {
                            skipRest = true; // as we have an alias defined lets skip any other types (assumes the first class is the one to alias)
                        }
                        if (StringTools.startsWith(resolvedClass, ".")) {
                            continue;
                        }
                        code += 'haxe.ui.scripting.ScriptInterp.addClassAlias("${classAlias}", "${resolvedClass}");\n';

                        if (skipRest == true) {
                            break;
                        }
                        if (s.keep == true) {
                            MacroHelpers.addMeta(t, ":keep", Context.currentPos());
                        }
                        if (s.staticClass == true) {
                            code += 'haxe.ui.scripting.ScriptInterp.addStaticClass("${classAlias}", ${resolvedClass});\n';
                        }
                    }
                }
            }

            // setup themes
            for (t in m.themeEntries) {
                if (t.parent != null) {
                    code += 'haxe.ui.themes.ThemeManager.instance.getTheme("${t.name}").parent = "${t.parent}";\n';
                }
                for (r in t.styles) {
                    code += 'haxe.ui.themes.ThemeManager.instance.addStyleResource("${t.name}", "${r.resource}");\n';
                }
            }

            // handle plugins
            for (p in m.plugins) {
                switch (p.type) {
                    case "asset":
                        code += 'var assetPlugin:${p.className} = new ${p.className}();\n';
                        for (propName in p.config.keys()) {
                            var propValue = p.config.get(propName);
                            code += 'assetPlugin.setProperty("${propName}", "${propValue}");\n';
                        }
                        code += 'ToolkitAssets.instance.addPlugin(assetPlugin);\n';
                    default:
                        trace("WARNING: unknown plugin type: " + p.type);
                }
            }

            // set toolkit properties
            for (p in m.properties) {
                code += 'Toolkit.properties.set("${p.name}", "${p.value}");\n';
            }

            // load animations
            for (a in m.animations) {
                code += 'var a:haxe.ui.animation.Animation = new haxe.ui.animation.Animation();\n';
                code += 'a.id = "${a.id}";\n';
                code += 'a.easing = haxe.ui.animation.Animation.easingFromString("${a.ease}");\n';
                for (kf in a.keyFrames) {
                    code += 'var kf:haxe.ui.animation.AnimationKeyFrame = a.addKeyFrame(${kf.time});\n';
                    for (r in kf.componentRefs) {
                        code += 'var ref:haxe.ui.animation.AnimationComponentRef = kf.addComponentRef("${r.id}");\n';
                        for (p in r.properties.keys()) {
                            code += 'ref.addProperty("${p}", ${r.properties.get(p)});\n';
                        }
                        for (v in r.vars.keys()) {
                            code += 'ref.addVar("${v}", "${r.vars.get(v)}");\n';
                        }
                    }
                }

                code += 'haxe.ui.animation.AnimationManager.instance.registerAnimation(a.id, a);\n';
            }
            
            for (p in m.preload) {
                code += 'ToolkitAssets.instance.preloadList.push({type: "${p.type}", resourceId: "${p.id}"});\n';
            }
        }

        populateClassMap();
        for (alias in ComponentClassMap.list()) {
            var className:String = ComponentClassMap.get(alias);
            code += 'haxe.ui.core.ComponentClassMap.register("${alias}", "${className}");\n';
        }

        code += "})()\n";
        //trace(code);

        _modulesProcessed = true;

        return Context.parseInlineString(code, Context.currentPos());
    }

    #if macro
    private static var _classMapPopulated:Bool = false;
    public static function populateClassMap() {
        if (_classMapPopulated == true) {
            return;
        }

        var modules:Array<Module> = ModuleMacros.loadModules();
        for (m in modules) {
            // load component classes from all modules
            for (c in m.componentEntries) {
                var types:Array<haxe.macro.Type> = null;
                if (c.className != null) {
                    types = Context.getModule(c.className);
                } else if (c.classPackage != null) {
                    types = MacroHelpers.typesFromPackage(c.classPackage);
                }

                if (types != null) {
                    for (t in types) {
                        if (MacroHelpers.hasSuperClass(t, "haxe.ui.core.Component") == true) {
                            var resolvedClass:String = MacroHelpers.classNameFromType(t);
                            if (c.className != null && resolvedClass != c.className) {
                                continue;
                            }
                            var classAlias:String = c.classAlias;
                            if (classAlias == null) {
                                classAlias = resolvedClass.substr(resolvedClass.lastIndexOf(".") + 1, resolvedClass.length);
                            }
                            classAlias = classAlias.toLowerCase();
                            ComponentClassMap.register(classAlias, resolvedClass);
                        }
                    }
                }
            }
        }

        _classMapPopulated = true;
    }

    private static var _modulesLoaded:Bool = false;
    public static function loadModules():Array<Module> {
        if (_modulesLoaded == true) {
            return _modules;
        }

        MacroHelpers.scanClassPath(function(filePath:String) {
            var moduleParser = ModuleParser.get(MacroHelpers.extension(filePath));
            if (moduleParser != null) {
                try {
                    var module:Module = moduleParser.parse(File.getContent(filePath), Context.getDefines());
                    module.validate();
                    _modules.push(module);
                    return true;
                } catch (e:Dynamic) {
                    trace('WARNING: Problem parsing module ${MacroHelpers.extension(filePath)} (${filePath}) - ${e} (skipping file)');
                }
            }
            return false;
        }, ["module."]);

        _modulesLoaded = true;
        return _modules;
    }

    private static function addResources(path:String, base:String, prefix:String) {
        if (prefix == null) {
            prefix = "";
        }
        var contents:Array<String> = sys.FileSystem.readDirectory(path);
        for (f in contents) {
            var file = path + "/" + f;
            if (sys.FileSystem.isDirectory(file)) {
                addResources(file, base, prefix);
            } else {
                var relativePath = prefix + StringTools.replace(file, base, "");
                var resourceName:String = relativePath;
                if (StringTools.startsWith(resourceName, "/")) {
                    resourceName = resourceName.substr(1, resourceName.length);
                }
                Context.addResource(resourceName, File.getBytes(file));
            }
        }
    }
    #end
}