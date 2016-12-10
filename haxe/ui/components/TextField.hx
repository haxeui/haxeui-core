package haxe.ui.components;

import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.focus.IFocusable;
import haxe.ui.core.IClonable;
import haxe.ui.styles.Style;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;
import haxe.ui.layouts.DefaultLayout;

@:dox(icon="/icons/ui-text-field.png")
class TextField extends InteractiveComponent implements IFocusable implements IClonable<TextField> {
    private var _icon:Image;

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function createDefaults():Void {
        _defaultBehaviours = [
            "text" => new TextFieldDefaultTextBehaviour(this),
            "icon" => new TextFieldDefaultIconBehaviour(this)
        ];
        _defaultLayout = new TextFieldLayout();
    }

    private override function create():Void {
        super.create();
        if (_text == null) {
            behaviourSet("text", "");
        }
        //behaviourSet("icon", _iconResource);
    }

    private override function createChildren():Void {
        if (componentWidth == 0) {
            componentWidth = 150;
        }

        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        registerEvent(UIEvent.CHANGE, _onTextChanged);
    }

    private override function destroyChildren():Void {
        super.destroyChildren();

        unregisterEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        unregisterEvent(UIEvent.CHANGE, _onTextChanged);

        if (_icon != null) {
            removeComponent(_icon);
            _icon = null;
        }
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function get_text():String {
        return behaviourGet("text");
    }

    private override function set_text(value:String):String {
        if (value == _text) {
            return value;
        }

        value = super.set_text(value);
        behaviourSet("text", value);
        return value;
    }

    private override function applyStyle(style:Style):Void {
        super.applyStyle(style);
        if (style.icon != null) {
            icon = style.icon;
        }
        if (hasTextInput() == true) {
            if (style.color != null) {
                getTextInput().color = style.color;
            }
            if (style.fontName != null) {
                getTextInput().fontName = style.fontName;
            }
            if (style.fontSize != null) {
                getTextInput().fontSize = style.fontSize;
            }
            #if openfl  //TODO - all platforms
            if (style.textAlign != null) {
                getTextInput().textAlign = style.textAlign;
            }
            #end
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _iconResource:String;
    /**
     The image resource to use as the textfields icon
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
        behaviourSet("icon", value);
        return value;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private function _onTextChanged(event:UIEvent):Void {
        handleBindings(["text", "value"]);
    }

    private function _onMouseDown(event:MouseEvent):Void {
        
        FocusManager.instance.focus = this;
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.TextField)
class TextFieldDefaultTextBehaviour extends Behaviour {
    public override function set(value:Variant) {
        if (value.isNull) {
            return;
        }

        var textField:TextField = cast _component;
        textField.getTextInput().text = value;
        textField.invalidateDisplay();
    }

    public override function get():Variant {
        var textField:TextField = cast _component;
        return textField.getTextInput().text;
    }
}

@:dox(hide)
@:access(haxe.ui.components.TextField)
class TextFieldDefaultIconBehaviour extends Behaviour {
    public override function set(value:Variant) {
        if (value == null || value.isNull || value == "null") { // TODO: hack
            return;
        }

        var textField:TextField = cast _component;
        if (textField._icon == null) {
            textField._icon = new Image();
            textField._icon.id = "textfield-icon";
            textField._icon.addClass("icon");
            textField._icon.scriptAccess = false;
            textField.addComponent(textField._icon);
        }
        textField._icon.resource = value.toString();
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.TextField)
class TextFieldLayout extends DefaultLayout {
    private var iconPosition(get, null):String;
    private function get_iconPosition():String {
        if (component.style.iconPosition == null) {
            return "left";
        }
        return component.style.iconPosition;
    }

    private override function repositionChildren():Void {
        //super.repositionChildren();
        var icon:Image = component.findComponent("textfield-icon");
        var xpos:Float = paddingLeft;
        if (icon != null) {
            switch (iconPosition) {
                case "left":
                    icon.left = xpos;
                    icon.top = (component.componentHeight / 2) - (icon.componentHeight / 2);
                    xpos += icon.componentWidth + horizontalSpacing;
                case "right":
                    icon.left = component.componentWidth - icon.componentWidth - paddingRight;
                    icon.top = (component.componentHeight / 2) - (icon.componentHeight / 2);
            }
        }

        if (component.hasTextInput() == true) {
            component.getTextInput().left = xpos;
            component.getTextInput().top = (component.componentHeight / 2) - (component.getTextInput().textHeight / 2);
        }
    }

    private override function resizeChildren() {
        super.resizeChildren();

        if (component.hasTextInput() == true) {
            var size:Size = usableSize;
            #if !pixijs
            component.getTextInput().width = size.width;
            #end
            
            //component.getTextInput().height = size.height;
        }
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var size:Size = super.calcAutoSize(exclusions);
        if (component.hasTextInput() == true) {
            if (component.getTextInput().textWidth + paddingLeft + paddingRight > size.width) {
                size.width = component.getTextInput().textWidth + paddingLeft + paddingRight;
            }
            if (component.getTextInput().textHeight + paddingTop + paddingBottom > size.height) {
                size.height = component.getTextInput().textHeight + paddingTop + paddingBottom;
            }
        }

        return size;
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var icon:Image = component.findComponent("textfield-icon");
        if (icon != null) {
            size.width -= icon.componentWidth + horizontalSpacing;
        }
        return size;
    }
}