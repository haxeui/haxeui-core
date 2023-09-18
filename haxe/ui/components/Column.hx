package haxe.ui.components;

import haxe.ui.components.Button.ButtonEvents;
import haxe.ui.constants.SortDirection;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.SortEvent;
import haxe.ui.events.UIEvent;

@:composite(Events)
class Column extends Button {
    /**
     * The field on which the sortings will be based on.
     */
    public var sortField:String;
    
    /**
     * Whether this column should allow sorting or not.
     */
    public var sortable(get, set):Bool;
    private function get_sortable():Bool {
        return hasClass("sortable");
    }
    private function set_sortable(value:Bool):Bool {
        if (value == true) {
            addClass("sortable");
        } else {
            removeClass("sortable");
        }
        return value;
    }
    
    private var _sortDirection:String = null;

    /**
     * When sorting is enabled, this is the direction of the sort - can be either:
     * 
     *  - `SortDirection.ASCENDING`, `"asc"`
     *  - `SortDirection.DESCENDING`, `"desc"`
     *
     */
    public var sortDirection(get, set):SortDirection;
    private function get_sortDirection():SortDirection {
        return _sortDirection;
    }
    private function set_sortDirection(value:SortDirection):SortDirection {
        if (value == _sortDirection) {
            return value;
        }
        
        _sortDirection = value;
        sortable = true;
        if (_sortDirection == SortDirection.ASCENDING) {
            swapClass("sort-asc", "sort-desc");
        } else if (_sortDirection == SortDirection.DESCENDING) {
            swapClass("sort-desc", "sort-asc");
        } else if (sortDirection == null) {
            removeClasses(["sort-asc", "sort-desc"]);
        }
        
        return value;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends ButtonEvents  {
    private var _column:Column;
    
    public function new(column:Column) {
        super(column);
        _column = column;
        _column.registerEvent(MouseEvent.CLICK, onColumnClick);
        _column.registerEvent(UIEvent.READY, function(_) {
            if (_column.sortDirection != null) {
                var sortEvent = new SortEvent(SortEvent.SORT_CHANGED);
                sortEvent.direction = _column.sortDirection;
                _column.dispatch(sortEvent);
            }
        });
    }
    
    private override function onMouseDown(event:MouseEvent) {
        var components = _column.findComponentsUnderPoint(event.screenX, event.screenY, InteractiveComponent);
        components.remove(_column);
        if (components.length == 0) {
            super.onMouseDown(event);
        }
    }
    
    private function onColumnClick(event:MouseEvent) {
        if (_column.sortable == false) {
            return;
        }

        var components = _column.findComponentsUnderPoint(event.screenX, event.screenY, InteractiveComponent);
        components.remove(_column);
        if (components.length != 0) {
            return;
        }

        if (_column.sortDirection == null) {
            _column.sortDirection = SortDirection.ASCENDING;
        } else if (_column.sortDirection == SortDirection.ASCENDING) {
            _column.sortDirection = SortDirection.DESCENDING;
        } else if (_column.sortDirection == SortDirection.DESCENDING) {
            _column.sortDirection = SortDirection.ASCENDING;
        }
        
        var sortEvent = new SortEvent(SortEvent.SORT_CHANGED);
        sortEvent.direction = _column.sortDirection;
        _column.dispatch(sortEvent);
    }
}