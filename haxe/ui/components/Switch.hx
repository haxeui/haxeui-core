package haxe.ui.components;

import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.MathUtil;

/**
 A Switch is a two-state toggle switch component that can select between two options
**/
//@:dox(icon = "")  //TODO
class Switch extends InteractiveComponent {
    private var _button:Button;
    private var _label:Label;

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new SwitchLayout();
    }

    private override function createChildren() {
        if (_button == null) {
            _label = new Label();
            _label.id = "switch-label";
            _label.addClass("switch-label");
            _label.text = _unselectedText;
            addComponent(_label);
            
            _button = new Button();
            _button.id = "switch-button";
            _button.addClass("switch-button");
            _button.onClick = function(e) {
                selected = !selected;
            }
            addComponent(_button);
        }

        registerEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
    }

    private override function destroyChildren() {
        super.destroyChildren();

        unregisterEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        unregisterEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);


        if(_button != null) {
            removeComponent(_button);
            _button = null;
        }
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************

    private override function get_value():Variant {
        return _selected;
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);

        if(_button != null) {
            _button.customStyle.borderRadius = style.borderRadius;
        }
    }

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************

    private override function validateData() {
        if (_selected == false) {
            _label.text = _unselectedText;
            _label.removeClass(":selected");
            removeClass(":selected");
        } else {
            _label.text = _selectedText;
            _label.addClass(":selected");
            addClass(":selected");
        }

        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(event);
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
        return value;
    }

    private var _selectedText:String = "On";
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
    
    private var _unselectedText:String = "Off";
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
    
    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private var _mouseDownOffsetX:Float;
    private var _mouseDownOffsetY:Float;
    private var _down:Bool = false;

    private function _onMouseOver(event:MouseEvent) {
        if (_down == false) {
            addClass(":hover");
        }
    }

    private function _onMouseOut(event:MouseEvent) {
        removeClass(":hover");
    }

    private function _onMouseDown(event:MouseEvent) {
        if (FocusManager.instance.focusInfo != null && FocusManager.instance.focusInfo.currentFocus != null) {
            FocusManager.instance.focusInfo.currentFocus.focus = false;
        }
        _down = true;

        _mouseDownOffsetX = event.screenX;
        _mouseDownOffsetY = event.screenY;
        screen.registerEvent(MouseEvent.MOUSE_UP, _onMouseUp);
    }

    private function _onMouseUp(event:MouseEvent) {
        _down = false;

        //Check if the user makes a click (selected should change) or if the user tries to move the button
        if(MathUtil.distance(event.screenX, event.screenY, _mouseDownOffsetX, _mouseDownOffsetY) < 5) {   //TODO - DPI should be considered
            selected = !selected;
        } else {
            selected = (event.screenX - ((screenLeft + componentWidth) / 2) > 0);
        }

        if (hitTest(event.screenX, event.screenY)) {
            addClass(":hover");
        }

        screen.unregisterEvent(MouseEvent.MOUSE_UP, _onMouseUp);
    }
}

@:dox(hide)
class SwitchLayout extends DefaultLayout {
    public function new() {
        super();
    }

    private override function repositionChildren() {
        var switchComp:Switch = cast _component;
        var button:Button = switchComp.findComponent("switch-button");
        var label:Label = switchComp.findComponent("switch-label");
        if (button == null || label == null) {
            return;
        }
        
        button.top = paddingTop;
        label.top = (component.componentHeight / 2) - (label.componentHeight / 2);
        
        if(switchComp.selected == true) {
            button.left = switchComp.componentWidth - button.componentWidth - paddingRight;
            label.left = (button.componentWidth / 2) - (label.componentWidth / 2);
        } else {
            button.left = paddingLeft;
            label.left = button.left + button.componentWidth + (button.componentWidth / 2) - (label.componentWidth / 2);
        }
    }
}