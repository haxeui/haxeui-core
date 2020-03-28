package haxe.ui.core;

import haxe.ui.layouts.Layout;
import haxe.ui.styles.Style;

class ComponentLayout extends ComponentValidation {
    //***********************************************************************************************************
    // Layout related
    //***********************************************************************************************************
    
    //***********************************************************************************************************
    // Style related
    //***********************************************************************************************************
    /**
     The calculated style of this component
    **/
    @:dox(group = "Style related properties and methods")
    public var style(get, set):Style;
    private function get_style():Style {
        return _style;
    }

    private function set_style(value):Style {
        _style = value;
        return value;
    }
}