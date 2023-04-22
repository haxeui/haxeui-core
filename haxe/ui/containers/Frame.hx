package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;

@:composite(Builder, Layout)
class Frame extends Box {
    @:clonable @:behaviour(TextBehaviour)               public var text:String;
    @:clonable @:behaviour(IconBehaviour)               public var icon:String;
    @:clonable @:behaviour(CollapsibleBehaviour)        public var collapsible:Bool;
    @:clonable @:behaviour(CollapsedBehaviour)          public var collapsed:Bool;
    @:clonable @:value(text)                            public var value:Dynamic;
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
        var icon:Image = _component.findComponent("frame-icon", Image, false);
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

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class CollapsibleBehaviour extends DataBehaviour {
    private override function validateData() {
        var builder = cast(_component._compositeBuilder, Builder);
        if (_value == true) {
            builder.addCollapsibleHeader();
        } else {
            builder.removeCollapsibleHeader();
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class CollapsedBehaviour extends DataBehaviour {
    private override function validateData() {
        var frame = cast(_component, Frame);
        var builder = cast(_component._compositeBuilder, Builder);
        builder.addCollapsibleHeader();
        frame.collapsible = true;


        var header = _component.findComponent("frame-header", Header);
        var border = _component.findComponent("frame-border", Box);
        var contents = _component.findComponent("frame-contents", Box);
        var collapseExpandIcon = header.findComponent("frame-collapse-expand-icon", Image);

        if (_value == true) {
            collapseExpandIcon.swapClass("collapsed", "expanded");
            border.swapClass("collapsed", "expanded");
            contents.swapClass("collapsed", "expanded");
        } else {
            collapseExpandIcon.swapClass("expanded", "collapsed");
            border.swapClass("expanded", "collapsed");
            contents.swapClass("expanded", "collapsed");
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _frame:Frame;
    private var _border:Box;
    private var _contents:Box;
    private var _label:Label;
    private var _header:Header;

    public function new(frame:Frame) {
        super(frame);
        _frame = frame;
    }

    public override function create() {
        _border = new Box();
        _border.id = "frame-border";
        _border.addClass("frame-border");
        _border.includeInLayout = false;
        _border.scriptAccess = false;
        _frame.addComponent(_border);

        _contents = new Box();
        _contents.id = "frame-contents";
        _contents.addClass("frame-contents");
        _contents.scriptAccess = false;
        _frame.addComponent(_contents);

        _label = new Label();
        _label.text = "My Frame";
        _label.id = "frame-title";
        _label.addClass("frame-title");
        _label.includeInLayout = false;
        _label.scriptAccess = false;
        _frame.addComponent(_label);

        var line = new Component();
        line.id = "frame-left-line";
        line.addClass("frame-left-line");
        line.includeInLayout = false;
        _label.scriptAccess = false;
        _frame.addComponent(line);

        var line = new Component();
        line.id = "frame-right-line";
        line.addClass("frame-right-line");
        line.includeInLayout = false;
        _label.scriptAccess = false;
        _frame.addComponent(line);
    }

    public function addCollapsibleHeader() {
        _component.addClass("collapsible");
        var header = _component.findComponent("frame-header", Header);
        if (header == null) {
            header = new Header();
            _component.addComponent(header);
        }
        var collapseExpandIcon = header.findComponent("frame-collapse-expand-icon", Image);
        if (collapseExpandIcon == null) {
            collapseExpandIcon = new Image();
            collapseExpandIcon.id = "frame-collapse-expand-icon";
            collapseExpandIcon.addClasses(["frame-collapse-expand-icon", "expanded"]);
            header.addComponent(collapseExpandIcon);
            collapseExpandIcon.onClick = onExpandCollapseClicked;
        }
        var title = _component.findComponent("frame-title", Label);
        if (title != null) {
            title.onClick = onExpandCollapseClicked;
        }
        var icon = _component.findComponent("frame-icon", Image);
        if (icon != null) {
            icon.onClick = onExpandCollapseClicked;
        }
    }

    public function removeCollapsibleHeader() {
        _component.removeClass("collapsible");
        var header = _component.findComponent("frame-header", Header);
        if (header != null) {
            _component.removeComponent(header);
        }
    }

    private function onExpandCollapseClicked(_) {
        _frame.collapsed = !_frame.collapsed;
    }

    public override function addComponent(child:Component):Component {
        if ((child is Header)) {
            _header = cast child;
            _header.id = "frame-header";
            _header.addClass("frame-header");
            _header.includeInLayout = false;
        } else if (child.id != "frame-border" && child.id != "frame-contents" && child.id != "frame-title"  && child.id != "frame-icon" && child.id != "frame-left-line" && child.id != "frame-right-line") {
            return _contents.addComponent(child);
        }
        return super.addComponent(child);
    }

    public override function applyStyle(style:Style) {
        if (style.icon != null) {
            _frame.icon = style.icon;
        } else {
            //_frame.icon = null;
        }
    }
}

//***********************************************************************************************************
// Layout
//***********************************************************************************************************
private class Layout extends DefaultLayout {
    public override function resizeChildren() {
        var border = findComponent("frame-border", Box, false);
        var contents = findComponent("frame-contents", Box, false);
        var label = findComponent("frame-title", Label, false);
        var icon = findComponent("frame-icon", Image, false);
        var line1 = findComponent("frame-left-line", Component, false);
        var line2 = findComponent("frame-right-line", Component, false);

        border.width = _component.width;
        border.height = _component.height - (label.height / 2);

        if (_component.autoWidth == false) {
            contents.width = border.width;
        }
        if (_component.autoHeight == false) {    
            contents.height = border.height;
        }
        var offset:Float = 2;
        #if haxeui_openfl
        offset = 0;
        #end

        var titleOffset:Float = 0;
        var frameHeader = findComponent("frame-header", Header, false);
        if (frameHeader != null) {
            switch (frameHeader.horizontalAlign) {
                case "left":
                    titleOffset = frameHeader.width;
            }
        }

        line1.width = paddingLeft - offset;
        var cx = label.width;
        if (icon != null) {
            cx += icon.width + horizontalSpacing;
        }
        line2.width = _component.width - (paddingLeft + cx) - offset - titleOffset;
    }

    public override function repositionChildren() {
        var border = findComponent("frame-border", Box, false);
        var contents = findComponent("frame-contents", Box, false);
        var label = findComponent("frame-title", Label, false);
        var icon = findComponent("frame-icon", Image, false);
        var line1 = findComponent("frame-left-line", Component, false);
        var line2 = findComponent("frame-right-line", Component, false);

        var titleOffset:Float = 0;
        var frameHeader = findComponent("frame-header", Header, false);
        if (frameHeader != null) {
            switch (frameHeader.horizontalAlign) {
                case "left":
                    frameHeader.left = marginLeft(frameHeader);
                    titleOffset = frameHeader.width + marginLeft(frameHeader);
                case "right":
                    frameHeader.left = _component.width - frameHeader.width - marginRight(frameHeader);
            }

            switch (frameHeader.verticalAlign) {
                case "center":
                    frameHeader.top = (label.height / 2) - (frameHeader.height / 2);
            }
        }

        border.top = _component.height - border.height;
        contents.top = border.top;

        var x = paddingLeft + titleOffset;
        if (icon != null) {
            icon.top = (label.height / 2) - (icon.height / 2) - 1;
            icon.left = paddingLeft + titleOffset - marginLeft(frameHeader);
            x += icon.width + horizontalSpacing;
        }
        label.left = x - marginLeft(frameHeader);
        line1.top = contents.top;
        line2.left = _component.width - line2.width;
        line2.top = contents.top;
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var label = findComponent("frame-title", Label, false);
        var size = super.calcAutoSize(exclusions);
        size.height += label.height / 2;
        size.width -= paddingLeft;
        if (label != null && label.width > size.width) {
            var contents = findComponent("frame-contents", Box, false);
            size.width = label.width + (childPaddingLeft(contents) + childPaddingRight(contents));
        }
        return size;
    }
}
