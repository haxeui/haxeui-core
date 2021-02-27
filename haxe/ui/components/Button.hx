package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Timer;
import haxe.ui.util.Variant;
/**
 General purpose push button that supports both text and icon as well as repeat event dispatching

 Composite children:
    | Id             | Type                       | Style Name   | Notes                                  |
    | `button-label` | `haxe.ui.components.Label` | `.label`     | The text of the button (if applicable) |
    | `button-icon`  | `haxe.ui.components.Image` | `.icon`      | The icon of the button (if applicable) |

 Pseudo classes:
    | Name      | Notes                                                                    |
    | `:hover`  | The style to be applied when the cursor is over the button               |
    | `:down`   | The style to be applied when a mouse button is pressed inside the button |
    | `:active` | The style to be applied when the button has focus                        |

  XML example:
    <button text="Button"
            styleNames="myCustomButton"
            style="font-size: 30px"
            onClick="trace('hello world')" />

  Code example:
    var button = new Button();
    button.text = "Button";
    button.styleNames = "myCustomButton";
    button.fontSize = 30;
    button.onClick = function(e) {
        trace("hello world");
    }
**/

@:dox(icon = "ui-button.png")
@:composite(ButtonEvents, ButtonBuilder, ButtonLayout)
class Button extends InteractiveComponent {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    @:style(layout)                                     public var iconPosition:String;
    @:style(layout)                                     public var fontSize:Null<Float>;
    @:style(layout)                                     public var textAlign:String;

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    /**
     Whether this button will dispatch multiple click events while the the mouse is pressed within it
    **/
    @:clonable @:behaviour(DefaultBehaviour, false)    public var repeater:Bool;

    /**
     How often this button will dispatch multiple click events while the the mouse is pressed within it
    **/
    @:clonable @:behaviour(DefaultBehaviour, 50)       public var repeatInterval:Int;

    /**
     Whether this button will ease in to specified repeatInterval
    **/
    @:clonable @:behaviour(DefaultBehaviour, false)    public var easeInRepeater:Bool;

    /**
     Whether the buttons state should remain pressed even when the mouse has left its bounds
    **/
    @:clonable @:behaviour(DefaultBehaviour, false)    public var remainPressed:Bool;

    /**
     Whether this button should behave as a toggle button or not
    **/
    @:clonable @:behaviour(ToggleBehaviour)            public var toggle:Bool;

    /**
     Whether this button is toggled or not (only relavant if toggle = true)
    **/
    @:clonable @:behaviour(SelectedBehaviour)           public var selected:Bool;

    /**
     The text (label) of this button
    **/
    @:clonable @:behaviour(TextBehaviour)              public var text:String;

    /**
     The value of this button, which is equivelant to its text
    **/
    @:clonable @:value(text)                           public var value:Dynamic;

    /**
     The image resource to use as the buttons icon
    **/
    @:clonable @:behaviour(IconBehaviour)              public var icon:Variant;

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function applyStyle(style:Style) { // TODO: is this the only one? Is it really worth a macro??
        super.applyStyle(style);
        if (style.icon != null) {
            icon = style.icon;
        }
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class ButtonLayout extends DefaultLayout {
    private var iconPosition(get, null):String;
    private function get_iconPosition():String {
        if (component.style == null || component.style.iconPosition == null) {
            return "left";
        }
        return component.style.iconPosition;
    }

    private override function resizeChildren() {
        super.resizeChildren();

        var label:Label = component.findComponent(Label, false);
        var icon:Image = component.findComponent("button-icon", false);
        if (_component.autoWidth == false) {
            var ucx:Size = usableSize;
            if (label != null) {
                var cx = ucx.width;
                if (icon != null && (iconPosition == "far-right" || iconPosition == "far-left" || iconPosition == "left" || iconPosition == "right")) {
                    cx -= icon.width + verticalSpacing;
                }
                label.width = cx;
            }
        }
    }

    private override function repositionChildren() {
        super.repositionChildren();

        var label:Label = component.findComponent(Label, false);
        if (label != null && label.hidden == true) {
            label = null;
        }
        var icon:Image = component.findComponent("button-icon", false);
        if (icon != null && icon.hidden == true) {
            icon = null;
        }
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
            case "far-left":
                if (label != null && icon != null) {
                    var x:Float = paddingLeft;

                    if (iconPosition == "far-left") {
                        icon.left = x + marginLeft(icon) - marginRight(icon);
                        x += horizontalSpacing + icon.componentWidth;
                        label.left = x + marginLeft(label) - marginRight(label);
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
                    if (cast(component, Button).textAlign == "left") {
                        x = paddingLeft;
                    }

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
            _component.invalidateComponentStyle(true);
        }

        label.text = _value;
    }
}

@:dox(hide) @:noCompletion
private class IconBehaviour extends DataBehaviour {
    private override function validateData() {
        var icon:Image = _component.findComponent("button-icon", false);
        if (icon == null) {
            icon = new Image();
            icon.addClass("icon");
            icon.id = "button-icon";
            icon.scriptAccess = false;
            _component.addComponentAt(icon, 0);
            _component.invalidateComponentStyle(true);
        }

        icon.resource = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
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
        button.registerInternalEvents(button._internalEventsClass, true);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.ButtonEvents)
private class SelectedBehaviour extends DataBehaviour {
    private override function validateData() {
        var button:Button = cast(_component, Button);
        if (button.toggle == false) {
            return;
        }

        if (_value == false) {
            button.removeClass(":down", true, true);
        } else {
            button.addClass(":down", true, true);
        }
        var events = cast(button._internalEvents, ButtonEvents);
        if (events.lastMouseEvent != null && button.hitTest(events.lastMouseEvent.screenX, events.lastMouseEvent.screenY)) {
            button.addClass(":hover", true, true);
            events.lastMouseEvent = null;
        } else {
            button.removeClass(":hover", true, true);
        }
        events.dispatchChanged();
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class ButtonEvents extends haxe.ui.events.Events {
    private var _button:Button;
    private var _down:Bool = false;
    private var _repeatTimer:Timer;
    private var _repeater:Bool = false;
    private var _repeatInterval:Int = 0;

    public var lastMouseEvent:MouseEvent = null;

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
        if (hasEvent(UIEvent.MOVE, onMove) == false) {
            registerEvent(UIEvent.MOVE, onMove);
        }

        if (_button.toggle == true) {
            registerEvent(MouseEvent.CLICK, onMouseClick);
        }
    }

    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        unregisterEvent(MouseEvent.CLICK, onMouseClick);
        unregisterEvent(UIEvent.MOVE, onMove);
    }

    private function onMouseOver(event:MouseEvent) {
        if (_button.toggle == true && _button.hasClass(":down")) {
            return;
        }

        if (event.buttonDown == false || _down == false) {
            _button.addClass(":hover", true, true);
        } else {
            _button.addClass(":down", true, true);
        }
    }

    private function onMouseOut(event:MouseEvent) {
        if (_button.toggle == true && _button.selected == true) {
            return;
        }

        if (_button.remainPressed == false) {
            _button.removeClass(":down", true, true);
        }
        _button.removeClass(":hover", true, true);
    }

    private function onMouseDown(event:MouseEvent) {
        if (_button.allowFocus == true && FocusManager.instance.focusInfo != null && FocusManager.instance.focusInfo.currentFocus != null) {
            FocusManager.instance.focusInfo.currentFocus.focus = false;
        }
        if (_button.repeater == true && _repeatInterval == 0) {
            _repeatInterval = (_button.easeInRepeater) ? _button.repeatInterval * 2 : _button.repeatInterval;
        }
        _down = true;
        _button.addClass(":down", true, true);
        _button.screen.registerEvent(MouseEvent.MOUSE_UP, onMouseUp);
        if (_repeater == true && _repeatInterval == _button.repeatInterval) {
            _repeatTimer = new Timer(_repeatInterval, onRepeatTimer);
        } else if (_button.repeater == true) {
            if (_repeatTimer != null) {
                _repeatTimer.stop();
                _repeatTimer = null;
            }
            Timer.delay(function():Void {
                if (_repeater == true && _repeatTimer == null) {
                    if (_button.easeInRepeater == true && _repeatInterval > _button.repeatInterval) {
                        _repeatInterval = Std.int(_repeatInterval - (_repeatInterval - _button.repeatInterval) / 2);
                        onRepeatTimer();
                    }
                    onMouseDown(event);
                }
            }, _repeatInterval);
        }
        _repeater = _button.repeater;
    }

    private var _lastScreenEvent:MouseEvent = null;
    private function onMouseUp(event:MouseEvent) {
        //event.cancel();
        _down = _repeater = false;
        _repeatInterval = (_button.easeInRepeater) ? _button.repeatInterval * 2 : _button.repeatInterval;
        _button.screen.unregisterEvent(MouseEvent.MOUSE_UP, onMouseUp);

        if (_button.toggle == true) {
            return;
        }

        _lastScreenEvent = event;
        _button.removeClass(":down", true, true);
        var over = _button.hitTest(event.screenX, event.screenY);
        if (event.touchEvent == false && over == true) {
            _button.addClass(":hover", true, true);
        } else if (over == false) {
            _button.removeClass(":hover", true, true);
        }

        if (_repeatTimer != null) {
            _repeatTimer.stop();
            _repeatTimer = null;
        }
    }

    private function onMove(event:UIEvent) {
        if (_lastScreenEvent == null) {
            return;
        }

        var over = _button.hitTest(_lastScreenEvent.screenX, _lastScreenEvent.screenY);
        if (_lastScreenEvent.touchEvent == false && over == true) {
            _button.addClass(":hover", true, true);
        } else if (over == false) {
            _button.removeClass(":hover", true, true);
        }
        
        _lastScreenEvent = null;
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
            _button.removeClass(":down", true, true);
        }
        if (_button.hitTest(event.screenX, event.screenY)) {
            _button.addClass(":hover", true, true);
        }
    }

    private function dispatchChanged() {
        _button.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class ButtonBuilder extends CompositeBuilder {
    private var _button:Button;

    public function new(button:Button) {
        super(button);
        _button = button;
    }

    public override function applyStyle(style:Style) {
        var label:Label = _button.findComponent(Label);
        if (label != null &&
            (label.customStyle.color != style.color ||
            label.customStyle.fontName != style.fontName ||
            label.customStyle.fontSize != style.fontSize ||
            label.customStyle.cursor != style.cursor ||
            label.customStyle.textAlign != style.textAlign)) {

            label.customStyle.color = style.color;
            label.customStyle.fontName = style.fontName;
            label.customStyle.fontSize = style.fontSize;
            label.customStyle.cursor = style.cursor;
            label.customStyle.textAlign = style.textAlign;
            label.invalidateComponentStyle();
        }

        var icon:Image = _button.findComponent("button-icon", false);
        if (icon != null && (icon.customStyle.cursor != style.cursor)) {
            icon.customStyle.cursor = style.cursor;
            icon.invalidateComponentStyle();
        }
    }
}