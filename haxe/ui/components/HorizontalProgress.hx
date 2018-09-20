package haxe.ui.components;

@:composite(HorizontalRange.HorizontalRangeLayout)
class HorizontalProgress extends Progress {
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() { // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        defaultBehaviour("posFromCoord", new HorizontalRange.HorizontalRangePosFromCoord(this));
    }
}
