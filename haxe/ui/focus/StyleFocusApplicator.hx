package haxe.ui.focus;

import haxe.ui.core.Component;

class StyleFocusApplicator extends FocusApplicator {
    public override function apply(target:Component):Void {
        target.addClass(":active");
    }
    
    public override function unapply(target:Component):Void {
        target.removeClass(":active");
    }
}