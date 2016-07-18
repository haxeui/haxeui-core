package haxe.ui.components;

import haxe.ui.core.Behaviour;
import haxe.ui.core.IClonable;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;

/**
 Checkbox component showing either a selected or unselected state including a text label
**/
@:dox(icon="/icons/ui-check-boxes.png")
class CheckBox extends InteractiveComponent implements IClonable<CheckBox> {
    private var _value:CheckBoxValue;
    private var _label:Label;

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults():Void {
        _defaultBehaviours = [
            "text" => new CheckBoxDefaultTextBehaviour(this),
            "selected" => new CheckBoxDefaultSelectedBehaviour(this)
        ];
        _defaultLayout = new HorizontalLayout();
    }

    private override function create():Void {
        super.create();
        behaviourSet("text", _text);
        behaviourSet("selected", selected);
    }

    private override function createChildren():Void {
        if (_value == null) {
            _value = new CheckBoxValue();
            _value.id = "checkbox-value";
            _value.addClass("checkbox-value");
            addComponent(_value);

            _value.registerEvent(MouseEvent.CLICK, _onClick);
            _value.registerEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
            _value.registerEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        }
    }

    private override function destroyChildren():Void {
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

    private override function applyStyle(style:Style):Void {
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
     Whether to show a checkmark in this checkbox component or not
    **/
    @:dox(group="Selection related properties")
    @:clonable public var selected(get, set):Bool;
    private function set_selected(value:Bool):Bool {
        if (value == _selected) {
            return value;
        }
        _selected = value;
        behaviourSet("selected", value);
        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(event);
        return value;
    }

    private function get_selected():Bool {
        return _selected;
    }

    private function toggleSelected():Bool {
        return selected = !selected;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private function _onClick(event:MouseEvent):Void {
        toggleSelected();
        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(event);
    }

    private function _onMouseOver(event:MouseEvent):Void {
        addClass(":hover");
        _value.addClass(":hover");
    }

    private function _onMouseOut(event:MouseEvent):Void {
        removeClass(":hover");
        _value.removeClass(":hover");
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.CheckBox)
class CheckBoxDefaultTextBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var checkbox:CheckBox = cast _component;
        if (checkbox._label == null) {
            checkbox._label = new Label();
            checkbox._label.id = "checkbox-label";
            checkbox._label.addClass("checkbox-label");

            checkbox._label.registerEvent(MouseEvent.CLICK, checkbox._onClick);
            checkbox._label.registerEvent(MouseEvent.MOUSE_OVER, checkbox._onMouseOver);
            checkbox._label.registerEvent(MouseEvent.MOUSE_OUT, checkbox._onMouseOut);

            checkbox.addComponent(checkbox._label);
        }
        checkbox._label.text = value;
    }
}

@:dox(hide)
@:access(haxe.ui.components.CheckBox)
class CheckBoxDefaultSelectedBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var checkbox:CheckBox = cast _component;
        if (checkbox._value == null) {
            return;
        }

        if (value == true) {
            checkbox._value.addClass(":selected");
        } else {
            checkbox._value.removeClass(":selected");
        }
    }
}

//***********************************************************************************************************
// Special children
//***********************************************************************************************************
/**
 Specialised `InteractiveComponent` used to contain the `CheckBox` icon and respond to style changes
**/
class CheckBoxValue extends InteractiveComponent {
    private var _icon:Image;

    public function new() {
        super();
        #if openfl
        mouseChildren = false;
        #end

        _icon = new Image();
        _icon.id = "checkbox-icon";
        _icon.addClass("checkbox-icon");
        addComponent(_icon);
    }

    private override function applyStyle(style:Style):Void {
        super.applyStyle(style);
        if (_icon != null) {
            _icon.resource = style.icon;
        }
    }
}