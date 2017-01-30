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
        var v = Reflect.getProperty(o, f);
        return parseResult(v);
    }

    private function parseResult(v):Dynamic {
        if (v == null) {
            return v;
        }
        var temp = Std.string(v);
        var regexp:EReg = new EReg("^_?(Bool|Float|Int|String)\\((.*)\\)", "g");
        if (regexp.match(temp) == false) {
            return v;
        }

        var m1 = regexp.matched(1);
        var m2 = regexp.matched(2);
        switch (m1) {
            case "Bool":
                return Std.parseFloat(m2);
            case "Float":
                return Std.parseFloat(m2);
            case "Int":
                return Std.parseInt(m2);
            case "String":    
                return Std.string(m2);
            case _:    
        }
        return v;
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