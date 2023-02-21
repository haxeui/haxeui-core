package haxe.ui.locale;

using StringTools;

class LocaleStringExpression {
    public var isDefault:Bool = false;
    public var varName:String;
    public var expression:LocalStringExpressionOperation;
    public var expressionResult:String;

    public function new() {
    }

    public function evaluate(param0:Dynamic = null, param1:Dynamic = null, param2:Dynamic = null, param3:Dynamic = null):Bool {
        if (expression == null) {
            return false;
        }

        var varValue = param0;
        if (varName == "[0]") varValue = param0;
        if (varName == "[1]") varValue = param1;
        if (varName == "[2]") varValue = param2;
        if (varName == "[3]") varValue = param3;

        var result = eval(varValue, expression);
        return result;
    }

    // probably all needs a revision
    private function eval(varValue:Dynamic, expr:LocalStringExpressionOperation):Any {
        return switch (expr) {
            case Equals(expr):
                var r = false;
                if (Type.typeof(varValue) == TFloat) {
                    var floatValue:Float = varValue;
                    var floatResult:Float = Std.parseFloat(Std.string(eval(floatValue, expr)));
                    r = floatValue == floatResult;
                } else if (Type.typeof(varValue) == TInt) {
                    var intValue:Int = varValue;
                    var intResult:Int = Std.parseInt(Std.string(eval(intValue, expr)));
                    r = intValue == intResult;
                } else {
                    var stringValue:String = Std.string(varValue);
                    var stringResult:String = Std.string(eval(stringValue, expr));
                    r = stringValue == stringResult;
                }
                r;
            case LessThan(expr):    
                var r = false;
                if (Type.typeof(varValue) == TFloat) {
                    var floatValue:Float = varValue;
                    var floatResult:Float = Std.parseFloat(Std.string(eval(floatValue, expr)));
                    r = floatValue < floatResult;
                } else if (Type.typeof(varValue) == TInt) {
                    var intValue:Int = varValue;
                    var intResult:Int = Std.parseInt(Std.string(eval(intValue, expr)));
                    r = intValue < intResult;
                }
                r;
            case GreaterThan(expr):    
                var r = false;
                if (Type.typeof(varValue) == TFloat) {
                    var floatValue:Float = varValue;
                    var floatResult:Float = Std.parseFloat(Std.string(eval(floatValue, expr)));
                    r = floatValue > floatResult;
                } else if (Type.typeof(varValue) == TInt) {
                    var intValue:Int = varValue;
                    var intResult:Int = Std.parseInt(Std.string(eval(intValue, expr)));
                    r = intValue > intResult;
                }
                r;
            case LessThanOrEquals(expr):    
                var r = false;
                if (Type.typeof(varValue) == TFloat) {
                    var floatValue:Float = varValue;
                    var floatResult:Float = Std.parseFloat(Std.string(eval(floatValue, expr)));
                    r = floatValue <= floatResult;
                } else if (Type.typeof(varValue) == TInt) {
                    var intValue:Int = varValue;
                    var intResult:Int = Std.parseInt(Std.string(eval(intValue, expr)));
                    r = intValue <= intResult;
                }
                r;
            case GreaterThanOrEquals(expr):    
                var r = false;
                if (Type.typeof(varValue) == TFloat) {
                    var floatValue:Float = varValue;
                    var floatResult:Float = Std.parseFloat(Std.string(eval(floatValue, expr)));
                    r = floatValue >= floatResult;
                } else if (Type.typeof(varValue) == TInt) {
                    var intValue:Int = varValue;
                    var intResult:Int = Std.parseInt(Std.string(eval(intValue, expr)));
                    r = intValue >= intResult;
                }
                r;
            case Range(start, end):  
                (varValue >= start && varValue <= end);
            case Value(value):
                value;
            case List(values): // this seems screwy, returning the list item so Equal will match it
                var found:Null<Float> = null;
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

        expression = extractExpression(expr);
        if (expression == null) {
            var replacement = LocaleManager.instance.lookupString(expr);
            if (replacement != null) {
                expression = extractExpression(replacement);
            }
        }
    }

    private function extractExpression(expr:String):LocalStringExpressionOperation {
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
            return null;
        }

        varName = expr.substring(0, n).trim();
        expr = expr.substring(n).trim();
        var expression = parseExpression(expr);
        return expression;
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
            expression = Value(s);
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
    Value(value:Any);
}