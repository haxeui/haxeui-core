package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.IClonable;
import haxe.ui.layouts.HorizontalGridLayout;

//@:dox(icon="")  //TODO
class HGrid extends Component implements IClonable<HGrid> {
    public function new() {
        super();

        rows = 1;
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        _defaultLayout = new HorizontalGridLayout();
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _rows:Int;
    @:clonable public var rows(get, set):Int;
    private function get_rows():Int {
        return _rows;
    }

    private function set_rows(value:Int):Int {
        if(_rows != value)
        {
            _rows = value;

            cast(layout, HorizontalGridLayout).rows = value;
            invalidateLayout();
        }
        return value;
    }
}
