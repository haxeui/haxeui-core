package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.geom.Size;

class DefaultLayout extends Layout {
    @:clonable private var _calcFullWidths:Bool = false;
    @:clonable private var _calcFullHeights:Bool = false;
    @:clonable private var _roundFullWidths:Bool = false;
    
    private override function resizeChildren() {
        var items = getLayoutItems();
        items.calcFullWidths = _calcFullWidths;
        items.calcFullHeights = _calcFullHeights;
        items.roundFullWidths = _roundFullWidths;
        items.applyRounding();

        if (items.usableWidth <= 0 || items.usableHeight <= 0 || items.children.length == 0) {
            return;
        }

        for (child in items.children) {
            var cx:Null<Float> = null;
            var cy:Null<Float> = null;

            if (child.percentWidth != null) {
                var childPercentWidth = child.percentWidth;
                if (childPercentWidth == 100) {
                    childPercentWidth = items.fullWidthValue;
                }
                cx = ((items.usableSize.width * childPercentWidth) / 100) - child.marginLeft - child.marginRight;
                if (child.widthRoundingDirection != null) {
                    if (child.widthRoundingDirection == 0) {
                        cx = Math.ffloor(cx);
                    } else if (child.widthRoundingDirection == 1) {
                        cx = Math.fceil(cx);
                    }
                }
            }

            if (child.percentHeight != null) {
                var childPercentHeight = child.percentHeight;
                if (childPercentHeight == 100) {
                    childPercentHeight = items.fullHeightValue;
                }
                cy = ((items.usableSize.height * childPercentHeight) / 100) - child.marginTop - child.marginBottom;
            }

            if (cx != null) {
                if (child.minWidth != null && cx <= child.minWidth) {
                    cx = child.minWidth;
                }
                if (child.maxWidth != null && cx >= child.maxWidth) {
                    cx = child.maxWidth;
                }
            }

            if (cy != null) {
                if (child.minHeight != null && cy <= child.minHeight) {
                    cy = child.minHeight;
                }
                if (child.maxHeight != null && cy >= child.maxHeight) {
                    cy = child.maxHeight;
                }
            }

            child.resizeComponent(cx, cy);
        }
    }

    private override function repositionChildren() {
        var items = getLayoutItems();
        if (items.usableWidth <= 0 || items.usableHeight <= 0 || items.children.length == 0) {
            return;
        }

        for (child in items.children) {
            var xpos:Float = 0;
            var ypos:Float = 0;

            switch (child.horizontalAlign) {
                case "center":
                    xpos = ((items.usableSize.width - child.width) / 2) + paddingLeft + child.marginLeft - child.marginRight;
                case "right":
                    xpos = component.componentWidth - (child.width + paddingRight + child.marginRight);
                default:    //left
                    xpos = paddingLeft + child.marginLeft;
            }

            switch (child.verticalAlign) {
                case "center":
                    ypos = ((items.usableSize.height - child.height) / 2) + paddingTop + child.marginTop - child.marginBottom;
                case "bottom":
                    ypos = component.componentHeight - (child.height + paddingBottom + child.marginBottom);
                default:    //top
                    ypos = paddingTop + child.marginTop;
            }

            child.moveComponent(xpos, ypos);
        }
    }
}