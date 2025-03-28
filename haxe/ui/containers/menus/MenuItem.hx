package haxe.ui.containers.menus;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.containers.Box;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.Events;
import haxe.ui.events.MouseEvent;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.styles.Style;

@:composite(Events, Builder, Layout)
class MenuItem extends Box {
    @:clonable @:behaviour(TextBehaviour)           public var text:String;
    @:clonable @:behaviour(ShortcutTextBehaviour)   public var shortcutText:String;
    @:clonable @:behaviour(IconBehaviour)           public var icon:Variant;
    @:clonable @:behaviour(ExpandableBehaviour)     public var expandable:Bool;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent("menuitem-label", true);
        label.text = _value;
    }
}

@:dox(hide) @:noCompletion
private class ShortcutTextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent("menuitem-shortcut-label", true);
        if (label != null) {
            label.text = _value;
        }
    }
}

@:dox(hide) @:noCompletion
private class IconBehaviour extends DataBehaviour {
    private override function validateData() {
        if (_value == null || _value.isNull) {
            return;
        }

        var icon:Image = _component.findComponent("menuitem-icon", true);
        if (icon == null) {
            icon = new Image();
            icon.id = "menuitem-icon";
            icon.addClass("menuitem-icon");
            icon.addClass("icon");
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

        var box = new HBox();
        box.id = "menuitem-container";
        //box.percentWidth = 100;
        box.verticalAlign = "center";

        var label = new Label();
        label.id = "menuitem-label";
        //label.percentWidth = 100;
        label.styleNames = "menuitem-label";
        box.addComponent(label);

        var label = new Label();
        label.id = "menuitem-shortcut-label";
        label.styleNames = "menuitem-shortcut-label";
        box.addComponent(label);

        _component.addComponent(box);
    }
    
    public override function applyStyle(style:Style) {
        haxe.ui.macros.ComponentMacros.cascadeStylesTo("menuitem-label", [color, fontName, fontSize, cursor, textAlign, fontBold]);
    }
}

private class Layout extends HorizontalLayout {
    private override function resizeChildren() {
        if (_component.percentWidth != null) {
            var container = _component.findComponent("menuitem-container", HBox);
            if (container != null && container.percentWidth != 100) {
                container.percentWidth = 100;
            }
            var label = _component.findComponent("menuitem-label", Label);
            if (label != null && label.percentWidth != 100) {
                label.percentWidth = 100;
            }
            super.resizeChildren();
        } else {
            super.resizeChildren();
        }
    }
}