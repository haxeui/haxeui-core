package haxe.ui.components;

import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;

@:composite(Events, CheckBoxBuilder, HorizontalLayout)
class CheckBox extends InteractiveComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(TextBehaviour)              public var text:String;
    @:clonable @:behaviour(SelectedBehaviour)          public var selected:Bool;
    @:clonable @:value(selected)                       public var value:Dynamic;
}

//***********************************************************************************************************
// Custom children
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Value extends InteractiveComponent {
    public function new() {
        super();
        #if (openfl && !flixel)
        mouseChildren = false;
        #end
    }

    private override function onReady() { // use onReady so we have a parentComponent
        var icon:Image = findComponent(Image);
        if (icon == null) {
            icon = new Image();
            icon.id = '${parentComponent.cssName}-icon';
            icon.addClass('${parentComponent.cssName}-icon');
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
    private override function validateData() {
        var valueComponent:Value = _component.findComponent(Value);
        if (_value == true) {
            valueComponent.addClass(":selected");
        } else {
            valueComponent.removeClass(":selected");
        }
        
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
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
    }
    
    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        unregisterEvent(MouseEvent.CLICK, onClick);
    }
    
    private function onMouseOver(event:MouseEvent) {
        _target.addClass(":hover");
        _target.findComponent(Value).addClass(":hover");
    }
    
    private function onMouseOut(event:MouseEvent) {
        _target.removeClass(":hover");
        _target.findComponent(Value).removeClass(":hover");
    }
    
    private function onClick(event:MouseEvent) {
        _checkbox.selected = !_checkbox.selected;
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
    }
    
    public override function create() {
        if (_checkbox.findComponent(Value) == null) {
            var value = new Value();
            value.id = '${_checkbox.cssName}-value';
            value.addClass('${_checkbox.cssName}-value');
            value.scriptAccess = false;
            _checkbox.addComponent(value);
        }
    }
    
    public override function applyStyle(style:Style) {
        var label:Label = _checkbox.findComponent(Label);
        if (label != null &&
            (label.customStyle.color != style.color ||
            label.customStyle.fontName != style.fontName ||
            label.customStyle.fontSize != style.fontSize ||
            label.customStyle.cursor != style.cursor)) {

            label.customStyle.color = style.color;
            label.customStyle.fontName = style.fontName;
            label.customStyle.fontSize = style.fontSize;
            label.customStyle.cursor = style.cursor;
            label.invalidateComponentStyle();
        }
    }
    
    private override function get_cssName():String {
        return "checkbox";
    }
}