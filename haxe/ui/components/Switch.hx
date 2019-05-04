package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.util.Variant;

@:composite(Events, Builder, HorizontalLayout)
class Switch extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(SelectedBehaviour)         public var selected:Bool;
    @:clonable @:behaviour(DefaultBehaviour)          public var value:Variant;
    @:clonable @:behaviour(TextBehaviour)             public var text:String;
    @:clonable @:behaviour(DefaultBehaviour)          public var textOn:String;
    @:clonable @:behaviour(DefaultBehaviour)          public var textOff:String;
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.events.Events {
    private var _switch:Switch;
    
    public function new(s:Switch) {
        super(s);
        _switch = s;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class SelectedBehaviour extends DataBehaviour {
    private override function validateData() {
        _component.findComponent(SwitchButtonSub).selected = _value;
    }
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent(Label, false);
        if (label == null) {
            label = new Label();
            label.styleNames = "switch-label";
            label.id = "switch-label";
            label.scriptAccess = false;
            _component.addComponentAt(label, 0);
            
            var spacer = new Spacer(); // TODO: ugly
            spacer.percentWidth = 100;
            _component.addComponentAt(spacer, 1);
            
            _component.invalidateComponentStyle(true);
            
        }
        
        label.text = _value;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _switch:Switch;
    
    private var _button:SwitchButtonSub;
    private var _label:Label;
    
    public function new(s:Switch) {
        super(s);
        _switch = s;
    }
    
    public override function create() {
        if (_button == null) {
            _button = new SwitchButtonSub();
            _button.onChange = function(e) {
                _switch.selected = _button.selected;
                _switch.dispatch(new UIEvent(UIEvent.CHANGE));
            }
            _component.addComponent(_button);
        }
    }
}

//***********************************************************************************************************
// Custom children
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:composite(SwitchButtonLayout)
private class SwitchButtonSub extends InteractiveComponent {
    private var _button:Button;
    private var _label:Label;
    
    private override function createChildren() {
        super.createChildren();
        
        if (_button == null) {
            _label = new Label();
            _label.id = "switch-label";
            _label.addClass("switch-label");
            _label.text = _unselectedText;
            addComponent(_label);
            
            _button = new Button();
            _button.id = "switch-button";
            _button.addClass("switch-button");
            addComponent(_button);
            
            onClick = function(e) {
                selected = !selected;
            }
            
            var component:Component = new Component();
            component.addClass("switch-button-sub-extra");
            addComponentAt(component, 0);
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _selected:Bool = false;
    @:clonable public var selected(get, set):Bool;
    private function get_selected():Bool {
        return _selected;
    }
    private function set_selected(value:Bool):Bool {
        if (value == _selected) {
            return value;
        }

        invalidateComponentData();
        invalidateComponentLayout();
        _selected = value;
        
        if (_selected == false) {
            _label.text = _unselectedText;
            _label.removeClass(":selected");
            removeClass(":selected", true, true);
            addClass(":unselected", true, true);
        } else {
            _label.text = _selectedText;
            _label.addClass(":selected");
            removeClass(":unselected", true, true);
            addClass(":selected", true, true);
        }

        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(event);
        
        return value;
    }

    private var _selectedText:String = "";
    public var selectedText(get, set):String;
    private function get_selectedText():String {
        return _selectedText;
    }
    private function set_selectedText(value:String):String {
        _selectedText = value;
        if (_ready && _selected == true) {
            _label.text = _selectedText;
        }
        return value;
    }
    
    private var _unselectedText:String = "";
    public var unselectedText(get, set):String;
    private function get_unselectedText():String {
        return _unselectedText;
    }
    private function set_unselectedText(value:String):String {
        _unselectedText = value;
        if (_ready && _selected == false) {
            _label.text = _unselectedText;
        }
        return value;
    }
    
    private var _pos:Float = 0;
    public var pos(get, set):Float;
    private function get_pos():Float {
        return _pos;
    }
    private function set_pos(value:Float):Float {
        if (_pos == value) {
            return value;
        }
        
        _pos = value;
        invalidateComponentLayout();
        
        return value;
    }
}

//***********************************************************************************************************
// SwitchButton Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class SwitchButtonLayout extends DefaultLayout {
    private override function repositionChildren() {
        var switchComp = cast(_component, SwitchButtonSub);
        var button:Button = switchComp.findComponent("switch-button");
        var label:Label = switchComp.findComponent("switch-label");
        if (button == null || label == null) {
            return;
        }
        
        button.top = paddingTop;
        label.top = (component.componentHeight / 2) - (label.componentHeight / 2);
        
        if(switchComp.selected == true) {
            label.left = (button.componentWidth / 2) - (label.componentWidth / 2);
        } else {
            label.left = button.left + button.componentWidth + (button.componentWidth / 2) - (label.componentWidth / 2);
        }
        
        var ucx:Float = usableWidth - button.width;
        var min = 0;
        var max = 100;
        var x = (switchComp.pos - min) / (max - min) * ucx;

        button.left = paddingLeft + x;
        
        
        var extra:Component = switchComp.findComponent("switch-button-sub-extra", "css");
        if (extra != null) {
            extra.top = (_component.height / 2) - (extra.height / 2);
        }
        
    }
}