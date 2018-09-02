package haxe.ui.components;

class HorizontalProgress extends Progress {
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (componentWidth <= 0) {
            componentWidth = 150;
        }
        if (componentHeight <= 0) {
            componentHeight = 20;
        }
    }
    
    private override function createDefaults() { // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayoutClass = HorizontalRange.HorizontalRangeLayout;
        defaultBehaviour("posFromCoord", new HorizontalRange.HorizontalRangePosFromCoord(this));
    }
}
