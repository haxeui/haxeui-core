package haxe.ui.components;

import haxe.ds.StringMap;
import haxe.ui.actions.ActionType;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.constants.Priority;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.Screen;
import haxe.ui.events.ActionEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Timer;
import haxe.ui.util.Variant;
/**
    General purpose push button that supports both text and icon as well as repeat event dispatching

    Composite children:

    | Id             | Type                       | Style Name   | Notes                                  |
    | -------------- | -------------------------- | ------------ | -------------------------------------- |
    | `button-label` | `haxe.ui.components.Label` | `.label`     | The text of the button (if applicable) |
    | `button-icon`  | `haxe.ui.components.Image` | `.icon`      | The icon of the button (if applicable) |

    Pseudo classes:

    | Name      | Notes                                                                    |
    | --------- | ------------------------------------------------------------------------ |
    | `:hover`  | The style to be applied when the cursor is over the button               |
    | `:down`   | The style to be applied when a mouse button is pressed inside the button |
    | `:active` | The style to be applied when the button has focus                        |

    XML example:
    ```xml
    <button text="Button"
            styleNames="myCustomButton"
            style="font-size: 30px"
            onClick="trace('hello world')" />
    ```

    Code example:

    ```haxe
    var button = new Button();
    button.text = "Button";
    button.styleNames = "myCustomButton";
    button.fontSize = 30;
    button.onClick = function(e) {
        trace("hello world");
    }
    ```
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
    @:clonable @:behaviour(DefaultBehaviour, 100)      public var repeatInterval:Int;

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
    
    @:clonable @:behaviour(GroupBehaviour)             public var componentGroup:String;
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

        if (_component.autoWidth == false) {
            var label:Label = component.findComponent(Label, false);
            var ucx:Size = usableSize;
            var cx = ucx.width;
            if (label != null) {
                label.width = cx;
            }
            
            var itemRenderer = component.findComponent(ItemRenderer);
            if (itemRenderer != null) {
                itemRenderer.width = cx;
            }
        }
    }

    private override function get_usableSize():Size {
        var size = super.get_usableSize();
        var icon:Image = component.findComponent("button-icon", false);
        if (icon != null && (iconPosition == "far-right" || iconPosition == "far-left" || iconPosition == "left" || iconPosition == "right")) {
            size.width -= icon.width + verticalSpacing;
        }
        return size;
    }
    
    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var exclusions:Array<Component> = [];
        var itemRenderer = component.findComponent(ItemRenderer);
        var icon:Image = component.findComponent("button-icon", false);
        if (itemRenderer != null && isIconRelevant()) {
            exclusions.push(icon);
        }
        var size = super.calcAutoSize(exclusions);
        if (itemRenderer != null && isIconRelevant()) {
            size.width += icon.width + verticalSpacing;
        }
        return size;
    }
    
    private inline function isIconRelevant() {
        var icon:Image = component.findComponent("button-icon", false);
        return icon != null && (iconPosition == "far-right" || iconPosition == "far-left" || iconPosition == "left" || iconPosition == "right");
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
                    icon.left = (component.componentWidth - icon.componentWidth - paddingRight) + marginLeft(icon) - marginRight(icon);
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
private class GroupBehaviour extends DataBehaviour {
    public override function validateData() {
        ButtonGroups.instance.add(_value, cast _component);
    }
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    public override function get():Variant {
        var itemRenderer = _component.findComponent(ItemRenderer);
        if (itemRenderer == null) {
            return super.get();
        } else {
            if (!_component.isReady) {
                return super.get();
            } else {
                var data:Dynamic = itemRenderer.data;
                var text = null;
                if (data != null) {
                    if (Type.typeof(data) == TObject) {
                        text = data.text;
                        if (text == null) {
                            text = data.value;
                        }
                    } else {
                        text = Std.string(data);
                    }
                }
                return text;
            }
        }
    }
    
    private override function validateData() {
        var itemRenderer = _component.findComponent(ItemRenderer);
        if (itemRenderer != null) {
            var data:Dynamic = itemRenderer.data;
            if (data == null) {
                data = {};
            } else {
                data = Reflect.copy(data);
            }
            data.text = _value.toString();
            itemRenderer.data = data;
        } else {
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
}

@:dox(hide) @:noCompletion
private class IconBehaviour extends DataBehaviour {
    private override function validateData() {
        var icon:Image = _component.findComponent("button-icon", false);

        if ((_value == null || _value.isNull) && icon != null) {
            _component.customStyle.icon = null;
            _component.removeComponent(icon);
            return;
        }
        
        if (icon == null) {
            icon = new Image();
            icon.addClass("icon");
            icon.id = "button-icon";
            icon.scriptAccess = false;
            _component.addComponentAt(icon, 0);
            _component.invalidateComponentStyle(true);
        }

        //_component.customStyle.icon = _value;
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

        cast(button._compositeBuilder, ButtonBuilder).setSelection(button, _value);
        
        if (_value == false) {
            button.removeClass(":down", true, true);
        } else {
            button.addClass(":down", true, true);
        }
        var events = cast(button._internalEvents, ButtonEvents);
        if (button.hitTest(Screen.instance.currentMouseX, Screen.instance.currentMouseY)) {
            button.addClass(":hover", true, true);
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

    public var recursiveStyling:Bool = true;
    
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
        if (hasEvent(ActionEvent.ACTION_START, onActionStart) == false) {
            registerEvent(ActionEvent.ACTION_START, onActionStart);
        }
        if (hasEvent(ActionEvent.ACTION_END, onActionEnd) == false) {
            registerEvent(ActionEvent.ACTION_END, onActionEnd);
        }

        if (_button.toggle == true) {
            // we want to add the event as high so it gets called first before any user handlers
            // this is because if its a toggle we want the .selected property to refect the actual
            // value which is set as part of this handler
            registerEvent(MouseEvent.CLICK, onMouseClick, Priority.HIGH);
        }
    }

    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        unregisterEvent(MouseEvent.CLICK, onMouseClick);
        unregisterEvent(UIEvent.MOVE, onMove);
        unregisterEvent(ActionEvent.ACTION_START, onActionStart);
        unregisterEvent(ActionEvent.ACTION_END, onActionEnd);
    }

    private function onMouseOver(event:MouseEvent) {
        if (_button.toggle == true && _button.hasClass(":down")) {
            return;
        }

        if (event.buttonDown == false || _down == false) {
            _button.addClass(":hover", true, recursiveStyling);
        } else {
            _button.addClass(":down", true, recursiveStyling);
        }
    }

    private function onMouseOut(event:MouseEvent) {
        if (_button.toggle == true && _button.selected == true) {
            return;
        }

        if (_button.remainPressed == false) {
            _button.removeClass(":down", true, recursiveStyling);
        }
        _button.removeClass(":hover", true, recursiveStyling);
    }

    private function onMouseDown(event:MouseEvent) {
        _button.focus = true;
        if (_button.repeater == true && _repeatInterval == 0) {
            _repeatInterval = (_button.easeInRepeater) ? _button.repeatInterval * 2 : _button.repeatInterval;
        }
        _down = true;
        _button.addClass(":down", true, recursiveStyling);
        _button.screen.registerEvent(MouseEvent.MOUSE_UP, onMouseUp);
        if (_repeater == true && _repeatInterval == _button.repeatInterval) {
            _repeatTimer = new Timer(_repeatInterval, onRepeatTimer);
        } else if (_button.repeater == true) {
            if (_repeatTimer != null) {
                _repeatTimer.stop();
                _repeatTimer = null;
            }
            Timer.delay(function() {
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

    private function onMouseUp(event:MouseEvent) {
        //event.cancel();
        _down = _repeater = false;
        _repeatInterval = (_button.easeInRepeater) ? _button.repeatInterval * 2 : _button.repeatInterval;
        _button.screen.unregisterEvent(MouseEvent.MOUSE_UP, onMouseUp);

        if (_button.toggle == true) {
            return;
        }

        _button.removeClass(":down", true, recursiveStyling);
        var over = _button.hitTest(event.screenX, event.screenY);
        if (event.touchEvent == false && over == true) {
            _button.addClass(":hover", true, recursiveStyling);
        } else if (over == false) {
            _button.removeClass(":hover", true, recursiveStyling);
        }

        if (_repeatTimer != null) {
            _repeatTimer.stop();
            _repeatTimer = null;
        }
    }

    private function onMove(event:UIEvent) {
        var over = _button.hitTest(Screen.instance.currentMouseX, Screen.instance.currentMouseY);
        if (over == true) {
            _button.addClass(":hover", true, recursiveStyling);
        } else if (over == false) {
            _button.removeClass(":hover", true, recursiveStyling);
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
            _button.removeClass(":down", true, recursiveStyling);
        }
        if (_button.hitTest(event.screenX, event.screenY)) {
            _button.addClass(":hover", true, recursiveStyling);
        }
    }

    private function dispatchChanged() {
        _button.dispatch(new UIEvent(UIEvent.CHANGE));
    }
    
    private function press() {
        _down = true;
        if (_button.toggle == true) {
            _button.addClass(":down", true, recursiveStyling);
        } else {
            _button.addClass(":down", true, recursiveStyling);
        }
    }
    
    private function release() {
        if (_down == true) {
            _down = false;
            if (_button.toggle == true) {
                _button.selected = !_button.selected;
                _button.dispatch(new MouseEvent(MouseEvent.CLICK));
            } else {
                _button.removeClass(":down", true, recursiveStyling);
                _button.dispatch(new MouseEvent(MouseEvent.CLICK));
            }
        }
    }
    
    private function onActionStart(event:ActionEvent) {
        switch (event.action) {
            case ActionType.PRESS | ActionType.CONFIRM:
                press();
            case _:    
        }
    }
    
    private function onActionEnd(event:ActionEvent) {
        switch (event.action) {
            case ActionType.PRESS | ActionType.CONFIRM:
                release();
            case _:    
        }
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

    public override function onReady() {
        super.onReady();
        
        var renderer = _button.findComponent(ItemRenderer);
        if (renderer != null) {
            if (!_button.autoWidth) {
                renderer.removeClass("auto-size");
            } else {
                renderer.addClass("auto-size");
            }
        }
    }
    
    public override function applyStyle(style:Style) {
        super.applyStyle(style);
        
        haxe.ui.macros.ComponentMacros.cascacdeStylesTo("button-label", [
            color, fontName, fontSize, cursor, textAlign, fontBold, fontUnderline, fontItalic
        ], false);
        haxe.ui.macros.ComponentMacros.cascacdeStylesTo("button-icon", [cursor], false);
        haxe.ui.macros.ComponentMacros.cascacdeStylesToList(Label, [
            color, fontName, fontSize, cursor, textAlign, fontBold, fontUnderline, fontItalic
        ]);
        
        if (style.icon != null) {
            _button.icon = style.icon;
        } else {
            //_button.icon = null;
        }
    }
    
    public function setSelection(button:Button, value:Bool, allowDeselection:Bool = false) {
        if (button.componentGroup != null && value == false && allowDeselection == false) { // dont allow false if no other group selection
            var arr:Array<Button> = ButtonGroups.instance.get(button.componentGroup);
            var hasSelection:Bool = false;
            if (arr != null) {
                for (b in arr) {
                    if (b != button && b.selected == true) {
                        hasSelection = true;
                        break;
                    }
                }
            }
            if (hasSelection == false && allowDeselection == false) {
                button.behaviours.softSet("selected", true);
                return;
            }
        }

        if (button.componentGroup != null && value == true) { // set all the others in group
            var arr:Array<Button> = ButtonGroups.instance.get(button.componentGroup);
            if (arr != null) {
                for (b in arr) {
                    if (b != button) {
                        b.selected = false;
                    }
                }
            }
        }

        if (allowDeselection == true && value == false) {
            button.behaviours.softSet("selected", false);
        }
    }
    
    public override function addComponent(child:Component):Component {
        if ((child is ItemRenderer)) {
            var existingRenderer = _component.findComponent(ItemRenderer);
            if (existingRenderer != null) {
                _component.removeComponent(existingRenderer);
            }
            child.addClass("auto-size");
        }
        return null;
    }
}

//***********************************************************************************************************
// Util classes
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class ButtonGroups { // singleton
    private static var _instance:ButtonGroups;
    public static var instance(get, null):ButtonGroups;
    private static function get_instance():ButtonGroups {
        if (_instance == null) {
            _instance = new ButtonGroups();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance methods
    //***********************************************************************************************************
    private var _groups:StringMap<Array<Button>> = new StringMap<Array<Button>>();
    private function new () {
    }

    public function get(name:String):Array<Button> {
        return _groups.get(name);
    }

    public function set(name:String, buttons:Array<Button>) {
        _groups.set(name, buttons);
    }

    public function add(name:String, button:Button) {
        var arr:Array<Button> = get(name);
        if (arr == null) {
            arr = [];
        }

        if (arr.indexOf(button) == -1) {
            arr.push(button);
        }
        set(name, arr);
    }
    
    public function remove(name:String, button:Button) {
        var arr:Array<Button> = get(name);
        if (arr == null) {
            return;
        }
        
        arr.remove(button);
        if (arr.length == 0) {
            _groups.remove(name);
        }
    }
    
    public function reset(name:String) {
        var arr:Array<Button> = get(name);
        if (arr == null) {
            return;
        }
        
        var selection = null;
        for (item in arr) {
            if (item.selected == true) {
                selection = item;
                break;
            }
        }
        
        if (selection == null) {
            return;
        }
        
        cast(selection._compositeBuilder, ButtonBuilder).setSelection(selection, false, true);
    }
}