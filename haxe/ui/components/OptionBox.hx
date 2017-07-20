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

    private var _value:OptionBoxValue;
    private var _label:Label;

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

    private override function create() {
        super.create();
        behaviourSet("text", _text);
        behaviourSet("group", _groupName);
        behaviourSet("selected", selected);
    }

    private override function createChildren() {
        if (_value == null) {
            _value = new OptionBoxValue();
            _value.id = "optionbox-value";
            _value.addClass("optionbox-value");
            addComponent(_value);

            _value.registerEvent(MouseEvent.CLICK, _onClick);
            _value.registerEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
            _value.registerEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        }
    }

    private override function destroyChildren() {
        if (_value != null) {
            removeComponent(_value);
            _value = null;
        }
        if (_label != null) {
            removeComponent(_label);
            _label = null;
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
        value = super.set_text(value);
        behaviourSet("text", value);
        return value;
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);
        if (_label != null) {
            _label.customStyle.color = style.color;
            _label.customStyle.fontName = style.fontName;
            _label.customStyle.fontSize = style.fontSize;
            _label.customStyle.cursor = style.cursor;
            _label.invalidateStyle();
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

        _selected = value;
        behaviourSet("selected", value);

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
        return behaviourGet("selected");
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

        _groupName = value;
        behaviourSet("group", value);
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
        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(event);
    }

    private function _onMouseOver(event:MouseEvent) {
        addClass(":hover");
        _value.addClass(":hover");
    }

    private function _onMouseOut(event:MouseEvent) {
        removeClass(":hover");
        _value.removeClass(":hover");
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
        if (value == null || value.isNull) {
            return;
        }

        var optionbox:OptionBox = cast _component;
        if (optionbox._label == null) {
            optionbox._label = new Label();
            optionbox._label.id = "optionbox-label";
            optionbox._label.addClass("optionbox-label");

            optionbox._label.registerEvent(MouseEvent.CLICK, optionbox._onClick);
            optionbox._label.registerEvent(MouseEvent.MOUSE_OVER, optionbox._onMouseOver);
            optionbox._label.registerEvent(MouseEvent.MOUSE_OUT, optionbox._onMouseOut);

            optionbox.addComponent(optionbox._label);
        }
        optionbox._label.text = value;
    }
}

@:dox(hide)
@:access(haxe.ui.components.OptionBox)
class OptionBoxDefaultSelectedBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var optionbox:OptionBox = cast _component;
        if (optionbox._value == null) {
            return;
        }

        if (value == true) {
            optionbox._value.addClass(":selected");
        } else {
            optionbox._value.removeClass(":selected");
        }
    }

    public override function get():Variant {
        var optionbox:OptionBox = cast _component;
        return optionbox._selected;
    }
}

//***********************************************************************************************************
// Special children
//***********************************************************************************************************
/**
 Specialised `InteractiveComponent` used to contain the `OptionBox` icon and respond to style changes
**/
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