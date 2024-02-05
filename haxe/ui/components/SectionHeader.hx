package haxe.ui.components;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Label;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.styles.Style;

@:composite(Builder)
/**
    A content header you can add to your components to make, for example, some sort of a navbar.
**/
class SectionHeader extends VBox {
    /**
        The text displayed inside this header.
    **/
    @:clonable @:behaviour(TextBehaviour)              public var text:String;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label:Label = _component.findComponent(Label, false);
        label.text = _value;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    public override function create() {
        super.create();
        
        var label = new Label();
        label.text = "Section Header";
        label.scriptAccess = false;
        _component.addComponent(label);
        
        var line = new HorizontalRule();
        line.addClasses(["section-line", "line"]);
        line.scriptAccess = false;
        _component.addComponent(line);
    }

    public override function applyStyle(style:Style) {
        super.applyStyle(style);
        
        haxe.ui.macros.ComponentMacros.cascadeStylesToList(Label, [
            color, fontName, fontSize, cursor, textAlign, fontBold, fontUnderline, fontItalic
        ]);
    }
}