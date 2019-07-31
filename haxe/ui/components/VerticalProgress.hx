package haxe.ui.components;

import haxe.ui.geom.Point;

@:composite(VerticalRange.VerticalRangeLayout)
class VerticalProgress extends Progress {
    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(VerticalRange.VerticalRangePosFromCoord)     private override function posFromCoord(coord:Point):Float;
}
