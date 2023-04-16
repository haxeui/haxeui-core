package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Size;

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
        var horizontalSpacing = this.horizontalSpacing;

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

            if (usedCX - horizontalSpacing > ucx) {
                heights.push(rowCY);
                ypos += rowCY + verticalSpacing;
                xpos = paddingLeft;
                usedCX = rc.width + horizontalSpacing;
                rowCY = 0;
                row++;
            }

            if (dimensions.length <= row) {
                dimensions.push([]);
            }

            if (dimensions[row] == null) { // too small to display anything, lets pop our prev row and overwrite with adjusted one column
                ypos -= verticalSpacing;
                row--;
                dimensions[row].pop();
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

        var additionalSpacing:Array<Null<Float>> = [];
        var varyingWidths:Null<Bool> = null;
        var evenlySpace = false;
        if (component.style != null && (component.style.justifyContent == "space-evenly" || component.style.justifyContent == "space-around" || component.style.justifyContent == "space-between")) {
            evenlySpace = true;
        }
        // now lets do some spacing calculations based on if we are going to justify the content or not
        if (evenlySpace) {
            var x:Int = 0;
            var lastWidth:Null<Float> = null;
            for (r in dimensions) {
                var isLastRow = (x == dimensions.length - 1);
                var total:Float = 0;
                for (c in r) {
                    total += c.width;
                    if (lastWidth == null) {
                        lastWidth = c.width;
                        varyingWidths = false;
                    } else if (lastWidth != c.width) {
                        varyingWidths = true;
                    }
                }
                total += horizontalSpacing * (r.length - 1);
                if (isLastRow) {
                    //if ()
                    if (ucx - total <= total) {
                        additionalSpacing.push((ucx - total) / (r.length - 1));
                    } else {
                        if (additionalSpacing[x - 1] != null) {
                            additionalSpacing.push(additionalSpacing[x - 1]);
                        }
                    }
                } else {
                    additionalSpacing.push((ucx - total) / (r.length - 1));
                }
                x++;
            }
            if (x <= 1) {
                if (varyingWidths == false) {
                    var max = Math.ffloor((ucx + horizontalSpacing) / (lastWidth + horizontalSpacing));
                    var total = (max * lastWidth) + (horizontalSpacing * (max - 1));
                    additionalSpacing = [(ucx - total) / (max - 1)];
                } else {
                    additionalSpacing = [];
                }
            }
        }

        // finally lets apply the spacing and component positions
        var x:Int = 0;
        for (r in dimensions) {
            var height:Float = heights[x];
            var rowSpacing = horizontalSpacing;
            if (varyingWidths) {
                if (additionalSpacing[x] != null) {
                    rowSpacing += additionalSpacing[x];
                }
            } else {
                if (additionalSpacing[0] != null) {
                    rowSpacing += additionalSpacing[0];
                }
            }
            var spaceX:Float = ((r.length - 1) / r.length) * rowSpacing;
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
                    c.left += n * (rowSpacing - spaceX);
                    c.width -= spaceX;
                } else {
                    c.left += n * rowSpacing;
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