package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Label;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;

@:composite(Builder)
class SectionHeader extends VBox {
    @:clonable @:behaviour(TextBehaviour)              public var text:String;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent(Label, false);
        label.text = _value;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    public override function create() {
        super.create();
        
        var label = new Label();
        label.text = "Section Header";
        label.scriptAccess = false;
        _component.addComponent(label);
        
        var line = new Component();
        line.addClasses(["section-line", "line"]);
        line.scriptAccess = false;
        _component.addComponent(line);
    }
}