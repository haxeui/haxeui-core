package haxe.ui.components;

import haxe.ds.StringMap;
import haxe.ui.core.Behaviour;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;

/**
 Optionbox component where only one option of a group may be selected at a single time
**/
@:dox(icon = "/icons/ui-radio-buttons.png")
class OptionBox extends InteractiveComponent {
    private static var _groups:StringMap<Array<OptionBox>>;

    public function new() {
        super();

        if (_groups == null) {
            _groups = new StringMap<Array<OptionBox>>();
        }
        groupName = "defaultGroup";
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "text" => new OptionBoxDefaultTextBehaviour(this),
            "selected" => new OptionBoxDefaultSelectedBehaviour(this)
        ]);
        _defaultLayout = new HorizontalLayout();
    }

    private override function createChildren() {
        var optionboxValue:OptionBoxValue = findComponent(OptionBoxValue);
        if (optionboxValue == null) {
            optionboxValue = new OptionBoxValue();
            optionboxValue.id = "optionbox-value";
            optionboxValue.addClass("optionbox-value");
            addComponent(optionboxValue);

            optionboxValue.registerEvent(MouseEvent.CLICK, _onClick);
            optionboxValue.registerEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
            optionboxValue.registerEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        }
    }

    private override function destroyChildren() {
        var value:OptionBoxValue = findComponent(OptionBoxValue);
        if (value != null) {
            removeComponent(value);
            value = null;
        }

        var label:Label = findComponent(Label);
        if (label != null) {
            removeComponent(label);
            label = null;
        }
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function get_value():Variant {
        return selected;
    }

    private override function set_value(value:Variant):Variant {
        selected = value;
        return value;
    }

    private override function set_text(value:String):String {
        if (_text == value) {
            return value;
        }

        invalidateComponentData();
        _text = value;
        return value;
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);

        var label:Label = findComponent(Label);
        if (label != null &&
            (label.customStyle.color != style.color
            || label.customStyle.fontName != style.fontName
            || label.customStyle.fontSize != style.fontSize
            || label.customStyle.cursor != style.cursor)) {

            label.customStyle.color = style.color;
            label.customStyle.fontName = style.fontName;
            label.customStyle.fontSize = style.fontSize;
            label.customStyle.cursor = style.cursor;
            label.invalidateComponentStyle();
        }
    }

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************

    private override function validateData() {
        if (behaviourGet("text") != _text) {
            behaviourSet("text", _text);
        }

        if (behaviourGet("selected") != _selected) {
            behaviourSet("selected", _selected);
        }

        if (behaviourGet("group") != _groupName) {
            behaviourSet("group", _groupName);
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _selected:Bool = false;
    /**
     Whether to set this optionbox to be selected, any other optionboxes in the same group will be unselected
    **/
    @:clonable @:bindable public var selected(get, set):Bool;
    private function set_selected(value:Bool):Bool {
        if (value == _selected) {
            return value;
        }

        if (_groupName != null && value == false) { // dont allow false if no other group selection
            var arr:Array<OptionBox> = _groups.get(_groupName);
            var hasSelection:Bool = false;
            if (arr != null) {
                for (option in arr) {
                    if (option != this && option.selected == true) {
                        hasSelection = true;
                        break;
                    }
                }
            }
            if (hasSelection == false) {
                return value;
            }
        }

        invalidateComponentData();
        _selected = value;

        /*
        if (value == true) {
            _value.addClass(":selected");
        } else {
            _value.removeClass(":selected");
        }
        */

        if (_groupName != null && value == true) { // set all the others in group
            var arr:Array<OptionBox> = _groups.get(_groupName);
            if (arr != null) {
                for (option in arr) {
                    if (option != this) {
                        option.selected = false;
                    }
                }
            }
        }

        return value;
    }

    private function get_selected():Bool {
        return _selected;
    }

    private function toggleSelected():Bool {
        return selected = !selected;
    }

    private var _groupName:String;
    /**
     The group that this optionbox belongs to, any options that belong to the same group can only ever have a single option selected at a time
    **/
    @:clonable public var groupName(get, set):String;
    private function get_groupName():String {
        return _groupName;
    }

    private function set_groupName(value:String):String {
        if (value != null) {
            var arr:Array<OptionBox> = _groups.get(value);
            if (arr != null) {
                arr.remove(this);
            }
        }

        invalidateComponentData();
        _groupName = value;
        var arr:Array<OptionBox> = _groups.get(value);
        if (arr == null) {
            arr = [];
        }

        if (optionInGroup(value, this) == false) {
            arr.push(this);
        }
        _groups.set(value, arr);

        return value;
    }

    /**
     A utility property to retrieve that actual `OptionBox` that is currently selected
    **/
    public var selectedOption(get, null):OptionBox;
    private function get_selectedOption():OptionBox {
        var arr:Array<OptionBox> = getGroupOptions(_groupName);
        var selectionOption:OptionBox = null;
        if (arr != null) {
            for (test in arr) {
                if (test.selected == true) {
                    selectionOption = test;
                    break;
                }
            }
        }
        return selectionOption;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private function _onClick(event:MouseEvent) {
        toggleSelected();
    }

    private function _onMouseOver(event:MouseEvent) {
        addClass(":hover");
        var value:OptionBoxValue = findComponent(OptionBoxValue);
        if (value != null) {
            value.addClass(":hover");
        }
    }

    private function _onMouseOut(event:MouseEvent) {
        removeClass(":hover");
        var value:OptionBoxValue = findComponent(OptionBoxValue);
        if (value != null) {
            value.removeClass(":hover");
        }
    }

    //******************************************************************************************
    // Helpers
    //******************************************************************************************
    private static function optionInGroup(value:String, option:OptionBox):Bool {
        var exists:Bool = false;
        var arr:Array<OptionBox> = _groups.get(value);
        if (arr != null) {
            for (test in arr) {
                if (test == option) {
                    exists = true;
                    break;
                }
            }
        }
        return exists;
    }

    private static function getGroupOptions(group:String):Array<OptionBox> {
        return _groups.get(group);
    }

}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.OptionBox)
class OptionBoxDefaultTextBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var optionbox:OptionBox = cast _component;
        var label:Label = optionbox.findComponent(Label);
        if (label == null) {
            label = new Label();
            label.id = "optionbox-label";
            label.addClass("optionbox-label");

            label.registerEvent(MouseEvent.CLICK, optionbox._onClick);
            label.registerEvent(MouseEvent.MOUSE_OVER, optionbox._onMouseOver);
            label.registerEvent(MouseEvent.MOUSE_OUT, optionbox._onMouseOut);

            optionbox.addComponent(label);
        }
        label.text = value;
    }

    public override function get():Variant {
        var optionbox:OptionBox = cast _component;
        var label:Label = optionbox.findComponent(Label);
        if (label == null) {
            return null;
        }
        return label.text;
    }
}

@:dox(hide)
@:access(haxe.ui.components.OptionBox)
class OptionBoxDefaultSelectedBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var optionbox:OptionBox = cast _component;
        var optionboxValue:OptionBoxValue = optionbox.findComponent(OptionBoxValue);
        if (optionboxValue == null) {
            return;
        }

        if (value == true) {
            optionboxValue.addClass(":selected");
        } else {
            optionboxValue.removeClass(":selected");
        }
    }

    public override function get():Variant {
        var optionbox:OptionBox = cast _component;
        var optionboxValue:OptionBoxValue = optionbox.findComponent(OptionBoxValue);
        if (optionboxValue == null) {
            return false;
        }
        return optionboxValue.hasClass(":selected");
    }
}

//***********************************************************************************************************
// Special children
//***********************************************************************************************************
/**
 Specialised `InteractiveComponent` used to contain the `OptionBox` icon and respond to style changes
**/
@:dox(hide)
class OptionBoxValue extends InteractiveComponent {
    private var _icon:Image;

    public function new() {
        super();
        #if (openfl && !flixel)
        mouseChildren = false;
        #end

        _icon = new Image();
        _icon.id = "optionbox-icon";
        _icon.addClass("optionbox-icon");
        addComponent(_icon);
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);
        if (_icon != null) {
            _icon.resource = style.icon;
        }
    }
}