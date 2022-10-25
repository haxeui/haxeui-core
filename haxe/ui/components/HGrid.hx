package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.layouts.HorizontalGridLayout;

//@:dox(icon="")  //TODO
/**
 * A grid that lays out its children horizontally.
 */
class HGrid extends Component {

    /**
     * Creates a new horizontal grid with a single row.
     */
    public function new() {
        super();

        rows = 1;
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayoutClass = HorizontalGridLayout;
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _rows:Int;

    /**
     * The number of rows in this grid. Defaults to `1`.
     */
    @:clonable public var rows(get, set):Int;
    private function get_rows():Int {
        return _rows;
    }

    private function set_rows(value:Int):Int {
        if (_rows != value) {
            _rows = value;

            cast(layout, HorizontalGridLayout).rows = value;
            invalidateComponentLayout();
        }
        return value;
    }
}
