package haxe.ui.containers.menus;

import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.Component;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Variant;

@:composite(Builder)
class MenuOptionBox extends MenuItem {
    @:clonable @:behaviour(GroupBehaviour)          public var componentGroup:String;
    @:clonable @:behaviour(TextBehaviour)           public var text:String;
    @:clonable @:behaviour(ShortcutTextBehaviour)   public var shortcutText:String;
    @:clonable @:behaviour(SelectedBehaviour)       public var selected:Bool;
    @:clonable @:behaviour(SelectedOptionBehaviour) public var selectedOption:Component;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class GroupBehaviour extends DataBehaviour {
    private override function validateData() {
        var optionbox:OptionBox = _component.findComponent(OptionBox, false);
        if (optionbox == null) {
            optionbox = new OptionBox();
            optionbox.styleNames = "menuitem-optionbox";
            optionbox.scriptAccess = false;
            _component.addComponent(optionbox);
        }

        optionbox.componentGroup = _value;
    }
}

@:dox(hide) @:noCompletion
private class ShortcutTextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent("menuitem-shortcut-label", false);
        if (label != null) {
            label.text = _value;
        }
    }
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var optionbox:OptionBox = _component.findComponent(OptionBox, false);
        if (optionbox == null) {
            optionbox = new OptionBox();
            optionbox.styleNames = "menuitem-optionbox";
            optionbox.scriptAccess = false;
            _component.addComponent(optionbox);
        }

        optionbox.text = _value;
    }
}

@:dox(hide) @:noCompletion
private class SelectedBehaviour extends DataBehaviour {
    private override function validateData() {
        var optionbox:OptionBox = _component.findComponent(OptionBox, false);
        if (optionbox == null) {
            optionbox = new OptionBox();
            optionbox.styleNames = "menuitem-optionbox";
            optionbox.scriptAccess = false;
            _component.addComponent(optionbox);
        }

        optionbox.selected = _value;
    }

    public override function get():Variant {
        var optionbox:OptionBox = _component.findComponent(OptionBox, false);
        if (optionbox == null) {
            return false;
        }
        return optionbox.selected;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedOptionBehaviour extends Behaviour {
    public override function get():Variant {
        var optionbox:OptionBox = _component.findComponent(OptionBox, false);
        if (optionbox == null) {
            return null;
        }
        return optionbox.selectedOption;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _optionbox:OptionBox;

    public override function create() {
        _optionbox = new OptionBox();
        _optionbox.styleNames = "menuitem-optionbox";
        _optionbox.percentWidth = 100;
        _optionbox.registerEvent(UIEvent.CHANGE, onOptionboxChange);
        _optionbox.scriptAccess = false;
        _component.addComponent(_optionbox);

        var label = new Label();
        label.id = "menuitem-shortcut-label";
        label.styleNames = "menuitem-shortcut-label";
        label.scriptAccess = false;
        _component.addComponent(label);
    }

    private function onOptionboxChange(event:UIEvent) {
        _component.dispatch(event);
    }
}
