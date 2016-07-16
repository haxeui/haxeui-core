package haxe.ui.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.rtti.Meta;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Type.ClassField;
#end

class MacroHelpers {
	private static var SKIP_PATTERNS = ["/lib/actuate/",
										"/lib/lime/",
										"/lib/openfl/",
										"/lib/yaml/",
										"/lib/hscript/",
										"/haxe/std/"];
    
    #if macro
    public static function getConstructor(fields:Array<Field>) {
        return getFunction(fields, "new");
    }
                                        
    public static function getFunction(fields:Array<Field>, name:String) {
        var fn = null;
		for (f in fields) {
			if (f.name == name) {
				switch (f.kind) {
					case FFun(f):
							fn = f;
						break;
					default:
				}
			}
		}
        return fn;
    }
    
	public static function skipPath(path:String):Bool {
		var skip:Bool = false;

		path = StringTools.replace(path, "\\", "/");
		
		for (s in SKIP_PATTERNS) {
			if (path.indexOf(s) != -1) {
				skip = true;
				break;
			}
		}
		
		return skip;
	}
	
	public static function resolveFile(file:String):String {
		var resolvedPath:String = null;
		if (sys.FileSystem.exists(file) == false) {
			var paths:Array<String> = Context.getClassPath();
			//paths.push("assets");
			
			for (path in paths) {
				path = path + "/" + file;
				if (sys.FileSystem.exists(path)) {
					resolvedPath = path;
					break;
				}
			}
		} else {
			resolvedPath = file;
		}
		return resolvedPath;
	}
	
	public static function typesFromPackage(pack:String):Array<haxe.macro.Type> {
		var types:Array<haxe.macro.Type> = new Array<haxe.macro.Type>();
		
		var paths:Array<String> = Context.getClassPath();
		var arr:Array<String> = pack.split(".");
		for (path in paths) {
			var dir:String = path + arr.join("/");
			if(!sys.FileSystem.exists(dir) || !sys.FileSystem.isDirectory(dir)) {
				continue;
			}
			
			var files:Array<String> = sys.FileSystem.readDirectory(dir);
			if (files != null) {
				for (file in files) {
					if (StringTools.endsWith(file, ".hx") && !StringTools.startsWith(file, ".")) {
						var name:String = file.substr(0, file.length - 3);
						var temp:Array<haxe.macro.Type> = Context.getModule(pack + "." + name);
						types = types.concat(temp);
					}
				}
			}
		}
		
		return types;
	}

	public static function classNameFromType(t:haxe.macro.Type):String {
		var className:String = "";
		switch (t) {
				case TAnonymous(t): className = t.toString();
				case TMono(t): className = t.toString();
				case TLazy(t): className = "";
				case TFun(t, _): className = t.toString();
				case TDynamic(t): className = "";
				case TInst(t, _): className = t.toString();
				case TEnum(t, _): className = t.toString();
				case TType(t, _): className = t.toString();
				case TAbstract(t, _): className = t.toString();
		}
		
		var c = className.split(".");
		var name = c[c.length - 1];
		var module = moduleNameFromType(t);
		if (StringTools.endsWith(module, name) == false) {
			className = module + "." + name;
		}
		
		return className;
	}
	
	public static function moduleNameFromType(t:haxe.macro.Type):String {
		var moduleName:String = "";
		switch (t) {
			case TInst(t, _):
				moduleName = t.get().module;
			default:	
		}
		return moduleName;
	}
	
	public static function addMeta(t:haxe.macro.Type, meta:String, pos:haxe.macro.Position) {
		switch (t) {
			case TInst(t, _):
				t.get().meta.add(meta, [], pos);
			default:	
		}
	}
	
	public static function hasSuperClass(t:haxe.macro.Type, classRequired:String):Bool {
		var has:Bool = false;
		switch (t) {
				case TAnonymous(t): {};
				case TMono(t): {};
				case TLazy(t): {};
				case TFun(t, _): {};
				case TDynamic(t): {};
				case TInst(t, _): {
					if (t.toString() == classRequired) {
						has = true;
					} else {
						while (t != null) {
							if (t.get().superClass != null) {
								if (t.toString() == classRequired) {
									has = true;
									break;
								} else {
									t = t.get().superClass.t;
								}
							} else {
								t = null;
							}
						}
					}
				}
				case TEnum(t, _): {};
				case TType(t, _): {};
				case TAbstract(t, _): {};
		}
		
		return has;
	}
	
	public static function mkPath(name:String):TypePath {
		var parts = name.split('.');
		return {
			sub: null,
			params: [],
			name: parts.pop(),
			pack: parts
		}
	}
	
	public static function mkType(s:String):ComplexType {
		return TPath(mkPath(s)); 
	}
	
	public static function extension(path:String):String {
		if (path.indexOf(".") == -1) {
			return null;
		}
		var arr:Array<String> = path.split(".");
		var extension:String = arr[arr.length - 1];
		return extension;
	}
    
    public static function aliasType(source:String, target:String) {
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
        Context.defineType(c);
    }
    
	public static function insertExpr(arr:Array<Expr>, pos:Int, item:Expr):Array<Expr> {
		if (pos == -1) {
			arr.push(item);
		} else {
			arr.insert(pos, item);
		}
		return arr;
	}
    
    public static function checkCondition(condition:String):Bool {
        var result:Bool = true;
        if (condition != null) {
            var parser = new hscript.Parser();
            var program = parser.parseString(condition);
            var interp = new hscript.Interp();
            interp.variables.set("backend", BackendMacros.backendId);
            
            try {
                var r = interp.execute(program);
                result = ("" + r == "true");
            } catch (e:Dynamic) {
                trace('WARNING: Problem checking condition "${condition}" in config file: ' + e + ' (excluding section!)');
                result = false;
            }
        }
        return result;
    }
    
    #end
}