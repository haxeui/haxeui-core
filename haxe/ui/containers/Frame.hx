package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;

@:composite(Builder, Layout)
class Frame extends Box {
    @:clonable @:behaviour(TextBehaviour)              public var text:String;
    @:clonable @:behaviour(IconBehaviour)              public var icon:String;
    @:clonable @:value(text)                           public var value:Dynamic;
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

@:dox(hide) @:noCompletion
private class IconBehaviour extends DataBehaviour {
    private override function validateData() {
        var icon:Image = _component.findComponent("frame-icon", false);
        if (icon == null) {
            icon = new Image();
            icon.addClass("frame-icon");
            icon.id = "frame-icon";
            icon.scriptAccess = false;
            icon.includeInLayout = false;
            _component.addComponent(icon);
        }

        icon.resource = _value;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _frame:Frame;
    private var _contents:Box;
    private var _label:Label;

    public function new(frame:Frame) {
        super(frame);
        _frame = frame;
    }

    public override function create() {
        _contents = new Box();
        _contents.id = "frame-contents";
        _contents.addClass("frame-contents");
        _frame.addComponent(_contents);

        _label = new Label();
        _label.text = "My Frame";
        _label.id = "frame-title";
        _label.addClass("frame-title");
        _label.includeInLayout = false;
        _frame.addComponent(_label);

        var line = new Component();
        line.id = "frame-left-line";
        line.addClass("frame-left-line");
        line.includeInLayout = false;
        _frame.addComponent(line);

        var line = new Component();
        line.id = "frame-right-line";
        line.addClass("frame-right-line");
        line.includeInLayout = false;
        _frame.addComponent(line);
    }

    public override function addComponent(child:Component):Component {
        if (child.id != "frame-contents" && child.id != "frame-title"  && child.id != "frame-icon" && child.id != "frame-left-line" && child.id != "frame-right-line") {
            return _contents.addComponent(child);
        }
        return super.addComponent(child);
    }
}

//***********************************************************************************************************
// Layout
//***********************************************************************************************************
private class Layout extends DefaultLayout {
    public override function resizeChildren() {
        var contents = findComponent("frame-contents", Box, false);
        var label = findComponent("frame-title", Label, false);
        var icon = findComponent("frame-icon", Image, false);
        var line1 = findComponent("frame-left-line", Component, false);
        var line2 = findComponent("frame-right-line", Component, false);

        if (_component.autoWidth == false) {
            contents.width = _component.width;
        }
        if (_component.autoHeight == false) {
            contents.height = _component.height - (label.height / 2);
        }
        var offset = 2;
        #if haxeui_openfl
        offset = 0;
        #end
        line1.width = paddingLeft - offset;
        var cx = label.width;
        if (icon != null) {
            cx += icon.width + horizontalSpacing;
        }
        line2.width = _component.width - (paddingLeft + cx) - offset;
    }

    public override function repositionChildren() {
        var contents = findComponent("frame-contents", Box, false);
        var label = findComponent("frame-title", Label, false);
        var icon = findComponent("frame-icon", Image, false);
        var line1 = findComponent("frame-left-line", Component, false);
        var line2 = findComponent("frame-right-line", Component, false);

        contents.top = _component.height - contents.height;
        var offset = 2;
        #if haxeui_openfl
        offset = 0;
        #end
        var x = paddingLeft;
        if (icon != null) {
            icon.top = (label.height / 2) - (icon.height / 2) - 1;
            icon.left = paddingLeft;
            x += icon.width + horizontalSpacing;
        }
        label.left = x;
        line1.top = contents.top;
        line2.left = _component.width - line2.width;
        line2.top = contents.top;
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var label = findComponent("frame-title", Label, false);
        var size = super.calcAutoSize(exclusions);
        size.height += label.height / 2;
        size.width -= paddingLeft;
        return size;
    }
}
