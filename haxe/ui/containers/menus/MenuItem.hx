package haxe.ui.containers.menus;

import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.Events;

@:composite(Events, Builder)
class MenuItem extends HBox {
    @:clonable @:behaviour(TextBehaviour)           public var text:String;
    @:clonable @:behaviour(IconBehaviour)           public var icon:String;
    @:clonable @:behaviour(ExpandableBehaviour)     public var expandable:Bool;
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

@:dox(hide) @:noCompletion
private class IconBehaviour extends DataBehaviour {
    private override function validateData() {
        if (_value == null || _value.isNull) {
            return;
        }
        
        var icon:Image = _component.findComponent("menuitem-icon", Image, false);
        if (icon == null) {
            icon = new Image();
            icon.scriptAccess = false;
            icon.id = "menuitem-icon";
            icon.addClass("menuitem-icon");
            _component.addComponentAt(icon, 0);
        }
        icon.resource = _value;
    }
}

@:dox(hide) @:noCompletion
private class ExpandableBehaviour extends DataBehaviour {
    private override function validateData() {
        var image:Image = _component.findComponent("menuitem-expandable");
        if (image == null && _value == true) {
            image = new Image();
            image.id = "menuitem-expandable";
            image.styleNames = "menuitem-expandable";
            image.scriptAccess = false;
            _component.addComponent(image);
            _component.invalidateComponentStyle(true);
        } else if (_value == false) {
            _component.removeComponent(image);
        }
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.events.Events {
    public override function register() {
        if (!hasEvent(MouseEvent.MOUSE_OVER, onMouseOver)) {
            registerEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        }
        if (!hasEvent(MouseEvent.MOUSE_OUT, onMouseOut)) {
            registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        }
    }
    
    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);
    }   
    
    private function onMouseOver(event:MouseEvent) {
        _target.addClass(":hover", true, true);
    }
    
    private function onMouseOut(event:MouseEvent) {
        _target.removeClass(":hover", true, true);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    public override function create() {
        super.create();
        
        var label = new Label();
        label.id = "menuitem-label";
        label.styleNames = "menuitem-label";
        label.scriptAccess = false;
        _component.addComponent(label);
    }
}
