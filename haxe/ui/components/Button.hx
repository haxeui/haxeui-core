package haxe.ui.components;

import haxe.ui.validation.InvalidationFlags;
import haxe.ui.core.Behaviour;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Timer;
import haxe.ui.util.Variant;

/**
 General purpose push button that supports both text and icon as well as repeat event dispatching
 
 Composite children:
    | Id             | Type    | Style Name   | Notes                                  |
    | `button-label` | `Label` | `.label`     | The text of the button (if applicable) |
    | `button-icon`  | `Image` | `.icon`      | The icon of the button (if applicable) |
 
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
@:dox(icon = "/icons/ui-button.png")
class Button extends InteractiveComponent {
    private var _repeatTimer:Timer;

    public function new() {
        super();
        #if openfl
        //mouseChildren = false;
        #end
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "text" => new ButtonDefaultTextBehaviour(this),
            "icon" => new ButtonDefaultIconBehaviour(this)
        ]);
        _defaultLayout = new ButtonLayout();
    }

    private override function createChildren() {
        registerEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
    }

    private override function destroyChildren() {
        super.destroyChildren();

        unregisterEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        unregisterEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);

        var label:Label = findComponent(Label);
        if (label != null) {
            removeComponent(label);
            label = null;
        }

        var icon:Image = findComponent(Image);
        if (icon != null) {
            removeComponent(icon);
            icon = null;
        }
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function set_text(value:String):String {
        value = super.set_text(value);
        invalidateComponentData();
        return value;
    }

    private override function applyStyle(style:Style) {
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

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private override function validateData() {
        if (behaviourGet("text") != _text) {
            behaviourSet("text", _text);
        }

        if (behaviourGet("icon") != _iconResource) {
            behaviourSet("icon", _iconResource);
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    /**
     Whether the buttons state should remain pressed even when the mouse has left its bounds
    **/
    @:clonable public var remainPressed(default, default):Bool = false;

    /**
     Whether this button will dispatch multiple click events while the the mouse is pressed within it
    **/
    @:dox(group = "Repeater related properties")
    @:clonable public var repeater(default, default):Bool = false;

    /**
     How often this button will dispatch multiple click events while the the mouse is pressed within it
    **/
    @:dox(group = "Repeater related properties")
    @:clonable public var repeatInterval(default, default):Int = 50;

    private var _iconResource:String;
    /**
     The image resource to use as the buttons icon
    **/
    @:clonable public var icon(get, set):String;
    private function get_icon():String {
        return _iconResource; // TODO: temp
    }

    private function set_icon(value:String):String {
        if (_iconResource == value) {
            return value;
        }

        _iconResource = value;
        invalidateComponentData();
        return value;
    }

    @:style(layout)   public var iconPosition:String;
    @:style(layout)   public var fontSize:Null<Float>;
    @:style(layout)   public var textAlign:String;

    /**
     Whether this button should behave as a toggle button or not
    **/
    private var _toggle:Bool;
    @:clonable public var toggle(get, set):Bool;
    private function get_toggle():Bool {
        return _toggle;
    }
    private function set_toggle(value:Bool):Bool {
        if (value == _toggle) {
            return value;
        }

        if (value == false) {
            unregisterEvent(MouseEvent.CLICK, _onMouseClick);
            selected = false;
        } else {
            registerEvent(MouseEvent.CLICK, _onMouseClick);
        }

        _toggle = value;
        return value;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private var _down:Bool = false;
    private function _onMouseOver(event:MouseEvent) {
        if (_toggle == true && hasClass(":down")) {
            return;
        }

        if (event.buttonDown == false || _down == false) {
            addClass(":hover");
        } else {
            addClass(":down");
        }
    }

    private function _onMouseOut(event:MouseEvent) {
        if (_toggle == true && _selected == true) {
            return;
        }

        if (remainPressed == false) {
            removeClass(":down");
        }
        removeClass(":hover");
    }

    private function _onMouseDown(event:MouseEvent) {
        if (FocusManager.instance.focusInfo != null && FocusManager.instance.focusInfo.currentFocus != null) {
            FocusManager.instance.focusInfo.currentFocus.focus = false;
        }
        _down = true;
        addClass(":down");
        screen.registerEvent(MouseEvent.MOUSE_UP, _onMouseUp);

        if (repeater == true) {
            _repeatTimer = new Timer(repeatInterval, _onRepeatTimer);
        }
    }

    private function _onRepeatTimer() {
        if (hasClass(":hover") && _down == true) {
            var event:MouseEvent = new MouseEvent(MouseEvent.CLICK);
            dispatch(event);
        }
    }

    private function _onMouseUp(event:MouseEvent) {
        event.cancel();
        _down = false;
        screen.unregisterEvent(MouseEvent.MOUSE_UP, _onMouseUp);

        if (_toggle == true) {
            return;
        }

        removeClass(":down");
        if (event.touchEvent == false && hitTest(event.screenX, event.screenY)) {
            addClass(":hover");
        }

        if (_repeatTimer != null) {
            _repeatTimer.stop();
            _repeatTimer = null;
        }
    }

    private function _onMouseClick(event:MouseEvent) {
        _selected = !_selected;
        if (_selected == false) {
            removeClass(":down");
        }
    }

    private var _selected:Bool = false;
    public var selected(get, set):Bool;
    private function get_selected():Bool {
        return _selected;
    }
    private function set_selected(value:Bool):Bool {
        if (value == _selected || _toggle == false) {
            return value;
        }
        _selected = value;
        if (_selected == false) {
            removeClass(":down");
        } else {
            addClass(":down");
        }
        removeClass(":hover");
        return value;
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Button)
class ButtonDefaultTextBehaviour extends Behaviour {
    public override function set(value:Variant) {
        if (value.isNull) {
            return;
        }

        var button:Button = cast _component;
        var label:Label = button.findComponent(Label);
        if (label == null) {
            label = new Label();
            label.id = "button-label";
            label.scriptAccess = false;
            button.addComponent(label);
        }
        label.text = value;
    }
}

@:dox(hide)
@:access(haxe.ui.components.Button)
class ButtonDefaultIconBehaviour extends Behaviour {
    public override function get():Variant {
        var button:Button = cast _component;
        var icon:Image = button.findComponent(Image);
        if (icon == null) {
            return null;
        }

        return icon.resource;
    }

    public override function set(value:Variant) {
        if (value.isNull) {
            return;
        }

        var button:Button = cast _component;
        var icon:Image = button.findComponent(Image);
        if (icon == null) {
            icon = new Image();
            icon.addClass("icon");
            icon.id = "button-icon";
            icon.scriptAccess = false;
            button.addComponentAt(icon, 0);
        }

        icon.resource = value;
    }
}

//***********************************************************************************************************
// Layout
//***********************************************************************************************************
@:dox(hide)
class ButtonLayout extends DefaultLayout {
    public function new() {
        super();
    }

    private var iconPosition(get, null):String;
    private function get_iconPosition():String {
        if (component.style == null || component.style.iconPosition == null) {
            return "left";
        }
        return component.style.iconPosition;
    }

    private override function repositionChildren() {
        super.repositionChildren();

        var label:Label = component.findComponent("button-label");
        var icon:Image = component.findComponent("button-icon");

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