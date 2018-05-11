package haxe.ui.components;

import haxe.ui.validation.InvalidationFlags;
import haxe.ui.core.Behaviour;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;

/**
 Checkbox component showing either a selected or unselected state including a text label
**/
@:dox(icon = "/icons/ui-check-boxes.png")
class CheckBox extends InteractiveComponent {
    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "text" => new CheckBoxDefaultTextBehaviour(this),
            "selected" => new CheckBoxDefaultSelectedBehaviour(this)
        ]);
        _defaultLayout = new HorizontalLayout();
    }

    private override function createChildren() {
        var checkboxValue:CheckBoxValue = findComponent(CheckBoxValue);
        if (checkboxValue == null) {
            checkboxValue = new CheckBoxValue();
            checkboxValue.id = "checkbox-value";
            checkboxValue.addClass("checkbox-value");
            addComponent(checkboxValue);
            
            checkboxValue.registerEvent(MouseEvent.CLICK, _onClick);
            checkboxValue.registerEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
            checkboxValue.registerEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        }
    }

    private override function destroyChildren() {
        var value:CheckBoxValue = findComponent(CheckBoxValue);
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
            
            var event:UIEvent = new UIEvent(UIEvent.CHANGE);
            dispatch(event);
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _selected:Bool = false;
    /**
     Whether to show a checkmark in this checkbox component or not
    **/
    @:dox(group = "Selection related properties")
    @:clonable public var selected(get, set):Bool;
    private function set_selected(value:Bool):Bool {
        if (value == _selected) {
            return value;
        }
        invalidateComponentData();
        _selected = value;
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
    private function _onClick(event:MouseEvent) {
        toggleSelected();
        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(event);
    }

    private function _onMouseOver(event:MouseEvent) {
        addClass(":hover");
        var value:CheckBoxValue = findComponent(CheckBoxValue);
        if (value != null) {
            value.addClass(":hover");
        }
    }

    private function _onMouseOut(event:MouseEvent) {
        removeClass(":hover");
        var value:CheckBoxValue = findComponent(CheckBoxValue);
        if (value != null) {
            value.removeClass(":hover");
        }
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.CheckBox)
class CheckBoxDefaultTextBehaviour extends Behaviour {
    public override function set(value:Variant) {
        if (value == null || value.isNull) {
            return;
        }

        var checkbox:CheckBox = cast _component;
        var label:Label = checkbox.findComponent(Label);
        if (label == null) {
            label = new Label();
            label.id = "checkbox-label";
            label.addClass("checkbox-label");

            label.registerEvent(MouseEvent.CLICK, checkbox._onClick);
            label.registerEvent(MouseEvent.MOUSE_OVER, checkbox._onMouseOver);
            label.registerEvent(MouseEvent.MOUSE_OUT, checkbox._onMouseOut);

            checkbox.addComponent(label);
        }
        label.text = value;
    }

    public override function get():Variant {
        var checkbox:CheckBox = cast _component;
        var label:Label = checkbox.findComponent(Label);
        if (label == null) {
            return null;
        }
        return label.text;
    }
}

@:dox(hide)
@:access(haxe.ui.components.CheckBox)
class CheckBoxDefaultSelectedBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var checkbox:CheckBox = cast _component;
        var checkboxValue:CheckBoxValue = checkbox.findComponent(CheckBoxValue);
        if (checkboxValue == null) {
            return;
        }

        if (value == true) {
            checkboxValue.addClass(":selected");
        } else {
            checkboxValue.removeClass(":selected");
        }
    }

    public override function get():Variant {
        var checkbox:CheckBox = cast _component;
        var checkboxValue:CheckBoxValue = checkbox.findComponent(CheckBoxValue);
        if (checkboxValue == null) {
            return false;
        }
        return checkboxValue.hasClass(":selected");
    }
}

//***********************************************************************************************************
// Special children
//***********************************************************************************************************
/**
 Specialised `InteractiveComponent` used to contain the `CheckBox` icon and respond to style changes
**/
@:dox(hide)
class CheckBoxValue extends InteractiveComponent {
    public function new() {
        super();
        #if (openfl && !flixel)
        mouseChildren = false;
        #end

        var icon:Image = findComponent(Image); // its going to be null, but just in case it moves
        if (icon == null) {
            icon = new Image();
            icon.id = "checkbox-icon";
            icon.addClass("checkbox-icon");
            addComponent(icon);
        }
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);
        var icon:Image = findComponent(Image);
        if (icon != null) {
            icon.resource = style.icon;
        }
    }
}