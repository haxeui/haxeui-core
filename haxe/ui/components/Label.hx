package haxe.ui.components;

import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;

class Label extends Component {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    @:style(layout)           public var textAlign:Null<String>;
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(TextBehaviour)  public var text:String;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() { // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayout = new LabelLayout();
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function applyStyle(style:Style) {
        super.applyStyle(style);
        if (hasTextDisplay() == true) {
            getTextDisplay().textStyle = style;
        }
    }

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private override function validateData() {
        handleBindings(["text", "value"]);
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
class TextBehaviour extends Behaviour {
    public override function get():Variant {
        if (_component.hasTextDisplay() == false) {
            return "";
        }

        return _component.getTextDisplay().text;
    }

    public override function set(value:Variant) {
        if (value == null) {
            value = "";
        }

        if (get() == value) {
            return;
        }

        _component.getTextDisplay().text = '${value}';
        _component.invalidateData();
    }
}