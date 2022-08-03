package haxe.ui.components;

import haxe.ui.actions.ActionType;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.ActionEvent;
import haxe.ui.events.Events;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Size;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.styles.Style;

/**
 * A basic checkbox component.
 */
@:composite(Events, CheckBoxBuilder, CheckBoxLayout)
class CheckBox extends InteractiveComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    /**
     * The text for the label of this checkbox
     */
    @:clonable @:behaviour(TextBehaviour)              public var text:String;

    /**
     * Whether this checkbox is checked or not
     */
    @:clonable @:behaviour(SelectedBehaviour)          public var selected:Bool;

    /**
     * similar to `selected`, and for casual use you should use `selected` instead.
     * 
     * `value` is a universal way to access the value a component is based on.
     */
    @:clonable @:value(selected)                       public var value:Dynamic;
}

//***********************************************************************************************************
// Custom children
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class CheckBoxValue extends InteractiveComponent {
    public function new() {
        super();
        #if (haxeui_openfl && !haxeui_flixel)
        mouseChildren = false;
        #end
    }

    private override function onReady() { // use onReady so we have a parentComponent
        createIcon();
        registerEvent(ActionEvent.ACTION_START, onActionStart);
        registerEvent(ActionEvent.ACTION_END, onActionEnd);
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);
        var icon:Image = findComponent(Image);
        if (icon != null) {
            icon.resource = style.icon;
        }
    }

    public function createIcon() {
        var icon:Image = findComponent(Image);
        if (icon == null && parentComponent != null) {
            icon = new Image();
            icon.id = '${parentComponent.cssName}-icon';
            icon.addClass('${parentComponent.cssName}-icon');
            if (style != null && style.icon != null) {
                icon.resource = style.icon;
            }
            addComponent(icon);
        }
    }

    private var _down:Bool = true;
    private function onActionStart(event:ActionEvent) {
        switch (event.action) {
            case ActionType.PRESS | ActionType.CONFIRM:
                _down = true;
            case _:    
        }
    }

    private function onActionEnd(event:ActionEvent) {
        switch (event.action) {
            case ActionType.PRESS | ActionType.CONFIRM:
                if (_down == true) {
                    _down = false;
                    if (parentComponent != null) {
                        var checkbox = cast(parentComponent, CheckBox);
                        checkbox.selected = !checkbox.selected;
                    }
                }
            case _:    
        }
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent(Label, false);
        if (label == null) {
            label = new Label();
            label.id = '${_component.cssName}-label';
            label.addClass('${_component.cssName}-label');
            label.scriptAccess = false;
            _component.addComponent(label);
            _component.invalidateComponentStyle(true);
        }

        label.text = _value;
    }
}

@:dox(hide) @:noCompletion
private class SelectedBehaviour extends DataBehaviour {
    /*
    public override function get():Variant {
        var valueComponent:Value = _component.findComponent(Value);
        return valueComponent.hasClass(":selected");
    }

    public override function set(value:Variant) {
        if (value == get()) {
            return;
        }

        var valueComponent:Value = _component.findComponent(Value);
        _value = value;
        if (_value == true) {
            valueComponent.addClass(":selected");
        } else {
            valueComponent.removeClass(":selected");
        }
        invalidateData();
    }
    */

    private override function validateData() {
        var valueComponent:CheckBoxValue = _component.findComponent(CheckBoxValue);
        if (valueComponent == null) {
            return;
        }

        valueComponent.createIcon();

        if (_value == true) {
            valueComponent.addClass(":selected");
        } else {
            valueComponent.removeClass(":selected");
        }

        var event = new UIEvent(UIEvent.CHANGE);
        event.previousValue = _previousValue;
        event.value = _value;
        _component.dispatch(event);
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.events.Events  {
    private var _checkbox:CheckBox;

    public function new(checkbox:CheckBox) {
        super(checkbox);
        _checkbox = checkbox;
    }
    
    public override function register() {
        if (hasEvent(MouseEvent.MOUSE_OVER, onMouseOver) == false) {
            registerEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        }
        if (hasEvent(MouseEvent.MOUSE_OUT, onMouseOut) == false) {
            registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        }
        if (hasEvent(MouseEvent.CLICK, onClick) == false) {
            registerEvent(MouseEvent.CLICK, onClick);
        }
        if (hasEvent(MouseEvent.MOUSE_DOWN, onMouseDown) == false) {
            registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
    }

    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        unregisterEvent(MouseEvent.CLICK, onClick);
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    private function onMouseOver(event:MouseEvent) {
        _target.addClass(":hover");
        _target.findComponent(CheckBoxValue).addClass(":hover");
    }

    private function onMouseOut(event:MouseEvent) {
        _target.removeClass(":hover");
        _target.findComponent(CheckBoxValue).removeClass(":hover");
    }

    private function onClick(event:MouseEvent) {
        _checkbox.selected = !_checkbox.selected;
    }
    
    private function onMouseDown(event:MouseEvent) {
        _checkbox.findComponent(CheckBoxValue).focus = true;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class CheckBoxBuilder extends CompositeBuilder {
    private var _checkbox:CheckBox;

    public function new(checkbox:CheckBox) {
        super(checkbox);
        _checkbox = checkbox;
        _checkbox.allowFocus = false;
    }

    public override function create() {
        if (_checkbox.findComponent(CheckBoxValue) == null) {
            var value = new CheckBoxValue();
            value.id = '${_checkbox.cssName}-value';
            value.addClass('${_checkbox.cssName}-value');
            value.scriptAccess = false;
            _checkbox.addComponent(value);
        }
    }

    public override function applyStyle(style:Style) {
        haxe.ui.macros.ComponentMacros.cascacdeStylesTo('${_checkbox.cssName}-label', [
            color, fontName, fontSize, cursor, textAlign, fontBold, fontUnderline, fontItalic
        ]);
    }

    private override function get_cssName():String {
        return "checkbox";
    }
}

//***********************************************************************************************************
// Layout
//***********************************************************************************************************
private class CheckBoxLayout extends HorizontalLayout {
    public override function repositionChildren() {
        super.repositionChildren();

        var icon = _component.findComponent(Image, true);
        if (icon != null) {
            icon.left = Math.fround(icon.left);
            icon.top = Math.fround(icon.top);
        }
    }
    
    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var size = super.calcAutoSize(exclusions);
        if (_component.autoWidth == false) {
            var label = _component.findComponent(Label, false);
            if (label != null) {
                label.percentWidth = 100;
            }
        }
        return size;
    }
}
