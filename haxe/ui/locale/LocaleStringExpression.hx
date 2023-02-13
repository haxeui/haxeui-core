package haxe.ui.locale;

using StringTools;

class LocaleStringExpression {
    public var isDefault:Bool = false;
    public var varName:String;
    public var expression:LocalStringExpressionOperation;
    public var expressionResult:String;

    public function new() {
    }

    public function evaluate(vars:Dynamic):Bool {
        if (!Reflect.hasField(vars, varName)) {
            trace("WARNING: var '" + varName + "' not found");
            return false;
        }
        var varValue = Reflect.field(vars, varName);
        var result = eval(varValue, expression);
        return result;
    }

    // probably all needs a revision
    private function eval(varValue:Float, expr:LocalStringExpressionOperation):Any {
        return switch (expr) {
            case Equals(expr):
                varValue == eval(varValue, expr);
            case LessThan(expr):    
                varValue < cast eval(varValue, expr);
            case GreaterThan(expr):    
                varValue > cast eval(varValue, expr);
            case LessThanOrEquals(expr):    
                varValue <= cast eval(varValue, expr);
            case GreaterThanOrEquals(expr):    
                varValue >= cast eval(varValue, expr);
            case Range(start, end):  
                (varValue >= start && varValue <= end);
            case Value(value):
                value;
            case List(values): // this seems screwy, returning the list item so Equal will match it
                var found = null;
                for (v in values) {
                    if (v == varValue) {
                        found = v;
                        break;
                    }
                }
                found;
            case Modulus(modulus, expr):
                var r = varValue % modulus;
                eval(r, expr);
        }
    }

    public function parse(s:String) {
        s = s.trim();

        var n = s.indexOf(":");
        if (n == -1) {
            return;
        }

        var expr = s.substring(0, n).trim();
        expressionResult = s.substring(n + 1).trim();

        if (expr == "_") {
            isDefault = true;
            return;
        }

        var n = -1;
        for (i in 0...expr.length) {
            var ch = expr.charAt(i);
            switch (ch) {
                case "=" | "<" | ">" | "%" | " ":
                    n = i;
                    break;
                case _:    
            }
        }

        if (n == -1) {
            return;
        }

        varName = expr.substring(0, n).trim();
        expr = expr.substring(n).trim();
        expression = parseExpression(expr);
    }

    private function parseExpression(s:String):LocalStringExpressionOperation {
        var expression = null;
        s = s.trim();
        if (s.startsWith(">=")) {
            expression = GreaterThanOrEquals(parseExpression(s.substring(2)));
        } else if (s.startsWith("<=")) {
            expression = LessThanOrEquals(parseExpression(s.substring(2)));
        } else if (s.startsWith(">")) {
            expression = GreaterThan(parseExpression(s.substring(1)));
        } else if (s.startsWith("<")) {
            expression = LessThan(parseExpression(s.substring(1)));
        } else if (s.startsWith("=")) {
            expression = Equals(parseExpression(s.substring(1)));
        } else if (s.startsWith("mod ")) {
            var mod = s.substring(3).trim();
            var n = -1;
            for (i in 0...mod.length) {
                var ch = mod.charAt(i);
                switch (ch) {
                    case "=" | "<" | ">" | "%" | " ":
                        n = i;
                        break;
                    case _:    
                }
            }
            if (n != -1) {
                var rest = mod.substring(n);
                var mod = mod.substring(0, n).trim();
                expression = Modulus(Std.parseFloat(mod), parseExpression(rest));
            }
        } else if (s.startsWith("in ")) {
            var range = s.substr(2).trim().split("...");
            expression = Range(Std.parseFloat(range[0]), Std.parseFloat(range[1]));
        } else if (s.indexOf("|") != -1) {
            var valueParts = s.split("|");
            var values = [];
            for (p in valueParts) {
                p = p.trim();
                if (p.length == 0) {
                    continue;
                }
                values.push(Std.parseFloat(p));
            }
            expression = List(values);
        } else {
            expression = Value(Std.parseFloat(s));
        }
        return expression;
    }
}

private enum LocalStringExpressionOperation {
    Equals(expr:LocalStringExpressionOperation);
    LessThan(expr:LocalStringExpressionOperation);
    GreaterThan(expr:LocalStringExpressionOperation);
    LessThanOrEquals(expr:LocalStringExpressionOperation);
    GreaterThanOrEquals(expr:LocalStringExpressionOperation);
    Range(start:Float, end:Float);
    Modulus(modulus:Float, expr:LocalStringExpressionOperation);
    List(values:Array<Float>);
    Value(value:Float);
}