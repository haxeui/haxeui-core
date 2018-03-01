package haxe.ui.components;

class HorizontalProgress2 extends Progress2 {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new HorizontalRange.HorizontalRangeLayout();
        defaultBehaviour("posFromCoord", new HorizontalRange.HorizontalRangePosFromCoord(this));
    }
}
