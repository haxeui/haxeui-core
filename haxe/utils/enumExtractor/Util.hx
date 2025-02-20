package haxe.utils.enumExtractor;

import haxe.macro.Expr;

class Util {
    public static function removeIfMeta(e:Expr):Expr {
        return switch(e) {
            case null:
                null;
            case macro @if $c:
                return c;
            default:
                e;
        }
    }
}