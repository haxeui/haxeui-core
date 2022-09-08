package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.geom.Size;

class DefaultLayout extends Layout {
    private var _calcFullWidths:Bool = false;
    private var _calcFullHeights:Bool = false;
    private var _roundFullWidths:Bool = false;

    private function buildWidthRoundingMap():Map<Component, Int> {
        if (_roundFullWidths == false || component.childComponents.length <= 1) {
            return null;
        }

        var map:Map<Component, Int> = null;
        var hasNonFullWidth:Bool = false;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            if (child.percentWidth == null || child.percentWidth != 100) {
                hasNonFullWidth = true;
                break;
            }
        }
        
        if (hasNonFullWidth == false) {
            var remainderWidth = usableWidth % component.childComponents.length;
            if (remainderWidth != 0) {
                map = new Map<Component, Int>();
                for (child in component.childComponents) {
                    if (child.includeInLayout == false) {
                        continue;
                    }
                    
                    var n = 0;
                    if (remainderWidth > 0) {
                        n = 1;
                        remainderWidth--;
                    }
                    map.set(child, n);
                }
            }
        }
        
        return map;
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

        // not all backends will work (nicely) with sub pixels (heaps, openfl, etc)
        // so we'll add a small optimization here that if all the items are 100%
        // then we'll round them up / down to ensure we always get single pixel
        // sizes (no fractions), this makes things look _much_ nicer without
        // making the whole UI look bad from using subpixels, which cases nasty
        // drawing artifacts in most cases
        var childRoundingWidth:Map<Component, Int> = buildWidthRoundingMap();
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
                if (childRoundingWidth != null && childRoundingWidth.exists(child)) {
                    var roundDirection = childRoundingWidth.get(child);
                    if (roundDirection == 0) {
                        cx = Math.ffloor(cx);
                    } else if (roundDirection == 1) {
                        cx = Math.fceil(cx);
                    }
                }
                
                /*
                #if debug
                if (_component.autoWidth && usableSize.width <= 0) {
                    trace("WARNING: trying to use a % width in a child (id: " + child.id + ") with autosized parent (id: " + _component.id + ")");
                }
                #end
                */
            }
            if (child.percentHeight != null) {
                var childPercentHeight = child.percentHeight;
                if (childPercentHeight == 100) {
                    childPercentHeight = fullHeightValue;
                }
                cy = (usableSize.height * childPercentHeight) / percentHeight - marginTop(child) - marginBottom(child);
                
                /*
                #if debug
                if (_component.autoHeight && usableSize.height <= 0) {
                    trace("WARNING: trying to use a % height in a child (id: " + child.id + ") with autosized parent (id: " + _component.id + ")");
                }
                #end
                */
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