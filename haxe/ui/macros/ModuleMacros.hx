package haxe.ui.macros;
import haxe.ds.ArraySort;
import haxe.macro.Expr.ComplexType;
import haxe.macro.ExprTools;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr.TypePath;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.LayoutClassMap;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;
import haxe.ui.parsers.modules.Module;
import haxe.ui.parsers.modules.ModuleParser;
import haxe.ui.util.StringUtil;
import sys.FileSystem;
import sys.io.File;
#end

class ModuleMacros {
    
    #if macro
    private static var _modules:Array<Module> = [];
    private static var _modulesProcessed:Bool;
    private static var _resourceIds:Array<String> = [];
    #end
    
    macro public static function processModules() {
        if (_modulesProcessed == true) {
            return macro null;
        }

        /*
        _modules = [];
        _resourceIds = [];
        ComponentClassMap.clear();
        */
        
        loadModules();
        
        var preloadAll:Bool = false;
        var builder = new CodeBuilder();
        for (m in _modules) {
            if (m.preloadList == "all") {
                preloadAll = true;
            }
            
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
                var types:Array<haxe.macro.Type> = MacroHelpers.typesFromClassOrPackage(s.className, s.classPackage);
                if (types != null) {
                    for (t in types) {
                        if (!t.match(TInst(_))) {
                            continue;
                        }

                        var scriptType = new ClassBuilder(t);
                        if (scriptType.isPrivate == true) {
                            continue;
                        }
                        
                        var skipRest = false;
                        var resolvedClass:String = scriptType.fullPath;
                        var classAlias:String = s.classAlias;
                        if (classAlias == null) {
                            classAlias = scriptType.name;
                        } else {
                            skipRest = true; // as we have an alias defined lets skip any other types (assumes the first class is the one to alias)
                        }
                        if (StringTools.startsWith(resolvedClass, ".")) {
                            continue;
                        }
                        
                        builder.add(macro 
                            haxe.ui.scripting.ScriptInterp.addClassAlias($v{classAlias}, $v{resolvedClass})
                        );
                        
                        if (s.staticClass == true || s.keep == true) {
                            builder.add(macro 
                                haxe.ui.scripting.ScriptInterp.addStaticClass($v{classAlias}, $p{resolvedClass.split(".")})
                            );
                        }

                        if (skipRest == true) {
                            break;
                        }
                    }
                }
            }

            // setup themes
            for (t in m.themeEntries) {
                if (t.parent != null) {
                    builder.add(macro 
                        haxe.ui.themes.ThemeManager.instance.getTheme($v{t.name}).parent = $v{t.parent}
                    );
                }
                for (r in t.styles) {
                    builder.add(macro 
                        haxe.ui.themes.ThemeManager.instance.addStyleResource($v{t.name}, $v{r.resource}, $v{r.priority})
                    );
                }
            }

            // handle plugins
            /* TODO: is this still relevant??? Check haxeui-kha
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
            */

            // set toolkit properties
            for (p in m.properties) {
                builder.add(macro 
                    haxe.ui.Toolkit.properties.set($v{p.name}, $v{p.value})
                );
            }

            for (p in m.preload) {
                builder.add(macro 
                    haxe.ui.ToolkitAssets.instance.preloadList.push({type: $v{p.type}, resourceId: $v{p.id}})
                );
            }
        }
        
        if (preloadAll) {
            for (r in _resourceIds) {
                if (StringTools.endsWith(r, ".png")) {
                    builder.add(macro 
                        haxe.ui.ToolkitAssets.instance.preloadList.push({type: "image", resourceId: $v{r}})
                    );
                }
            }
        }

        populateClassMap();
        
        for (alias in ComponentClassMap.list()) {
            builder.add(macro 
                haxe.ui.core.ComponentClassMap.register($v{alias}, $v{ComponentClassMap.get(alias)})
            );
        }

        for (alias in LayoutClassMap.list()) {
            builder.add(macro 
                haxe.ui.core.LayoutClassMap.register($v{alias}, $v{LayoutClassMap.get(alias)})
            );
        }
        
        _modulesProcessed = true;
        return builder.expr;
    }

    #if macro
    private static var _classMapPopulated:Bool = false;
    public static function populateClassMap() {
        if (_classMapPopulated == true) {
            return;
        }

        var modules:Array<Module> = loadModules();
        for (m in modules) {
            // load component classes from all modules
            for (c in m.componentEntries) {
                var types:Array<haxe.macro.Type> = MacroHelpers.typesFromClassOrPackage(c.className, c.classPackage);
                if (types != null) {
                    for (t in types) {
                        var orgType = t;
                        t = Context.follow(orgType);
                        var builder = new ClassBuilder(t);
                        if (builder.isPrivate == true) {
                            continue;
                        }
                        var org = new ClassBuilder(orgType);
                        
                        if (builder.hasSuperClass("haxe.ui.core.Component") == true) {
                            var resolvedClass:String = builder.fullPath;
                            if (c.className != null && org.fullPath != c.className) {
                                continue;
                            }
                            
                            var resolvedClassName = org.name;
                            var classAlias:String = c.classAlias;
                            if (classAlias == null) {
                                classAlias = resolvedClassName;
                            }
                            classAlias = classAlias.toLowerCase();
                            
                            if (builder.hasInterface("haxe.ui.core.IDirectionalComponent")) {
                                if (StringTools.startsWith(resolvedClassName, "Horizontal")) { // alias HorizontalComponent with hcomponent
                                    ComponentClassMap.register("h" + StringTools.replace(resolvedClassName, "Horizontal", "").toLowerCase(), resolvedClass);
                                } else if (StringTools.startsWith(resolvedClassName, "Vertical")) { // alias VerticalComponent with vcomponent
                                    ComponentClassMap.register("v" + StringTools.replace(resolvedClassName, "Vertical", "").toLowerCase(), resolvedClass);
                                }
                            }
                            ComponentClassMap.register(classAlias, resolvedClass);
                        }
                    }
                }
            }

            // load layout classes from all modules
            for (c in m.layoutEntries) {
                var types:Array<haxe.macro.Type> = MacroHelpers.typesFromClassOrPackage(c.className, c.classPackage);
                if (types != null) {
                    for (t in types) {
                        var builder = new ClassBuilder(t);
                        if (builder.isPrivate == true) {
                            continue;
                        }

                        if (builder.hasSuperClass("haxe.ui.layouts.Layout") == true) {                            
                            var resolvedClass:String = builder.fullPath;
                            if (c.className != null && resolvedClass != c.className) {
                                continue;
                            }

                            var resolvedClassName = builder.name;
                            var classAlias:String = c.classAlias;
                            if (classAlias == null) {
                                classAlias = resolvedClassName;
                            }
                            classAlias = classAlias.toLowerCase();

                            LayoutClassMap.register(classAlias, resolvedClass);
                        }
                    }
                }
            }
        }
       
        // do this last so we have all the other haxeui classes from modules - might need sometype pf dependancy walker eventually
        populateDynamicClassMap();
        
        _classMapPopulated = true;
    }

    private static var _dynamicClassMapPopulated:Bool = false;
    private static function populateDynamicClassMap() {
        if (_dynamicClassMapPopulated == true) {
            return;
        }
        _dynamicClassMapPopulated = true;
        
        var modules:Array<Module> = loadModules();
        for (m in modules) {
            for (c in m.componentEntries) {
                if (c.classFolder != null) {
                    createDynamicClasses(c.classFolder);
                } else if (c.classFile != null) {
                    createDynamicClass(c.classFile, c.classAlias);
                }
            }
        }
    }
    
    private static function createDynamicClasses(dir:String, root:String = null) {
        var resolvedPath = null;
        try { 
            resolvedPath = Context.resolvePath(dir); 
        } catch (e:Dynamic) { 
            resolvedPath = haxe.io.Path.join([Sys.getCwd(), dir]); 
        } 
        if (resolvedPath == null || FileSystem.exists(resolvedPath) == false || FileSystem.isDirectory(resolvedPath) == false) {
            trace("WARNING: Could not find path " + resolvedPath);
        }
        
        dir = Path.normalize(resolvedPath);
        if (root == null) {
            root = dir;
        }
        
        var contents = FileSystem.readDirectory(dir);
        for (item in contents) {
            var fullPath = Path.normalize(dir + "/" + item);
            if (FileSystem.isDirectory(fullPath)) {
                createDynamicClasses(fullPath, root);
            } else {
                createDynamicClass(fullPath, null, root);
            }
        }
    }
    
    public static function createDynamicClass(filePath:String, alias:String = null, root:String = null):String {
        var resolvedPath = null;
        try { 
            resolvedPath = Context.resolvePath(filePath); 
        } catch (e:Dynamic) { 
            resolvedPath = haxe.io.Path.join([Sys.getCwd(), filePath]); 
        } 
        if (resolvedPath == null || FileSystem.exists(resolvedPath) == false || FileSystem.isDirectory(resolvedPath) == true) {
            trace("WARNING: Could not find path " + resolvedPath);
        }
        
        filePath = Path.normalize(resolvedPath);
        var fullPath = filePath;
        if (root != null) {
            filePath = StringTools.replace(filePath, root, "");
        }
        
        var fileParts = filePath.split("/");
        var fileName = fileParts.pop();
        var className:String = StringUtil.capitalizeFirstLetter(StringUtil.capitalizeHyphens(new Path(fileName).file));
        if (alias != null) {
			className = StringUtil.capitalizeFirstLetter(alias);
        }
        
        var temp = [];
        for (part in fileParts) {
            part = StringTools.trim(part);
            if (part == "" || part == "." || part == "..") {
                continue;
            }
            part = StringTools.replace(part, "-", "");
            temp.push(part.toLowerCase());
        }
        fileParts = temp;
        
        var fullClass = fileParts.concat([className]).join(".");
        /* this causes problems with language server it seems
        if (ComponentClassMap.hasClass(fullClass) == true) {
            return fullClass;
        }
        */
        
        var superClassString = "haxe.ui.containers.Box";
        var superClassParts = superClassString.split(".");
        var superClass:TypePath = {
            name: superClassParts.pop(),
            pack: superClassParts
        }
        var xml = sys.io.File.getContent(fullPath);
        var namedComponents:Map<String, ComponentMacros.NamedComponentDescription> = new Map<String, ComponentMacros.NamedComponentDescription>();
        var codeBuilder = new CodeBuilder();
        ComponentMacros.buildComponentFromString(codeBuilder, xml, namedComponents);
        codeBuilder.add(macro {
            addComponent(c0);
            if (c0.width > 0) {
                this.width = c0.width;
            }
            if (c0.height > 0) {
                this.height = c0.height;
            }
            if (c0.percentWidth != null && c0.percentWidth > 0) {
                this.percentWidth = c0.percentWidth;
            }
            if (c0.percentHeight != null && c0.percentHeight > 0) {
                this.percentHeight = c0.percentHeight;
            }
        });

        var newClass = macro
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        class $className extends $superClass {
            public function new() {
                super();
                $e{codeBuilder.expr}
            }
            
            private override function createChildren() {
                super.createChildren();
            }
        };
        
        var classBuilder = new ClassBuilder(newClass.fields, Context.currentPos());
        
        for (name in namedComponents.keys()) {
            var typeClass = namedComponents.get(name).type;
            var typeParts = typeClass.split(".");
            var typeName = typeParts.pop();
            var t:TypePath = {
                name: typeName,
                pack: typeParts
            }
            
            classBuilder.addVar(name, ComplexType.TPath(t));
            classBuilder.constructor.add(macro $i{name} = findComponent($v{name}, $p{typeClass.split(".")}));
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////

        Context.defineModule(fileParts.concat([className]).join("."), [newClass]);
        ComponentClassMap.register(className, fileParts.concat([className]).join("."));
        return fileParts.concat([className]).join(".");
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
                    var module:Module = moduleParser.parse(File.getContent(filePath), Context.getDefines(), filePath);
                    module.validate();
                    module.rootPath = new Path(filePath).dir;
                    _modules.push(module);
                    return true;
                } catch (e:Dynamic) {
                    trace('WARNING: Problem parsing module ${MacroHelpers.extension(filePath)} (${filePath}) - ${e} (skipping file)');
                }
            }
            return false;
        }, ["module."]);

        ArraySort.sort(_modules, function(a, b):Int {
            if (a.priority < b.priority) return -1;
            else if (a.priority > b.priority) return 1;
            return 0;
        });    
        
        for (entry in MacroHelpers.classPathCache) {
            var entryModule = null;
            for (m in _modules) {
                if (StringTools.startsWith(entry.path, m.rootPath)) {
                    entryModule = m;
                    break;
                }
            }
            if (entryModule != null) {
                entry.priority = entryModule.priority;
            }
        }
        
        ArraySort.sort(MacroHelpers.classPathCache, function(a, b):Int {
            if (a.priority < b.priority) return -1;
            else if (a.priority > b.priority) return 1;
            return 0;
        });    
        
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
                _resourceIds.push(resourceName);
                Context.addResource(resourceName, File.getBytes(file));
            }
        }
    }
    #end
}
