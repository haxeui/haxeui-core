package haxe.ui.containers;

import haxe.ui.layouts.VerticalGridLayout;

/**
 A `Grid` component that lays its children out horizontally or vertically
**/
class Grid extends Box {
    public function new() {
        super();
        layout = new VerticalGridLayout();
        cast(_layout, VerticalGridLayout).columns = 4;
    }
    
    public var columns(get, set):Int;
    private function get_columns():Int {
        return cast(_layout, VerticalGridLayout).columns;
    }
    private function set_columns(value:Int):Int {
        cast(_layout, VerticalGridLayout).columns = value;
        return value;
    }
}