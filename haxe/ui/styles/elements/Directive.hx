package haxe.ui.styles.elements;

import haxe.ui.styles.Value;

class Directive {
    public var directive:String = null;
    public var value:Value = null;
    public var defective:Bool = false;
    
    public function new(directive:String, value:Value, defective:Bool = false) {
        this.directive = directive;
        this.value = value;
        this.defective = defective;
    }
    
    /*
    private function parseValue(s:String):Value {
        var v = null;
        
        if (StringTools.endsWith(s, "%") == true) {
            v = Value.VDimension(Dimension.PERCENT(Std.parseFloat(s)));
        } else if (StringTools.endsWith(s, "px") == true) {
            v = Value.VDimension(Dimension.PX(Std.parseFloat(s)));
        } else if (StringTools.endsWith(s, "vw") == true) {
            v = Value.VDimension(Dimension.VW(Std.parseFloat(s)));
        } else if (StringTools.endsWith(s, "vh") == true) {
            v = Value.VDimension(Dimension.VH(Std.parseFloat(s)));
        } else if (StringTools.endsWith(s, "rem") == true) {
            v = Value.VDimension(Dimension.REM(Std.parseFloat(s)));
        } else if (s.indexOf("(") != -1 && StringTools.endsWith(s, ")")) {    
            var n = s.indexOf("(");
            var f = s.substr(0, n);
            var params = s.substr(n + 1, s.length - n - 2);
            if (f == "calc") {
                params = "'" + params + "'";
            }
            var vl = [];
            for (p in params.split(",")) {
                p = StringTools.trim(p);
                vl.push(parseValue(p));
            }
            v = Value.VCall(f, vl);
        } else if (StringTools.startsWith(s, "\"") && StringTools.endsWith(s, "\"")) {
            v = Value.VString(s.substr(1, s.length - 2));
        } else if (StringTools.startsWith(s, "'") && StringTools.endsWith(s, "'")) {
            v = Value.VString(s.substr(1, s.length - 2));
        } else if (Math.isNaN(Std.parseFloat(s)) == false) {
            v = Value.VNumber(Std.parseFloat(s));
        } else if (s == "true" || s == "false") {
            v = Value.VBool(s == "true");
        } else {
            v = Value.VConstant(s);
        }
        
        return v;
    }
    */
}
