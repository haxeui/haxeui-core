package haxe.ui.util;

class ExpressionUtil {
    public static function stringToLanguageExpression(s:String, localeManager:String = "haxe.ui.locale.LocaleManager"):String {
        var fixedParts = [];
        var beforePos = 0;
        var n1 = s.indexOf("{{");
        while (n1 != -1) {
            var before = s.substring(beforePos, n1);
            if (before.length > 0) {
                fixedParts.push("'" + before + "'");
            }
            
            var n2 = s.indexOf("}}", n1);
            var code = s.substring(n1 + 2, n2);
            
            var parts = code.split(",");
            var stringId = parts.shift();
            var callString = localeManager + ".instance.lookupString('";
            callString += stringId;
            callString += "'";
            if (parts.length > 0) {
                callString += ", ";
                callString += parts.join(", ");
            }
            callString += ")";
            fixedParts.push(callString);
            
            n1 = s.indexOf("{{", n2);
            beforePos = n2 + 2;
        }
        if (beforePos < s.length) {
            var before = s.substring(beforePos, s.length);
            if (before.length > 0) {
                fixedParts.push("'" + before + "'");
            }
        }
        var fixedCode = fixedParts.join(" + ");
        return fixedCode;
    }
}