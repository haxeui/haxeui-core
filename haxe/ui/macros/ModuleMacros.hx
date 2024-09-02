package haxe.ui.macros;

import haxe.ui.util.TypeConverter;
#if macro
import haxe.ds.ArraySort;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr.TypePath;
import haxe.macro.Expr;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.macros.ComponentMacros.BuildData;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;
import haxe.ui.parsers.modules.Module;
import haxe.ui.parsers.modules.ModuleParser;
import haxe.ui.util.StringUtil;
import sys.FileSystem;
import sys.io.File;
#end

@:access(haxe.ui.macros.ComponentMacros)
class ModuleMacros {

    #if macro
    private static var _modules:Array<Module> = [];
    private static var _modulesProcessed:Bool;
    private static var _resourceIds:Array<String> = [];
    
    public static var properties:Map<String, String> = new Map<String, String>();
    #end

    macro public static function processModules():Expr {
        #if !haxeui_experimental_no_cache
        if (_modulesProcessed == true) {
            return macro null;
        }
        #end

        #if haxeui_macro_times
        var stopTimer = Context.timer("ModuleMacros.processModules");
        #end

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
            if (m.preloader != null) {
                var p = m.preloader;
                builder.add(macro
                    haxe.ui.HaxeUIApp.instance.preloaderClass = cast Type.resolveClass($v{p})
                );
            }

            // add resources as haxe resources (plus prefix)
            #if resource_resolution_verbose
            var moduleId = m.id;
            if (moduleId == null) {
                moduleId = "unamed";
            }
            Sys.println("adding resources for module '" + moduleId +"'");
            #end
            var resourceList = [];
            for (r in m.resourceEntries) {
                var inclusions = ModuleResourceEntry.globalInclusions.concat(r.inclusions);
                var exclusions = ModuleResourceEntry.globalExclusions.concat(r.exclusions);

                if (r.path != null) {
                    if (r.prefix == null) {
                        r.prefix = r.path;
                    }
                    var resolvedPaths = resolvePaths(r.path);
                    if (resolvedPaths == null || resolvedPaths.length == 0) {
                        trace("WARNING: Could not resolve resource path " + r.path);
                    } else {
                        for (resolvedPath in resolvedPaths) {
                            addResources(resolvedPath, resolvedPath, r.prefix, inclusions, exclusions, resourceList);
                        }
                    }
                }
            }
            #if resource_resolution_verbose
            Sys.println("");
            #end

            // setup themes
            for (t in m.themeEntries) {
                if (t.parent != null) {
                    builder.add(macro
                        haxe.ui.themes.ThemeManager.instance.getTheme($v{t.name}).parent = $v{t.parent}
                    );
                }
                for (r in t.styles) {
                    var useResource = true;
                    if (r.resource != null && r.resource != "" && resourceList.indexOf(r.resource) == -1) {
                        useResource = false;
                    }
                    if (useResource) {
                        builder.add(macro
                            haxe.ui.themes.ThemeManager.instance.addStyleResource($v{t.name}, $v{r.resource}, $v{r.priority}, $v{r.styleData})
                        );
                    }
                }
                for (r in t.images) {
                    builder.add(macro
                        haxe.ui.themes.ThemeManager.instance.addImageResource($v{t.name}, $v{r.id}, $v{r.resource}, $v{r.priority})
                    );
                }
                for (r in t.vars.keys()) {
                    var v = t.vars.get(r);
                    builder.add(macro
                        haxe.ui.themes.ThemeManager.instance.setThemeVar($v{t.name}, $v{r}, $v{v})
                    );
                }
            }

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
            
            for (c in m.componentEntries) {
                if (c.loadAll == true) { // loadAll means will be populate the classmap - this means a ref will be made to EACH of these components
                    var types = MacroHelpers.typesFromClassOrPackage(c.className, c.classPackage);
                    if (types != null) {
                        for (t in types) {
                            var classInfo = new ClassBuilder(t);
                            if (classInfo.hasSuperClass("haxe.ui.core.Component")) {
                                var fullPath = classInfo.fullPath;
                                builder.add(macro
                                    haxe.ui.core.ComponentClassMap.register($v{classInfo.name}, $v{fullPath})
                                );
                            } else if (classInfo.hasInterface("haxe.ui.IComponentDelegate")) {
                                var fullPath = classInfo.fullPath;
                                builder.add(macro
                                    haxe.ui.core.ComponentClassMap.register($v{classInfo.name}, $v{fullPath})
                                );
                            }
                        }
                    }
                }
            }

            processLayoutEntries(m.layoutEntries, builder);
            
            for (l in m.locales) {
                var localeId = l.id;
                if (localeId == null) {
                    continue;
                }
                for (r in l.resources) {
                    if (r != null) {
                        builder.add(macro
                            haxe.ui.locale.LocaleManager.instance.parseResource($v{localeId}, $v{r})
                        );
                    }
                }
            }
            
            for (validator in m.validators) {
                var id = validator.id;
                var className = validator.className;
                var parts = className.split(".");
                var name:String = parts.pop();
                var t:TypePath = {
                    pack: parts,
                    name: name
                }


                var convertedProperties:Map<String, Any> = null;
                if (validator.properties != null) {
                    for (propertyName in validator.properties.keys()) {
                        var propertyValue = validator.properties.get(propertyName);
                        if (convertedProperties == null) {
                            convertedProperties = new Map<String, Any>();
                        }
                        convertedProperties.set(propertyName, TypeConverter.convertFrom(propertyValue));
                    }
                }
                builder.add(macro
                    haxe.ui.validators.ValidatorManager.instance.registerValidator($v{id}, function() {
                        return new $t();
                    }, $v{convertedProperties})
                );
            }

            for (inputSource in m.actionInputSources) {
                var className = inputSource.className;
                var parts = className.split(".");
                var name:String = parts.pop();
                var t:TypePath = {
                    pack: parts,
                    name: name
                }
                
                builder.add(macro
                    haxe.ui.actions.ActionManager.instance.registerInputSource(new $t())
                );
            }

            for (imageLoader in m.imageLoaders) {
                var className = imageLoader.className;
                var parts = className.split(".");
                var name:String = parts.pop();
                var t:TypePath = {
                    pack: parts,
                    name: name
                }

                builder.add(macro
                    haxe.ui.loaders.image.ImageLoader.instance.register($v{imageLoader.prefix}, function() {
                        return new $t();
                    }, $v{imageLoader.pattern}, $v{imageLoader.isDefault}, $v{imageLoader.singleInstance})
                );
            }

            for (cssFunction in m.cssFunctions) {
                builder.add(macro
                    haxe.ui.styles.CssFunctions.registerCssFunction($v{cssFunction.name}, $p{cssFunction.call.split(".")})
                );
            }

            for (cssFilter in m.cssFilters) {
                var ctor = cssFilter.className + ".new";
                builder.add(macro
                    haxe.ui.styles.CssFilters.registerCssFilter($v{cssFilter.name}, $p{ctor.split(".")})
                );
            }

            for (cssDirective in m.cssDirectives) {
                var ctor = cssDirective.className + ".new";
                builder.add(macro
                    haxe.ui.styles.DirectiveHandler.registerDirectiveHandler($v{cssDirective.name}, $p{ctor.split(".")})
                );
            }
        }

        if (preloadAll) {
            for (r in _resourceIds) {
                if (isImage(r)) {
                    builder.add(macro
                        haxe.ui.ToolkitAssets.instance.preloadList.push({type: "image", resourceId: $v{r}})
                    );
                } else if (isFont(r)) {
                    builder.add(macro
                        haxe.ui.ToolkitAssets.instance.preloadList.push({type: "font", resourceId: $v{r}})
                    );
                }
            }
        }

        populateDynamicClassMap();

        for (alias in ComponentClassMap.list()) {
            builder.add(macro
                haxe.ui.core.ComponentClassMap.register($v{alias}, $v{ComponentClassMap.get(alias)})
            );
        }

        _modulesProcessed = true;

        #if haxeui_macro_times
        stopTimer();
        #end

        return builder.expr;
    }

    #if macro
    private static function resolvePaths(path:String):Array<String> {
        var paths = [];

        #if haxeui_macro_times
        var stopTimer = Context.timer("ModuleMacros.resolvePaths");
        #end
        if (Path.isAbsolute(path)) {
            var isDir = FileSystem.exists(path) && FileSystem.isDirectory(path);
            if (isDir == true) {
                paths.push(path);
            }
        }
        for (c in Context.getClassPath()) {
            if (c.length == 0) {
                c = Sys.getCwd();
            }
            var p = Path.normalize(c + "/" + path);
            var isDir = FileSystem.exists(p) && FileSystem.isDirectory(p);
            if (isDir == true) {
                paths.push(p);
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end

        return paths;
    }

    private static var virtualModuleMap:Map<String, String> = new Map<String, String>();
    public static function resolveComponentClass(name:String, namespace:String = null):String {
        #if macro_times_verbose
        var stopTimer = Context.timer("ModuleMacros.resolveComponentClass");
        #end

        populateDynamicClassMap();
        
        if (namespace == null) {
            namespace = Module.DEFAULT_HAXEUI_NAMESPACE;
        }

        var qualifiedName = namespace + "/" + name;
        name = name.toLowerCase();
        #if component_resolution_verbose
            Sys.print("resolving component class '" + qualifiedName + "'");
        #end
        var resolvedClass = ComponentClassMap.get(qualifiedName);
        if (resolvedClass != null) {
            #if component_resolution_verbose
                Sys.println(" => " + resolvedClass + " (from cache)");
            #end
            #if macro_times_verbose
            stopTimer();
            #end
            return resolvedClass;
        }
        
        var modules:Array<Module> = loadModules();
        var namespaceToClassPath:Map<String, Array<String>> = new Map<String, Array<String>>();
        var namespaceMap:Map<String, String> = new Map<String, String>();

        // maybe move this to a new function and only populate once, concern is about language server and caching
        for (m in modules) {
            for (nsp in m.namespaces.keys()) {
                var nsv = m.namespaces.get(nsp);
                var list = namespaceToClassPath.get(nsp);
                if (list == null) {
                    list = [];
                    namespaceToClassPath.set(nsp, list);
                }
                if (list.indexOf(m.classPath) == -1) {
                    list.push(m.classPath);
                }
                namespaceMap.set(nsp, nsv);
            }
        }

        var namespacePrefix = null;
        for (mapNamespacePrefix in namespaceMap.keys()) {
            var mapNamespaceValue = namespaceMap.get(mapNamespacePrefix);
            if (mapNamespaceValue == namespace) {
                namespacePrefix = mapNamespacePrefix;
                break;
            }
        }

        #if component_resolution_verbose
        var pathsSearched:Map<String, String> = new Map<String, String>();
        var classPackages:Map<String, String> = new Map<String, String>();
        #end

        for (m in modules) {
            for (c in m.componentEntries) {
                var types = null;
                
                if (c.className != null) {
                    var className = c.className.toLowerCase().split(".").pop();
                    if (name == className) {
                        types = Context.getModule(c.className);
                    }
                } else if (c.classPackage != null) {
                    #if component_resolution_verbose
                        classPackages.set(c.classPackage, c.classPackage);
                    #end
                    var paths = namespaceToClassPath.get(namespacePrefix);
                    var arr:Array<String> = c.classPackage.split(".");
                    for (path in paths) {
                        #if component_resolution_verbose 
                        pathsSearched.set(path, path);
                        #end
                        var dir:String = path + arr.join("/");
                        if (!sys.FileSystem.exists(dir) || !sys.FileSystem.isDirectory(dir)) {
                            continue;
                        }
                        
                        var files:Array<String> = sys.FileSystem.readDirectory(dir);
                        if (files != null) {
                            for (file in files) {
                                if (StringTools.endsWith(file, ".hx") && !StringTools.startsWith(file, ".")) {
                                    var fileName:String = file.substr(0, file.length - 3);
                                    if (fileName.toLowerCase() == name) {
                                        var pkg = c.classPackage + ".";
                                        if (c.classPackage == ".") {
                                            pkg = "";
                                        }
                                        types = Context.getModule(pkg + fileName);
                                        break;
                                    }
                                }
                            }
                        }
                        
                        if (types != null) {
                            break;
                        }
                    }
                }
                
                if (types != null) {
                    for (t in types) {
                        resolvedClass = resolveComponentClassInternal(t, c, namespace);
                        if (resolvedClass != null) {
                            return resolvedClass;
                        }
                    }
                }
            }
        }
        
        if (resolvedClass == null) {
            var module = virtualModuleMap.get(name);
            if (module != null) {
                var m = Context.getModule(module);
                for (t in m) {
                    var resolvedClass = resolveComponentClassInternal(t, null, namespace);
                    if (resolvedClass != null) {
                        return resolvedClass;
                    }
                }
            }
        }

        #if component_resolution_verbose
        if (resolvedClass == null) {
            Sys.println(" => NOT FOUND!");
            Sys.println("  Paths searched:");
            for (key in pathsSearched.keys()) {
                Sys.println("    * " + key);
            }
            Sys.println("  Registered class packages:");
            for (key in classPackages.keys()) {
                Sys.println("    * " + key);
            }
        }
        #end

        #if macro_times_vebose
        stopTimer();
        #end

        return resolvedClass;
    }

    public static function defineComponentType(typeDef:TypeDefinition) {
        var name = typeDef.name.toLowerCase();
        name = StringTools.replace(name, "_", "");
        virtualModuleMap.set(name, typeDef.name);
        Context.defineModule(typeDef.name, [typeDef]);
    }

    private static function resolveComponentClassInternal(t:haxe.macro.Type, c:ModuleComponentEntry, namespace:String) {
        var orgType = t;
        var builder = new ClassBuilder(t);
        if (builder.isPrivate == true) {
            return null;
        }
        var org = new ClassBuilder(orgType);
        
        var resolvedClass:String = null;
        if (builder.hasSuperClass("haxe.ui.core.Component") == true) {
            resolvedClass = builder.fullPath;
            if (c != null && c.className != null && org.fullPath != c.className) {
                return null;
            }
            var resolvedClassName = org.name;
            
            if (builder.hasInterface("haxe.ui.core.IDirectionalComponent")) {
                if (StringTools.startsWith(resolvedClassName, "Horizontal")) { // alias HorizontalComponent with hcomponent
                    ComponentClassMap.register(namespace + "/" + "h" + StringTools.replace(resolvedClassName, "Horizontal", "").toLowerCase(), resolvedClass);
                } else if (StringTools.startsWith(resolvedClassName, "Vertical")) { // alias VerticalComponent with vcomponent
                    ComponentClassMap.register(namespace + "/" + "v" + StringTools.replace(resolvedClassName, "Vertical", "").toLowerCase(), resolvedClass);
                } else {
                    var parts = builder.fullPath.split(".");
                    var tempName = parts.pop();
                    var hname = "Horizontal" + tempName;
                    var hclass = parts.join(".") + "." + hname;
                    ComponentClassMap.register(namespace + "/" + hname.toLowerCase(), hclass);
                    ComponentClassMap.register(namespace + "/" + ("h" + tempName).toLowerCase(), hclass);
                    
                    
                    var vname = "Vertical" + tempName;
                    var vclass = parts.join(".") + "." + vname;
                    ComponentClassMap.register(namespace + "/" + vname.toLowerCase(), vclass);
                    ComponentClassMap.register(namespace + "/" + ("v" + tempName).toLowerCase(), vclass);
                }
            }
            
            ComponentClassMap.register(namespace + "/" + resolvedClassName.toLowerCase(), resolvedClass);
            #if component_resolution_verbose
                Sys.println(" => " + resolvedClass);
            #end

            return resolvedClass;
        }

        return null;
    }

    private static var _dynamicClassMapPopulated:Bool = false;
    private static function populateDynamicClassMap() {
        if (_dynamicClassMapPopulated == true) {
            return;
        }
        _dynamicClassMapPopulated = true;

        #if haxeui_macro_times
        var stopTimer = Context.timer("ModuleMacros.populateDynamicClassMap");
        #end

        var modules:Array<Module> = loadModules();
        var list = [];
        for (m in modules) {
            for (c in m.componentEntries) {
                if (c.classFolder != null) {
                    findDynamicClasses(c.classFolder, list);
                } else if (c.classFile != null) {
                    list.push(c.classFile);
                }
            }
        }

        list = orderDynamicClassesByDependency(list);
        for (file in list) {
            createDynamicClass(file, null, null, null);
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    private static function findDynamicClasses(dir:String, list:Array<String>) {
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
        var contents = FileSystem.readDirectory(dir);
        for (item in contents) {
            var fullPath = Path.normalize(dir + "/" + item);
            if (FileSystem.isDirectory(fullPath)) {
                findDynamicClasses(fullPath, list);
            } else {
                list.push(fullPath);
            }
        }
    }

    private static function orderDynamicClassesByDependency(list:Array<String>) {
        var classNames = [];
        var classNameToFile:Map<String, String> = new Map<String, String>();
        for (filename in list) {
            var className:String = StringUtil.capitalizeFirstLetter(StringUtil.capitalizeHyphens(new Path(filename).file)).toLowerCase();
            classNames.push(className);
            classNameToFile.set(className, filename);
        }

        for (filename in list) {
            var resolvedPath = null;
            try {
                resolvedPath = Context.resolvePath(filename);
            } catch (e:Dynamic) {
                resolvedPath = haxe.io.Path.join([Sys.getCwd(), filename]);
            }
            if (resolvedPath == null || FileSystem.exists(resolvedPath) == false || FileSystem.isDirectory(resolvedPath) == true) {
                trace("WARNING: Could not find path " + resolvedPath);
            }
    
            var fullPath = Path.normalize(resolvedPath);
    
            var className:String = StringUtil.capitalizeFirstLetter(StringUtil.capitalizeHyphens(new Path(filename).file)).toLowerCase();
            var fileContents = sys.io.File.getContent(fullPath);
            try {
                var xml = Xml.parse(fileContents);
                walkXmlNodes(className, xml.firstElement(), classNames);
            } catch(e:Dynamic) {}
        }

        var orderedList = [];
        for (className in classNames) {
            orderedList.push(classNameToFile.get(className));
        }
        return orderedList;
    }
    
    private static function walkXmlNodes(currentClassName:String, xml:Xml, classNames:Array<String>) {
        var nodeName = StringTools.replace(xml.nodeName.toLowerCase(), "-", "");
        if (classNames.indexOf(nodeName) != -1) {
            var currentClassIndex = classNames.indexOf(currentClassName);
            var dependencyClassIndex = classNames.indexOf(nodeName);
            if (dependencyClassIndex > currentClassIndex) {
                classNames.remove(nodeName);
                classNames.insert(currentClassIndex, nodeName);
            }
        }
        for (el in xml.elements()) {
            walkXmlNodes(currentClassName, el, classNames);
        }
    }

    private static function buildDynamicClassDep(filename:String) {
        var className:String = StringUtil.capitalizeFirstLetter(StringUtil.capitalizeHyphens(new Path(filename).file));
        trace("build deps for", filename, className);
    }

    private static function createDynamicClasses(dir:String, root:String, namespaces:Map<String, String>) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ModuleMacros.createDynamicClasses");
        #end

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
                createDynamicClasses(fullPath, root, namespaces);
            } else {
                createDynamicClass(fullPath, null, root, namespaces);
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }

    public static function createDynamicClass(filePath:String, alias:String = null, root:String = null, namespaces:Map<String, String> = null):String {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ModuleMacros.createDynamicClass");
        #end

        var resolvedPath = null;
        try {
            resolvedPath = Context.resolvePath(filePath);
        } catch (e:Dynamic) {
            resolvedPath = haxe.io.Path.join([Sys.getCwd(), filePath]);
        }
        if (resolvedPath == null || FileSystem.exists(resolvedPath) == false || FileSystem.isDirectory(resolvedPath) == true) {
            trace("WARNING: Could not find path " + resolvedPath);
        }

        var fullPath = Path.normalize(resolvedPath);
        if (root != null) {
            filePath = StringTools.replace(fullPath, root, "");
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

        /* this causes problems with language server it seems
        var fullClass = fileParts.concat([className]).join(".");
        if (ComponentClassMap.hasClass(fullClass) == true) {
            return fullClass;
        }
        */

        var xml = sys.io.File.getContent(fullPath);
        var buildData:BuildData = { };
        var codeBuilder = new CodeBuilder();
        var c = ComponentMacros.buildComponentFromStringCommon(codeBuilder, xml, buildData);

        var superClassString = "haxe.ui.containers.Box";
        var superClassLookup:String = ModuleMacros.resolveComponentClass(c.type, c.namespace);
        if (superClassLookup != null) {
            superClassString = superClassLookup;
        }
        var superClassParts = superClassString.split(".");
        var superClass:TypePath = {
            name: superClassParts.pop(),
            pack: superClassParts
        }

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

        for (name in buildData.namedComponents.keys()) {
            var typeClass = buildData.namedComponents.get(name).type;
            var typeParts = typeClass.split(".");
            var typeName = typeParts.pop();
            var t:TypePath = {
                name: typeName,
                pack: typeParts
            }

            classBuilder.addVar(name, ComplexType.TPath(t));
            classBuilder.ctor.add(macro $i{name} = findComponent($v{name}, $p{typeClass.split(".")}));
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }
        if (fullScript.length > 0) {
            ComponentMacros.buildScriptFunctions(classBuilder, null, buildData.namedComponents, fullScript);
        }

        Context.defineModule(fileParts.concat([className]).join("."), [newClass]);
        if (namespaces != null) {
            for (k in namespaces.keys()) {
                var ns = namespaces.get(k);
                ComponentClassMap.register(ns + "/" + className, fileParts.concat([className]).join("."));
            }
        } else {
            ComponentClassMap.register(Module.DEFAULT_HAXEUI_NAMESPACE + "/" + className, fileParts.concat([className]).join("."));
        }

        #if haxeui_macro_times
        stopTimer();
        #end

        return fileParts.concat([className]).join(".");
    }

    private static var _modulesLoaded:Bool = false;
    public static function loadModules():Array<Module> {
        if (_modulesLoaded == true) {
            return _modules;
        }
        _modulesLoaded = true;


        #if haxeui_macro_times
        var stopTimer = Context.timer("ModuleMacros.loadModules");
        #end

        #if module_resolution_verbose
        Sys.println("scanning class path for modules");
        #end
        #if haxeui_macro_times
        var stopTimerScan = Context.timer("ModuleMacros.loadModules - scanClassPath");
        #end

        var moduleDetails:Array<{filePath:String, fileContents:String, hash:String, base:String}> = [];
        MacroHelpers.scanClassPath(function(filePath:String, base:String) {
            #if module_resolution_verbose
            Sys.println("    module found at '" + filePath + "' (base: '" + base + "')");
            #end
            var moduleParser = ModuleParser.get(MacroHelpers.extension(filePath));
            if (moduleParser != null) {
                var fileContents = File.getContent(filePath);
                var hash = haxe.crypto.Md5.encode(fileContents);
                var found = false;
                for (details in moduleDetails) {
                    if (details.hash == hash) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    moduleDetails.push({
                        filePath: filePath,
                        fileContents: fileContents,
                        hash: hash,
                        base: base
                    });
                }
            }
            return false;
        }, ["module."]);

        for (moduleDetail in moduleDetails) {
            var moduleParser = ModuleParser.get(MacroHelpers.extension(moduleDetail.filePath));
            if (moduleParser != null) {
                try {
                    var module:Module = moduleParser.parse(moduleDetail.fileContents, Context.getDefines(), moduleDetail.filePath);
                    module.validate();
                    module.rootPath = new Path(moduleDetail.filePath).dir;
                    module.classPath = moduleDetail.base;
                    _modules.push(module);
                } catch (e:Dynamic) {
                    Sys.println('WARNING: Problem parsing module ${MacroHelpers.extension(moduleDetail.filePath)} (${moduleDetail.filePath}) - ${e} (skipping file)');
                }
            }
        }
        #if module_resolution_verbose
        Sys.println(_modules.length + " module(s) found\n");
        #end
        #if haxeui_macro_times
        stopTimerScan();
        #end
        
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

        for (m in _modules) {
            for (p in m.properties) {
                properties.set(p.name, p.value);
            }
            processLayoutEntries(m.layoutEntries);
        }
        
        #if haxeui_macro_times
        stopTimer();
        #end

        return _modules;
    }

    private static function processLayoutEntries(layoutEntries:Array<ModuleLayoutEntry>, builder:CodeBuilder = null) {
        for (l in layoutEntries) {
            var types = MacroHelpers.typesFromClassOrPackage(l.className, l.classPackage);
            if (types != null) {
                for (t in types) {
                    var classInfo = new ClassBuilder(t);
                    if (classInfo.hasSuperClass("haxe.ui.layouts.Layout")) {
                        var fullPath = classInfo.fullPath;
                        for (alias in LayoutMacros.buildLayoutAliases(fullPath)) {
                            if (builder != null) {
                                builder.add(macro haxe.ui.layouts.LayoutFactory.register($v{alias}, $v{fullPath}));
                            }
                            haxe.ui.layouts.LayoutFactory.register(alias, fullPath);
                        }
                    }
                }
            }
        }
    }

    private static function addResources(path:String, base:String, prefix:String, inclusions:Array<String>, exclusions:Array<String>, resourceList:Array<String>) {
        #if haxeui_macro_times
        var stopTimer = Context.timer("ModuleMacros.addResources");
        #end

        if (prefix == null) {
            prefix = "";
        }
        var contents:Array<String> = sys.FileSystem.readDirectory(path);
        for (f in contents) {
            var file = path + "/" + f;
            if (sys.FileSystem.isDirectory(file)) {
                addResources(file, base, prefix, inclusions, exclusions, resourceList);
            } else {
                var relativePath = prefix + StringTools.replace(file, base, "");
                var resourceName:String = relativePath;
                if (StringTools.startsWith(resourceName, "/")) {
                    resourceName = resourceName.substr(1, resourceName.length);
                }
                var includedIndex = isInInclusions(resourceName, inclusions);
                var excludedIndex = isInExclusions(resourceName, exclusions);
                
                if (includedIndex != -1 && excludedIndex == -1) {
                    _resourceIds.push(resourceName);
                    
                    #if resource_resolution_verbose
                    if (includedIndex != -1 && includedIndex != 0xffffff) {
                        var inclusionPattern = inclusions[includedIndex];
                        if (ModuleResourceEntry.globalInclusions.indexOf(inclusionPattern) != -1) {
                            Sys.println("    + '" + resourceName + "' - explicitly included via global pattern '" + inclusions[includedIndex] + "'");
                        } else {
                            Sys.println("    + '" + resourceName + "' - explicitly included via pattern '" + inclusions[includedIndex] + "'");
                        }
                    } else {
                        Sys.println("    + '" + resourceName);
                    }
                    #end
                    
                    if (resourceList != null) {
                        resourceList.push(resourceName);
                    }
                    Context.addResource(resourceName, File.getBytes(file));
                } else {
                    #if resource_resolution_verbose
                    if (includedIndex == -1) {
                        Sys.println("    - '" + resourceName + "' based on inclusion patterns: " + inclusions.join(", "));
                    }
                    if (excludedIndex != -1) {
                        var exclusionPattern = exclusions[excludedIndex];
                        if (ModuleResourceEntry.globalExclusions.indexOf(exclusionPattern) != -1) {
                            Sys.println("    - '" + resourceName + "' based on global exclusion pattern '" + exclusions[excludedIndex] + "'");
                        } else {
                            Sys.println("    - '" + resourceName + "' based on exclusion pattern '" + exclusions[excludedIndex] + "'");
                        }
                    }
                    #end
                }
            }
        }

        #if haxeui_macro_times
        stopTimer();
        #end
    }
    
    private static function isInInclusions(s:String, inclusions:Array<String>):Int {
        if (inclusions.length == 0) {
            return 0xffffff;
        }
        var n = -1;
        var i = 0;
        for (inclusion in inclusions) {
            try {
                inclusion = fixPattern(inclusion);
                var pattern = new EReg(inclusion, "gmi");
                if (pattern.match(s)) {
                    n = i;
                    break;
                }
            } catch (e:Dynamic) {
                trace("WARNING: inclusion pattern '" + inclusion + "' not valid");
            }
            i++;
        }
        return n;
    }
    
    private static function isInExclusions(s:String, exclusions:Array<String>):Int {
        var n = -1;
        var i = 0;
        for (exclusion in exclusions) {
            try {
                exclusion = fixPattern(exclusion);
                var pattern = new EReg(exclusion, "gmi");
                if (pattern.match(s)) {
                    n = i;
                    break;
                }
            } catch (e:Dynamic) {
                trace("WARNING: exclusion pattern '" + exclusion + "' not valid");
            }
            i++;
        }
        return n;
    }
    
    private static function fixPattern(s:String) { // this just means we can make the regexp a little "simpler"
        s = StringTools.replace(s, ".*", "|*");
        s = StringTools.replace(s, "/", "\\/");
        s = StringTools.replace(s, "\\.", ".");
        s = StringTools.replace(s, ".", "\\.");
        s = StringTools.replace(s, "|*", ".*");
        if (StringTools.startsWith(s, "*")) { // lets "fix" a regexp so you can use things like "*.png" rather than ".*\.png"
            s = ".*" + s.substr(1);
        }
        return s;
    }
    
    private static function isImage(file:String):Bool {
        return StringTools.endsWith(file, ".png")
            || StringTools.endsWith(file, ".gif")
            || StringTools.endsWith(file, ".svg")
            || StringTools.endsWith(file, ".jpg")
            || StringTools.endsWith(file, ".jpeg");
    }

    private static function isFont(file:String):Bool {
        return StringTools.endsWith(file, ".ttf");
    }

    #end
}
