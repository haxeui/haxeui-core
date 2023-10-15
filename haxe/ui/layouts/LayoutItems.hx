package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.geom.Size;

class LayoutItems {
    public var component:Component = null;
    public var layout:Layout = null;
    public var children:Array<LayoutItem> = [];

    public var calcFullWidths:Bool = false;
    public var calcFullHeights:Bool = false;
    public var roundFullWidths:Bool = false;

    public function new(component:Component, layout:Layout) {
        this.component = component;
        this.layout = layout;
    }

    private var _fullWidthValue:Null<Float> = null;
    public var fullWidthValue(get, null):Float;
    private function get_fullWidthValue():Float {
        if (_fullWidthValue == null) {
            calcFullSizes();
        }
        return _fullWidthValue;
    }

    private var _fullHeightValue:Null<Float> = null;
    public var fullHeightValue(get, null):Float;
    private function get_fullHeightValue():Float {
        if (_fullHeightValue == null) {
            calcFullSizes();
        }
        return _fullHeightValue;
    }

    private function calcFullSizes() {
        var fullWidthValue:Float = 100;
        var fullHeightValue:Float = 100;
        if (calcFullWidths == true || calcFullHeights == true) {
            var n1 = 0;
            var n2 = 0;
            for (child in this.children) {
                if (calcFullWidths == true && child.percentWidth != null && child.percentWidth == 100) {
                    var viable = true;
                    if (child.minWidth != null && child.width <= child.minWidth) {
                        viable = false;
                    }
                    if (child.maxWidth != null && child.width >= child.maxWidth) {
                        viable = false;
                    }
                    if (viable) {
                        n1++;
                    }
                }
                if (calcFullHeights == true && child.percentHeight != null && child.percentHeight == 100) {
                    var viable = true;
                    if (child.minHeight != null && child.height <= child.minHeight) {
                        viable = false;
                    }
                    if (child.maxHeight != null && child.height >= child.maxHeight) {
                        viable = false;
                    }
                    if (viable) {
                        n2++;
                    }
                }
            }

            if (n1 > 0) {
                fullWidthValue = 100 / n1;
            }
            if (n2 > 0) {
                fullHeightValue = 100 / n2;
            }
        }

        _fullWidthValue = fullWidthValue;
        _fullHeightValue = fullHeightValue;
    }

    private var _usableSize:Size = null;
    public var usableSize(get, null):Size;
    private function get_usableSize():Size {
        if (_usableSize == null) {
            _usableSize = layout.usableSize;
            for (child in children) {
                if (calcFullWidths) {
                    if (child.minWidth != null && child.width <= child.minWidth) {
                        _usableSize.width -= child.minWidth;
                    }
                    if (child.maxWidth != null && child.width >= child.maxWidth) {
                        _usableSize.width -= child.maxWidth;
                    }
                }
                if (calcFullHeights) {
                    if (child.minHeight != null && child.height <= child.minHeight) {
                        _usableSize.height -= child.minHeight;
                    }
                    if (child.maxHeight != null && child.height >= child.maxHeight) {
                        _usableSize.height -= child.maxHeight;
                    }
                }
            }
        }
        return _usableSize;
    }

    public var usableWidth(get, null):Float;
    private function get_usableWidth():Float {
        return usableSize.width;
    }

    public var usableHeight(get, null):Float;
    private function get_usableHeight():Float {
        return usableSize.height;
    }

    // not all backends will work (nicely) with sub pixels (heaps, openfl, etc)
    // so we'll add a small optimization here that if all the items are 100%
    // then we'll round them up / down to ensure we always get single pixel
    // sizes (no fractions), this makes things look _much_ nicer without
    // making the whole UI look bad from using subpixels, which cases nasty
    // drawing artifacts in most cases
    public function applyRounding() {
        buildWidthRounding();
    }

    private function buildWidthRounding() {
        if (roundFullWidths == false || children.length <= 1) {
            return;
        }

        var hasNonFullWidth:Bool = false;
        for (child in children) {
            if (child.percentWidth == null || child.percentWidth != 100) {
                hasNonFullWidth = true;
                break;
            }
        }

        if (hasNonFullWidth == false) {
            var remainderWidth = usableWidth % children.length;
            if (remainderWidth != 0) {
                for (child in children) {
                    var n = 0;
                    if (remainderWidth > 0) {
                        n = 1;
                        remainderWidth--;
                    }
                    child.widthRoundingDirection = n;
                }
            }
        }
    }

    public function refresh() {
        _fullWidthValue = null;
        _fullHeightValue = null;
        _usableSize = null;
        for (child in children) {
            child.width = child.component.width;
            child.percentWidth = child.component.percentWidth;
            child.height = child.component.height;
            child.percentHeight = child.component.percentHeight;
            child.reset();
        }
    }
}