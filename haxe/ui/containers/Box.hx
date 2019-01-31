package haxe.ui.containers;

import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.LayoutFactory;

/**
 Base `Layout` that allows a container to specify an `icon`. How that icon resource is used depends on subclasses, like `TabView`
**/
@:dox(icon = "/icons/ui-panel.png")
class Box extends Component {
    public function new() {
        super();
        layout = new DefaultLayout();
    }


    private var _layoutName:String;
    @:clonable public var layoutName(get, set):String;
    private function get_layoutName():String {
        return _layoutName;
    }
    private function set_layoutName(value:String):String {
        if (_layoutName == value) {
            return value;
        }

        _layoutName = value;
        layout = LayoutFactory.createFromName(layoutName);
        return value;
    }
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _icon:String;
    /**
     The icon associated with this box component

     *Note*: this class itself does nothing special with this property and simply here to allow subclasses to make use
     of it should they want to
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