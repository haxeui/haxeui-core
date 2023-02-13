package haxe.ui.locale;

using StringTools;

class LocaleString {
    public var id:String;

    private var parts:Array<LocaleStringPart> = [];

    public function new() {
    }

    public function build(vars:Dynamic = null):String {
        if (vars == null) {
            vars = {};
        }
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
                    result += expr.evaluate(vars);
            }
        }

        if (result == null) {
            result = id;
        }

        if (result != null) {
            for (f in Reflect.fields(vars)) {
                result = result.replace("%" + f + "%", Reflect.field(vars, f));
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
    }
}

private enum LocaleStringPart {
    Literal(s:String);
    ExpressionBlock(expr:LocaleStringExpressionBlock);
}