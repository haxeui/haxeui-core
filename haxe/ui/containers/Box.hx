package haxe.ui.containers;

import haxe.ui.core.IClonable;
import haxe.ui.layouts.DefaultLayout;

/**
 Base `Layout` that allows a container to specify an `icon`. How that icon resource is used depends on subclasses, like
 `haxe.ui.containers.TabView`
**/
@:dox(icon = "/icons/ui-panel.png")
class Box extends haxe.ui.core.Component implements IClonable<Box> {
    public function new() {
        super();
        layout = new DefaultLayout();
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _icon:String;
    /**
     The icon associated with this box component

     _Note: this class itself does nothing special with this property and simply here to allow subclasses to make use
     of it should they want to_
    **/
    @:clonable public var icon(get, set):String;
    private function get_icon():String {
        return _icon;
    }

    private function set_icon(value:String):String {
        _icon = value;
        return value;
    }
}