package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.containers.HBox;
import haxe.ui.core.CompositeBuilder;

@:composite(Builder)
class Tag extends HBox {
    @:clonable @:behaviour(TextBehaviour)              public var text:String;
    @:clonable @:behaviour(Closable, true)             public var closable:Bool;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent(Label, false);
        if (label != null) {
            label.text = _value;
        }
    }
}

@:dox(hide) @:noCompletion
private class Closable extends DataBehaviour {
    private override function validateData() {
        var image:Image = _component.findComponent("tag-close", false);
        if (_value == null || _value.isNull) {
            if (image != null) {
                _component.removeComponent(image);
            }
        } else if (image == null) {
            image = new Image();
            image.id = "tag-close";
            image.addClass("tag-close");
            image.scriptAccess = false;
            _component.addComponent(image);
            image.onClick = function(_) {
                _component.fadeOut(function() {
                    _component.parentComponent.removeComponent(_component);
                });
            }
        }
    }
}

private class Builder extends CompositeBuilder {
    private var _label:Label;

    public override function create() {
        super.create();
        _label = new Label();
        _label.scriptAccess = false;
        _label.id = "tag-label";
        _label.addClass("tag-label");
        _label.text = "tag";
        _component.addComponent(_label);
    }
}