package haxe.ui.components;

class HorizontalProgress2 extends Progress2 {
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (width <= 0) {
            width = 150;
        }
        if (height <= 0) {
            height = 20;
        }
    }
    
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new HorizontalRange.HorizontalRangeLayout();
        defaultBehaviour("posFromCoord", new HorizontalRange.HorizontalRangePosFromCoord(this));
    }
}
