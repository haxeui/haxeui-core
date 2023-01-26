package haxe.ui.core;

import haxe.ui.geom.Rectangle;
import haxe.ui.validation.InvalidationFlags;

class ComponentBounds extends ComponentLayout {

    //***********************************************************************************************************
    // Size related
    //***********************************************************************************************************

    /**
     * When enabled, this component will automatically resize itself based on it's children's calculated width.
     * 
     * For example, if this component's padding is `5`, and it has one child, `150` pixels wide, 
     * and `autoWidth` is set to `true`, this component's width should be `160`
     */
    @:dox(group = "Size related properties and methods")
    public var autoWidth(get, null):Bool;
    private function get_autoWidth():Bool {
        if (_percentWidth != null || _width != null) {
            return false;
        }
        
        if (style == null) {
            return true;
        }
        
        if (style.autoWidth == null) {
            return false;
        }
        return style.autoWidth;
    }

    /**
     * When enabled, this component will automatically resize itself based on it's children's calculated height.
     * 
     * For example, if this component's padding is `5`, and it has one child, `200` pixels tall, 
     * and `autoHeight` is set to `true`, this component's height should be `210`
     */
    @:dox(group = "Size related properties and methods")
    public var autoHeight(get, null):Bool;
    private function get_autoHeight():Bool {
        if (_percentHeight != null || _height  != null || style == null) {
            return false;
        }
        if (style.autoHeight == null) {
            return false;
        }
        return style.autoHeight;
    }

    /**
     * Resizes a component to be `w` pixels wide and `h` pixels tall.
     * 
     * Useful if you want to resize the component in both the X & Y axis, 
     * and don't want to call the resizing logic twice.
     * @param w The component's new width.
     * @param h The component's new height.
     */
    @:dox(group = "Size related properties and methods")
    public function resizeComponent(w:Null<Float>, h:Null<Float>) {
        var invalidate:Bool = false;

        if (w != null && _componentWidth != w) {
            _componentWidth = w;
            invalidate = true;
        }

        if (h != null && _componentHeight != h) {
            _componentHeight = h;
            invalidate = true;
        }

        if (invalidate == true && isComponentInvalid(InvalidationFlags.LAYOUT) == false) {
            invalidateComponentLayout();
        }
    }

    /**
     * The component's true width on screen. 
     * 
     * May differ from `componentWidth` if `Toolkit.scaleX != 1` 
     */
    public var actualComponentWidth(get, null):Float;
    private function get_actualComponentWidth():Float {
        return componentWidth * Toolkit.scaleX;
    }

    /**
     * The component's true height on screen. 
     * 
     * May differ from `componentHeight` if `Toolkit.scaleY != 1` 
     */
    public var actualComponentHeight(get, null):Float;
    private function get_actualComponentHeight():Float {
        return componentHeight * Toolkit.scaleY;
    }

    @:noCompletion private var _componentWidth:Null<Float>;
    @:allow(haxe.ui.layouts.Layout)
    @:allow(haxe.ui.core.Screen)

    /**
     * This component's calculated width.
     */
    @:dox(group = "Size related properties and methods")
    @:clonable private var componentWidth(get, set):Null<Float>;
    private function get_componentWidth():Null<Float> {
        if (_componentWidth == null) {
            return 0;
        }
        return _componentWidth;
    }
    private function set_componentWidth(value:Null<Float>):Null<Float> {
        resizeComponent(value, null);
        return value;
    }

    @:noCompletion private var _componentHeight:Null<Float>;
    @:allow(haxe.ui.layouts.Layout)
    @:allow(haxe.ui.core.Screen)

    /**
     * This component's calculated height.
     */
    @:dox(group = "Size related properties and methods")
    @:clonable private var componentHeight(get, set):Null<Float>;
    private function get_componentHeight():Null<Float> {
        if (_componentHeight == null) {
            return 0;
        }
        return _componentHeight;
    }
    private function set_componentHeight(value:Null<Float>):Null<Float> {
        resizeComponent(null, value);
        return value;
    }

    @:noCompletion private var _percentWidth:Null<Float>;

    /**
     * When set, sets this component's width to be `percentWidth`% percent of it's parent's width.
     */
    @:dox(group = "Size related properties and methods")
    @clonable @bindable public var percentWidth(get, set):Null<Float>;
    private function get_percentWidth():Null<Float> {
        return _percentWidth;
    }
    private function set_percentWidth(value:Null<Float>):Null<Float> {
        if (_percentWidth == value) {
            return value;
        }

        _percentWidth = value;

        if (parentComponent != null) {
            parentComponent.invalidateComponentLayout();
        } else {
            Screen.instance.resizeRootComponents();
        }
        return value;
    }

    @:noCompletion private var _percentHeight:Null<Float>;

    /**
     * When set, sets this component's height to be `percentHeight`% percent of it's parent's height.
     */
    @:dox(group = "Size related properties and methods")
    @clonable @bindable public var percentHeight(get, set):Null<Float>;
    private function get_percentHeight():Null<Float> {
        return _percentHeight;
    }
    private function set_percentHeight(value:Null<Float>):Null<Float> {
        if (_percentHeight == value) {
            return value;
        }
        _percentHeight = value;

        if (parentComponent != null) {
            parentComponent.invalidateComponentLayout();
        } else {
            Screen.instance.resizeRootComponents();
        }
        return value;
    }

    @:noCompletion private var _cachedPercentWidth:Null<Float> = null;
    @:noCompletion private var _cachedPercentHeight:Null<Float> = null;
    private function cachePercentSizes(clearExisting:Bool = true) {
        if (_percentWidth != null) {
            _cachedPercentWidth = _percentWidth;
            if (clearExisting == true) {
                _percentWidth = null;
            }
        }
        if (_percentHeight != null) {
            _cachedPercentHeight = _percentHeight;
            if (clearExisting == true) {
                _percentHeight = null;
            }
        }
    }
    
    private function restorePercentSizes() {
        if (_cachedPercentWidth != null) {
            percentWidth = _cachedPercentWidth;
        }
        if (_cachedPercentHeight != null) {
            percentHeight = _cachedPercentHeight;
        }
    }
    
    #if ((haxeui_openfl || haxeui_nme) && !haxeui_flixel)

    #if flash @:setter(x) #else override #end
    public function set_x(value:Float): #if flash Void #else Float #end {
        #if flash
        super.x = value;
        #else
        super.set_x(value);
        #end
        left = value;
        #if !flash return value; #end
    }

    #if flash @:setter(y) #else override #end
    public function set_y(value:Float): #if flash Void #else Float #end {
        #if flash
        super.y = value;
        #else
        super.set_y(value);
        #end
        top = value;
        #if !flash return value; #end
    }

    @:noCompletion private var _width:Null<Float>;
    #if flash @:setter(width) #else override #end
    private function set_width(value:Float): #if flash Void #else Float #end {
        if (_width == value) {
            return #if !flash value #end;
        }
        if (value == haxe.ui.util.MathUtil.MIN_INT) {
            _width = null;
            componentWidth = null;
        } else {
            _width = value;
            componentWidth = value;
        }
        #if !flash return value; #end
    }

    #if flash @:getter(width) #else override #end
    private function get_width():Float {
        var f:Float = componentWidth;
        return f;
    }

    @:noCompletion private var _height:Null<Float>;
    #if flash @:setter(height) #else override #end
    private function set_height(value:Float): #if flash Void #else Float #end {
        if (_height == value) {
            return #if !flash value #end;
        }
        if (value == haxe.ui.util.MathUtil.MIN_INT) {
            _height = null;
            componentHeight = null;
        } else {
            _height = value;
            componentHeight = value;
        }
        #if !flash return value; #end
    }

    #if flash @:getter(height) #else override #end
    private function get_height():Float {
        var f:Float = componentHeight;
        return f;
    }

    #elseif (haxeui_flixel)

    @:noCompletion private var _width:Null<Float>;
    private override function set_width(value:Float):Float {
        if (value == 0) {
            return value;
        }
        if (_width == value) {
            return value;
        }
        _width = value;
        componentWidth = value;
        return value;
    }

    private override function get_width():Float {
        var f:Float = componentWidth;
        return f;
    }

    @:noCompletion private var _height:Null<Float>;
    private override function set_height(value:Float):Float {
        if (value == 0) {
            return value;
        }
        if (_height == value) {
            return value;
        }
        _height = value;
        componentHeight = value;
        return value;
    }

    private override function get_height() {
        var f:Float = componentHeight;
        return f;
    }

    #else

    /**
        This component's width. similar to `componentWidth`
    **/
    @:dox(group = "Size related properties and methods")
    @bindable public var width(get, set):Null<Float>;
    @:noCompletion private var _width:Null<Float>;
    private function set_width(value:Null<Float>):Null<Float> {
        if (_width == value) {
            return value;
        }
        _width = value;
        componentWidth = value;
        return value;
    }

    private function get_width():Null<Float> {
        var f:Float = componentWidth;
        return f;
    }

    /**
        This component's height. similar to `componentHeight`
    **/
    @:dox(group = "Size related properties and methods")
    @bindable public var height(get, set):Null<Float>;
    @:noCompletion private var _height:Null<Float>;
    private function set_height(value:Null<Float>):Null<Float> {
        if (_height == value) {
            return value;
        }
        _height = value;
        componentHeight = value;
        return value;
    }

    private function get_height():Null<Float> {
        var f:Float = componentHeight;
        return f;
    }

    #end

    @:noCompletion private var _actualWidth:Null<Float>;
    @:noCompletion private var _actualHeight:Null<Float>;

    @:noCompletion private var _hasScreen:Null<Bool> = null;

    /**
     * Whether this component, or one if it's parents, has a screen.
     */
    public var hasScreen(get, null):Bool;
    private function get_hasScreen():Bool {
        var p = this;
        while (p != null) {
            if (p._hasScreen == false) {
                return false;
            }
            p = p.parentComponent;
        }
        return true;
    }

    /**
     Whether or not a point is inside this components bounds

     *Note*: `left` and `top` must be stage (screen) co-ords
    **/
    @:dox(group = "Size related properties and methods")
    public function hitTest(left:Float, top:Float, allowZeroSized:Bool = false):Bool { // co-ords must be stage

        if (hasScreen == false) {
            return false;
        }

        left *= Toolkit.scale;
        top *= Toolkit.scale;

        var b:Bool = false;
        var sx:Float = screenLeft;
        var sy:Float = screenTop;

        var cx:Float = 0;
        if (componentWidth != null) {
            cx = actualComponentWidth;
        }
        var cy:Float = 0;
        if (componentHeight != null) {
            cy = actualComponentHeight;
        }

        if (allowZeroSized == true) {
            /*
            var c = cast(this, Component);
            if (c.layout != null) {
                var us = c.layout.usableSize;
                if (us.width <= 0 || us.height <= 0) {
                    return true;
                }
            }
            */
            if (this.width <= 0 || this.height <= 0) {
                return true;
            }
        }

        if (left >= sx && left < sx + cx && top >= sy && top < sy + cy) {
            b = true;
        }

        return b;
    }

    /**
     Autosize this component based on its children
    **/
    @:dox(group = "Size related properties and methods")
    private function autoSize():Bool {
        if (_componentReady == false || _layout == null) {
            return false;
        }
        return _layout.autoSize();
    }

    //***********************************************************************************************************
    // Position related
    //***********************************************************************************************************
    /**
     Move this components left and top co-ord in one call
    **/
    /**
     * Moves this component to the position (`left`, `top`) in one function call.
     * 
     * A more performant alternative to doing:
     * 
     *      component.x = value;
     *      component.y = anotherValue;
     * 
     * @param left The x position of the top-left corner of this component
     * @param top The y position of the top-left corner of this component
     */
    @:dox(group = "Position related properties and methods")
    public function moveComponent(left:Null<Float>, top:Null<Float>) {
        var invalidate:Bool = false;
        if (left != null && _left != left) {
            _left = left;
            invalidate = true;
        }
        if (top != null && _top != top) {
            _top = top;
            invalidate = true;
        }

        if (invalidate == true && isComponentInvalid(InvalidationFlags.POSITION) == false) {
            invalidateComponentPosition();
        }
    }

    @:noCompletion private var _left:Null<Float> = 0;
    /**
     * The position of this component on the horizontal, x-axis.
     * 
     * This position is relative to this component's parent.
     */
    @:dox(group = "Position related properties and methods")
    public var left(get, set):Null<Float>;
    private function get_left():Null<Float> {
        return _left;
    }
    private function set_left(value:Null<Float>):Null<Float> {
        moveComponent(value, null);
        return value;
    }

    @:noCompletion private var _top:Null<Float> = 0;
    /**
     * The position of this component on the vertical, y-axis.
     * 
     * This position is relative to this component's parent.
     */
    @:dox(group = "Position related properties and methods")
    public var top(get, set):Null<Float>;
    private function get_top():Null<Float> {
        return _top;
    }
    private function set_top(value:Null<Float>):Null<Float> {
        moveComponent(null, value);
        return value;
    }

    /**
     * The **on-screen** position of this component on the horizontal, x-axis. 
     */
    @:dox(group = "Position related properties and methods")
    public var screenLeft(get, null):Float;
    private function get_screenLeft():Float {
        var c = this;
        var xpos:Float = 0;
        while (c != null) {
            var l = c.left;
            if (c.parentComponent != null) {
                l *= Toolkit.scale;
            }
            xpos += l;

            if (c.componentClipRect != null) {
                xpos -= c.componentClipRect.left * Toolkit.scaleX;
            }

            c = c.parentComponent;
        }
        return xpos;
    }

    /**
     * The **on-screen** position of this component on the vertical, y-axis. 
     */
    @:dox(group = "Position related properties and methods")
    public var screenTop(get, null):Float;
    private function get_screenTop():Float {
        var c = this;
        var ypos:Float = 0;
        while (c != null) {
            var t = c.top;
            if (c.parentComponent != null) {
                t *= Toolkit.scale;
            }
            ypos += t;

            if (c.componentClipRect != null) {
                ypos -= c.componentClipRect.top * Toolkit.scaleY;
            }

            c = c.parentComponent;
        }
        return ypos;
    }

    //***********************************************************************************************************
    // Clip rect
    //***********************************************************************************************************
    @:noCompletion private var _componentClipRect:Rectangle = null;

    /**
     * When set to a non-null value, restricts the component's "rendering zone"
     * to only render inside the bounds of the given rectangle, effectively "clipping" the component.
     */
    public var componentClipRect(get, set):Rectangle;
    private function get_componentClipRect():Rectangle {
        if (style != null && style.clip != null && style.clip == true) {
            return new Rectangle(0, 0, componentWidth, componentHeight);
        }
        return _componentClipRect;
    }
    private function set_componentClipRect(value:Rectangle):Rectangle {
        _componentClipRect = value;
        invalidateComponentDisplay();
        return value;
    }

    /**
     * Whether this component has a non-null clipping rectangle or not.
     */
    public var isComponentClipped(get, null):Bool;
    private function get_isComponentClipped():Bool {
        return (componentClipRect != null);
    }
    
    /**
     * `true` if this component's area intersects with the screen, `false` otherwise.
     * 
     * clipRect is not taken into consideration - that means, if a clipRect turns a component from being
     * visible on screen to being invisible on screen, `isComponentOffScreen` should still be `false`.
     * 
     */
    public var isComponentOffscreen(get, null):Bool;
    private function get_isComponentOffscreen():Bool {
        if (this.width == 0 && this.height == 0) {
            return false;
        }
        var x:Float = screenLeft;
        var y:Float = screenTop;
        var w:Float = this.width;
        var h:Float = this.height;
        
        var thisRect = new Rectangle(x, y, w, h);
        var screenRect = new Rectangle(0, 0, Screen.instance.width, Screen.instance.height);
        return !screenRect.intersects(thisRect);
    }
}