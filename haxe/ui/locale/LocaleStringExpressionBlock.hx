package haxe.ui.locale;

using StringTools;

class LocaleStringExpressionBlock {
    public var expressions:Array<LocaleStringExpression> = [];

    public function new() {

    }

    public function evaluate(param0:Dynamic = null, param1:Dynamic = null, param2:Dynamic = null, param3:Dynamic = null):String {
        var result:String = null;

        for (expr in expressions) {
            if (expr.isDefault) {
                continue;
            }
            if (expr.evaluate(param0, param1, param2, param3) == true) {
                result = expr.expressionResult;
                break;
            }
        }

        if (result == null) {
            var defaultExpression = findDefaultExpression();
            if (defaultExpression != null) {
                result = defaultExpression.expressionResult;
            }
        }

        return result;
    }

    private function findDefaultExpression():LocaleStringExpression {
        for (expr in expressions) {
            if (expr.isDefault) {
                return expr;
            }
        }
        return null;
    }

    public function parse(s:String) {
        expressions = [];
        s = s.trim();
        var lines = s.split("\n");
        for (l in lines) {
            var expr = new LocaleStringExpression();
            expr.parse(l);
            expressions.push(expr);
        }
    }
}
