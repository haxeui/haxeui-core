package haxe.ui.styles;

import haxe.ui.constants.AnimationDirection;
import haxe.ui.constants.AnimationFillMode;
import haxe.ui.geom.Rectangle;
import haxe.ui.util.Color;

//////////////////////////////////////////////////////////////////////////////////////////////////////////

enum Option<T> {
    Some(v:Null<T>);
    none;
    inherit;
}

@:forwardStatics
abstract Optional<T>(Option<T>) from Option<T> to Option<T> {
    @:from private static inline function fromInt(v:Int):Optional<Int> {
        return Some(cast v);
    }
    
    @:from private static inline function fromFloat(v:Float):Optional<Float> {
        return Some(cast v);
    }

    @:from private static inline function fromString(v:String):Optional<String> {
        return Some(cast v);
    }

    @:from private static inline function fromArray<T>(v:Array<T>):Optional<Array<T>> {
        return Some(v);
    }
    
    @:to private inline function toT<T>():Null<T> {
        switch(this) {
            case Some(v):
                return v;
            case none | inherit:
                return null;
        }
    }
    
    /*
    @:op(A - B) static inline function subT<T>(a:Optional<T>, b:T):Optional<T> {
        return switch (a) {
            case Some(aa):
                cast((cast aa) - (cast b));
            case _: null;
        }
    }
    
    @:op(A - B) static inline function subT2<T>(a:Optional<T>, b:Optional<T>):Optional<T> {
        return switch [a, b] {
            case [Some(aa), Some(bb)]:
                cast((cast aa) - (cast bb));
            case _: null;
        }
    }

    @:op(A + B) static inline function sumT<T>(a:Optional<T>, b:T):Optional<T> {
        return switch (a) {
            case Some(aa):
                cast((cast aa) + (cast b));
            case _: null;
        }
    }
    
    @:op(A + B) static inline function sumT2<T>(a:Optional<T>, b:Optional<T>):Optional<T> {
        return switch [a, b] {
            case [Some(aa), Some(bb)]:
                cast((cast aa) + (cast bb));
            case _: null;
        }
    }

    @:op(A * B) static inline function multT<T>(a:Optional<T>, b:T):Optional<T> {
        return switch (a) {
            case Some(aa):
                cast((cast aa) * (cast b));
            case _: null;
        }
    }
    
    @:op(A * B) static inline function multT2<T>(a:Optional<T>, b:Optional<T>):Optional<T> {
        return switch [a, b] {
            case [Some(aa), Some(bb)]:
                cast((cast aa) * (cast bb));
            case _: null;
        }
    }
    */
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef StyleColorBlockType = {
    var color:Null<Color>;
    @:optional var block:Null<Float>;
}

@:forward
abstract StyleColorBlock(StyleColorBlockType) from StyleColorBlockType to StyleColorBlockType {
    @:from private static inline function fromInt(v:Int):StyleColorBlock {
        return {color: v};
    }
    @:from private static inline function fromString(v:String):StyleColorBlock {
        return {color: v};
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef StyleBoundsType = {
    @:optional var top:Optional<Float>;
    @:optional var right:Optional<Float>;
    @:optional var bottom:Optional<Float>;
    @:optional var left:Optional<Float>;
}

@:forward    
abstract StyleBounds(StyleBoundsType) from StyleBoundsType to StyleBoundsType {
    public inline function new(v:StyleBoundsType) {
        this = v;
    }

    @:from private static inline function fromOptional<T>(v:Optional<T>):StyleBounds {
        return switch(v) {
            case Some(q):
                cast q;
            case none:
                {top: none, right: none, bottom: none, left: none};
            case inherit:
                {top: inherit, right: inherit, bottom: inherit, left: inherit};
            case _:
                null;
        }
    }
    
    @:from private static inline function fromFloat(v:Float):StyleBounds {
        return {top: Some(v), right: Some(v), bottom: Some(v), left: Some(v)};
    }
    
    public var isNull(get, never):Bool;
    private inline function get_isNull():Bool {
        return (this.top == null && this.right == null && this.bottom == null && this.left == null);
    }
    
    @:to private inline function toRect():Rectangle {
        if (isNull == true) {
            return null;
        }
        var left:Float = this.left;
        var top:Float = this.top;
        var right:Float = this.right;
        var bottom:Float = this.bottom;
        return new Rectangle(left, top, right - left, bottom - top);
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////

enum StyleDimensionType {
    percent(v:Float);
    pixels(v:Float);
    auto;
}

@:forwardStatics
abstract StyleDimension(StyleDimensionType) from StyleDimensionType to StyleDimensionType {
    public inline function new(v:StyleDimension) {
        this = v;
    }
    
    @:from private static inline function fromString(v:String):StyleDimension {
        v = v.toLowerCase();
        return if (v == "auto") {
            auto;
        } else if (StringTools.endsWith(v, "%")) {
            percent(Std.parseFloat(v.substr(0, v.indexOf("%"))));
        } else if (StringTools.endsWith(v, "px")) {
            pixels(Std.parseFloat(v.substr(0, v.indexOf("px"))));
        } else {
            pixels(Std.parseFloat(v));
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef StyleBorderPartType = {
    @:optional var width:Optional<Float>;
    @:optional var color:Color;
    @:optional var style:Optional<String>;
}

@:forward
abstract StyleBorderPart(StyleBorderPartType) from StyleBorderPartType to StyleBorderPartType {
    public inline function new(v:StyleBorderPartType) {
        this = v;
    }
    
    @:from private static inline function fromOptional<T>(v:Optional<T>):StyleBorderPart {
        return switch(v) {
            case Some(q):
                cast q;
            case none:
                {width: none, color: none, style: none};
            case _:
                null;
        }
    }
    
    @:from private static inline function fromFloat(v:Float):StyleBorderPart {
        return {width: v};
    }
    
    @:op(A == B) private inline function equals(b:StyleBorderPart):Bool {
        var colorEqual = (this.color == b.color);
        var v1 = null, v2 = null;
        switch (this.width) {
            case Some(v):
                v1 = v;
            case none | null | inherit:  
        }
        switch (b.width) {
            case Some(v):
                v2 = v;
            case none | null | inherit:    
        }
        var sizeEqual = (v1 == v2);
        
        
        var v1 = null, v2 = null;
        switch (this.style) {
            case Some(v):
                v1 = v;
            case none | null | inherit:  
        }
        switch (b.style) {
            case Some(v):
                v2 = v;
            case none | null | inherit:    
        }
        var styleEqual = (v1 == v2);
        
        return (colorEqual && sizeEqual && styleEqual);
    }
    
    public var isEmpty(get, never):Bool;
    private function get_isEmpty():Bool {
        if (this.width == null && this.color == null && this.style == null) {
            return true;
        }
        return false;
    }
    
    public var isNull(get, never):Bool;
    private function get_isNull():Bool {
        if (this.width == null && this.color == null && this.style == null) {
            return true;
        }
        return false;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef StyleBorderType = {
    @:optional var top:StyleBorderPart;
    @:optional var right:StyleBorderPart;
    @:optional var bottom:StyleBorderPart;
    @:optional var left:StyleBorderPart;
    @:optional var radius:Optional<Float>;
    @:optional var opacity:Optional<Float>;
    @:optional var color:Null<Color>;
    @:optional var width:Optional<Float>;
}

@:forward
abstract StyleBorder(StyleBorderType) from StyleBorderType to StyleBorderType {
    public inline function new(v:StyleBorderType) {
        this = v;
    }

    @:from private static inline function fromOptional<T>(v:Optional<T>):StyleBorder {
        return switch(v) {
            case Some(q):
                cast q;
            case none:
                { top: none, right: none, bottom: none, left: none };
            case _:
                null;
        }
    }

    @:from private static inline function fromFloat(v:Float):StyleBorder {
        return {top: {width: v}, right: {width: v}, bottom: {width: v}, left: {width: v}};
    }
    
    public var top(get, set):StyleBorderPart;
    private function get_top():StyleBorderPart {
        if (this.top == null) {
            this.top = {color: this.color, width: this.width};
        }
        return this.top;
    }
    private function set_top(v:StyleBorderPart):StyleBorderPart {
        this.top = v;
        return v;
    }
    
    public var right(get, set):StyleBorderPart;
    private function get_right():StyleBorderPart {
        if (this.right == null) {
            this.right = {color: this.color, width: this.width};
        }
        return this.right;
    }
    private function set_right(v:StyleBorderPart):StyleBorderPart {
        this.right = v;
        return v;
    }
    
    public var bottom(get, set):StyleBorderPart;
    private function get_bottom():StyleBorderPart {
        if (this.bottom == null) {
            this.bottom = {color: this.color, width: this.width};
        }
        return this.bottom;
    }
    private function set_bottom(v:StyleBorderPart):StyleBorderPart {
        this.bottom = v;
        return v;
    }
    
    public var left(get, set):StyleBorderPart;
    private function get_left():StyleBorderPart {
        if (this.left == null) {
            this.left = {color: this.color, width: this.width};
        }
        return this.left;
    }
    private function set_left(v:StyleBorderPart):StyleBorderPart {
        this.left = v;
        return v;
    }
    
    public var width(never, set):Optional<Float>;
    private function set_width(v:Optional<Float>):Optional<Float> {
        top.width = v;
        left.width = v;
        bottom.width = v;
        right.width = v;
        return v;
    }

    public var color(never, set):Color;
    private function set_color(v:Color):Color {
        top.color = v;
        left.color = v;
        bottom.color = v;
        right.color = v;
        return v;
    }
    
    public var isEmpty(get, never):Bool;
    private function get_isEmpty():Bool {
        if (this.top == null && this.right == null && this.bottom == null && this.left == null) {
            return true;
        }
        if (this.top.isEmpty == true && this.right.isEmpty == true && this.bottom.isEmpty == true && this.left.isEmpty == true) {
            return true;
        }
        return false;
    }

    public var isNull(get, never):Bool;
    private function get_isNull():Bool {
        if (this.top == null && this.right == null && this.bottom == null && this.left == null && this.radius == null && this.opacity == null && this.color == null && this.width == null) {
            return true;
        }
        return false;
    }
    
    public var isCompound(get, never):Bool;
    private function get_isCompound():Bool {
        return !(left == top && left == bottom && left == right);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef StyleSpacingType = {
    @:optional var horizontal:Optional<Float>;
    @:optional var vertical:Optional<Float>;
}

@:forward
abstract StyleSpacing(StyleSpacingType) from StyleSpacingType to StyleSpacingType {
    public inline function new(v:StyleSpacingType) {
        this = v;
    }
    
    @:from private static inline function fromOptional<T>(v:Optional<T>):StyleSpacing {
        return switch(v) {
            case Some(q):
                cast q;
            case none:
                { horizontal: none, vertical: none };
            case _:
                null;
        }
    }
    
    @:from private static inline function fromFloat(v:Float):StyleSpacing {
        return {horizontal: v, vertical: v};
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef StyleFontType = {
    @:optional var family:Optional<String>;
    @:optional var style:Optional<String>;
    @:optional var size:Optional<Float>;
    @:optional var weight:Optional<Float>;
}

@:forward
abstract StyleFont(StyleFontType) from StyleFontType to StyleFontType {
    public inline function new(v:StyleFontType) {
        this = v;
    }
    
    @:from private static inline function fromOptional<T>(v:Optional<T>):StyleFont {
        return switch(v) {
            case Some(q):
                cast q;
            case none:
                { family: none, style: none, size: none, weight: none };
            case inherit:
                { family: inherit, style: inherit, size: inherit, weight: inherit };
            case _:
                null;
        }
    }
    
    @:from private static inline function fromFloat(v:Float):StyleFont {
        return {size: v};
    }
    
    @:from private static inline function fromString(v:String):StyleFont {
        return {family: v};
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef StyleBackgroundImageType = {
    @:optional var resource:Optional<String>;
    @:optional var repeat:Optional<String>;
    @:optional var clip:StyleBounds;
    @:optional var slice:StyleBounds;
}

@:forward
abstract StyleBackgroundImage(StyleBackgroundImageType) from StyleBackgroundImageType to StyleBackgroundImageType {
    public inline function new(v:StyleBackgroundImageType) {
        this = v;
    }
    
    @:from private static inline function fromOptional<T>(v:Optional<T>):StyleBackgroundImage {
        return switch(v) {
            case Some(q):
                cast q;
            case none:
                { resource: none, repeat: none, clip: none, slice: none };
            case inherit:
                { resource: inherit, repeat: inherit, clip: inherit, slice: inherit };
            case _:
                null;
        }
    }
    
    @:from private static inline function fromString(v:String):StyleBackgroundImage {
        return { resource: v };
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public var clip(get, set):StyleBounds;
    private function get_clip():StyleBounds {
        if (this.clip == null) {
            this.clip = {};
        }
        return this.clip;
    }
    private function set_clip(v:StyleBounds):StyleBounds {
        this.clip = v;
        return v;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public var slice(get, set):StyleBounds;
    private function get_slice():StyleBounds {
        if (this.slice == null) {
            this.slice = {};
        }
        return this.slice;
    }
    private function set_slice(v:StyleBounds):StyleBounds {
        this.slice = v;
        return v;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef StyleAnimationType = {
    @:optional public var name:Optional<String>;
    @:optional public var duration:Optional<Float>;
    @:optional public var delay:Optional<Float>;
    @:optional public var iterationCount:Optional<Int>;
    @:optional public var direction:Optional<AnimationDirection>;
    @:optional public var easingFunction:Optional<EasingFunction>;
    @:optional public var fillMode:Optional<AnimationFillMode>;
}

@:forward
abstract StyleAnimation(StyleAnimationType) from StyleAnimationType to StyleAnimationType {
    public inline function new(v:StyleAnimationType) {
        this = v;
    }
    
    @:from private static inline function fromOptional<T>(v:Optional<T>):StyleAnimation {
        return switch(v) {
            case Some(q):
                cast q;
            case none:
                { name: none, duration: none, delay: none, iterationCount: none, easingFunction: none, direction: none, fillMode: none };
            case inherit:
                { name: inherit, duration: inherit, delay: inherit, iterationCount: inherit, easingFunction: inherit, direction: inherit, fillMode: inherit };
            case _:
                null;
        }
    }
    
    @:from private static inline function fromString(v:String):StyleAnimation {
        return { name: v, duration: 0.5, delay: 0, iterationCount: 1, easingFunction: EasingFunction.EASE, direction: AnimationDirection.NORMAL, fillMode: AnimationFillMode.FORWARDS };
    }
    
    public var isNull(get, never):Bool;
    private function get_isNull():Bool {
        if (this.name == null && this.duration == null && this.delay == null && this.iterationCount == null && this.easingFunction == null && this.direction == null && this.fillMode == null) {
            return true;
        }
        return false;
    }
    
    @:op(A == B) private inline function equals(b:StyleAnimation):Bool {
        if ((b == null || b.isNull) && (this == null || isNull)) {
            return true;
        }
        return (this.name == b.name && this.duration == b.duration && this.delay == b.delay && this.iterationCount == b.iterationCount && this.easingFunction == b.easingFunction && this.direction == b.direction && this.fillMode == b.fillMode);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef Style2Type = {
    @:optional var backgroundColors:Optional<Array<StyleColorBlock>>;
    @:optional var backgroundStyle:Optional<String>;
    @:optional var backgroundOpacity:Optional<Float>;
    @:optional var backgroundImage:StyleBackgroundImage;
    
    @:optional var padding:Null<StyleBounds>;
    @:optional var margin:Null<StyleBounds>;
    
    @:optional var width:Null<StyleDimension>;
    @:optional var initialWidth:Null<StyleDimension>;
    @:optional var minWidth:Null<StyleDimension>;
    @:optional var maxWidth:Null<StyleDimension>;
    
    @:optional var height:Null<StyleDimension>;
    @:optional var initialHeight:Null<StyleDimension>;
    @:optional var minHeight:Null<StyleDimension>;
    @:optional var maxHeight:Null<StyleDimension>;
    
    @:optional var border:Null<StyleBorder>;

    @:optional var font:Null<StyleFont>;
    
    @:optional var top:Optional<Float>;
    @:optional var left:Optional<Float>;
    
    @:optional var spacing:Null<StyleSpacing>;
    @:optional var display:Optional<String>;
    @:optional var cursor:Optional<String>;
    @:optional var color:Null<Color>;
    @:optional var opacity:Optional<Float>;
    
    @:optional var horizontalAlign:Optional<String>;
    @:optional var verticalAlign:Optional<String>;
    @:optional var textAlign:Optional<String>;
    
    @:optional var animation:Null<StyleAnimation>;
}

@:forward    
abstract Style2(Style2Type) from Style2Type to Style2Type {
    public inline function new(v:Style2Type) {
        this = v;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    public var padding(get, set):StyleBounds;
    private function get_padding():StyleBounds {
        if (this.padding == null) {
            this.padding = {};
        }
        return this.padding;
    }
    private function set_padding(v:StyleBounds):StyleBounds {
        this.padding = v;
        return v;
    }
        
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public var margin(get, set):StyleBounds;
    private function get_margin():StyleBounds {
        if (this.margin == null) {
            this.margin = {};
        }
        return this.margin;
    }
    private function set_margin(v:StyleBounds):StyleBounds {
        this.margin = v;
        return v;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public var border(get, set):StyleBorder;
    private function get_border():StyleBorder {
        if (this.border == null) {
            this.border = {};
        }
        return this.border;
    }
    private function set_border(v:StyleBorder):StyleBorder {
        this.border = v;
        return v;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public var spacing(get, set):StyleSpacing;
    private function get_spacing():StyleSpacing {
        if (this.spacing == null) {
            this.spacing = {};
        }
        return this.spacing;
    }
    private function set_spacing(v:StyleSpacing):StyleSpacing {
        this.spacing = v;
        return v;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public var font(get, set):StyleFont;
    private function get_font():StyleFont {
        if (this.font == null) {
            this.font = {};
        }
        return this.font;
    }
    private function set_font(v:StyleFont):StyleFont {
        this.font = v;
        return v;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public var backgroundImage(get, set):StyleBackgroundImage;
    private function get_backgroundImage():StyleBackgroundImage {
        if (this.backgroundImage == null) {
            this.backgroundImage = {};
        }
        return this.backgroundImage;
    }
    private function set_backgroundImage(v:StyleBackgroundImage):StyleBackgroundImage {
        this.backgroundImage = v;
        return v;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public var animation(get, set):StyleAnimation;
    private function get_animation():StyleAnimation {
        if (this.animation == null) {
            this.animation = {};
        }
        return this.animation;
    }
    private function set_animation(v:StyleAnimation):StyleAnimation {
        this.animation = v;
        return v;
    }
}
