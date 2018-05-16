package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.focus.IFocusable;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Size;

class TextArea2 extends InteractiveComponent implements IFocusable {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(TextBehaviour)              public var text:String;
    @:behaviour(PlaceholderBehaviour)       public var placeholder:String;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {  // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayout = new TextAreaLayout();
    }
    
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (width <= 0) {
            width = 150;
        }
        
        registerInternalEvents(Events);
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextAreaLayout extends DefaultLayout {
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
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PlaceholderBehaviour extends DataBehaviour {
    public override function validateData() {
        var textarea:TextArea2 = cast(_component, TextArea2);
        TextAreaHelper.validateText(textarea, textarea.text);
    }
}

@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    public override function validateData() {
        var textarea:TextArea2 = cast(_component, TextArea2);
        var text:String = _value != null ? _value : "";
        TextAreaHelper.validateText(textarea, text);
    }
}

//***********************************************************************************************************
// Helpers
//***********************************************************************************************************
@:access(haxe.ui.core.Component)
private class TextAreaHelper {
    public static function validateText(textarea:TextArea2, text:String) {
        var placeholderVisible:Bool = (text == null || text.length == 0);
        
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
        } else if (placeholderVisible == true) {
            textarea.removeClass(":empty");
        } else {
            textarea.removeClass(":empty");
        }
        
        textarea.getTextInput().text = '${text}';
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
private class Events extends haxe.ui.core.Events {
    private var _textarea:TextArea2;
    
    public function new(textarea:TextArea2) {
        super(textarea);
        _textarea = textarea;
    }
    
    public override function register() {
        if (_textarea.getTextInput().data.onChangedCallback == null) {
            _textarea.getTextInput().multiline = true;
            _textarea.getTextInput().data.onChangedCallback = function() {
                if (_textarea.hasClass(":empty") == false) {
                    _textarea.text = _textarea.getTextInput().text;
                }
            };
        }
        
        /*
        registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        registerEvent(FocusEvent.FOCUS_IN, onFocusChange);
        registerEvent(FocusEvent.FOCUS_OUT, onFocusChange);
        */
    }
}