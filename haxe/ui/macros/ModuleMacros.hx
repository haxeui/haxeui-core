package haxe.ui.macros;

#if macro
import haxe.ds.ArraySort;
import haxe.ui.macros.ComponentMacros.BuildData;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
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

@:access(haxe.ui.macros.ComponentMacros)
class ModuleMacros {

    #if macro
    private static var _modules:Array<Module> = [];
    private static var _modulesProcessed:Bool;
    private static var _resourceIds:Array<String> = [];
    
    public static var properties:Map<String, String> = new Map<String, String>();
    #end

    macro public static function processModules():Expr {
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
                            }
                        }
                    }
                }
            }
            
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
        }

        if (preloadAll) {
            for (r in _resourceIds) {
                if (StringTools.endsWith(r, ".png")) {
                    builder.add(macro
                        haxe.ui.ToolkitAssets.instance.preloadList.push({type: "image", resourceId: $v{r}})
                    );
                } else if (StringTools.endsWith(r, ".ttf")) {
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

        for (alias in LayoutClassMap.list()) {
            builder.add(macro
                haxe.ui.core.LayoutClassMap.register($v{alias}, $v{LayoutClassMap.get(alias)})
            );
        }

        _modulesProcessed = true;
        return builder.expr;
    }

    #if macro
    private static function resolvePaths(path:String):Array<String> {
        var paths = [];

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

        return paths;
    }

    public static function resolveComponentClass(name:String):String {
        populateDynamicClassMap();
        
        name = name.toLowerCase();
        var resolvedClass = ComponentClassMap.get(name);
        if (resolvedClass != null) {
            return resolvedClass;
        }
        
        var modules:Array<Module> = loadModules();
        for (m in modules) {
            for (c in m.componentEntries) {
                var types = null;
                
                if (c.className != null) {
                    var className = c.className.toLowerCase().split(".").pop();
                    if (name == className) {
                        types = Context.getModule(c.className);
                    }
                } else if (c.classPackage != null) {
                    var paths:Array<String> = Context.getClassPath();
                    var arr:Array<String> = c.classPackage.split(".");
                    for (path in paths) {
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
                        var orgType = t;
                        var builder = new ClassBuilder(t);
                        if (builder.isPrivate == true) {
                            continue;
                        }
                        var org = new ClassBuilder(orgType);
                        
                        if (builder.hasSuperClass("haxe.ui.core.Component") == true) {
                            resolvedClass = builder.fullPath;
                            if (c.className != null && org.fullPath != c.className) {
                                continue;
                            }
                            var resolvedClassName = org.name;
                            
                            if (builder.hasInterface("haxe.ui.core.IDirectionalComponent")) {
                                if (StringTools.startsWith(resolvedClassName, "Horizontal")) { // alias HorizontalComponent with hcomponent
                                    ComponentClassMap.register("h" + StringTools.replace(resolvedClassName, "Horizontal", "").toLowerCase(), resolvedClass);
                                } else if (StringTools.startsWith(resolvedClassName, "Vertical")) { // alias VerticalComponent with vcomponent
                                    ComponentClassMap.register("v" + StringTools.replace(resolvedClassName, "Vertical", "").toLowerCase(), resolvedClass);
                                } else {
                                    var parts = builder.fullPath.split(".");
                                    var tempName = parts.pop();
                                    var hname = "Horizontal" + tempName;
                                    var hclass = parts.join(".") + "." + hname;
                                    ComponentClassMap.register(hname.toLowerCase(), hclass);
                                    ComponentClassMap.register(("h" + tempName).toLowerCase(), hclass);
                                    
                                    
                                    var vname = "Vertical" + tempName;
                                    var vclass = parts.join(".") + "." + vname;
                                    ComponentClassMap.register(vname.toLowerCase(), vclass);
                                    ComponentClassMap.register(("v" + tempName).toLowerCase(), vclass);
                                }
                            }
                            
                            ComponentClassMap.register(resolvedClassName.toLowerCase(), resolvedClass);
                            return resolvedClass;
                        }
                    }
                }
            }
        }
        
        return resolvedClass;
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
                    createDynamicClass(c.classFile);
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
        var superClassLookup:String = ModuleMacros.resolveComponentClass(c.type);
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

        Context.defineModule(fileParts.concat([className]).join("."), [newClass]);
        ComponentClassMap.register(className, fileParts.concat([className]).join("."));
        return fileParts.concat([className]).join(".");
    }

    private static var _modulesLoaded:Bool = false;
    public static function loadModules():Array<Module> {
        if (_modulesLoaded == true) {
            return _modules;
        }

        #if module_resolution_verbose
        Sys.println("scanning class path for modules");
        #end
        MacroHelpers.scanClassPath(function(filePath:String) {
            #if module_resolution_verbose
            Sys.println("    module found at '" + filePath + "'");
            #end
            
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
        #if module_resolution_verbose
        Sys.println(_modules.length + " module(s) found\n");
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
        }
        
        _modulesLoaded = true;
        return _modules;
    }

    private static function addResources(path:String, base:String, prefix:String, inclusions:Array<String>, exclusions:Array<String>, resourceList:Array<String>) {
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
    
    #end
}
