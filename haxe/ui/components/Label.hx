package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.geom.Size;
import haxe.ui.styles.Style2;
import haxe.ui.util.Variant;

@:composite(Builder, LabelLayout)
class Label extends Component {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
//    @:style(layout)                             public var textAlign:Null<String>;
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(TextBehaviour)       public var text:String;
    @:clonable @:behaviour(TextBehaviour)       public var value:Variant;
    @:clonable @:behaviour(HtmlTextBehaviour)   public var htmlText:String;
    
    private override function applyStyle2(style:Style2) {
        super.applyStyle2(style);
        if (hasTextDisplay() == true) {
            getTextDisplay().textStyle2 = style;
        }
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

             // TODO: make not specific - need to check all backends first
            #if (flixel)
            component.getTextDisplay().wordWrap = true;
            component.getTextDisplay().tf.autoSize = false;
            #elseif (openfl)
            component.getTextDisplay().textField.autoSize = openfl.text.TextFieldAutoSize.NONE;
            component.getTextDisplay().multiline = true;
            component.getTextDisplay().wordWrap = true;
            #elseif (pixijs)
            component.getTextDisplay().textField.style.wordWrapWidth = component.getTextDisplay().width;
            component.getTextDisplay().wordWrap = true;
            #else
            component.getTextDisplay().wordWrap = true;
            #end
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
        if (child == null || child.computedStyle == null || child.computedStyle.textAlign == null) {
            return "left";
        }
        return child.computedStyle.textAlign;
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
    }
}

@:dox(hide) @:noCompletion
private class HtmlTextBehaviour extends DataBehaviour {
    public override function validateData() {
        _component.getTextDisplay().htmlText = '${_value}';
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
        /*
        var p = _component;
        while (p != null) {
            if (p.style != null && p.style.color != null) {
                trace("WE GOT COLOR FROM: " + Type.getClassName(Type.getClass(p)) + ", " + StringTools.hex(p.style.color, 6));
                //style.color = p.style.color;
            }
            p = p.parentComponent;
            if (p == null) {
                break;
            }
        }
        */
        
        
        if (_label.hasTextDisplay() == true) {
            _label.getTextDisplay().textStyle2 = _component.computedStyle;
        }
        if (_label.hasTextDisplay() == true) {
            _label.getTextDisplay().textStyle = style;
        }
    }
}
