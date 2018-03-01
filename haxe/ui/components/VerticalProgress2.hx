package haxe.ui.components;

class VerticalProgress2 extends Progress2 {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (width <= 0) {
            width = 20;
        }
        if (height <= 0) {
            height = 150;
        }
    }
    
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new VerticalRange.VerticalRangeLayout();
        defaultBehaviour("posFromCoord", new VerticalRange.VerticalRangePosFromCoord(this));
    }
}
