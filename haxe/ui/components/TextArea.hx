package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.TextInput;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
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
    @:behaviour(HtmlTextBehaviour)          public var htmlText:String;
    @:clonable @:value(text)                public var value:Dynamic;
    @:behaviour(PlaceholderBehaviour)       public var placeholder:String;
    @:behaviour(WrapBehaviour, true)        public var wrap:Bool;
    @:behaviour(DataSourceBehaviour)        public var dataSource:DataSource<String>;
    @:behaviour(DefaultBehaviour)           public var autoScrollToBottom:Bool;

    @:call(ScrollToTop)                     public function scrollToTop();
    @:call(ScrollToBottom)                  public function scrollToBottom();

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private inline function invalidateComponentScroll() {
        invalidateComponent(InvalidationFlags.SCROLL);
    }

    private override function validateComponentInternal(nextFrame:Bool = true) {
        var dataInvalid = isComponentInvalid(InvalidationFlags.DATA);
        var scrollInvalid = isComponentInvalid(InvalidationFlags.SCROLL);
        var layoutInvalid = isComponentInvalid(InvalidationFlags.LAYOUT);

        super.validateComponentInternal(nextFrame);

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
            component.getTextInput().left = paddingLeft + 2;
            component.getTextInput().top = paddingTop + 2;
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
            component.getTextInput().width = size.width - 4;
            component.getTextInput().height = size.height - 4;
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
@:access(haxe.ui.backend.TextInputImpl)
private class DataSourceBehaviour extends DataBehaviour {
    public override function set(value:Variant) {
        _value = value;
        _component.getTextInput().dataSource = value;
    }

    public override function get():Variant {
        if (_value == null || _value.isNull) {
            _value = new ArrayDataSource<String>();
            set(_value);
        }
        return _value;
    }
}

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
        if (textarea.autoScrollToBottom == true) {
            textarea.scrollToBottom();
        }
    }
}

@:dox(hide) @:noCompletion
private class HtmlTextBehaviour extends DataBehaviour {
    public override function validateData() {
        var textarea:TextArea = cast(_component, TextArea);
        var htmlText:String = _value != null ? _value : "";
        TextAreaHelper.validateHtmlText(textarea, htmlText);
        if (textarea.autoScrollToBottom == true) {
            textarea.scrollToBottom();
        }
    }
}

@:dox(hide) @:noCompletion
private class WrapBehaviour extends DataBehaviour {
    public override function validateData() {
        var textarea:TextArea = cast(_component, TextArea);
        textarea.getTextInput().wordWrap = _value;
    }
}

private class ScrollToTop extends Behaviour {
    public override function call(param:Any = null):Variant {
        var vscroll = _component.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            vscroll.pos = 0;
        }
        return null;
    }
}

private class ScrollToBottom extends Behaviour {
    public override function call(param:Any = null):Variant {
        var vscroll = _component.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            vscroll.pos = vscroll.max;
        }
        return null;
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

        var placeholderVisible:Bool = text.length == 0;
        if (textarea.placeholder != null) {
            if (textarea.focus == false) {
                if (text.length == 0) {
                    text = textarea.placeholder;
                    textarea.addClass(":empty");
                } else if (text != textarea.placeholder) {
                    textarea.removeClass(":empty");
                }
            } else {
                textarea.removeClass(":empty");
                if (text == textarea.placeholder) {
                    text = "";
                }
            }
        } else {
            if (placeholderVisible == true) {
                textarea.removeClass(":empty");
            }
        }

        textarea.getTextInput().text = '${text}';
        textarea.getTextInput().invalidateComponent(InvalidationFlags.MEASURE);
        textarea.invalidateComponentLayout();
    }
    
    public static function validateHtmlText(textarea:TextArea, htmlText:String) {
        if (htmlText == null) {
            htmlText = "";
        }

        var placeholderVisible:Bool = htmlText.length == 0;
        if (textarea.placeholder != null) {
            if (textarea.focus == false) {
                if (htmlText.length == 0) {
                    htmlText = textarea.placeholder;
                    textarea.addClass(":empty");
                } else if (htmlText != textarea.placeholder) {
                    textarea.removeClass(":empty");
                }
            } else {
                textarea.removeClass(":empty");
                if (htmlText == textarea.placeholder) {
                    htmlText = "";
                }
            }
        } else {
            if (placeholderVisible == true) {
                textarea.removeClass(":empty");
            }
        }

        textarea.getTextInput().htmlText = '${htmlText}';
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
                    var text = _textarea.getTextInput().text;
                    if (text == null) {
                        text = "";
                    }
                    _textarea.text = text;
                    _textarea.dispatch(new UIEvent(UIEvent.CHANGE));
                    if (_textarea.style.autoHeight == true) {
                        var maxHeight = _textarea.style.maxHeight;
                        var newHeight = _textarea.getTextInput().textHeight + 8; // TODO: where does this magic number come from, seems to work across all backends - doesnt seem to be padding
                        if (maxHeight == null || newHeight < maxHeight) {
                            _textarea.height = newHeight;
                        }
                    }

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

        if (hasEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel) == false) {
            registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }
        if (hasEvent(MouseEvent.MOUSE_DOWN, onMouseDown) == false) {
            registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
        if (hasEvent(FocusEvent.FOCUS_IN, onFocusChange) == false) {
            registerEvent(FocusEvent.FOCUS_IN, onFocusChange);
        }
        if (hasEvent(FocusEvent.FOCUS_OUT, onFocusChange) == false) {
            registerEvent(FocusEvent.FOCUS_OUT, onFocusChange);
        }
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
            event.cancel();
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
        if (_textarea.style.autoHeight == true) {
            var maxHeight = _textarea.style.maxHeight;
            var newHeight = _textarea.getTextInput().textHeight + 8; // TODO: where does this magic number come from, seems to work across all backends - doesnt seem to be padding
            if (maxHeight == null || newHeight < maxHeight) {
                _textarea.height = newHeight;
            }
            if (maxHeight != null && newHeight > maxHeight) {
                _textarea.height = maxHeight;
            }
        }
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
        //event.cancel();
        _textarea.focus = true;
    }

    private function onFocusChange(event:FocusEvent) {
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
        if (textInput.textWidth - textInput.width > 1) {
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
        if (textInput.textHeight - textInput.height > 1) {
            if (vscroll == null) {
                vscroll = createVScroll();
            }

            vscroll.max = textInput.vscrollMax;
            vscroll.pos = textInput.vscrollPos;
            vscroll.pageSize = textInput.vscrollPageSize;

            if (_textarea.autoScrollToBottom == true) {
                _textarea.scrollToBottom();
            }
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
        hscroll.allowFocus = false;
        hscroll.scriptAccess = false;
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
        vscroll.allowFocus = false;
        vscroll.scriptAccess = false;
        _component.addComponent(vscroll);
        _component.registerInternalEvents(true);
        return vscroll;
    }

    public override function applyStyle(style:Style) {
        super.applyStyle(style);
        if (_textarea.hasTextInput() == true) {
            _textarea.getTextInput().textStyle = style;
            
            if ((style.contentType == "auto" || style.contentType == "html") && _textarea.getTextInput().supportsHtml && isHtml(Std.string(_textarea.text))) {
                _textarea.htmlText = _textarea.text;
            }
        }
    }
    
    public static inline function isHtml(v:String):Bool {
        return v == null ? false : v.indexOf("<font ") != -1;
    }
}
