package haxe.ui.layouts;

import haxe.ui.geom.Size;

class DefaultLayout extends Layout {
    private var _calcFullWidths:Bool = false;
    private var _calcFullHeights:Bool = false;

    public function new() {
        super();
    }

    private override function resizeChildren() {
        var usableSize:Size = usableSize;
        var percentWidth:Float = 100;
        var percentHeight:Float = 100;

        var fullWidthValue:Float = 100;
        var fullHeightValue:Float = 100;
        if (_calcFullWidths == true || _calcFullHeights == true) {
            var n1 = 0;
            var n2 = 0;
            for (child in component.childComponents) {
                if (child.includeInLayout == false) {
                    continue;
                }

                if (_calcFullWidths == true && child.percentWidth != null && child.percentWidth == 100) {
                    n1++;
                }
                if (_calcFullHeights == true && child.percentHeight != null && child.percentHeight == 100) {
                    n2++;
                }
            }

            if (n1 > 0) {
                fullWidthValue = 100 / n1;
            }
            if (n2 > 0) {
                fullHeightValue = 100 / n2;
            }
        }

        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var cx:Null<Float> = null;
            var cy:Null<Float> = null;

            if (child.percentWidth != null) {
                var childPercentWidth = child.percentWidth;
                if (childPercentWidth == 100) {
                    childPercentWidth = fullWidthValue;
                }
                cx = (usableSize.width * childPercentWidth) / percentWidth - marginLeft(child) - marginRight(child);
            }
            if (child.percentHeight != null) {
                var childPercentHeight = child.percentHeight;
                if (childPercentHeight == 100) {
                    childPercentHeight = fullHeightValue;
                }
                cy = (usableSize.height * childPercentHeight) / percentHeight - marginTop(child) - marginBottom(child);
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