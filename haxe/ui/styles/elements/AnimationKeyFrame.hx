package haxe.ui.styles.elements;

import haxe.ui.styles.Value;

class AnimationKeyFrame {
    public var time:Value;

    public var directives:Array<Directive>;

    public function new() {
    }
    
    public function set(directive:Directive) {
        var found:Bool = false;
        for (d in directives) {
            if (d.directive == directive.directive) {
                d.value = directive.value;
                found = true;
            }
        }
        if (found == false) {
            directives.push(directive);
        }
    }
    
    public function find(id:String) {
        for (d in directives) {
            if (d.directive == id) {
                return d;
            }
        }
        return null;
    }
    
    public function clear() {
        directives = [];
    }
}