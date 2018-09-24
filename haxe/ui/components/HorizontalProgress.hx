package haxe.ui.components;

import haxe.ui.util.Point;

@:composite(HorizontalRange.HorizontalRangeLayout)
class HorizontalProgress extends Progress {
    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(HorizontalRange.HorizontalRangePosFromCoord)     private override function posFromCoord(coord:Point):Float;
}
