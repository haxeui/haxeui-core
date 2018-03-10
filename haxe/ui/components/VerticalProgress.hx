package haxe.ui.components;

class VerticalProgress extends Progress {
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (componentWidth <= 0) {
            componentWidth = 20;
        }
        if (componentHeight <= 0) {
            componentHeight = 150;
        }
    }
    
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new VerticalRange.VerticalRangeLayout();
        defaultBehaviour("posFromCoord", new VerticalRange.VerticalRangePosFromCoord(this));
    }
}
