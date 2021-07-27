package haxe.ui.macros.helpers;

import haxe.macro.Expr;
import haxe.macro.ExprTools;

class CodeBuilder {
    public var expr:Expr = null;

    public function new(expr:Expr = null) {
        if (expr == null) {
            expr = macro {};
        }
        this.expr = expr;
    }

    function findSuper(exprs:Array<Expr>):Null<Int> {
        var result:Null<Int> = null;
        for (pos in 0...exprs.length) {
            var expr = exprs[pos];
            switch (expr.expr) {
                case ECall({expr: EConst(CIdent("super")), pos:_}, params):
                    result = pos;
                    break;
                default:
            }
        }
        return result;
    }

    public function addToStart(e:Expr = null, cb:CodeBuilder = null) {
        add(e, cb, CodePos.Start);
    }
    
    public function add(e:Expr = null, cb:CodeBuilder = null, where:CodePos = null) {
        if (where == null) {
            where = CodePos.End;
        }
        if (e == null && cb == null) {
            throw "Nothing specified";
        }
        if (e == null) {
            e = cb.expr;
        }

        switch (expr.expr) {
            case EBlock(el):
                switch (where) {
                    case Start:
                        el.unshift(e);
                    case End:
                        if (isLastLineReturn() == true) {
                            el.insert(el.length - 1, e);
                        } else {
                            el.push(e);
                        }
                    case AfterSuper:
                        var superPos = findSuper(el);
                        if (superPos == null) {
                            throw 'super call not found in method at ${e.pos}';
                        } else {
                            el.insert(superPos + 1, e);
                        }
                    case Pos(pos):
                        el.insert(pos, e);
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

    public function toString():String {
        return ExprTools.toString(expr);
    }
}