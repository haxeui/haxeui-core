package haxe.ui.core;

import haxe.ui.util.Variant;

class LayoutBehaviour extends DataBehaviour { // TODO: this should replace InvalidatingBehaviour
   public override function set(value:Variant) {
        if (value != get()) {
            super.set(value);
            _component.invalidateLayout();
        }
    }
}
