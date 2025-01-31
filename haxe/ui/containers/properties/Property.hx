package haxe.ui.containers.properties;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDataComponent;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.util.Variant;

@:composite(Events, Builder)
class Property extends HBox implements IDataComponent {
    @:clonable @:behaviour(LabelBehaviour)              public var label:String;
    @:clonable @:behaviour(ValueBehaviour)              public var value:Variant;
    @:clonable @:behaviour(DefaultBehaviour)            public var type:String;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var min:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var max:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var step:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var forceStep:Null<Bool>;
    @:clonable @:behaviour(DefaultBehaviour, null)      public var precision:Null<Int>;
    @:behaviour(DataSourceBehaviour)                    public var dataSource:DataSource<Dynamic>;
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
        var builder = cast(_property._compositeBuilder, Builder);
        if (builder.labelContainer != null) {
            var label = builder.labelContainer.findComponent(Label, true);
            if (label != null) {
                label.text = value;
            }
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class ValueBehaviour extends DataBehaviour {
    private var _property:Property;

    public function new(property:Property) {
        super(property);
        _property = property;
    }

    private override function validateData() {
        var builder = cast(_property._compositeBuilder, Builder);
        builder.applyValue(_value);
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
            var builder = cast(_property._compositeBuilder, Builder);
            builder.hasDataSource = true;
            _value = new ArrayDataSource<Dynamic>();
        }
        return _value;
    }

    public override function set(value:Variant) {
        super.set(value);
        var builder = cast(_property._compositeBuilder, Builder);
        builder.hasDataSource = true;
        if (builder.editor != null) {
            builder.editor.applyDataSource(value);
        }
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Events extends haxe.ui.events.Events {
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var property:Property;
    public var editor:PropertyEditor;
    public var hasDataSource:Bool = false;
    public var labelContainer:HBox = null;

    public function new(property:Property) {
        super(property);
        this.property = property;
    }

    public override function create() {
        super.create();

        labelContainer = new HBox();
        labelContainer.addClass("property-label-container");

        var label = new Label();
        label.text = "";
        label.addClass("property-label");
        labelContainer.addComponent(label);
        property.addComponent(labelContainer);
    }

    public override function onInitialize() {
        super.onInitialize();
        editor = buildEditor(property.type);
        property.addComponent(editor);

        if (hasDataSource) {
            editor.applyDataSource(property.dataSource);
        }
        if (_value != null) {
            editor.applyValue(_value);
        }
    }

    private var _value:Variant = null;
    public function applyValue(value:Variant) {
        if (editor != null) {
            editor.applyValue(value);
        } else {
            _value = value;
        }
    }

    private function buildEditor(type:String):PropertyEditor {
        var editor = PropertyGrid.createEditor(type);
        editor.applyProperties(property);
        return editor;
    }

    public override function addComponent(child:Component):Component {
        if (child.hasClass("property-label-container")) {
            return null;
        }
        if ((child is PropertyEditor)) {
            return null;
        }

        labelContainer.removeAllComponents();
        child.percentWidth = 100;
        return labelContainer.addComponent(child);

        trace(child.className);
        return super.addComponent(child);
    }
}