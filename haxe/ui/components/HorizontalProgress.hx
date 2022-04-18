package haxe.ui.components;

import haxe.ui.geom.Point;

/**
 * A horizontal progress bar.
 */
@:composite(HorizontalRange.HorizontalRangeLayout)
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
