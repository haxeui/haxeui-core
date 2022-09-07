package haxe.ui.components;

import haxe.ui.components.Progress.ProgressBuilder;
import haxe.ui.geom.Point;

@:composite(VerticalRange.VerticalRangeLayout, Builder)
class VerticalProgress extends Progress {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(VerticalRange.VerticalRangePosFromCoord)     private override function posFromCoord(coord:Point):Float;
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends ProgressBuilder {
    private override function showWarning() { // do nothing
    }
}