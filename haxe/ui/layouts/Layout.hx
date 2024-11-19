package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.geom.Size;

@:build(haxe.ui.macros.LayoutMacros.build())
@:autoBuild(haxe.ui.macros.LayoutMacros.build())
class Layout implements ILayout {
    public function new() {

    }

    private var _component:Component;
    public var component(get, set):Component;
    private function get_component():Component {
        return _component;
    }
    private function set_component(value:Component):Component {
        _component = value;
        if (_component != null) {
            _component.invalidateComponentLayout();
        }
        return value;
    }

    private function findComponent<T:Component>(criteria:String = null, type:Class<T> = null, recursive:Null<Bool> = null, searchType:String = "id"):Null<T> {
        if (_component == null) {
            return null;
        }
        return _component.findComponent(criteria, type, recursive, searchType);
    }

    private function findComponents<T:Component>(styleName:String = null, type:Class<T> = null, maxDepth:Int = 5):Array<T> {
        if (_component == null) {
            return null;
        }
        return _component.findComponents(styleName, type, maxDepth);
    }
    
    public function applyProperties(props:Map<String, Any>) {
        
    }

    @:access(haxe.ui.core.Component)
    public function refresh() {
        if (_component != null && _component.isReady == true) {

            resizeChildren();

            _component.handlePreReposition();
            repositionChildren();
            _component.handlePostReposition();
        }
    }

    public function autoSize():Bool {
        if (component.isReady == false) {
            return false;
        }

        var calculatedWidth:Null<Float> = null;
        var calculatedHeight:Null<Float> = null;
        if (component.autoWidth == true || component.autoHeight == true) {
            var size:Size = calcAutoSize();
            if (component.autoWidth == true) {
                calculatedWidth = size.width;
            }
            if (component.autoHeight == true) {
                calculatedHeight = size.height;
            }
            component.resizeComponent(calculatedWidth, calculatedHeight);
        }

        return (calculatedWidth != null || calculatedHeight != null);
    }

    //******************************************************************************************
    // Child helpers
    //******************************************************************************************
    private function marginTop(child:Component):Float {
        if (child == null || child.style == null || child.style.marginTop == null) {
            return 0;
        }
        return child.style.marginTop;
    }

    private function marginLeft(child:Component):Float {
        if (child == null || child.style == null || child.style.marginLeft == null) {
            return 0;
        }

        return child.style.marginLeft;
    }

    private function marginBottom(child:Component):Float {
        if (child == null || child.style == null || child.style.marginBottom == null) {
            return 0;
        }

        return child.style.marginBottom;
    }

    private function marginRight(child:Component):Float {
        if (child == null || child.style == null || child.style.marginRight == null) {
            return 0;
        }

        return child.style.marginRight;
    }

    private function childPaddingTop(child:Component):Float {
        if (child == null || child.style == null || child.style.paddingTop == null) {
            return 0;
        }
        return child.style.paddingTop;
    }

    private function childPaddingLeft(child:Component):Float {
        if (child == null || child.style == null || child.style.paddingLeft == null) {
            return 0;
        }

        return child.style.paddingLeft;
    }

    private function childPaddingBottom(child:Component):Float {
        if (child == null || child.style == null || child.style.paddingBottom == null) {
            return 0;
        }

        return child.style.paddingBottom;
    }

    private function childPaddingRight(child:Component):Float {
        if (child == null || child.style == null || child.style.paddingRight == null) {
            return 0;
        }

        return child.style.paddingRight;
    }
    
    private function hidden(c:Component = null):Bool {
        if (c == null) {
            c = component;
        }
        return c.hidden;
    }

    private function horizontalAlign(child:Component):String {
        if (child == null || child.style == null || child.style.horizontalAlign == null) {
            return "left";
        }
        return child.style.horizontalAlign;
    }

    private function verticalAlign(child:Component):String {
        if (child == null || child.style == null || child.style.verticalAlign == null) {
            return "top";
        }
        return child.style.verticalAlign;
    }

    private function fixedMinWidth(child:Component):Bool {
        var fixedMinWidth = false;
        if (child != null && child.style != null && child.style.minWidth != null) {
            fixedMinWidth = child.componentWidth <= child.style.minWidth;
        }
        return fixedMinWidth;
    }

    private function hasFixedMinWidth(child:Component):Bool {
        if (child != null && child.style != null && child.style.minWidth != null) {
            return true;
        }
        return false;
    }

    private function hasFixedMinPercentWidth(child:Component):Bool {
        if (child != null && child.style != null && child.style.minPercentWidth != null) {
            return true;
        }
        return false;
    }

    private function hasFixedMaxPercentWidth(child:Component):Bool {
        if (child != null && child.style != null && child.style.maxPercentWidth != null) {
            return true;
        }
        return false;
    }

    private function fixedMaxWidth(child:Component):Bool {
        var fixedMaxWidth = false;
        if (child != null && child.style != null && child.style.maxWidth != null) {
            fixedMaxWidth = child.componentWidth >= child.style.maxWidth;
        }
        return fixedMaxWidth;
    }

    private function hasFixedMaxWidth(child:Component):Bool {
        if (child != null && child.style != null && child.style.maxWidth != null) {
            return true;
        }
        return false;
    }

    private inline function minWidth(child:Component):Float {
        if (child != null && child.style != null && child.style.minWidth != null) {
            return child.style.minWidth;
        }
        return 0;
    }

    private inline function minPercentWidth(child:Component):Float {
        if (child != null && child.style != null && child.style.minPercentWidth != null) {
            return child.style.minPercentWidth;
        }
        return 0;
    }

    private inline function maxWidth(child:Component):Float {
        if (child != null && child.style != null && child.style.maxWidth != null) {
            return child.style.maxWidth;
        }
        return 0;
    }

    private inline function maxPercentWidth(child:Component):Float {
        if (child != null && child.style != null && child.style.maxPercentWidth != null) {
            return child.style.maxPercentWidth;
        }
        return 0;
    }

    private function fixedMinHeight(child:Component):Bool {
        var fixedMinHeight = false;
        if (child != null && child.style != null && child.style.minHeight != null) {
            fixedMinHeight = child.componentHeight <= child.style.minHeight;
        }
        return fixedMinHeight;
    }

    private function hasFixedMinHeight(child:Component):Bool {
        if (child != null && child.style != null && child.style.minHeight != null) {
            return true;
        }
        return false;
    }

    private function hasFixedMinPercentHeight(child:Component):Bool {
        if (child != null && child.style != null && child.style.minPercentHeight != null) {
            return true;
        }
        return false;
    }

    private function hasFixedMaxPercentHeight(child:Component):Bool {
        if (child != null && child.style != null && child.style.maxPercentHeight != null) {
            return true;
        }
        return false;
    }

    private function fixedMaxHeight(child:Component):Bool {
        var fixedMaxHeight = false;
        if (child != null && child.style != null && child.style.maxHeight != null) {
            fixedMaxHeight = child.componentWidth >= child.style.maxHeight;
        }
        return fixedMaxHeight;
    }

    private function hasFixedMaxHeight(child:Component):Bool {
        if (child != null && child.style != null && child.style.maxHeight != null) {
            return true;
        }
        return false;
    }

    private inline function minHeight(child:Component):Float {
        if (child != null && child.style != null && child.style.minHeight != null) {
            return child.style.minHeight;
        }
        return 0;
    }

    private inline function minPercentHeight(child:Component):Float {
        if (child != null && child.style != null && child.style.minPercentHeight != null) {
            return child.style.minPercentHeight;
        }
        return 0;
    }

    private inline function maxHeight(child:Component):Float {
        if (child != null && child.style != null && child.style.maxHeight != null) {
            return child.style.maxHeight;
        }
        return 0;
    }

    private inline function maxPercentHeight(child:Component):Float {
        if (child != null && child.style != null && child.style.maxPercentHeight != null) {
            return child.style.maxPercentHeight;
        }
        return 0;
    }

    //******************************************************************************************
    // Helper props
    //******************************************************************************************
    private var borderSize(get, null):Float;
    private function get_borderSize():Float {
        if (_component.style == null) {
            return 0;
        }

        var n = _component.style.fullBorderSize;
        if (n > 0) {
            //n--;
        }
        return n;
    }
    
    public var paddingLeft(get, null):Float;
    private function get_paddingLeft():Float {
        if (_component == null || _component.style == null || _component.style.paddingLeft == null) {
            return 0;
        }
        return _component.style.paddingLeft;
    }

    public var paddingTop(get, null):Float;
    private function get_paddingTop():Float {
        if (_component == null || _component.style == null || _component.style.paddingTop == null) {
            return 0;
        }
        return _component.style.paddingTop;
    }

    public var paddingBottom(get, null):Float;
    private function get_paddingBottom():Float {
        if (_component == null || _component.style == null || _component.style.paddingBottom == null) {
            return 0;
        }
        return _component.style.paddingBottom;
    }

    public var paddingRight(get, null):Float;
    private function get_paddingRight():Float {
        if (_component == null || _component.style == null || _component.style.paddingRight == null) {
            return 0;
        }
        return _component.style.paddingRight;
    }

    public var horizontalSpacing(get, null):Float;
    private function get_horizontalSpacing():Float {
        if (_component == null || _component.style == null || _component.style.horizontalSpacing == null) {
            return 0;
        }
        return _component.style.horizontalSpacing;
    }

    public var verticalSpacing(get, null):Float;
    private function get_verticalSpacing():Float {
        if (_component == null || _component.style == null || _component.style.verticalSpacing == null) {
            return 0;
        }
        return _component.style.verticalSpacing;
    }

    //******************************************************************************************
    // Helpers
    //******************************************************************************************
    public var innerWidth(get, null):Float;
    public var innerHeight(get, null):Float;

    // Inner width returns the size of the component minus padding
    private function get_innerWidth():Float {
        if (component == null) {
            return 0;
        }
        return component.componentWidth - (paddingLeft + paddingRight);
    }

    // Inner height returns the size of the component minus padding
    private function get_innerHeight():Float {
        if (component == null) {
            return 0;
        }
        var padding:Float = 0;
        if (component.style != null && component.style.paddingTop != null) {
            padding = component.style.paddingTop + padding;
        }
        if (component.style != null && component.style.paddingBottom != null) {
            padding = component.style.paddingBottom + padding;
        }
        var icy:Float = component.componentHeight - padding;
        return icy;
    }

    private function resizeChildren() {
    }

    private function repositionChildren() {
    }

    public var usableSize(get, null):Size;
    private function get_usableSize():Size {
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

    public var usableWidth(get, null):Float;
    private function get_usableWidth():Float {
        return usableSize.width;
    }

    public var usableHeight(get, null):Float;
    private function get_usableHeight():Float {
        return usableSize.height;
    }

    public function calcAutoWidth():Float {
        return calcAutoSize().width;
    }

    public function calcAutoHeight():Float {
        return calcAutoSize().height;
    }

    public function calcAutoSize(exclusions:Array<Component> = null):Size {
        var x1:Float = 0xFFFFFF;
        var x2:Float = 0;
        var y1:Float = 0xFFFFFF;
        var y2:Float = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false || excluded(exclusions, child) == true) {
                continue;
            }

            if (child.percentWidth == null || minWidth(child) > 0) {
                if (child.left < x1) {
                    x1 = child.left - marginLeft(child) + marginRight(child);
                }
                if (child.componentWidth != null && child.left + child.componentWidth > x2) {
                    x2 = child.left + child.componentWidth - marginLeft(child) + marginRight(child);
                }
            }

            if (child.percentHeight == null || minHeight(child) > 0) {
                if (child.top < y1) {
                    y1 = child.top - marginTop(child) + marginBottom(child);
                }
                if (child.componentHeight != null && child.top + child.componentHeight > y2) {
                    y2 = child.top + child.componentHeight - marginTop(child) + marginBottom(child);
                }
            }
        }

        if (x1 == 0xFFFFFF) {
            x1 = 0;
        }
        if (y1 == 0xFFFFFF) {
            y1 = 0;
        }

        var w:Float = (x2 - x1) + (paddingLeft + paddingRight);
        var h:Float = (y2 - y1) + (paddingTop + paddingBottom);

        if ((this is AbsoluteLayout)) {
            w += x1;
            h += y1;
        }

        if (hasFixedMinPercentWidth(component) && component.parentComponent != null && component.parentComponent.layout != null) {
            var p = component;
            var min:Float = 0;
            min = (p.parentComponent.layout.usableSize.width * p.style.minPercentWidth) / 100;
            if (min > 0 && w < min) {
                w = min;
            }
        }

        if (hasFixedMaxPercentWidth(component) && component.parentComponent != null && component.parentComponent.layout != null) {
            var p = component;
            var max:Float = 0;
            max = (p.parentComponent.layout.usableSize.width * p.style.maxPercentWidth) / 100;
            if (max > 0 && w > max) {
                w = max;
            }
        }

        if (hasFixedMinPercentHeight(component) && component.parentComponent != null && component.parentComponent.layout != null) {
            var p = component;
            var min:Float = 0;
            min = (p.parentComponent.layout.usableSize.height * p.style.minPercentHeight) / 100;
            if (min > 0 && h < min) {
                h = min;
            }
        }

        if (hasFixedMaxPercentHeight(component) && component.parentComponent != null &&  component.parentComponent.layout != null) {
            var p = component;
            var max:Float = 0;
            max = (p.parentComponent.layout.usableSize.height * p.style.maxPercentHeight) / 100;
            if (max > 0 && h > max) {
                h = max;
            }
        }

        if (hasFixedMinWidth(component)) {
            var min = minWidth(component);
            if (w < min) w = min;
        }

        if (hasFixedMinHeight(component)) {
            var min = minHeight(component);
            if (h < min) h = min;
        }

        if (hasFixedMaxWidth(component)) {
            var max = maxWidth(component);
            if (w > max) w = max;
        }

        if (hasFixedMaxHeight(component)) {
            var max = maxHeight(component);
            if (h > max) h = max;
        }

        return new Size(w, h);
    }

    private function excluded(exclusions:Array<Component>, child:Component):Bool {
        if (exclusions == null || child == null) {
            return false;
        }
        return exclusions.indexOf(child) != -1;
    }
}