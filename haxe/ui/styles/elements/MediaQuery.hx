package haxe.ui.styles.elements;

import haxe.ui.core.Screen;
import haxe.ui.styles.StyleSheet;

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
                    b = b && (Screen.instance.width > ValueTools.calcDimension(d.value));
                case "max-width":
                    b = b && (Screen.instance.width < ValueTools.calcDimension(d.value));
                case "min-height":
                    b = b && (Screen.instance.height > ValueTools.calcDimension(d.value));
                case "max-height":
                    b = b && (Screen.instance.height < ValueTools.calcDimension(d.value));
                case "min-aspect-ratio":
                    var sr = Screen.instance.width / Screen.instance.height;
                    b = b && (sr > buildRatio(ValueTools.string(d.value)));
                case "max-aspect-ratio":
                    var sr = Screen.instance.width / Screen.instance.height;
                    b = b && (sr < buildRatio(ValueTools.string(d.value)));
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

    private function buildRatio(s:String):Float {
        var p = s.split("/");
        var w = Std.parseInt(StringTools.trim(p[0]));
        var h = Std.parseInt(StringTools.trim(p[1]));
        return w / h;
    }

    public var styleSheet(get, null):StyleSheet;
    private function get_styleSheet():StyleSheet {
        return _styleSheet;
    }
}
