package haxe.ui.components;

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
        return behaviourGet("placeholder");
    }

    private function set_placeholder(value:String):String {
        if (_placeholder == value) {
            return value;
        }

        behaviourSet("placeholder", value);

        return value;
    }

    private var _wrap:Bool;
    @:clonable public var wrap(get, set):Bool;
    private function get_wrap():Bool {
        return behaviourGet("wrap");
    }
    private function set_wrap(value:Bool):Bool {
        if (value == _wrap) {
            return value;
        }
        
        _wrap = value;        
        behaviourSet("wrap", value);
        return value;
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function set_text(value:String):String {
        value = super.set_text(value);
        _validateText();
        checkScrolls();
        return value;
    }

//    private override function get_text():String {
//        return behaviourGet("text");
//    }

    private override function set_focus(value:Bool):Bool {
        if (_focus == value || allowFocus == false) {
            return value;
        }

        super.set_focus(value);
        if (empty == false) {
            text = behaviourGet("text");
        } else {
            _validateText();
        }

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

    private override function create() {
        super.create();

        if (_text == null) {
            behaviourSet("text", "");
        }
    }

    private override function createChildren() {
        super.createChildren();
        if (componentWidth == 0) {
            componentWidth = 150;
        }
        if (componentHeight == 0) {
            componentHeight = 100;
        }
        
        getTextInput().multiline = true;

        registerEvent(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        registerEvent(UIEvent.CHANGE, _onTextChanged);
    }

    private override function destroyChildren() {
        super.destroyChildren();

        unregisterEvent(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
        unregisterEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        unregisterEvent(UIEvent.CHANGE, _onTextChanged);
    }

    private override function onReady() {
        super.onReady();
        checkScrolls();
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);
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
        }
    }

    private var _hscroll:HScroll;
    private var _vscroll:VScroll;
    private function checkScrolls() {
        if (native == true) {
            return;
        }

        if (getTextInput().textWidth > getTextInput().width) {
            if (_hscroll == null) {
                _hscroll = new HScroll();
                _hscroll.id = "textarea-hscroll";
                addComponent(_hscroll);
                _hscroll.registerEvent(UIEvent.CHANGE, _onScrollChange);
            }
            _hscroll.max = getTextInput().textWidth - getTextInput().width;
            _hscroll.pos = getTextInput().hscrollPos;

            _hscroll.pageSize = (getTextInput().width * _hscroll.max) / getTextInput().textWidth;
            _hscroll.show();
        } else {
            if (_hscroll != null) {
                _hscroll.hide();
            }
        }
        
        if (getTextInput().textHeight > getTextInput().height) {
            if (_vscroll == null) {
                _vscroll = new VScroll();
                _vscroll.id = "textarea-vscroll";
                addComponent(_vscroll);
                _vscroll.registerEvent(UIEvent.CHANGE, _onScrollChange);
            }
            _vscroll.max = getTextInput().textHeight - getTextInput().height;
            _vscroll.pos = getTextInput().vscrollPos;

            _vscroll.pageSize = (getTextInput().height * _vscroll.max) / getTextInput().textHeight;
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
        var newText:String = behaviourGet("text");
        text = newText;
        handleBindings(["text", "value"]);
    }

    private function _onScrollChange(e:UIEvent) {
        if (_hscroll != null) {
            getTextInput().hscrollPos = _hscroll.pos;
        }
        if (_vscroll != null) {
            getTextInput().vscrollPos = _vscroll.pos;
        }
    }

    public override function onResized() {
        super.onResized();
        checkScrolls();
    }

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private function _validateText() {
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
        textArea.invalidateDisplay();
    }

    public override function get():Variant {
        var textArea:TextArea = cast _component;
        return textArea.getTextInput().text;
    }
}

@:dox(hide)
@:access(haxe.ui.components.TextArea)
class TextAreaDefaultPlaceholderBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var textArea:TextArea = cast _component;
        textArea._placeholder = value;
        textArea._validateText();
    }
    
    public override function get():Variant {
        var textArea:TextArea = cast _component;
        return textArea._placeholder;
    }
}

@:dox(hide)
@:access(haxe.ui.components.TextArea)
class TextAreaDefaultWrapBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var textArea:TextArea = cast _component;
        textArea.getTextInput().wordWrap = value;
        textArea.checkScrolls();
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
