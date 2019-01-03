package haxe.ui.behaviours;

import haxe.ui.util.Variant;

@:dox(hide) @:noCompletion
class LayoutBehaviour extends ValueBehaviour {
   public override function set(value:Variant) {
       if (value == get()) {
           return;
       }

       _value = value;
       _component.invalidateComponentLayout();
    }
}
