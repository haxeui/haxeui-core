package haxe.ui.components;

import haxe.ui.core.Behaviour;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Timer;
import haxe.ui.util.Variant;

class Button extends InteractiveComponent {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    @:style(layout)                         public var iconPosition:String;
    @:style(layout)                         public var fontSize:Null<Float>;
    @:style(layout)                         public var textAlign:String;
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DefaultBehaviour, false)    public var repeater:Bool;
    @:behaviour(DefaultBehaviour, 50)       public var repeatInterval:Int;
    @:behaviour(DefaultBehaviour, false)    public var remainPressed:Bool;
    @:behaviour(ToggleBehaviour)            public var toggle:Bool;
    @:behaviour(SelectedBehaviour)          public var selected:Bool;
    @:behaviour(TextBehaviour)              public var text:String;
    @:behaviour(IconBehaviour)              public var icon:String;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {  // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayout = new ButtonLayout();
    }
    
    private override function createChildren() {
        super.createChildren();
        
        registerInternalEvents(Events);
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function applyStyle(style:Style) {  // TODO: remove this eventually, @:styleApplier(...) or something
        super.applyStyle(style);
        if (style.icon != null) {
            icon = style.icon;
        }

        var label:Label = findComponent(Label);
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

        var icon:Image = findComponent(Image);
        if (icon != null && (icon.customStyle.cursor != style.cursor)) {
            icon.customStyle.cursor = style.cursor;
            icon.invalidateComponentStyle();
        }
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class ButtonLayout extends DefaultLayout {
    private var iconPosition(get, null):String;
    private function get_iconPosition():String {
        if (component.style == null || component.style.iconPosition == null) {
            return "left";
        }
        return component.style.iconPosition;
    }

    private override function repositionChildren() {
        super.repositionChildren();

        var label:Label = component.findComponent(Label, false);
        var icon:Image = component.findComponent(Image, false);

        switch (iconPosition) {
            case "far-right":
                if (label != null && icon != null) {
                    var cx:Float = label.componentWidth + icon.componentWidth + horizontalSpacing;
                    var x:Float = Std.int((component.componentWidth / 2) - (cx / 2));

                    if (iconPosition == "far-right") {
                        if (cx + paddingLeft + paddingRight < component.componentWidth) {
                            label.left = paddingLeft;
                            x += horizontalSpacing + label.componentWidth;
                            icon.left = (component.componentWidth - icon.componentWidth - paddingRight) + marginLeft(icon) - marginRight(icon);
                        } else {
                            label.left = paddingLeft;
                            x += horizontalSpacing + label.componentWidth;
                            icon.left = x + marginLeft(icon) - marginRight(icon);
                        }

                    }

                    label.top = Std.int((component.componentHeight / 2) - (label.componentHeight / 2)) + marginTop(label) - marginBottom(label);
                    icon.top = Std.int((component.componentHeight / 2) - (icon.componentHeight / 2)) + marginTop(icon) - marginBottom(icon);
                } else if (label != null) {
                    label.left = paddingLeft;
                    label.top = Std.int((component.componentHeight / 2) - (label.componentHeight / 2)) + marginTop(label) - marginBottom(label);
                } else if (icon != null) {
                    icon.left = Std.int((component.componentWidth / 2) - (icon.componentWidth / 2)); // + marginLeft(icon) - marginRight(icon);
                    icon.top = Std.int((component.componentHeight / 2) - (icon.componentHeight / 2)) + marginTop(icon) - marginBottom(icon);
                }
            case "left" | "right":
                if (label != null && icon != null) {
                    var cx:Float = label.componentWidth + icon.componentWidth + horizontalSpacing;
                    var x:Float = Std.int((component.componentWidth / 2) - (cx / 2));

                    if (iconPosition == "right") {
                        label.left = x + marginLeft(label) - marginRight(label);
                        x += horizontalSpacing + label.componentWidth;
                        icon.left = x + marginLeft(icon) - marginRight(icon);
                    } else {
                        icon.left = x + marginLeft(icon) - marginRight(icon);
                        x += horizontalSpacing + icon.componentWidth;
                        label.left = x + marginLeft(label) - marginRight(label);
                    }

                    label.top = Std.int((component.componentHeight / 2) - (label.componentHeight / 2)) + marginTop(label) - marginBottom(label);
                    icon.top = Std.int((component.componentHeight / 2) - (icon.componentHeight / 2)) + marginTop(icon) - marginBottom(icon);
                } else if (label != null) {
                    label.left = getTextAlignPos(label, component.componentWidth);
                    label.top = Std.int((component.componentHeight / 2) - (label.componentHeight / 2)) + marginTop(label) - marginBottom(label);
                } else if (icon != null) {
                    icon.left = Std.int((component.componentWidth / 2) - (icon.componentWidth / 2)); // + marginLeft(icon) - marginRight(icon);
                    icon.top = Std.int((component.componentHeight / 2) - (icon.componentHeight / 2)) + marginTop(icon) - marginBottom(icon);
                }
            case "top" | "bottom":
                if (label != null && icon != null) {
                    var cy:Float = label.componentHeight + icon.componentHeight + verticalSpacing;
                    var y:Float = Std.int((component.componentHeight / 2) - (cy / 2));

                    if (iconPosition == "bottom") {
                        label.top = y + marginTop(label) - marginBottom(label);
                        y += verticalSpacing + label.componentHeight;
                        icon.top = y + marginTop(icon) - marginBottom(icon);
                    } else {
                        icon.top = y + marginTop(icon) - marginBottom(icon);
                        y += verticalSpacing + icon.componentHeight;
                        label.top = y + marginTop(label) - marginBottom(label);
                    }

                    label.left = getTextAlignPos(label, component.componentWidth);
                    icon.left = Std.int((component.componentWidth / 2) - (icon.componentWidth / 2)) + marginLeft(icon) - marginRight(icon);
                } else if (label != null) {
                    label.left = Std.int((component.componentWidth / 2) - (label.componentWidth / 2)) + marginLeft(label) - marginRight(label);
                    label.top = Std.int((component.componentHeight / 2) - (label.componentHeight / 2)) + marginTop(label) - marginBottom(label);
                } else if (icon != null) {
                    icon.left = Std.int((component.componentWidth / 2) - (icon.componentWidth / 2)) + marginLeft(icon) - marginRight(icon);
                    icon.top = Std.int((component.componentHeight / 2) - (icon.componentHeight / 2)) + marginTop(icon) - marginBottom(icon);
                }
        }
    }

    private function getTextAlignPos(label:Label, usableWidth:Float):Float {
        switch (cast(component, Button).textAlign) {
            case "left":
                return marginLeft(label) + paddingLeft;
            case "right":
                return usableWidth - label.componentWidth - marginRight(label) - paddingRight;
            default:
                return Std.int((usableWidth / 2) - (label.componentWidth / 2)) + marginLeft(label) - marginRight(label);
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
            label.id = "button-label";
            label.scriptAccess = false;
            _component.addComponent(label);
        }
        
        label.text = _value;
    }
}

@:dox(hide) @:noCompletion
private class IconBehaviour extends DataBehaviour {
    private override function validateData() {
        var icon:Image = _component.findComponent(Image, false);
        if (icon == null) {
            icon = new Image();
            icon.addClass("icon");
            icon.id = "button-icon";
            icon.scriptAccess = false;
            _component.addComponentAt(icon, 0);
        }
        
        icon.resource = _value;
    }
}


@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Button)
private class ToggleBehaviour extends Behaviour {
    private var _value:Variant;
    
    public override function get():Variant {
        return _value;
    }
    
    public override function set(value:Variant) {
        if (_value == value) {
            return;
        }
        
        _value = value;
        var button:Button = cast(_component, Button);
        if (value == false) {
            button.selected = false;
        }
        button.registerInternalEvents(Events, true);
    }
}

@:dox(hide) @:noCompletion
private class SelectedBehaviour extends Behaviour {
    private var _value:Variant;
    
    public override function get():Variant {
        return _value;
    }
    
    public override function set(value:Variant) {
        var button:Button = cast(_component, Button);
        if (_value == value || button.toggle == false) {
            return;
        }
        
        _value = value;
        if (value == false) {
            button.removeClass(":down");
        } else {
            button.addClass(":down");
        }
        button.removeClass(":hover");
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.core.Events {
    private var _button:Button;
    private var _down:Bool = false;
    private var _repeatTimer:Timer;
    
    public function new(button:Button) {
        super(button);
        _button = button;
    }
    
    public override function register() {
        if (hasEvent(MouseEvent.MOUSE_OVER, onMouseOver) == false) {
            registerEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        }
        if (hasEvent(MouseEvent.MOUSE_OUT, onMouseOut) == false) {
            registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        }
        if (hasEvent(MouseEvent.MOUSE_DOWN, onMouseDown) == false) {
            registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
        
        if (_button.toggle == true && hasEvent(MouseEvent.CLICK, onMouseClick) == false) {
            registerEvent(MouseEvent.CLICK, onMouseClick);
        } else {
            unregisterEvent(MouseEvent.CLICK, onMouseClick);
        }
    }
    
    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
    }
    
    private function onMouseOver(event:MouseEvent) {
        if (_button.toggle == true && _button.hasClass(":down")) {
            return;
        }

        if (event.buttonDown == false || _down == false) {
            _button.addClass(":hover");
        } else {
            _button.addClass(":down");
        }
    }
    
    private function onMouseOut(event:MouseEvent) {
        if (_button.toggle == true && _button.selected == true) {
            return;
        }

        if (_button.remainPressed == false) {
            _button.removeClass(":down");
        }
        _button.removeClass(":hover");
    }
    
    private function onMouseDown(event:MouseEvent) {
        if (FocusManager.instance.focusInfo != null && FocusManager.instance.focusInfo.currentFocus != null) {
            FocusManager.instance.focusInfo.currentFocus.focus = false;
        }
        _down = true;
        _button.addClass(":down");
        _button.screen.registerEvent(MouseEvent.MOUSE_UP, onMouseUp);

        if (_button.repeater == true) {
            _repeatTimer = new Timer(_button.repeatInterval, onRepeatTimer);
        }
    }
    
    private function onMouseUp(event:MouseEvent) {
        //event.cancel();
        _down = false;
        _button.screen.unregisterEvent(MouseEvent.MOUSE_UP, onMouseUp);

        if (_button.toggle == true) {
            return;
        }

        _button.removeClass(":down");
        if (event.touchEvent == false && _button.hitTest(event.screenX, event.screenY)) {
            _button.addClass(":hover");
        }

        if (_repeatTimer != null) {
            _repeatTimer.stop();
            _repeatTimer = null;
        }
    }
    
    private function onRepeatTimer() {
        if (_button.hasClass(":hover") && _down == true) {
            var event:MouseEvent = new MouseEvent(MouseEvent.CLICK);
            _button.dispatch(event);
        }
    }
    
    private function onMouseClick(event:MouseEvent) {
        _button.selected = !_button.selected;
        if (_button.selected == false) {
            _button.removeClass(":down");
        }
    }
}
