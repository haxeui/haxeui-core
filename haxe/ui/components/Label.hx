package haxe.ui.components;

import haxe.ui.components.Label.LabelLayout;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.TextDisplay;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;
import haxe.ui.validation.InvalidationFlags;

/**
 A general purpose component to display text
**/
@:dox(icon = "/icons/ui-label.png")
class Label extends Component {
    public function new() {
        super();
        #if (openfl && !flixel)
        mouseChildren = false;
        #end
    }

    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    @:style(layout)           public var textAlign:Null<String>;

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "text" => new LabelDefaultTextBehaviour(this)
        ]);
        _defaultLayout = new LabelLayout();
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function set_text(value:String):String {
        if (value == _text) {
            return value;
        }

        value = super.set_text(value);
        invalidateComponentData();
        invalidateComponentLayout();
        return value;
    }

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
        behaviourSet("text", _text);
        handleBindings(["text", "value"]);
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Label)
class LabelLayout extends DefaultLayout {
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
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.Label)
class LabelDefaultTextBehaviour extends Behaviour {
    public override function set(value:Variant) {
        if (value.isNull) {
            value = "";
        }

        var label:Label = cast _component;
        label.getTextDisplay().text = '${value}';
        if (label.isInvalid(InvalidationFlags.DISPLAY) == false) {
            label.invalidateComponentDisplay();
        }
    }
}
