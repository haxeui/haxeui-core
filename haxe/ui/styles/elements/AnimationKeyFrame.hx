package haxe.ui.styles.elements;

import haxe.ui.styles.Value;

class AnimationKeyFrame {
    public var time:Value;
    
    public var style:Style2;
    
    public function new() {
        style = {};
    }
    
    private var _directives:Array<Directive>;
    public var directives(get, set):Array<Directive>;
    private function get_directives():Array<Directive> {
        return _directives;
    }
    private function set_directives(value:Array<Directive>):Array<Directive> {
        _directives = value;
        style = {};
        for (d in _directives) {
            StyleUtils.processDirective(style, d);
        }
        return value;
    }
}