package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.geom.Size;

@:composite(Builder, LabelLayout)
class Label extends Component {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    @:style(layout)                             public var textAlign:Null<String>;
    @:style(layout)                             public var wordWrap:Null<Bool>;

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(TextBehaviour)       public var text:String;
    @:clonable @:behaviour(HtmlTextBehaviour)   public var htmlText:String;
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
            component.getTextDisplay().tf.autoSize = !wordWrap;
            #elseif (haxeui_openfl)
            component.getTextDisplay().textField.autoSize = wordWrap == true ? openfl.text.TextFieldAutoSize.NONE : openfl.text.TextFieldAutoSize.LEFT;
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
