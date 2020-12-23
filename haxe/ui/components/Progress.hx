package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.behaviours.ValueBehaviour;
import haxe.ui.util.Variant;

class Progress extends Range implements IDirectionalComponent {
    public function new() {
        super();
         behaviours.updateOrder = ["min", "max", "pos", "indeterminate"];
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(Indeterminate)      public var indeterminate:Bool;
    @:clonable @:behaviour(Pos)                public var pos:Float;
    @:clonable @:behaviour(Min)                public var min:Float;
    @:clonable @:value(pos)                    public var value:Dynamic;

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function get_cssName():String {
        return "progress";
    }
}

//***********************************************************************************************************
// Default Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Pos extends DefaultBehaviour {
    public override function get():Variant {
        var progress = cast(_component, Progress);
        return progress.end;
    }

    public override function set(value:Variant) {
        var progress = cast(_component, Progress);
        progress.end = value;
    }
}

@:dox(hide) @:noCompletion
private class Min extends DefaultBehaviour {
    public override function set(value:Variant) {
        var progress = cast(_component, Progress);
        //progress.min = value;
        progress.start = value;
    }
}

@:dox(hide) @:noCompletion
private class Indeterminate extends ValueBehaviour {
    public function new(component:Component) {
        super(component);
    }

    public override function get():Variant {
        return _value;
    }

    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }

        super.set(value);

        if (value == false) {
            _component.removeClass(":indeterminate");
        } else {
            _component.addClass(":indeterminate");
        }

    }

    public override function detatch() {
        super.detatch();
        _component.removeClass(":indeterminate");
    }
}