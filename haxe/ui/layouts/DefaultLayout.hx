package haxe.ui.layouts;

import haxe.ui.geom.Size;

class DefaultLayout extends Layout {
    public function new() {
        super();
    }

    private override function resizeChildren() {
        var usableSize:Size = usableSize;
        var percentWidth:Float = 100;
        var percentHeight:Float = 100;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var cx:Null<Float> = null;
            var cy:Null<Float> = null;

            if (child.percentWidth != null) {
                cx = (usableSize.width * child.percentWidth) / percentWidth - marginLeft(child) - marginRight(child);
            }
            if (child.percentHeight != null) {
                cy = (usableSize.height * child.percentHeight) / percentHeight - marginTop(child) - marginBottom(child);
            }

            if (fixedMinWidth(child) && child.percentWidth != null) {
                percentWidth -= child.percentWidth;
            }
            if (fixedMinHeight(child) && child.percentHeight != null) {
                percentHeight -= child.percentHeight;
            }
            
            child.resizeComponent(cx, cy);
        }
    }

    private override function repositionChildren() {
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var xpos:Float = 0;
            var ypos:Float = 0;

            switch (horizontalAlign(child)) {
                case "center":
                    xpos = ((component.componentWidth - child.componentWidth) / 2) + marginLeft(child) - marginRight(child);
                case "right":
                    xpos = component.componentWidth - (child.componentWidth + paddingRight + marginRight(child));
                default:    //left
                    xpos = paddingLeft + marginLeft(child);
            }

            switch (verticalAlign(child)) {
                case "center":
                    ypos = ((component.componentHeight - child.componentHeight) / 2) + marginTop(child) - marginBottom(child);
                case "bottom":
                    ypos = component.componentHeight - (child.componentHeight + paddingBottom + marginBottom(child));
                default:    //top
                    ypos = paddingTop + marginTop(child);
            }

            child.moveComponent(xpos, ypos);
        }
    }
}