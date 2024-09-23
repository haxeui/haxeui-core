package haxe.ui.util;
import haxe.ui.util.Defines;

using StringTools;

enum SimpleExpressionEvaluatorOperation {
    Add;                    // +
    Subtract;               // -
    Multiply;               // *
    Divide;                 // /
    Equals;                 // ==
    NotEquals;              // !=
    GreaterThan;            // >
    GreaterThanOrEquals;    // >=
    LessThan;               // <
    LessThanOrEquals;       // <=
    LogicalAnd;             // &&
    LogicalOr;              // ||
}

class SimpleExpressionEvaluator {
    public static function evalCondition(condition:String):Bool {
        return eval(condition, {
            Backend: Backend,
            backend: Backend.id,
            defined: defined
        });
    }

    public static function defined(key:String):Bool {
        return return Defines.getAll().exists(key);
    }
    
    public static function eval(s:String, context:Dynamic = null):Dynamic {
        var r:Dynamic = null;
        
        if (s.indexOf("||") != -1) {
            var parts = s.split("||");
            for (p in parts) {
                if (r == null) {
                    r = evalSingle(p.trim(), context);
                } else {
                    r = r || evalSingle(p.trim(), context);
                }
            }
        } else if (s.indexOf("&&") != -1) {
            var parts = s.split("&&");
            for (p in parts) {
                if (r == null) {
                    r = evalSingle(p.trim(), context);
                } else {
                    r = r && evalSingle(p.trim(), context);
                }
            }
        } else {
            r = evalSingle(s, context);
        }
        return r;
    }
    
    private static function evalSingle(s:String, context:Dynamic = null):Dynamic {
        var result:Dynamic = null;

        var operation:SimpleExpressionEvaluatorOperation = null;
        var token = "";
        var inString = false;
        for (i in 0...s.length) {
            var ch = s.charAt(i);
            var next = s.charAt(i + 1);
            
            if (ch == "'" || ch == "\"") {
                inString = !inString;
            }
            
            if (inString == false) {
                if (ch == "+") {
                    operation = Add;
                    s = s.substr(i + 1);
                    break;
                } else if (ch == "-") {
                    operation = Subtract;
                    s = s.substr(i + 1);
                    break;
                } else if (ch == "*") {
                    operation = Multiply;
                    s = s.substr(i + 1);
                    break;
                } else if (ch == "/") {
                    operation = Divide;
                    s = s.substr(i + 1);
                    break;
                } else if (ch == ">" && next != "=") {
                    operation = GreaterThan;
                    s = s.substr(i + 1);
                    break;
                } else if (ch == "<" && next != "=") {
                    operation = LessThan;
                    s = s.substr(i + 1);
                    break;
                } else if (ch == "=" && next == "=") {
                    operation = Equals;
                    s = s.substr(i + 2);
                    break;
                } else if (ch == "!" && next == "=") {
                    operation = NotEquals;
                    s = s.substr(i + 2);
                    break;
                } else if (ch == ">" && next == "=") {
                    operation = GreaterThanOrEquals;
                    s = s.substr(i + 2);
                    break;
                } else if (ch == "<" && next == "=") {
                    operation = LessThanOrEquals;
                    s = s.substr(i + 2);
                    break;
                } else if (ch == "&" && next == "&") {
                    operation = LogicalAnd;
                    s = s.substr(i + 2);
                    break;
                } else if (ch == "|" && next == "|") {
                    operation = LogicalOr;
                    s = s.substr(i + 2);
                    break;
                }
            }
            
            token += ch;
            if (i == s.length - 1) { // end
                s = "";
                break;
            }
        }
        
        var r:Dynamic = null;
        if (s.length > 0) {
            r = evalSingle(s, context);
        }
        
        var trimmedToken = token.trim();
        if (isNum(trimmedToken)) {
            result = Std.parseFloat(trimmedToken);
        } else if (isBool(trimmedToken)) {
            result = (trimmedToken.toLowerCase() == "true");
        } else if (isString(trimmedToken)) {
            result = trimmedToken.substr(1, trimmedToken.length - 2);
        } else { // object / var / function
            var token = "";
            var bracketsOpen = 0;
            var call = null;
            var callParams = null;
            for (i in 0...trimmedToken.length) {
                var ch = trimmedToken.charAt(i);
                if (ch == "(") {
                    bracketsOpen++;
                    if (bracketsOpen == 1) {
                        call = token;
                        token = "";
                    } else {
                        token += ch;
                    }
                } else if (ch == ")") {
                    bracketsOpen--;
                    if (bracketsOpen == 0) {
                        callParams = token;
                    } else {
                        token += ")";
                    }
                } else {                
                    token += ch;
                }
            }
            
            var prop = null;
            if (call == null) {
                prop = token;
            }
            
            var parsedCallParams:Array<String> = [];
            if (callParams != null) {
                bracketsOpen = 0;
                token = "";
                for (i in 0...callParams.length) {
                    var ch = callParams.charAt(i);
                    if (ch == "(") {
                        bracketsOpen++;
                    } else if (ch == ")") {
                        bracketsOpen--;
                    }
                    
                    if (ch == ",") {
                        if (bracketsOpen == 0) {
                            parsedCallParams.push(token);
                            token = "";
                        } else {
                            token += ch;
                        }
                    } else {
                        token += ch;
                    }
                }
                
                if (token.length != 0) {
                    parsedCallParams.push(token);
                }
            }
            
            if (call != null) {
                var trimmedCall = call.trim();
                if (trimmedCall.length > 0) {
                    var callParts = trimmedCall.split(".");
                    var ref:Dynamic = context;
                    var prevRef:Dynamic = null;
                    for (callPart in callParts) {
                        prevRef = ref;
                        if (Reflect.hasField(ref, callPart)) {
                            ref = Reflect.field(ref, callPart);
                        } else {
                            ref = Reflect.getProperty(ref, callPart);
                        }
                        
                        if (ref == null) {
                            throw callPart + " not found";
                        }
                    }
                    
                    if (ref != null && Reflect.isFunction(ref)) {
                        var paramValues = [];
                        for (param in parsedCallParams) {
                            var paramResult = evalSingle(param, context);
                            paramValues.push(paramResult);
                        }
                        result = Reflect.callMethod(prevRef, ref, paramValues);
                    }
                }
            } else if (prop != null) {
                var trimmedProp = prop.trim();
                if (trimmedProp.length > 0) {
                    var propParts = trimmedProp.split(".");
                    var propName = propParts.pop();
                    var ref:Dynamic = context;
                    for (propPart in propParts) {
                        ref = Reflect.field(ref, propPart);
                    }
                    if (propName != null) {
                        if (Reflect.hasField(ref, propName)) {
                            result = Reflect.field(ref, propName);
                        } else {
                            #if js
                            var getter = js.Syntax.field(ref, "get_" + propName);
                            if (getter != null) {
                                result = js.Syntax.field(ref, "get_" + propName)();
                            }
                            #else
                            result = Reflect.getProperty(ref, propName);
                            #end
                        }
                    }
                }
            }
        }
        
        if (operation != null) {
            if (r != null) {
                switch (operation) {
                    case Add:
                        result = result + r;
                    case Subtract:
                        result = result - r;
                    case Multiply:
                        result = result * r;
                    case Divide:
                        result = result / r;
                    case Equals:
                        result = result == r;
                    case NotEquals:
                        result = result != r;
                    case GreaterThan:
                        result = result > r;
                    case GreaterThanOrEquals:
                        result = result >= r;
                    case LessThan:
                        result = result < r;
                    case LessThanOrEquals:
                        result = result <= r;
                    case LogicalAnd:
                        result = result && r;
                    case LogicalOr:
                        result = result || r;
                }
            } else {
                switch (operation) {
                    case Equals:
                        result = result == r;
                    case NotEquals:    
                        result = result != r;
                    case _:    
                }
            }
        }
        
        return result;
    }
    
    private static inline function isNum(value:String) {
        var v = Std.parseFloat(value);
        return return !Math.isNaN(v) && Math.isFinite(v);
    }
    
    private static inline function isString(value:String) {
        if (value.startsWith("'") && value.endsWith("'")) {
            return true;
        }
        if (value.startsWith("\"") && value.endsWith("\"")) {
            return true;
        }
        return false;
    }
    
    private static inline function isBool(value:String) {
        value = value.toLowerCase();
        return (value == "true" || value == "false");
    }
}
