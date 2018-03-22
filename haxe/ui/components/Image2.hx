package haxe.ui.components;

import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.util.Variant;

class Image2 extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(ResourceBehaviour)  var resource:String;
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        //_defaultLayout = new ImageLayout();
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class ResourceBehaviour extends Behaviour {
    private var _value:String = null;
    
    public override function get():Variant {
        return _value;
    }
    
    public override function set(value:Variant) {
       if (_value == value) {
          return;
       }
       
       trace("setting");
       
       _value = value;
    }
}
