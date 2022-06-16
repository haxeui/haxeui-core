package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.geom.Size;

/**
 * A way to display static (uneditable) text.
 */
@:composite(Builder, LabelLayout)
class Label extends Component {
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
     * Wether or not the label should escape text to the next line if its wider then the width of the label.
     */
    @:style(layout)                             public var wordWrap:Null<Bool>;

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    /**
     * The actual text that is displayed inside the label.
     */
    @:clonable @:behaviour(TextBehaviour)       public var text:String;

    /**
     * A string containing HTML markup to be displayed inside the text field.
     */
    @:clonable @:behaviour(HtmlTextBehaviour)   public var htmlText:String;

    /**
     * The text displayed inside of the label.
     * 
     * `value` is used as a universal way to access the value a component is based on. in this case its the text inside of the label.
     */
    @:clonable @:value(text)                    public var value:Dynamic;
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

        //Extra space is needed to ensure the last line in multiline labels is visible.
        var extraSpace:Int=(component.getTextDisplay().textField.numLines>1)?5:0;
        if (component.autoHeight == true) {
            component.getTextDisplay().height = component.getTextDisplay().textHeight+extraSpace;
        } else {
            component.getTextDisplay().height = component.height+extraSpace;
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
            //Extra space is needed to ensure the last line in multiline labels is visible.
            var extraSpace:Int=(component.getTextDisplay().textField.numLines>1)?5:0;
            size.height += component.getTextDisplay().textHeight+extraSpace;
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
