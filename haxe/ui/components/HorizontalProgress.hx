package haxe.ui.components;

import haxe.ui.components.Progress.ProgressBuilder;
import haxe.ui.geom.Point;

/**
 * A horizontal progress bar.
 */
@:composite(HorizontalRange.HorizontalRangeLayout, Builder)
class HorizontalProgress extends Progress {

    /**
     * Creates a new progress bar with built-in horizontal layout.
     */
    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(HorizontalRange.HorizontalRangePosFromCoord)     private override function posFromCoord(coord:Point):Float;
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends ProgressBuilder {
    private override function showWarning() { // do nothing
    }
}