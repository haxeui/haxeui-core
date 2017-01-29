package haxe.ui.components;

import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.util.Size;

class HButtonBar extends ButtonBar {

    public function new() {
        super();
    }

}

@:dox(hide)
class HButtonBarLayout extends HorizontalLayout {
    public function new() {
        super();
    }

    private override function resizeChildren() {
        var usableSize:Size = usableSize;
        trace(component.id, component.autoWidth);
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var cx:Null<Float> = null;
            var cy:Null<Float> = null;

            if (child.autoWidth == true && component.autoWidth == false) {
                child.percentWidth = 100 / component.childComponents.length;
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
        var xpos = paddingLeft;
        var usableSize:Size = component.layout.usableSize;

        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var ypos:Float = 0;

            switch (verticalAlign(child)) {
                case "center":
                    ypos = ((component.componentHeight - child.componentHeight) / 2) + marginTop(child) - marginBottom(child);
                case "bottom":
                    if (child.componentHeight < component.componentHeight) {
                        ypos = usableSize.height - (child.componentHeight + paddingBottom + marginTop(child));
                    }
                default:
                    ypos = paddingTop + marginTop(child);
            }

            child.moveComponent(xpos + marginLeft(child), ypos);
            xpos += child.componentWidth + horizontalSpacing;
            xpos = Math.fround(xpos);   // TODO - required to fix the issue -> https://github.com/haxeui/haxeui-core/issues/46
        }
    }
}