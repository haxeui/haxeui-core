package haxe.ui.components;

class VerticalProgress2 extends Progress2 {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new VerticalRange.VerticalRangeLayout();
    }
}
