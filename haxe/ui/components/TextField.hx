package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.events.FocusEvent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.Events;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.focus.IFocusable;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.geom.Size;
import haxe.ui.util.Variant;

@:composite(Events, Builder, TextFieldLayout)
class TextField extends InteractiveComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(PasswordBehaviour)          public var password:Bool;
    @:clonable @:behaviour(MaxCharsBehaviour, -1)      public var maxChars:Int;
    @:clonable @:behaviour(RestrictCharsBehaviour)     public var restrictChars:String;
    @:clonable @:behaviour(PlaceholderBehaviour)       public var placeholder:String;
    @:clonable @:behaviour(TextBehaviour)              public var text:String;
    @:clonable @:behaviour(ValueBehaviour)             public var value:String;
    @:clonable @:behaviour(IconBehaviour)              public var icon:String;
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
private class ValueBehaviour extends Behaviour {
    public override function get():Variant {
        return cast(_component, TextField).text;
    }
    
    public override function set(value:Variant) {
        cast(_component, TextField).text = value;
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
			if (textfield.focus == false)
			{
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
				if (text == textfield.placeholder) {
					text = "";
				}
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
                    //_textfield.dispatch(new UIEvent(UIEvent.CHANGE));
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
        }
    }
}
