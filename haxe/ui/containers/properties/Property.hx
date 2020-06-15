package haxe.ui.containers.properties;

import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.DropDown;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.core.ComponentContainer.ComponentValueBehaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDataComponent;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.util.Variant;

@:composite(PropertyBuilder)
class Property extends HBox implements IDataComponent {
    @:clonable @:behaviour(LabelBehaviour)              public var label:String;
    @:clonable @:behaviour(DefaultBehaviour, "text")    public var type:String;
    @:behaviour(DataSourceBehaviour)                    public var dataSource:DataSource<Dynamic>;
    @:clonable @:behaviour(PropertyValueBehaviour)      public var value:Dynamic;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class LabelBehaviour extends DefaultBehaviour {
    private var _property:Property;
    
    public function new(property:Property) {
        super(property);
        _property = property;
    }
    
    public override function set(value:Variant) {
        super.set(value);
        var builder = cast(_property._compositeBuilder, PropertyBuilder);
        if (builder.label != null) {
            builder.label.text = value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class DataSourceBehaviour extends DefaultBehaviour {
    private var _property:Property;
    
    public function new(property:Property) {
        super(property);
        _property = property;
    }
    
    public override function get():Variant {
        if (_value == null) {
            _value = new ArrayDataSource<Dynamic>();
        }
        return _value;
    }
    
    public override function set(value:Variant) {
        super.set(value);
        var builder = cast(_property._compositeBuilder, PropertyBuilder);
        if (builder.editor != null && Std.is(builder.editor, DropDown)) {
            cast(builder.editor, DropDown).dataSource = value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class PropertyValueBehaviour extends ComponentValueBehaviour {
    private var _property:Property;
    
    public function new(property:Property) {
        super(property);
        _property = property;
    }
    
    public override function set(value:Variant) {
        super.set(value);
        var builder = cast(_property._compositeBuilder, PropertyBuilder);
        if (builder.editor != null) {
            builder.editor.value = Variant.toDynamic(value);
        }
    }
}

//***********************************************************************************************************
// Builder
//***********************************************************************************************************
class PropertyBuilder extends CompositeBuilder {
    public var editor:Component = null;
    public var label:Label = null;
}
