package haxe.ui.styles.elements;

import haxe.ui.core.Screen;
import haxe.ui.styles.StyleSheet;
import haxe.ui.styles.Value;

class MediaQuery {
    private var _directives:Array<Directive> = [];
    private var _styleSheet:StyleSheet;

    public function new(directives:Array<Directive>, styleSheet:StyleSheet) {
        _directives = directives;
        _styleSheet = styleSheet;
    }

    public function addDirective(el:Directive) {
        _directives.push(el);
    }

    public var relevant(get, null):Bool;
    private function get_relevant():Bool {
        var b = true;
        for (d in _directives) {
            switch (d.directive) {
                case "min-width":
                    b = b && (Screen.instance.width >= ValueTools.calcDimension(d.value));
                case "max-width":
                    b = b && (Screen.instance.width < ValueTools.calcDimension(d.value));
                case "min-height":
                    b = b && (Screen.instance.height >= ValueTools.calcDimension(d.value));
                case "max-height":
                    b = b && (Screen.instance.height < ValueTools.calcDimension(d.value));
                case "min-aspect-ratio":
                    var sr = Screen.instance.width / Screen.instance.height;
                    b = b && (sr >= buildRatio(d.value));
                case "max-aspect-ratio":
                    var sr = Screen.instance.width / Screen.instance.height;
                    b = b && (sr < buildRatio(d.value));
                case "orientation":
                    var v = ValueTools.string(d.value);
                    if (v == "landscape") {
                        b = b && (Screen.instance.width > Screen.instance.height);
                    } else if (v == "portrait") {
                        b = b && (Screen.instance.height > Screen.instance.width);
                    }
                case "backend":
                    b = b && (Backend.id == ValueTools.string(d.value));
                case _:
                    #if debug
                    trace('WARN: media query "${d.directive}" not recognized');
                    #end
            }
        }
        return b;
    }

    // returns NaN for an invalid ratio, which never compares true, so the query is not relevant
    private function buildRatio(value:Value):Float {
        var s = ratioString(value);
        if (s == null) {
            return Math.NaN;
        }
        var p = s.split("/");
        var w = Std.parseFloat(StringTools.trim(p[0]));
        var h = (p.length > 1) ? Std.parseFloat(StringTools.trim(p[1])) : 1.0;
        return w / h;
    }

    // "16/9" is parsed as a single constant, but "16 / 9" (also valid css) is parsed as a composite
    // of its parts and a lone number (eg: "2") as a number, so rebuild the ratio text from the value
    private function ratioString(value:Value):String {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VNumber(v):
                // repeated spaces produce empty parts, which are parsed as NaN numbers
                return Math.isNaN(v) ? "" : Std.string(v);
            case Value.VComposite(vl):
                var s = "";
                for (part in vl) {
                    var ps = ratioString(part);
                    if (ps == null) {
                        return null;
                    }
                    s += ps;
                }
                return s;
            case _:
                return ValueTools.string(value);
        }
    }

    public var styleSheet(get, null):StyleSheet;
    private function get_styleSheet():StyleSheet {
        return _styleSheet;
    }
}
