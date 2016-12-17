package haxe.ui.scripting;

import hscript.Interp;

class ScriptInterp extends Interp {
    private static var _classAliases:Map<String, String>;
    private static var _staticClasses:Map<String, Dynamic>;

    public function new() {
        super();
        if (_staticClasses != null) {
            for (name in _staticClasses.keys()) {
                var c:Dynamic = _staticClasses.get(name);
                variables.set(name, c);
            }
        }
        variables.set("isVar", isVar);
    }

    private function isVar(varName:String):Bool {
        return variables.exists(varName);
    }

    override function cnew( cl : String, args : Array<Dynamic> ) : Dynamic {
        if (_classAliases != null && _classAliases.exists(cl)) {
            cl = _classAliases.get(cl);
        }
        return super.cnew(cl, args);
    }

    override function get( o : Dynamic, f : String ) : Dynamic {
        if ( o == null ) {
            throw error(EInvalidAccess(f));
        }
        return Reflect.getProperty(o, f);
    }

    override function set( o : Dynamic, f : String, v : Dynamic ) : Dynamic {
        if ( o == null ) {
            throw error(EInvalidAccess(f));
        }
        Reflect.setProperty(o, f, v);
        return v;
    }

    public static function addClassAlias(alias:String, classPath:String) {
        if (_classAliases == null) {
            _classAliases = new Map<String, String>();
        }
        _classAliases.set(alias, classPath);
    }

    public static function addStaticClass(alias:String, c:Dynamic) {
        if (_staticClasses == null) {
            _staticClasses = new Map<String, Dynamic>();
        }
        _staticClasses.set(alias, c);
    }
}