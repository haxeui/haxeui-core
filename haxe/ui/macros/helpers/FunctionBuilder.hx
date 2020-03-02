package haxe.ui.macros.helpers;

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
    
    public var isVoid(get, null):Bool;
    private function get_isVoid():Bool {
        return (returnType == "Void");
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
    
    public function set(e:Expr = null, cb:CodeBuilder = null) {
        if (e == null) {
            e = cb.expr;
        }
        fn.expr = e;
    }
    
    public function arg(index):FunctionArg {
        return fn.args[index];
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