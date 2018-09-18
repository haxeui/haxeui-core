package haxe.ui.components;

import haxe.ui.util.Variant;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.focus.IFocusable;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;

@:dox(icon = "/icons/ui-text-field.png")
class TextField extends InteractiveComponent implements IFocusable {
    private var _icon:Image;

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "text" => new TextFieldDefaultTextBehaviour(this),
            "icon" => new TextFieldDefaultIconBehaviour(this),
            "password" => new TextFieldDefaultPasswordBehaviour(this),
            "placeholder" => new TextFieldDefaultPlaceholderBehaviour(this)
        ]);
        _defaultLayout = new TextFieldLayout();
    }

    private override function createChildren() {
        if (componentWidth == 0) {
            componentWidth = 150;
        }

        getTextInput().multiline = false;
        getTextInput().data.onChangedCallback = function() {
            if (getTextInput().text != _text && hasClass(":empty") == false) {
                text = getTextInput().text;
            }
        };
        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        registerEvent(UIEvent.CHANGE, _onTextChanged);
    }

    private override function destroyChildren() {
        super.destroyChildren();

        getTextInput().data.onChangedCallback = null;
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

    private override function set_text(value:String):String {
        if (value == _text) {
            return value;
        }

        invalidateComponentData();
        value = super.set_text(value);
        return value;
    }

    private override function set_focus(value:Bool):Bool {
        if (_focus == value || allowFocus == false) {
            return value;
        }

        invalidateComponentData();
        super.set_focus(value);
        return value;
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);
        if (style.icon != null) {
            icon = style.icon;
        }
        if (hasTextInput() == true) {
            getTextInput().textStyle = style;
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    /**
     Return if the textfield is empty.
    **/
    public var empty(get, never):Bool;
    private function get_empty():Bool {
        return _text == null || _text.length == 0;
    }

    private var _iconResource:String;
    /**
     The image resource to use as the textfields icon
    **/
    @:clonable public var icon(get, set):String;
    private function get_icon():String {
        return _iconResource;
    }

    private function set_icon(value:String):String {
        if (_iconResource == value) {
            return value;
        }

        invalidateComponentData();
        _iconResource = value;
        return value;
    }

    private var _password:Bool = false;
    /**
     Whether to use this text field as a password text field
    **/
    @:clonable public var password(get, set):Bool;
    private function get_password():Bool {
        return _password;
    }

    private function set_password(value:Bool):Bool {
        if (_password == value) {
            return value;
        }

        _password = value;
        invalidateComponentData();
        return value;
    }
    
    private var _maxChars:Int = -1;
    /**
     Maximum number of characters allowed in the textfield. By default -1 (unlimited chars).
    **/
    @:clonable public var maxChars(get, set):Int;
    private function get_maxChars():Int {
        return _maxChars;
    }

    private function set_maxChars(value:Int):Int {
        if (_maxChars == value) {
            return value;
        }

        invalidateComponentData();
        _maxChars = value;
        return value;
    }

    private var _placeholder:String;
    /**
     A short hint that describes the expected value.
     The short hint is displayed in the textfield before the user enters a value.
     Use ":empty" css class to change the style.
    **/
    @:clonable public var placeholder(get, set):String;
    private function get_placeholder():String {
        return _placeholder;
    }

    private function set_placeholder(value:String):String {
        if (_placeholder == value) {
            return value;
        }

        invalidateComponentData();
        _placeholder = value;
        return value;
    }

    private var _restrictEReg:EReg;
    private var _restrictChars:String;
    /**
     Indicates the set of characters that an user can enter into the textfield. You can insert a range with the "-" character, or you can exclude with the "^" character.

     Examples include:

     - `a-z` : Allowed lowercase letters.

     - `a-zA-Z` : Allowed any letter.

     - `^Qq` : Allowed any char except `q` and `Q`.

     - `a-z^q`: Allowed lowercase letters except `q`.

     - `0-9a-z`: Allowed numbers and lowercase letters.

     - `0-9^4-6`: Allowed  numbers except `4`, `5` and `6`.
    **/
    @:clonable public var restrictChars(get, set):String;
    private function get_restrictChars():String {
        return _restrictChars;
    }

    private function set_restrictChars(value:String):String {
        if (_restrictChars == value) {
            return value;
        }

        _restrictChars = value;
        _restrictEReg = _generateRestrictEReg();

        return _restrictChars;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private function _onTextChanged(event:UIEvent) {
        var newText:String = behaviourGet("text");
        if (_restrictEReg != null && newText != "" && !_restrictEReg.match(newText)) {
            behaviourSet("text", _text != null ? _text : "");
            return;
        }

        text = newText;
    }

    private function _onMouseDown(event:MouseEvent) {
        FocusManager.instance.focus = this;
    }

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************

    private override function validateData() {
        if (behaviourGet("icon") != _iconResource) {
            behaviourSet("icon", _iconResource);
        }

        if (behaviourGet("placeholder") != _placeholder) {
            behaviourSet("placeholder", _placeholder);
        }

        var text:String = _text != null ? _text : "";
        var placeholderVisible:Bool = empty;

        //Max chars
        if (_maxChars != -1 && text.length > _maxChars && placeholderVisible == false) {
            text = text.substr(0, _maxChars);
            _text = text;
        }

        //Placeholder
        if (focus == false && _placeholder != null) {
            if (native == false) {
                if (text == "") {
                    text = _placeholder;
                    behaviourSet("password", false);
                    addClass(":empty");
                } else {
                    behaviourSet("password", _password);
                    removeClass(":empty");
                }
            }
        } else if (placeholderVisible == true) {
            if (native == false) { 
                text = "";
                removeClass(":empty");
                behaviourSet("password", _password);
            }
        } else {
            behaviourSet("password", _password);
        }

        behaviourSet("text", text);
        handleBindings(["text", "value"]);
    }

    //***********************************************************************************************************
    // Others
    //***********************************************************************************************************

    private function _generateRestrictEReg():EReg {
        if (_restrictChars == null) {
            return null;
        }

        var excludeEReg:EReg = ~/\^(.+)/g;
        var excludeChars:String = null;
        var includeChars:String = null;
        if (excludeEReg.match(_restrictChars)) {
            includeChars = excludeEReg.matchedLeft();
            excludeChars = excludeEReg.matched(1);
        } else {
            includeChars = _restrictChars;
        }

        includeChars = (includeChars.length == 0) ? '.' : '[$includeChars]';    //Any character if it is empty

        if (excludeChars != null && excludeChars.length > 0) {
            return new EReg('^((?=[^${excludeChars}])${includeChars})+$', "");
        } else {
            return new EReg('^${includeChars}+$', "");
        }
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
        if (value != textField.getTextInput().text) {
            textField.getTextInput().text = value;
            textField.invalidateComponentDisplay();
        }
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
        var textField:TextField = cast _component;
        if (value == null || value.isNull || value == "null") { // TODO: hack
            if (textField._icon != null) {
                textField.removeComponent(textField._icon);
                textField._icon = null;
            }
        } else {
            if (textField._icon == null) {
                textField._icon = new Image();
                textField._icon.id = "textfield-icon";
                textField._icon.addClass("icon");
                textField._icon.scriptAccess = false;
                textField.addComponent(textField._icon);    //TODO use addComponentAt with index=0
            }
            textField._icon.resource = value.toString();
        }
    }

    public override function get():Variant {
        var textField:TextField = cast _component;
        if (textField._icon == null) {
            return null;
        } else {
            return Variant.fromDynamic(textField._icon.resource);
        }
    }
}

@:dox(hide)
@:access(haxe.ui.components.TextField)
class TextFieldDefaultPasswordBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var textField:TextField = cast _component;
        textField.getTextInput().password = value;
    }
    
    public override function get():Variant {
        var textField:TextField = cast _component;
        return textField.getTextInput().password;
    }
}

@:dox(hide)
@:access(haxe.ui.components.TextField)
class TextFieldDefaultPlaceholderBehaviour extends Behaviour {
    private var _value:String;  //TODO - maybe we can create a generic ValueBehaviour class

    public override function set(value:Variant) {
        if (_value == value) {
           return;
        }

        _value = value;
    }
    
    public override function get():Variant {
        return _value;
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

    private override function repositionChildren() {
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
            //component.getTextInput().top = paddingTop;// (component.componentHeight / 2) - (component.getTextInput().textHeight / 2);
            component.getTextInput().top = (component.componentHeight / 2) - (component.getTextInput().height / 2);
        }
    }

    private override function resizeChildren() {
        super.resizeChildren();

        if (component.hasTextInput() == true) {
            var size:Size = usableSize;
            #if !pixijs
            component.getTextInput().width = size.width;
            component.getTextInput().height = size.height;
            #end

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