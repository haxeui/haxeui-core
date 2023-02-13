package haxe.ui.locale;

using StringTools;

class LocaleString {
    public var id:String;

    private var parts:Array<LocaleStringPart> = [];

    public function new() {
    }

    public function build(param0:Dynamic = null, param1:Dynamic = null, param2:Dynamic = null, param3:Dynamic = null):String {
        var result = null;

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
            if (param0 != null) result = result.replace("[0]", Std.string(param0));
            if (param1 != null) result = result.replace("[1]", Std.string(param1));
            if (param2 != null) result = result.replace("[2]", Std.string(param2));
            if (param3 != null) result = result.replace("[3]", Std.string(param3));
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
    }
}

private enum LocaleStringPart {
    Literal(s:String);
    ExpressionBlock(expr:LocaleStringExpressionBlock);
}