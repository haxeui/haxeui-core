package haxe.ui.styles.elements;
import haxe.ui.core.Screen;

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
    
    public function relevant():Bool {
        var b = true;
        for (d in _directives) {
            switch (d.directive) {
                case "min-width":
                    b = b && (Screen.instance.width > ValueTools.calcDimension(d.value));
                case "max-width":
                    b = b && (Screen.instance.width < ValueTools.calcDimension(d.value));
            }
        }
        return b;
    }
    
    public function styleSheet():StyleSheet {
        return _styleSheet;
    }
}
