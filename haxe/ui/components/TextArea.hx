package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.TextInput;
import haxe.ui.events.Events;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.IFocusable;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;
import haxe.ui.validation.InvalidationFlags;

@:composite(Events, TextAreaBuilder, TextAreaLayout)
class TextArea extends InteractiveComponent implements IFocusable {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(TextBehaviour)              public var text:String;
    @:behaviour(ValueBehaviour)             public var value:Variant;
    @:behaviour(PlaceholderBehaviour)       public var placeholder:String;
    @:behaviour(WrapBehaviour, true)        public var wrap:Bool;
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private inline function invalidateComponentScroll() {
        invalidateComponent(InvalidationFlags.SCROLL);
    }

    private override function validateComponentInternal() {
        var dataInvalid = isComponentInvalid(InvalidationFlags.DATA);
        var scrollInvalid = isComponentInvalid(InvalidationFlags.SCROLL);
        var layoutInvalid = isComponentInvalid(InvalidationFlags.LAYOUT);

        super.validateComponentInternal();

        if (scrollInvalid || layoutInvalid || dataInvalid) {
            if (_compositeBuilder != null) {
                cast(_compositeBuilder, TextAreaBuilder).checkScrolls(); // TODO: would be nice to not have this
            }
        }
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextAreaLayout extends DefaultLayout {
    private override function repositionChildren() {
        var hscroll:Component = component.findComponent(HorizontalScroll, false);
        var vscroll:Component = component.findComponent(VerticalScroll, false);

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

        var hscroll:Component = component.findComponent(HorizontalScroll, false);
        var vscroll:Component = component.findComponent(VerticalScroll, false);

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
            component.getTextInput().width = size.width - 1;
            component.getTextInput().height = size.height - 1;
            #end

        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var hscroll:Component = component.findComponent(HorizontalScroll, false);
        var vscroll:Component = component.findComponent(VerticalScroll, false);
        if (hscroll != null && hidden(hscroll) == false) {
            size.height -= hscroll.componentHeight;
        }
        if (vscroll != null && hidden(vscroll) == false) {
            size.width -= vscroll.componentWidth;
        }

        return size;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PlaceholderBehaviour extends DataBehaviour {
    public override function validateData() {
        var textarea:TextArea = cast(_component, TextArea);
        TextAreaHelper.validateText(textarea, textarea.text);
    }
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    public override function validateData() {
        var textarea:TextArea = cast(_component, TextArea);
        var text:String = _value != null ? _value : "";
        TextAreaHelper.validateText(textarea, text);
    }
}


@:dox(hide) @:noCompletion
private class ValueBehaviour extends Behaviour {
    public override function get():Variant {
        return cast(_component, TextArea).text;
    }
    
    public override function set(value:Variant) {
        cast(_component, TextArea).text = value;
    }
}

@:dox(hide) @:noCompletion
private class WrapBehaviour extends DataBehaviour {
    public override function validateData() {
        var textarea:TextArea = cast(_component, TextArea);
        textarea.getTextInput().wordWrap = _value;
    }
}

//***********************************************************************************************************
// Helpers
//***********************************************************************************************************
@:access(haxe.ui.core.Component)
private class TextAreaHelper {
    public static function validateText(textarea:TextArea, text:String) {
        if (text == null) {
           text = ""; 
        }

        if (textarea.focus == false && textarea.placeholder != null) {
            if (text == "") {
                text = textarea.placeholder;
                textarea.addClass(":empty");
            } else {
                textarea.removeClass(":empty");
            }
        } else {
            var placeholderVisible:Bool = text.length == 0;
            if (placeholderVisible == true) {
                text = "";
                textarea.removeClass(":empty");
            }
        }
        
        textarea.getTextInput().text = '${text}';
        textarea.getTextInput().invalidateComponent(InvalidationFlags.MEASURE);
        textarea.invalidateComponentLayout();
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:access(haxe.ui.core.Component)
private class Events extends haxe.ui.events.Events {
    private var _textarea:TextArea;
    
    public function new(textarea:TextArea) {
        super(textarea);
        _textarea = textarea;
    }
    
    public override function register() {
        if (_textarea.getTextInput().data.onChangedCallback == null) {
            _textarea.getTextInput().multiline = true;
            _textarea.getTextInput().data.onChangedCallback = function() {
                if (_textarea.hasClass(":empty") == false) {
                    _textarea.text = _textarea.getTextInput().text;
                    cast(_textarea._compositeBuilder, TextAreaBuilder).checkScrolls();
                }
            };
        }
        
        if (_textarea.getTextInput().data.onScrollCallback == null) {
            _textarea.getTextInput().data.onScrollCallback = function() {
                var hscroll:HorizontalScroll = _textarea.findComponent(HorizontalScroll, false);
                if (hscroll != null) {
                    hscroll.pos = _textarea.getTextInput().hscrollPos;
                }
                var vscroll:VerticalScroll = _textarea.findComponent(VerticalScroll, false);
                if (vscroll != null) {
                    vscroll.pos = _textarea.getTextInput().vscrollPos;
                }
            }
        }
        
        var hscroll:HorizontalScroll = _textarea.findComponent(HorizontalScroll, false);
        if (hscroll != null && hscroll.hasEvent(UIEvent.CHANGE, onScrollChange) == false) {
            hscroll.registerEvent(UIEvent.CHANGE, onScrollChange);
        }
        
        var vscroll:VerticalScroll = _textarea.findComponent(VerticalScroll, false);
        if (vscroll != null && vscroll.hasEvent(UIEvent.CHANGE, onScrollChange) == false) {
            vscroll.registerEvent(UIEvent.CHANGE, onScrollChange);
        }
        
        registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        registerEvent(FocusEvent.FOCUS_IN, onFocusChange);
        registerEvent(FocusEvent.FOCUS_OUT, onFocusChange);
    }
    
    public override function unregister() {
        _textarea.getTextInput().data.onChangedCallback = null;
        _textarea.getTextInput().data.onScrollCallback = null;
        
        var hscroll:HorizontalScroll = _textarea.findComponent(HorizontalScroll, false);
        if (hscroll != null) {
            hscroll.unregisterEvent(UIEvent.CHANGE, onScrollChange);
        }
        
        var vscroll:VerticalScroll = _textarea.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            vscroll.unregisterEvent(UIEvent.CHANGE, onScrollChange);
        }
        
        unregisterEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        unregisterEvent(FocusEvent.FOCUS_IN, onFocusChange);
        unregisterEvent(FocusEvent.FOCUS_OUT, onFocusChange);
    }
    
    private function onMouseWheel(event:MouseEvent) {
        if (_textarea.getTextInput().data.vscrollNativeWheel == true) {
            return;
        }
        var vscroll:VerticalScroll = _textarea.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            var step:Float = 20;
            if (_textarea.getTextInput().data.vscrollPageStep != null) {
                step = _textarea.getTextInput().data.vscrollPageStep;
            } else {
                step = Math.ceil((_textarea.getTextInput().textStyle.fontSize + 1) / 10) * 10;
            }
            if (event.delta > 0) {
                vscroll.pos -= step;
            } else if (event.delta < 0) {
                vscroll.pos += step;
            }
        }
    }
    
    private function onScrollChange(event:UIEvent) {
        var hscroll:HorizontalScroll = _textarea.findComponent(HorizontalScroll, false);
        if (hscroll != null) {
            _textarea.getTextInput().hscrollPos = hscroll.pos;
        }
        
        var vscroll:VerticalScroll = _textarea.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            _textarea.getTextInput().vscrollPos = vscroll.pos;
        }
    }
    
    private function onMouseDown(event:MouseEvent) { // TODO: this should happen automatically as part of InteractiveComponent (?)
        _textarea.focus = true;
    }
    
    private function onFocusChange(event:MouseEvent) {
        if (_textarea.focus == true) {
            _textarea.getTextInput().focus();
        } else {
            _textarea.getTextInput().blur();
        }
        TextAreaHelper.validateText(_textarea, _textarea.text);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.components.TextArea)
@:access(haxe.ui.core.Component)
private class TextAreaBuilder extends CompositeBuilder {
    private var _textarea:TextArea;
    
    public function new(textarea:TextArea) {
        super(textarea);
        _textarea = textarea;
    }
    
    public function checkScrolls() {
        if (_textarea.native == true) {
            return;
        }
        
        var textInput:TextInput = _textarea.getTextInput();
        
        var hscroll:HorizontalScroll = _component.findComponent(HorizontalScroll, false);
        if (textInput.textWidth > textInput.width) {
            if (hscroll == null) {
                hscroll = createHScroll();
            }
            
            hscroll.max = textInput.hscrollMax;
            hscroll.pos = textInput.hscrollPos;
            hscroll.pageSize = textInput.hscrollPageSize;
        } else {
            if (hscroll != null) {
                _component.removeComponent(hscroll);
            }
        }
        
        var vscroll:VerticalScroll = _component.findComponent(VerticalScroll, false);
        if (textInput.textHeight > textInput.height) {
            if (vscroll == null) {
                vscroll = createVScroll();
            }
            
            vscroll.max = textInput.vscrollMax;
            vscroll.pos = textInput.vscrollPos;
            vscroll.pageSize = textInput.vscrollPageSize;
            
        } else {
            if (vscroll != null) {
                _component.removeComponent(vscroll);
            }
        }
    }
    
    public function createHScroll():HorizontalScroll {
        var hscroll = new HorizontalScroll();
        hscroll.percentWidth = 100;
        hscroll.id = "textarea-hscroll";
        _component.addComponent(hscroll);
        _component.registerInternalEvents(true);
        return hscroll;
    }
    
    public function createVScroll():VerticalScroll {
        var vscroll = new VerticalScroll();
        if (_textarea.getTextInput().data.vscrollPageStep != null) {
            vscroll.increment = _textarea.getTextInput().data.vscrollPageStep;
        }
        vscroll.percentHeight = 100;
        vscroll.id = "textarea-vscroll";
        _component.addComponent(vscroll);
        _component.registerInternalEvents(true);
        return vscroll;
    }
    
    public override function applyStyle(style:Style) {
        super.applyStyle(style);
        if (_component.hasTextInput() == true) {
            _component.getTextInput().textStyle = style;
        }
    }
}