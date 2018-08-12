package haxe.ui.components;
import haxe.ui.backend.html5.native.layouts.ButtonLayout;
import haxe.ui.components.Button.ButtonEvents;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.util.Variant;

@:composite(DropDownEvents, DropDownBuilder)
class DropDown2 extends Button implements IDataComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DataSourceBehaviour)                    public var dataSource:DataSource<Dynamic>;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class DropDownEvents extends ButtonEvents {
    private var _dropdown:DropDown2;
    
    public function new(dropdown:DropDown2) {
        super(dropdown);
        _dropdown = dropdown;
    }
    
    public override function register() {
        super.register();
        registerEvent(MouseEvent.CLICK, onClick);
    }
    
    public override function unregister() {
        super.unregister();
        unregisterEvent(MouseEvent.CLICK, onClick);
    }
    
    private function onClick(event:MouseEvent) {
        if (_dropdown.selected == true) {
            trace("SHOW IT!");
        } else {
            trace("HIDE IT!");
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class DropDownBuilder extends CompositeBuilder {
    private var _dropdown:DropDown2;

    public function new(dropdown:DropDown2) {
        super(dropdown);
        _dropdown = dropdown;
    }
    
    public override function create() {
        _dropdown.toggle = true;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class DataSourceBehaviour extends DataBehaviour {
    public override function set(value:Variant) {
        super.set(value);
        var dataSource:DataSource<Dynamic> = _value;
        if (dataSource != null) {
            dataSource.transformer = new NativeTypeTransformer();
            dataSource.onChange = _component.invalidateComponentData;
        }
    }
}
