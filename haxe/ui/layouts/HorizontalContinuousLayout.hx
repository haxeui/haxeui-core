package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Size;

class HorizontalContinuousLayout extends HorizontalLayout {
    public function new() {
        super();
    }

    private override function resizeChildren() {
        //super.resizeChildren
    }

    private override function repositionChildren() {
        if (component.autoWidth == true) {
            super.repositionChildren();
            return;
        }

        var ucx:Float = usableWidth;
        if (ucx <= 0) {
            return;
        }

        // first lets calculate our dimentions without changing anthing for perf
        var ucx:Float = component.componentWidth - (paddingLeft + paddingRight);
        var ucy:Float = component.componentHeight - (paddingTop + paddingBottom);
        var dimensions:Array<Array<ComponentRectangle>> = [];
        var heights:Array<Float> = [];

        var row = 0;
        var usedCX:Float = 0;
        var xpos:Float = paddingLeft;
        var ypos:Float = paddingTop;
        var rowCY:Float = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var rc:ComponentRectangle = new ComponentRectangle(child.left, child.top, child.componentWidth, child.componentHeight);
            if (child.percentWidth != null) {
                rc.width = (ucx * child.percentWidth) / 100;
            } else {
                usedCX += horizontalSpacing;
            }
            if (child.percentHeight != null) {
                rc.height = (ucy * child.percentHeight) / 100;
            }
            rc.component = child;
            usedCX += rc.width;

            if (usedCX > ucx) {
                heights.push(rowCY);
                ypos += rowCY + verticalSpacing;
                xpos = paddingLeft;
                usedCX = rc.width;
                rowCY = 0;
                row++;
            }

            if (dimensions.length <= row) {
                dimensions.push([]);
            }

            rc.left = xpos;
            rc.top = ypos;
            dimensions[row].push(rc);
            xpos += rc.width;
            if (rc.height > rowCY) {
                rowCY = rc.height;
            }
        }

        if (rowCY > 0) {
            heights.push(rowCY);
        }

        // now lets do some spacing calculations and actual apply dimentions
        var x:Int = 0;
        for (r in dimensions) {
            var height:Float = heights[x];
            var spaceX:Float = ((r.length - 1) / r.length) * horizontalSpacing;
            var n:Int = 0;
            for (c in r) {
                switch (verticalAlign(c.component)) {
                    case "center":
                        c.top += (height / 2) - (c.height / 2);
                    case "bottom":
                        c.top += height - c.height;
                    default:
                }

                if (c.component.percentWidth != null) {
                    c.left += n * (horizontalSpacing - spaceX);
                    c.width -= spaceX;
                } else {
                    c.left += n * horizontalSpacing;
                }

                c.apply();

                n++;
            }
            x++;
        }
    }

    private override function get_usableSize():Size {
        if (component.autoWidth == true) {
            return super.get_usableSize();
        }

        var ucx:Float = 0;
        if (_component.componentWidth != null) {
            ucx = _component.componentWidth;
            ucx -= paddingLeft + paddingRight;
        }

        var ucy:Float = 0;
        if (_component.componentHeight != null) {
            ucy = _component.componentHeight;
            ucy -= paddingTop + paddingBottom;
        }

        return new Size(ucx, ucy);
    }
}

class ComponentRectangle extends Rectangle {
    public var component:Component;

    public function apply() {
        component.moveComponent(left, top);
        component.resizeComponent(width, height);
    }
}