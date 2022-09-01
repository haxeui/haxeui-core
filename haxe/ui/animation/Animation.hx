package haxe.ui.animation;

import haxe.ui.core.Component;

class Animation {
    public var target:Component;
    public function new(target:Component) {
        this.target = target;
    }
    
    public function build(builder:AnimationBuilder) {
    }
}