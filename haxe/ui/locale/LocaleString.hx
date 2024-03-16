package haxe.ui.locale;

using StringTools;

class LocaleString {
    public var id:String;

    private var parts:Array<LocaleStringPart> = [];

    // "simple" has no param placeholders, or expressions
    // this effectively means we can cache its result value
    // since it wont change (per locale)
    private var _isSimple:Bool = true;

    private var _cachedValue:String = null;

    public function new() {
    }

    public function build(param0:Dynamic = null, param1:Dynamic = null, param2:Dynamic = null, param3:Dynamic = null):String {
        if (_isSimple == true && _cachedValue != null) {
            return _cachedValue;
        }

        var result = null;

        switch (Type.typeof(param0)) {
            case TObject:
                if (param0 != null && param0.text != null) param0 = param0.text;
                if (param1 != null && param1.text != null) param1 = param1.text;
                if (param2 != null && param2.text != null) param2 = param2.text;
                if (param3 != null && param3.text != null) param3 = param3.text;
            case _:    
        }

        for (part in parts) {
            switch (part) {
                case Literal(s):
                    if (result == null) {
                        result = "";
                    }
                    result += s;
                case ExpressionBlock(expr):    
                    if (result == null) {
                        result = "";
                    }
                    result += expr.evaluate(param0, param1, param2, param3);
            }
        }

        if (result == null) {
            result = id;
        }

        if (result != null) {
            if (_isSimple == true) {
                if (result.indexOf("[0]") != -1) _isSimple = false;
                if (result.indexOf("[1]") != -1) _isSimple = false;
                if (result.indexOf("[2]") != -1) _isSimple = false;
                if (result.indexOf("[3]") != -1) _isSimple = false;
                if (result.indexOf("{{") != -1 && result.indexOf("}}") != -1) _isSimple = false;
            }

            if (param0 != null) result = result.replace("[0]", formatParam(param0));
            if (param1 != null) result = result.replace("[1]", formatParam(param1));
            if (param2 != null) result = result.replace("[2]", formatParam(param2));
            if (param3 != null) result = result.replace("[3]", formatParam(param3));
            
            var n1 = result.indexOf("{{");
            var beforePos = 0;
            while (n1 != -1) {
                var before = result.substring(beforePos, n1);
                var n2 = result.indexOf("}}", n1);
                var code = result.substring(n1 + 2, n2);
                var after = result.substring(n2 + 2);
                var subResult = LocaleManager.instance.lookupString(code);
                if (subResult != null) {
                    result = before + subResult + after;
                }
    
                n1 = result.indexOf("{{", n2);
                beforePos = n2 + 2;
            }

            if (_isSimple) {
                _cachedValue = result;
            }
        }

        return result;
    }

    public function parse(s:String) {
        parts = [];
        var n = s.indexOf("=");
        if (n == -1) {
            return;
        }

        id = s.substring(0, n).trim();
        s = s.substr(n + 1).trim();

        var inExpression:Bool = false;
        var part = "";
        for (i in 0...s.length) {
            var ch = s.charAt(i);
            switch (ch) {
                case "{":
                    if (part.length > 0) {
                        parts.push(Literal(part));
                    }
                    inExpression = true;
                    part = "";
                case "}":
                    if (part.length > 0) {
                        var block = new LocaleStringExpressionBlock();
                        block.parse(part);
                        parts.push(ExpressionBlock(block));
                    }
                    inExpression = false;
                    part = "";
                case _:
                    part += ch;
            }
        }
        if (part.length > 0) {
            parts.push(Literal(part));
        }

        for (part in parts) {
            switch (part) {
                case Literal(s):
                case ExpressionBlock(block):    
                    if (block.expressions != null && block.expressions.length > 0) {
                        _isSimple = false;
                        break;
                    }
            }
        }
    }

    function formatParam(param:Dynamic = null):String {
        if ((param is Float)) {
            return StringTools.replace(Std.string(param), ".", Formats.decimalSeparator);
        } else if ((param is Array)) {
            var arr:Array<Any> = param;
            return Std.string([for (x in arr) formatParam(x)]);
        }

        return Std.string(param);
    }
}

private enum LocaleStringPart {
    Literal(s:String);
    ExpressionBlock(block:LocaleStringExpressionBlock);
}