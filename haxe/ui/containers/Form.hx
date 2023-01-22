package haxe.ui.containers;

import haxe.ui.layouts.VerticalGridLayout;

class Form extends Box {
    public function new() {
        super();
        if (_columns == -1) { // dont set it if its already been set
            columns = 2;
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _columns:Int = -1;
    @:clonable public var columns(get, set):Int;
    private function get_columns():Int {
        if (!(_layout is VerticalGridLayout)) {
            return -1;
        }
        return cast(_layout, VerticalGridLayout).columns;
    }
    private function set_columns(value:Int):Int {
        if (_layout == null) {
            layout = createLayout();
        }

        if (!(_layout is VerticalGridLayout)) {
            layout = new VerticalGridLayout();
        }

        cast(_layout, VerticalGridLayout).columns = value;
        _columns = value;
        return value;
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayoutClass = VerticalGridLayout;
    }
}