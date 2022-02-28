package haxe.ui.focus;

import haxe.ui.core.Component;

class StyleFocusApplicator implements IFocusApplicator {
    public function new() {
    }
    
    public function apply(target:Component):Void {
        target.addClass(":active");
    }
    
    public function unapply(target:Component):Void {
        target.removeClass(":active");
    }
}