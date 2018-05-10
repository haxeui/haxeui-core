package haxe.ui.components;

import haxe.ui.core.TextInput;
import haxe.ui.validation.InvalidationFlags;
import haxe.ui.focus.FocusManager;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.focus.IFocusable;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;

class TextArea extends InteractiveComponent implements IFocusable {
    public function new() {
        super();
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

    private var _wrap:Bool = true;
    @:clonable public var wrap(get, set):Bool;
    private function get_wrap():Bool {
        return _wrap;
    }
    private function set_wrap(value:Bool):Bool {
        if (value == _wrap) {
            return value;
        }

        invalidateComponentData();
        _wrap = value;
        return value;
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

    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "text" => new TextAreaDefaultTextBehaviour(this),
            "placeholder" => new TextAreaDefaultPlaceholderBehaviour(this),
            "wrap" => new TextAreaDefaultWrapBehaviour(this)
        ]);
        _defaultLayout = new TextAreaLayout();
    }

    private override function createChildren() {
        super.createChildren();
        
        getTextInput().multiline = true;
        getTextInput().data.onChangedCallback = function() {
            if (getTextInput().text != _text && hasClass(":empty") == false) {
                text = getTextInput().text;
                
            }
        };
        getTextInput().data.onScrollCallback = function() {
            if (_hscroll != null) {
                _hscroll.pos = getTextInput().hscrollPos;
            }
            if (_vscroll != null) {
                _vscroll.pos = getTextInput().vscrollPos;
            }
        }

        registerEvent(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        registerEvent(UIEvent.CHANGE, _onTextChanged);
    }

    private override function destroyChildren() {
        super.destroyChildren();

        getTextInput().data.onChangedCallback = null;
        getTextInput().data.onScrollCallback = null;
        unregisterEvent(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
        unregisterEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        unregisterEvent(UIEvent.CHANGE, _onTextChanged);
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);
        if (hasTextInput() == true) {
            getTextInput().textStyle = style;
        }
    }

    private var _hscroll:HScroll;
    private var _vscroll:VScroll;
    private function checkScrolls() {
        if (native == true) {
            return;
        }

        var textInput:TextInput = getTextInput();
        
        if (textInput.textWidth > textInput.width) {
            if (_hscroll == null) {
                _hscroll = new HScroll();
                _hscroll.id = "textarea-hscroll";
                addComponent(_hscroll);
                _hscroll.registerEvent(UIEvent.CHANGE, _onScrollChange);
            }
            _hscroll.max = textInput.hscrollMax; // textInput.textWidth - getTextInput().width;
            _hscroll.pos = textInput.hscrollPos;

            _hscroll.pageSize = textInput.hscrollPageSize; //(textInput.width * _hscroll.max) / textInput.textWidth;
           // _hscroll.pageSize = (textInput.width * _hscroll.max) / textInput.textWidth;
            _hscroll.show();
        } else {
            if (_hscroll != null) {
                _hscroll.hide();
            }
        }
        
        if (textInput.textHeight > textInput.height) {
            if (_vscroll == null) {
                _vscroll = new VScroll();
                _vscroll.id = "textarea-vscroll";
                addComponent(_vscroll);
                _vscroll.registerEvent(UIEvent.CHANGE, _onScrollChange);
            }
            _vscroll.max = textInput.vscrollMax; //textInput.textHeight - textInput.height;
            _vscroll.pos = textInput.vscrollPos;

            _vscroll.pageSize = textInput.vscrollPageSize; // (textInput.height * _vscroll.max) / textInput.textHeight;
            _vscroll.show();
        } else {
            if (_vscroll != null) {
                _vscroll.hide();
            }
        }
    }

    private function _onMouseWheel(event:MouseEvent) {
        if (_vscroll != null) {
            if (event.delta > 0) {
                _vscroll.pos -= 60; // TODO: calculate this
            } else if (event.delta < 0) {
                _vscroll.pos += 60;
            }
        }
    }

    private function _onMouseDown(event:MouseEvent) {
        FocusManager.instance.focus = this;
    }

    private function _onTextChanged(event:UIEvent) {
        text = behaviourGet("text");
    }

    private function _onScrollChange(e:UIEvent) {
        if (_hscroll != null) {
            getTextInput().hscrollPos = _hscroll.pos;
        }
        if (_vscroll != null) {
            getTextInput().vscrollPos = _vscroll.pos;
        }
    }
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************

    private inline function invalidateComponentScroll() {
        invalidateComponent(InvalidationFlags.SCROLL);
    }

    private override function validateInternal() {
        var dataInvalid = isInvalid(InvalidationFlags.DATA);
        var scrollInvalid = isInvalid(InvalidationFlags.SCROLL);
        var layoutInvalid = isInvalid(InvalidationFlags.LAYOUT);

        super.validateInternal();

        if (scrollInvalid || layoutInvalid || dataInvalid) {
            validateScroll();
        }
    }

    private function validateScroll() {
        checkScrolls();
    }

    private override function validateData() {
        if (behaviourGet("placeholder") != _placeholder) {
            behaviourSet("placeholder", _placeholder);
        }

        if (behaviourGet("wrap") != _wrap) {
            behaviourSet("wrap", _wrap);
        }

        var text:String = _text != null ? _text : "";
        var placeholderVisible:Bool = empty;

        //Placeholder
        if (focus == false && _placeholder != null) {
            if (text == "") {
                text = _placeholder;
                addClass(":empty");
            } else {
                removeClass(":empty");
            }
        } else if (placeholderVisible == true){
            text = "";
            removeClass(":empty");
        }

        behaviourSet("text", text);
        handleBindings(["text", "value"]);
    }
    
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.TextArea)
class TextAreaDefaultTextBehaviour extends Behaviour {
    public override function set(value:Variant) {
        if (value.isNull) {
            return;
        }

        var textArea:TextArea = cast _component;
        textArea.getTextInput().text = value;
        textArea.getTextInput().invalidate(InvalidationFlags.MEASURE);
        textArea.invalidateComponentDisplay();
    }

    public override function get():Variant {
        var textArea:TextArea = cast _component;
        return textArea.getTextInput().text;
    }
}

@:dox(hide)
@:access(haxe.ui.components.TextField)
class TextAreaDefaultPlaceholderBehaviour extends Behaviour {
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

@:dox(hide)
@:access(haxe.ui.components.TextArea)
class TextAreaDefaultWrapBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var textArea:TextArea = cast _component;
        textArea.getTextInput().wordWrap = value;
        textArea.invalidateComponentDisplay();
    }
    
    public override function get():Variant {
        var textArea:TextArea = cast _component;
        return textArea.getTextInput().wordWrap;
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.TextArea)
class TextAreaLayout extends DefaultLayout {
    private override function repositionChildren() {
        var hscroll:Component = component.findComponent("textarea-hscroll");
        var vscroll:Component = component.findComponent("textarea-vscroll");

        var ucx = innerWidth;
        var ucy = innerHeight;

        if (hscroll != null && hidden(hscroll) == false) {
            hscroll.left = paddingLeft;
            hscroll.top = ucy - hscroll.componentHeight + paddingBottom;
        }

        if (vscroll != null && hidden(vscroll) == false) {
            vscroll.left = ucx - vscroll.componentWidth + paddingRight;
            vscroll.top = paddingTop;
        }

        if (component.hasTextInput() == true) {
            component.getTextInput().left = paddingLeft;
            component.getTextInput().top = paddingTop;
        }
    }

    private override function resizeChildren() {
        super.resizeChildren();

        var hscroll:Component = component.findComponent("textarea-hscroll");
        var vscroll:Component = component.findComponent("textarea-vscroll");

        var usableSize:Size = usableSize;
        if (hscroll != null && hidden(hscroll) == false) {
            hscroll.width = usableSize.width;
        }
        
        if (vscroll != null && hidden(vscroll) == false) {
            vscroll.height = usableSize.height;
        }
        
        if (component.hasTextInput() == true) {
            var size:Size = usableSize;
            #if !pixijs
            component.getTextInput().width = size.width - 2;
            component.getTextInput().height = size.height - 1;
            #end

        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        size.width -= 1;
        var hscroll:Component = component.findComponent("textarea-hscroll");
        var vscroll:Component = component.findComponent("textarea-vscroll");
        if (hscroll != null && hidden(hscroll) == false) {
            size.height -= hscroll.componentHeight;
        }
        if (vscroll != null && hidden(vscroll) == false) {
            size.width -= vscroll.componentWidth;
        }

        return size;
    }
    
    /*
    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var hscroll:Component = component.findComponent("textarea-hscroll");
        var vscroll:Component = component.findComponent("textarea-vscroll");
        var size:Size = super.calcAutoSize([hscroll, vscroll]);
        if (hscroll != null && hscroll.hidden == false) {
            size.height += hscroll.componentHeight;
        }
        if (vscroll != null && vscroll.hidden == false) {
            size.width += vscroll.componentWidth;
        }
        return size;
    }
    */
}
