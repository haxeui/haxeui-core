package haxe.ui.macros.helpers;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Expr;
import haxe.macro.Expr.Function;
import haxe.macro.ExprTools;

class FunctionBuilder {
    public var field:Field;
    public var fn:Function;

    public function new(field:Field, fn:Function) {
        this.field = field;
        this.fn = fn;
    }

    public var name(get, null):String;
    private function get_name():String {
        return field.name;
    }

    public var returnType(get, null):String;
    private function get_returnType():String {
        var r = null;
        switch (fn.ret) {
            case TPath(p):
                r = p.name;
            case _:
        }
        return r;
    }

    public var returnsComponent(get, null):Bool;
    private function get_returnsComponent():Bool {
        if (fn == null || fn.ret == null) {
            return false;
        }
        
        #if (haxe_ver < 4)
            switch (fn.ret) {
                case TPath(p):
                    if (p.name == "Component" || p.name == "String" || p.name == "Bool" || p.name == "Int" || p.name == "Variant") {
                        return false;
                    }
                case _:    
            }
        #end
        
        var classBuiler = new ClassBuilder(ComplexTypeTools.toType(fn.ret));
        return classBuiler.hasSuperClass("haxe.ui.core.Component");
    }
    
    public var isVoid(get, null):Bool;
    private function get_isVoid():Bool {
        return (returnType == "Void");
    }

    public var isBool(get, null):Bool;
    private function get_isBool():Bool {
        switch (fn.ret) {
            case TPath(p):
                if (p.name == "Bool") {
                    return true;
                }
            case _:
        }
        return false;
    }

    public var isString(get, null):Bool;
    private function get_isString():Bool {
        switch (fn.ret) {
            case TPath(p):
                if (p.name == "String") {
                    return true;
                }
            case _:
        }
        return false;
    }

    public var isNumeric(get, null):Bool;
    private function get_isNumeric():Bool {
        switch (fn.ret) {
            case TPath(p):
                if (p.name == "Int" || p.name == "Float") {
                    return true;
                }
            case _:
        }
        return false;
    }
    
    public function getArgName(index:Int):String {
        if (fn.args != null && fn.args.length > index) {
            return fn.args[index].name;
        }
        return null;
    }

    public function add(e:Expr = null, cb:CodeBuilder = null, where:CodePos = null) {
        if (where == null) {
            where = CodePos.End;
        }
        var current = new CodeBuilder(fn.expr);
        current.add(e, cb, where);
        fn.expr = current.expr;
    }

    public function addToStart(e:Expr = null, cb:CodeBuilder = null) {
        var where = CodePos.Start;
        var current = new CodeBuilder(fn.expr);
        current.add(e, cb, where);
        fn.expr = current.expr;
    }
    
    public function set(e:Expr = null, cb:CodeBuilder = null) {
        if (e == null) {
            e = cb.expr;
        }
        fn.expr = e;
    }

    public function arg(index):FunctionArg {
        return fn.args[index];
    }

    public var argCount(get, null):Int;
    private function get_argCount():Int {
        if (fn.args == null) {
            return 0;
        }
        return fn.args.length;
    }

    public function getMetaValueString(name:String, paramIndex:Int = 0):String {
        for (m in field.meta) {
            if (m.name == name || m.name == ':${name}') {
                if (m.params[paramIndex] == null) {
                    return null;
                }
                return ExprTools.toString(m.params[paramIndex]);
            }
        }
        return null;
    }

    public function getMetaValueExpr(name:String, paramIndex:Int = 0):Expr {
        for (m in field.meta) {
            if (m.name == name || m.name == ':${name}') {
                if (m.params[paramIndex] == null) {
                    return null;
                }
                return m.params[paramIndex];
            }
        }
        return null;
    }

    public function printString():String {
        return ExprTools.toString(fn.expr);
    }
}