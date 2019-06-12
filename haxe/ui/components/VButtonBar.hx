package haxe.ui.components;

import haxe.ui.layouts.VerticalLayout;
import haxe.ui.util.Size;

class VButtonBar extends ButtonBar {

    public function new() {
        super();

        layout = new VButtonBarLayout();
    }

}

@:dox(hide)
class VButtonBarLayout extends VerticalLayout {
    public function new() {
        super();
    }

    private override function resizeChildren() {
        var usableSize:Size = usableSize;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var cx:Null<Float> = null;
            var cy:Null<Float> = null;

            if (child.autoHeight == true && component.autoHeight == false) {
                child.percentHeight = 100 / component.childComponents.length;
            }

            if (child.percentWidth != null) {
                cx = (usableSize.width * child.percentWidth) / 100 - marginLeft(child) - marginRight(child);
            }

            if (child.percentHeight != null) {
                cy = (usableSize.height * child.percentHeight) / 100 - marginTop(child) - marginBottom(child);
            }

            child.resizeComponent(cx, cy);
        }
    }

    private override function repositionChildren() {
        var ypos = paddingTop;
        var usableSize:Size = component.layout.usableSize;

        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var xpos:Float = 0;

            switch (horizontalAlign(child)) {
                case "center":
                    xpos = ((component.componentWidth - child.componentWidth) / 2) + marginLeft(child) - marginRight(child);
                case "right":
                    if (child.componentWidth < component.componentWidth) {
                        xpos = component.componentWidth - (child.componentWidth + paddingRight + marginLeft(child));
                    }
                default:
                    xpos = paddingLeft + marginLeft(child);
            }

            child.moveComponent(xpos, ypos + marginTop(child));
            ypos += child.componentHeight + verticalSpacing;
            ypos = Math.fround(ypos);   // TODO - required to fix the issue -> https://github.com/haxeui/haxeui-core/issues/46
        }
    }
}