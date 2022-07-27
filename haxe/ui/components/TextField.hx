package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.ValueBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.Events;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;


/**
 * A single line text input box. for multiline text input use `TextArea`.
 */
@:composite(Events, Builder, TextFieldLayout)
class TextField extends InteractiveComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    /**
     * Whether or not the text inside the text field is fully visible,
     * or displayed as a password, with every character replaced by a `*`.
     */
    @:clonable @:behaviour(PasswordBehaviour)               public var password:Bool;

    /**
     * The maximum number of characters that can be entered in the text field.  
     * **Note** - this doesnt apply to text added via code.
     */
    @:clonable @:behaviour(MaxCharsBehaviour, -1)           public var maxChars:Int;

    /**
     * A string, containing a pattern of characters that the user can enter. When unspecified, the text field accepts all characters.
     * 
     * Usage:
     * 
     *  - type out lone characters to include them specifically - `"abcde047"`
     *  - use the `-` character to represent a range of characters - `"a-zA-Z0-9"` will accept characters from `a` to `z`, `A` to `Z` and `0` to `9`.
     *  - prefix the string with a `^` for it to only accept characters that do not match the string's pattern - `"^abc"` will accept any character except `a`, `b` and `c`.
     */
    @:clonable @:behaviour(RestrictCharsBehaviour)          public var restrictChars:String;

    /**
     * Displayed only when the text is empty.
     */
    @:clonable @:behaviour(PlaceholderBehaviour)            public var placeholder:String;

    /**
     * The actual text that is displayed inside the text field.
     */
    @:clonable @:behaviour(TextBehaviour)                   public var text:String;

    /**
     * A string containing HTML markup to be displayed inside the text field.
     */
    @:clonable @:behaviour(HtmlTextBehaviour)               public var htmlText:String;

    /**
     * The text displayed inside of the `TextField`.
     * 
     * `value` is used as a universal way to access the value a component is based on. in this case its the text inside of the text field.
     */
    @:clonable @:value(text)                                public var value:Dynamic;

    /**
     * An icon that is displayed to the left of the text field.
     *
     * To display an icon, set the `icon` property to a path to an image file.
     * If no icon is set, the text field will be displayed without any icon. The default is no icon.
     */
    @:clonable @:behaviour(IconBehaviour)                   public var icon:String;
    
    /**
     * The (zero based) position of the caret within the textfield
     *
     */
    @:clonable @:behaviour(CaretIndexBehaviour)             public var caretIndex:Int;
    @:clonable @:behaviour(SelectionStartIndexBehaviour)    public var selectionStartIndex:Int;
    @:clonable @:behaviour(SelectionEndIndexBehaviour)      public var selectionEndIndex:Int;
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextFieldLayout extends DefaultLayout {
    private var iconPosition(get, null):String;
    private function get_iconPosition():String {
        if (component.style.iconPosition == null) {
            return "left";
        }
        return component.style.iconPosition;
    }

    private override function repositionChildren() {
        var icon:Image = component.findComponent(Image, false);
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
            component.getTextInput().top = paddingTop + (component.componentHeight / 2) - ((component.getTextInput().height + paddingTop + paddingBottom) / 2);
        }
    }

    private override function resizeChildren() {
        super.resizeChildren();

        if (component.hasTextInput() == true) {
            var size:Size = usableSize;
            component.getTextInput().width = size.width;
            component.getTextInput().height = size.height;
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
        var icon:Image = component.findComponent(Image, false);
        if (icon != null) {
            size.width -= icon.componentWidth + horizontalSpacing;
        }

        return size;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PasswordBehaviour extends DataBehaviour {
    public var originalValue:Variant;

    public override function validateData() {
        if (originalValue == null) { // TODO: seems like a crappy way to handle placeholder / password
            originalValue = _value;
        }
        var textfield:TextField = cast(_component, TextField);
        textfield.getTextInput().password = _value;
    }
}

@:dox(hide) @:noCompletion
private class MaxCharsBehaviour extends DataBehaviour {
    public override function validateData() {
        var textfield:TextField = cast(_component, TextField);
        TextFieldHelper.validateText(textfield, textfield.text);
    }
}

@:dox(hide) @:noCompletion
private class RestrictCharsBehaviour extends DataBehaviour {
    public var regexp:EReg;

    public override function validateData() {
        var excludeEReg:EReg = ~/\^(.-.|.)/gu;
        var excludeChars:String = '';

        var includeChars:String = excludeEReg.map (_value, function (ereg:EReg) {
            excludeChars += ereg.matched (1);
            return '';
        });

        var testRegexpParts:Array<String> = [];

        if (includeChars.length > 0) {
            testRegexpParts.push ('[^$_value]');
        }

        if (excludeChars.length > 0) {
            testRegexpParts.push ('[$excludeChars]');
        }

        regexp = new EReg ('(${testRegexpParts.join(' | ')})', 'g');

        var textfield:TextField = cast(_component, TextField);
        TextFieldHelper.validateText(textfield, textfield.text);
    }
}

@:dox(hide) @:noCompletion
private class PlaceholderBehaviour extends DataBehaviour {
    public override function validateData() {
        var textfield:TextField = cast(_component, TextField);
        TextFieldHelper.validateText(textfield, textfield.text);
    }
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    public override function validateData() {
        var textfield:TextField = cast(_component, TextField);
        TextFieldHelper.validateText(textfield, _value);

        if (_value != null && _value != "") {
            _value = textfield.getTextInput().text;
        }
    }
}

@:dox(hide) @:noCompletion
private class HtmlTextBehaviour extends DataBehaviour {
    public override function validateData() {
        var textfield:TextField = cast(_component, TextField);
        TextFieldHelper.validateHtmlText(textfield, _value);

        if (_value != null && _value != "") {
            _value = textfield.getTextInput().htmlText;
        }
    }
}

@:dox(hide) @:noCompletion
private class IconBehaviour extends DataBehaviour {
    public override function validateData() {
        var textfield:TextField = cast(_component, TextField);
        var icon:Image = textfield.findComponent(Image, false);
        if ((_value == null || _value.isNull) && icon != null) {
            textfield.removeComponent(icon);
        } else {
            if (icon == null) {
                icon = new Image();
                icon.id = "textfield-icon";
                icon.addClass("icon");
                icon.scriptAccess = false;
                textfield.addComponentAt(icon, 0);
            }
            icon.resource = _value.toString();
        }
    }
}

@:dox(hide) @:noCompletion
private class CaretIndexBehaviour extends ValueBehaviour {
    public override function get():Variant {
        return _component.getTextInput().caretIndex;
    }
    public override function set(value:Variant) {
        super.set(value);
        _component.syncComponentValidation();
        _component.getTextInput().caretIndex = value;
    }
}


@:dox(hide) @:noCompletion
private class SelectionStartIndexBehaviour extends ValueBehaviour {
    public override function get():Variant {
        return _component.getTextInput().selectionStartIndex;
    }
    public override function set(value:Variant) {
        super.set(value);
        _component.syncComponentValidation();
        _component.getTextInput().selectionStartIndex = value;
    }
}

@:dox(hide) @:noCompletion
private class SelectionEndIndexBehaviour extends ValueBehaviour {
    public override function get():Variant {
        return _component.getTextInput().selectionEndIndex;
    }
    public override function set(value:Variant) {
        super.set(value);
        _component.syncComponentValidation();
        _component.getTextInput().selectionEndIndex = value;
    }
}
//***********************************************************************************************************
// Helpers
//***********************************************************************************************************
@:access(haxe.ui.core.Component)
private class TextFieldHelper {
    public static function validateText(textfield:TextField, text:String) {
        if (text == null) {
            text = "";
        }

        var placeholderVisible:Bool = text.length == 0;
        var password:Variant = cast(textfield.behaviours.find("password"), PasswordBehaviour).originalValue;  // TODO: seems like a crappy way to handle placeholder / password
        var regexp:EReg = cast(textfield.behaviours.find("restrictChars"), RestrictCharsBehaviour).regexp;  // TODO: seems like a crappy way to handle restrict chars

        if (textfield.maxChars > 0 && text.length > textfield.maxChars && placeholderVisible == false) {
            text = text.substr(0, textfield.maxChars);
        }

        if (regexp != null) {
            text = regexp.replace(text, "");
        }

        if (textfield.placeholder != null) {
            if (textfield.focus == false) {
                if (text.length == 0) {
                    text = textfield.placeholder;
                    textfield.password = false;
                    textfield.addClass(":empty");
                } else if (text != textfield.placeholder) {
                    textfield.password = password;
                    textfield.removeClass(":empty");
                }
            } else {
                textfield.removeClass(":empty");
                textfield.password = password;
            }
        } else {
            textfield.password = password;

            if (placeholderVisible == true) {
                textfield.removeClass(":empty");
            }
        }

        textfield.getTextInput().text = '${text}';
        textfield.invalidateComponentLayout();
    }
    
    public static function validateHtmlText(textfield:TextField, htmlText:String) {
        if (htmlText == null) {
            htmlText = "";
        }

        var placeholderVisible:Bool = htmlText.length == 0;
        var password:Variant = cast(textfield.behaviours.find("password"), PasswordBehaviour).originalValue;  // TODO: seems like a crappy way to handle placeholder / password
        var regexp:EReg = cast(textfield.behaviours.find("restrictChars"), RestrictCharsBehaviour).regexp;  // TODO: seems like a crappy way to handle restrict chars

        if (textfield.maxChars > 0 && htmlText.length > textfield.maxChars && placeholderVisible == false) {
            htmlText = htmlText.substr(0, textfield.maxChars);
        }

        if (regexp != null) {
            htmlText = regexp.replace(htmlText, "");
        }

        if (textfield.placeholder != null) {
            if (textfield.focus == false) {
                if (htmlText.length == 0) {
                    htmlText = textfield.placeholder;
                    textfield.password = false;
                    textfield.addClass(":empty");
                } else if (htmlText != textfield.placeholder) {
                    textfield.password = password;
                    textfield.removeClass(":empty");
                }
            } else {
                textfield.removeClass(":empty");
                textfield.password = password;
            }
        } else {
            textfield.password = password;

            if (placeholderVisible == true) {
                textfield.removeClass(":empty");
            }
        }

        textfield.getTextInput().htmlText = '${htmlText}';
        textfield.invalidateComponentLayout();
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends haxe.ui.events.Events {
    private var _textfield:TextField;

    public function new(textfield:TextField) {
        super(textfield);
        _textfield = textfield;
    }

    public override function register() {
        if (_textfield.getTextInput().data.onChangedCallback == null) {
            _textfield.getTextInput().multiline = false;
            _textfield.getTextInput().data.onChangedCallback = function() {
                if (_textfield.hasClass(":empty") == false) {
                    _textfield.text = _textfield.getTextInput().text;
                    _textfield.dispatch(new UIEvent(UIEvent.CHANGE));
                }
            };
        }

        registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        registerEvent(FocusEvent.FOCUS_IN, onFocusChange);
        registerEvent(FocusEvent.FOCUS_OUT, onFocusChange);
    }

    public override function unregister() {
        _textfield.getTextInput().data.onChangedCallback = null;
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        unregisterEvent(FocusEvent.FOCUS_IN, onFocusChange);
        unregisterEvent(FocusEvent.FOCUS_OUT, onFocusChange);
    }

    private function onMouseDown(event:MouseEvent) { // TODO: this should happen automatically as part of InteractiveComponent (?)
        //event.cancel();
        _textfield.focus = true;
    }

    private function onFocusChange(event:FocusEvent) {
        if (_textfield.focus == true) {
            _textfield.getTextInput().focus();
        } else {
            _textfield.getTextInput().blur();
        }
        TextFieldHelper.validateText(_textfield, _textfield.text);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _textfield:TextField;

    public function new(textfield:TextField) {
        super(textfield);
        _textfield = textfield;
    }

    public override function applyStyle(style:Style) {
        if (style.icon != null) {
            _textfield.icon = style.icon;
        }
        if (_textfield.hasTextInput() == true) {
            _textfield.getTextInput().textStyle = style;
            
            if ((style.contentType == "auto" || style.contentType == "html") && _textfield.getTextInput().supportsHtml && isHtml(Std.string(_textfield.text))) {
                _textfield.htmlText = _textfield.text;
            }
        }
    }
    
    public static inline function isHtml(v:String):Bool {
        return v == null ? false : v.indexOf("<font ") != -1;
    }
}
