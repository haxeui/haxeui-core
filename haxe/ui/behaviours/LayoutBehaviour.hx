package haxe.ui.behaviours;

import haxe.ui.util.Variant;

@:dox(hide) @:noCompletion
class LayoutBehaviour extends ValueBehaviour {
    public override function set(value:Variant) {
        if (value == get()) {
            return;
        }

        super.set(value);
        _component.invalidateComponentLayout();
    }
}
