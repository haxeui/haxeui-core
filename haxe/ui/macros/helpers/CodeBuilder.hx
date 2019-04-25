package haxe.ui.macros.helpers;

import haxe.macro.Expr;
import haxe.macro.ExprTools;

class CodeBuilder {
    public var expr:Expr = null;
    
    public function new(expr:Expr = null) {
        if (expr == null) {
            expr = macro {
            };
        }
        this.expr = expr;
    }
    
    public function add(e:Expr = null, cb:CodeBuilder = null, where:CodePos = CodePos.End) {
        if (e == null && cb == null) {
            throw "Nothing specified";
        }
        if (e == null) {
            e = cb.expr;
        }
        
        switch (expr.expr) {
            case EBlock(el):
                if (where == CodePos.Start) {
                    el.unshift(e);
                } else if (where == CodePos.End) {
                    if (isLastLineReturn() == true) {
                        el.insert(el.length - 1, e);
                    } else {
                        el.push(e);
                    }
                } else {
                    el.insert(where, e);
                }
            case _:    
                throw "NOT IMPL! - " + expr;
                return;
        }
    }
    
    private function isLastLineReturn():Bool {
        var r = false;
        
        switch (expr.expr) {
            case EBlock(el):
                var l = el[el.length - 1];
                if (l != null) {
                    switch (l.expr) {
                        case EReturn(_):
                            r = true;
                        case _:    
                    }
                }
            case _:    
                trace("NOT IMPL!");
        }
        
        return r;
    }
    
    public function toString() {
        return ExprTools.toString(expr);
    }
}