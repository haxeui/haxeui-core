package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.geom.Size;

class DefaultLayout extends Layout {
    @:clonable private var _calcFullWidths:Bool = false;
    @:clonable private var _calcFullHeights:Bool = false;
    @:clonable private var _roundFullWidths:Bool = false;

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

            var childPercentWidth = child.percentWidth;
            if (hasFixedMinPercentWidth(child)) {
                if (childPercentWidth != null) {
                    if (childPercentWidth < minPercentWidth(child)) {
                        childPercentWidth = minPercentWidth(child);
                    }
                } else {
                    childPercentWidth = minPercentWidth(child);
                }
            }
            if (hasFixedMaxPercentWidth(child)) {
                if (childPercentWidth != null) {
                    if (childPercentWidth > maxPercentWidth(child)) {
                        childPercentWidth = maxPercentWidth(child);
                    } 
                } else {
                    childPercentWidth = maxPercentWidth(child);
                }
            }

            if (childPercentWidth != null) {
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


            var childPercentHeight = child.percentHeight;
            if (hasFixedMinPercentHeight(child)) {
                if (childPercentHeight != null) {
                    if (childPercentHeight < minPercentHeight(child)) {
                        childPercentHeight = minPercentHeight(child);
                    }
                } else {
                    childPercentHeight = minPercentHeight(child);
                }
            }
            if (hasFixedMaxPercentHeight(child)) {
                if (childPercentHeight != null) {
                    if (childPercentHeight > maxPercentHeight(child)) {
                        childPercentHeight = maxPercentHeight(child);
                    } 
                } else {
                    childPercentHeight = maxPercentHeight(child);
                }
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

            var skipMaxWidth = false;
            
            if (hasFixedMinWidth(child) ) {
                if (child.percentWidth != null) {
                    if (cx > minWidth(child)) {
                    } else {
                        cx = minWidth(child);
                        skipMaxWidth  = true;
                    }
                    //percentWidth -= child.percentWidth;
                } else {
                    if (child.width < minWidth(child)) {
                        cx = minWidth(child);
                    }
                }
            } 

            if (hasFixedMinPercentWidth(child)) {
                if (child.style != null && child.style.width != null) {
                    if (cx < child.style.width) {
                        cx = child.style.width;
                    }
                }
            }

            if (hasFixedMaxPercentWidth(child)) {
                if (child.style != null && child.style.width != null) {
                    if (cx > child.style.width) {
                        cx = child.style.width;
                    }
                }
            }
            
            
            if (!skipMaxWidth && hasFixedMaxWidth(child) ) {
                if (child.percentWidth != null) {
                    if (cx > maxWidth(child)) {
                        cx = maxWidth(child);
                    }
                }
            }

            var skipMaxHeight = false;
            
            if (hasFixedMinHeight(child) ) {
                if (child.percentHeight != null) {
                    if (cy > minHeight(child)) {
                    } else {
                        cy = minHeight(child);
                        skipMaxHeight  = true;
                    }
                } else {
                    if (child.height < minHeight(child)) {
                        cy = minHeight(child);
                    }
                }
            } 

            if (hasFixedMinPercentHeight(child)) {
                if (child.style != null && child.style.height != null) {
                    if (cy < child.style.height) {
                        cy = child.style.height;
                    }
                }
            }

            if (hasFixedMaxPercentHeight(child)) {
                if (child.style != null && child.style.height != null) {
                    if (cy > child.style.height) {
                        cy = child.style.height;
                    }
                }
            }  
            
            if (!skipMaxHeight && hasFixedMaxHeight(child) ) {
                if (child.percentHeight != null) {
                    if (cy > maxHeight(child)) {
                        cy = maxHeight(child);
                    }
                    //percentWidth -= child.percentWidth;
                }
            }

            child.resizeComponent(cx, cy);

        }
    }

    private override function repositionChildren() {
        var usableSize = this.usableSize;

        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            repositionChild(child);
        }
    }

    private function repositionChild(child:Component) {
        if (child == null) {
            return;
        }

        var xpos:Float = 0;
        var ypos:Float = 0;

        switch (horizontalAlign(child)) {
            case "center":
                xpos = ((usableSize.width - child.componentWidth) / 2) + paddingLeft + marginLeft(child) - marginRight(child);
            case "right":
                xpos = component.componentWidth - (child.componentWidth + paddingRight + marginRight(child));
            default:    //left
                xpos = paddingLeft + marginLeft(child);
        }

        switch (verticalAlign(child)) {
            case "center":
                ypos = ((usableSize.height - child.componentHeight) / 2) + paddingTop + marginTop(child) - marginBottom(child);
            case "bottom":
                ypos = component.componentHeight - (child.componentHeight + paddingBottom + marginBottom(child));
            default:    //top
                ypos = paddingTop + marginTop(child);
        }

        child.moveComponent(xpos, ypos);
    }
}