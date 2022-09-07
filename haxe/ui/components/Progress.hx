package haxe.ui.components;

import haxe.ui.components.Range.RangeBuilder;
import haxe.ui.core.Component;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.behaviours.ValueBehaviour;
import haxe.ui.core.IValueComponent;
import haxe.ui.util.Variant;

/**
 * A progress bar that starts from 0 and ends at 100.
 */
@:composite(ProgressBuilder)
class Progress extends Range implements IDirectionalComponent implements IValueComponent {

    /**
     * Creates a new progress bar.
     */
    private function new() {
        super();
        behaviours.updateOrder = ["min", "max", "pos", "indeterminate"];
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    @:clonable @:behaviour(Indeterminate)      public var indeterminate:Bool;

    /**
     * The current position of the progress bar. the bar will be filled from 0 to this value.
     */
    @:clonable @:behaviour(Pos)                public var pos:Float;

    /**
     * The minimum value of the progress bar.
     */
    @:clonable @:behaviour(Min)                public var min:Float;

    /**
     * The current position of the progress bar.
     *
     * `value` is a universal way to access the value a component is based on.
     * In this case, value represents the current position of the progress bar.
     */
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

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class ProgressBuilder extends RangeBuilder {
}