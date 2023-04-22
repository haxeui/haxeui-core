package haxe.ui.containers;

import haxe.ui.components.Column;
import haxe.ui.constants.SortDirection;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.SortEvent;
import haxe.ui.layouts.HorizontalLayout;

@:composite(Layout, Builder)
class Header extends HBox {
    public function new() {
        super();
        layout = new Layout();
    }
}

private class Builder extends CompositeBuilder {
    private var _header:Header;
    
    public function new(header:Header) {
        super(header);
        _header = header;
    }
    
    public override function addComponent(child:Component):Component {
        addEventListeners(child);
        return null;
    }
    
    public override function addComponentAt(child:Component, index:Int):Component {
        addEventListeners(child);
        return null;
    }
    
    private function addEventListeners(c:Component) {
        if (!(c is Column)) {
            return;
        }
        
        var column:Column = cast(c, Column);
        column.registerEvent(SortEvent.SORT_CHANGED, onSortChanged);
    }
    
    private function onSortChanged(e:SortEvent) {
        for (c in _header.childComponents) {
            if (e.target == c) {
                _header.dispatch(e);
            } else {
                cast(c, Column).sortDirection = null;
            }
        }
    }
}

private class Layout extends HorizontalLayout {
    private override function resizeChildren() {
        super.resizeChildren();

        var max:Float = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            if (child.height > max) {
                max = child.height;
            }
        }
        
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            if (!(child is Column)) {
                continue;
            }

            if (child.text == null || child.text.length == 0 || child.height < max) {
                child.height = max;
            }
        }
    }
}