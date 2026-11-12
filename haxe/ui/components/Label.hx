package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.focus.IFocusable;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;

/**
 * A way to display static (uneditable) text.
 */
@:composite(Builder, LabelLayout)
class Label extends Component implements IFocusable {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    /**
     * The alignment of the text inside the label. can be one of:
     * 
     *  - "left"
     *  - "right"
     *  - "center"
     *  - "justify"
     */
    @:style(layout)                             public var textAlign:Null<String>;

    /**
     * Whether or not the label should automatically transfer text for which 
     * there isn't enough space from the end of the current line of text to the beginning of the next.
     */
    @:style(layout)                             public var wordWrap:Null<Bool>;

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    /**
     * The actual text displayed inside the label.
     */
    @:clonable @:behaviour(TextBehaviour)       public var text:String;

    /**
     * A string containing HTML markup to be displayed inside the label.
     */
    @:clonable @:behaviour(HtmlTextBehaviour)   public var htmlText:String;

    /**
     * The text displayed inside the label.
     * 
     * `value` is used as a universal way to access the "core" value a component is based on. 
     * in this case, its the text inside of the label.
     */
    @:clonable @:value(text)                    public var value:Dynamic;

    /**
     * Wheter the label text can be selected by the user or not
     */
    @:clonable @:behaviour(SelectableBehaviour) public var selectable:Bool;

    @:style public var fontSize:Null<Float>;

    //***********************************************************************************************************
    // Focus (opt in)
    //***********************************************************************************************************
    private var _focusableLinks:Bool = false;
    /**
     * Whether the links in `htmlText` can be reached by keyboard: the label then takes its turn in the focus order
     * (Tab) while its `htmlText` has a link, where the backend supports it. Off by default, so a label stays out of
     * the focus order and clicking one takes focus from what has it, as before.
     */
    public var focusableLinks(get, set):Bool;
    private function get_focusableLinks():Bool {
        return _focusableLinks;
    }
    private function set_focusableLinks(value:Bool):Bool {
        if (_focusableLinks == value) {
            return value;
        }
        _focusableLinks = value;
        if (value == false && _focus == true) {
            focus = false;
        }
        return value;
    }

    private var _focus:Bool = false;
    /**
     * Whether the label has focus: only with `focusableLinks` and a link in its `htmlText`.
     */
    public var focus(get, set):Bool;
    private function get_focus():Bool {
        return _focus;
    }
    private function set_focus(value:Bool):Bool {
        if (_focus == value || (value == true && allowFocus == false)) {
            return value;
        }
        _focus = value;
        if (_focus == true) {
            FocusManager.instance.focus = cast(this, IFocusable);
            var scrollview = findScroller();
            if (scrollview != null) {
                scrollview.ensureVisible(this);
            }
        } else if (FocusManager.instance.focus == cast(this, IFocusable)) {
            FocusManager.instance.focus = null;
        }
        dispatch(new FocusEvent(_focus == true ? FocusEvent.FOCUS_IN : FocusEvent.FOCUS_OUT));
        return value;
    }

    private var _allowFocus:Bool = true;
    /**
     * Whether the label takes focus: `focusableLinks` on, a link in its `htmlText`, and not set false (as a parent
     * keeping focus out of what's inside it does).
     */
    public var allowFocus(get, set):Bool;
    private function get_allowFocus():Bool {
        return _focusableLinks == true && _allowFocus == true && hasLink();
    }
    private function set_allowFocus(value:Bool):Bool {
        _allowFocus = value;
        return value;
    }

    /**
     * Never focused on its own when a view opens.
     */
    public var autoFocus(get, set):Bool;
    private function get_autoFocus():Bool {
        return false;
    }
    private function set_autoFocus(value:Bool):Bool {
        return value;
    }

    private static var linkPattern = ~/<a[\s>]/i;

    private function hasLink():Bool {
        var html = htmlText;
        return html != null && linkPattern.match(html);
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class LabelLayout extends DefaultLayout {
    private override function resizeChildren() {
        if (component.autoWidth == false) {
            component.getTextDisplay().width = component.componentWidth - paddingLeft - paddingRight;

            var wordWrap = true;
            if (_component.style != null && _component.style.wordWrap != null) {
                wordWrap = _component.style.wordWrap;
            }
            
            // TODO: make not specific - need to check all backends first - update: can move to backends!
            #if (haxeui_flixel)
            component.getTextDisplay().wordWrap = wordWrap;
            component.getTextDisplay().tf.autoSize = false;
            #elseif (haxeui_openfl)
            component.getTextDisplay().textField.autoSize = openfl.text.TextFieldAutoSize.NONE;
            component.getTextDisplay().multiline = wordWrap;
            component.getTextDisplay().wordWrap = wordWrap;
            #elseif (haxeui_pixijs)
            component.getTextDisplay().textField.style.wordWrapWidth = component.getTextDisplay().width;
            component.getTextDisplay().wordWrap = wordWrap;
            #else
            component.getTextDisplay().wordWrap = wordWrap;
            #end
        } else {
            component.getTextDisplay().width = component.getTextDisplay().textWidth;
        }

        if (component.autoHeight == true) {
            component.getTextDisplay().height = component.getTextDisplay().textHeight;
        } else {
            component.getTextDisplay().height = component.height;
        }
    }

    private override function repositionChildren() {
        if (component.hasTextDisplay() == true) {
            component.getTextDisplay().left = paddingLeft;
            component.getTextDisplay().top = paddingTop;
        }
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var size:Size = super.calcAutoSize(exclusions);
        if (component.hasTextDisplay() == true) {
            size.width += component.getTextDisplay().textWidth;
            size.height += component.getTextDisplay().textHeight;
        }
        return size;
    }

    private function textAlign(child:Component):String {
        if (child == null || child.style == null || child.style.textAlign == null) {
            return "left";
        }
        return child.style.textAlign;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    public override function validateData() {
        if (_component.getTextDisplay().textStyle != _component.style) {
            _component.invalidateComponentStyle(true);
        }
        _component.getTextDisplay().text = '${_value}';
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

@:dox(hide) @:noCompletion
private class HtmlTextBehaviour extends DataBehaviour {
    public override function validateData() {
        if (_component.getTextDisplay().textStyle != _component.style) {
            _component.invalidateComponentStyle(true);
        }
        _component.getTextDisplay().htmlText = '${_value}';
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

@:dox(hide) @:noCompletion
private class SelectableBehaviour extends DataBehaviour {
    public override function validateData() {
        _component.getTextDisplay().selectable = _value;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _label:Label;

    public function new(label:Label) {
        super(label);
        _label = label;
    }

    public override function applyStyle(style:Style) {
        if (_label.hasTextDisplay() == true) {
            _label.getTextDisplay().textStyle = style;

            if ((style.contentType == "auto" || style.contentType == "html") && _label.getTextDisplay().supportsHtml && isHtml(Std.string(_component.text))) {
                _label.htmlText = _label.text;
            }
        }

    }

    public static inline function isHtml(v:String):Bool {
        return v == null ? false : v.indexOf("<font ") != -1;
    }
    
    public override function get_isComponentClipped():Bool {
        var componentClipRect = _component.componentClipRect;
        if (componentClipRect == null) {
            return false;
        }
        
        return _label.getTextDisplay().measureTextWidth() > componentClipRect.width;
    }
}
