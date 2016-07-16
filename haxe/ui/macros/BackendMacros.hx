package haxe.ui.macros;

import haxe.ui.parsers.backends.Backend;
import haxe.ui.parsers.backends.BackendParser;
import haxe.ui.util.GenericConfig;
import haxe.ui.util.Properties;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Compiler;
#end

@:remove @:autoBuild(haxe.ui.macros.BackendMacros.test())
extern interface TestClass {}

class BackendMacros {
	public static var backends:Map<String, Backend> = new Map<String, Backend>();
    public static var properties:Properties = new Properties();
	
	public static var _backend:Backend;
	private static var _built:Bool = false;
    
    public static var backendId = null;
    
    macro public static function test():Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
        if (_built == true) {
           return fields; 
        }
        
        //trace("Building backend types2");
        /*
        
			var source:String = "haxe.ui.luxe.ComponentBase";
			var target:String = "haxe.ui.core.ComponentBase";
			//trace("replacing '" + target + "' with '" + source + "'");
		
			var pack = target.split(".");
			var name = pack.pop();
			
			var c = {
				pack : pack,
				name : name,
				pos : Context.currentPos(),
				meta : [],
				params : [],
				isExtern : false,
				kind : TDAlias(MacroHelpers.mkType(source)),
				fields : []
			}
            trace(c);
			Context.defineType(c);
        */
		loadBackends();
		if (_backend == null) {
			//throw "No backend config found!";
            // TODO: backend config isnt required now!
            return fields;
		} else if (Lambda.count(backends) > 1) {
			trace("WARNING: mulitple backend configs found, use --XXX to specify which to use"); // place holder
		}
		
		var backend = _backend;
		
		Compiler.define("haxeui-" + backend.id);
        Compiler.define("haxeui-backend", "haxeui-" + backend.id);
        backendId = backend.id;

		for (classEntry in backend.classEntries) {
			var source:String = classEntry.source;
			var target:String = classEntry.target;
			//trace("replacing '" + target + "' with '" + source + "'");
		
			var pack = target.split(".");
			var name = pack.pop();
			
			var c = {
				pack : pack,
				name : name,
				pos : Context.currentPos(),
				meta : [],
				params : [],
				isExtern : false,
				kind : TDAlias(MacroHelpers.mkType(source)),
				fields : []
			}
            //trace(c);
			Context.defineType(c);
		}
            
        _built = true;
        return fields;
    }
    
	macro public static function buildBackendTypes():Expr {	
        if (_built == true) {
            return macro null; 
        }
        
        //trace("Building backend types");
        
		loadBackends();
		if (_backend == null) {
			throw "No backend config found!";
		} else if (Lambda.count(backends) > 1) {
			trace("WARNING: mulitple backend configs found, use --XXX to specify which to use"); // place holder
		}
		
		var backend = _backend;
		
		Compiler.define("haxeui-" + backend.id);
        Compiler.define("haxeui-backend", "haxeui-" + backend.id);
        backendId = backend.id;
		
		for (classEntry in backend.classEntries) {
			var source:String = classEntry.source;
			var target:String = classEntry.target;
			//trace("replacing '" + target + "' with '" + source + "'");
		
			var pack = target.split(".");
			var name = pack.pop();
			
			var c = {
				pack : pack,
				name : name,
				pos : Context.currentPos(),
				meta : [],
				params : [],
				isExtern : false,
				kind : TDAlias(MacroHelpers.mkType(source)),
				fields : []
			}
            //trace(c);
			Context.defineType(c);
		}
		_built = true;
		return macro null;
	}
    
	macro public static function processBackend():Expr {
        loadBackends();
		if (_backend == null) { // should have already been found with 'buildBackendTypes'
			//throw "No backend config found!";
            return macro null;
		}

		loadBackendProperties();

		var code:String = "function() {\n";
		code += buildBackendConfig(_backend.config, 0);
        for (name in properties.names()) {
            code += 'Toolkit.backendProperties.setProp("${name}", "${properties.getProp(name)}");\n';
        }
		code += "}()\n";
		//trace(code);
		return Context.parseInlineString(code, Context.currentPos());
	}
	
	#if macro
	
	private static function buildBackendConfig(c:GenericConfig, v:Int):String {
		var code:String = "";
		for (key in c.values.keys()) {
			code += 's${v}.values.set("${key}", "${c.values.get(key)}");\n';
		}
		for (sectionName in c.sections.keys()) {
			for (section in c.sections.get(sectionName)) {
				if (v == 0) {
					code += 'var s1 = backendConfig.addSection("${sectionName}");\n';
				} else {
					code += 'var s${v + 1} = s${v}.addSection("${sectionName}");\n';
				}
				code += buildBackendConfig(section, v + 1);
			}
		}
		return code;
	}
	
    macro private static function loadBackendProperties():Expr {
        var paths:Array<String> = Context.getClassPath();
        for (p in paths) {
            findBackendProperties(p);
        }
        return macro null;
    }
    
    private static function findBackendProperties(path:String) {
		if (StringTools.trim(path).length == 0) {
			return;
		}

        if (FileSystem.exists(path) == false) {
            return;
        }
        
		var paths:Array<String> = FileSystem.readDirectory(path);
		var found:Bool = false;
		for (p in paths) {
			var file = path + "/" + p;
			if (MacroHelpers.skipPath(file) == true) {
				continue;
			}
			
			if (FileSystem.isDirectory(file) == true && found == false) {
				findBackendProperties(file);
			} else {
				if (p.indexOf('haxeui-${_backend.id}.properties') != -1 && p.indexOf("~") == -1) {
                    var props:Properties = new Properties();
                    props.fromFile(file);
                    properties.addAll(props);
                    found = true;
				}
			}
		}
    }
    
	macro private static function loadBackends():Expr {
		var paths:Array<String> = Context.getClassPath();
		for (p in paths) {
			findBackendConfig(p);
		}
		return macro null;
	}

	private static function findBackendConfig(path:String) {
		if (StringTools.trim(path).length == 0) {
			return;
		}

        if (FileSystem.exists(path) == false) {
            return;
        }
        
		var paths:Array<String> = FileSystem.readDirectory(path);
		var found:Bool = false;
		for (p in paths) {
			var file = path + "/" + p;
			if (MacroHelpers.skipPath(file) == true) {
				continue;
			}
			
			if (FileSystem.isDirectory(file) == true && found == false) {
				findBackendConfig(file);
			} else {
				if (p.indexOf(".config.") != -1 && p.indexOf("~") == -1) {
					var backend:Backend = BackendParser.get(MacroHelpers.extension(p)).parse(File.getContent(file));
					backend.validate();
					backends.set(backend.id, backend);
					found = true; // this will allow another backend config in the same dir,
								  // but wont go any deeper in the dir structure (by design)
					if (_backend == null) { // compiler param here to select which one to use if multiple found
						_backend = backend;
					}
				}
			}
		}
	}
	
	#end
}