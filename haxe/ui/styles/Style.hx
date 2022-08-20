package haxe.ui.styles;

import haxe.ui.filters.Filter;
import haxe.ui.filters.FilterParser;
import haxe.ui.styles.animation.Animation.AnimationOptions;
import haxe.ui.styles.elements.Directive;
import haxe.ui.util.Variant;

enum StyleBorderType {
    None;
    Full;
    Compound;
}

@:structInit
class Style {
    @:optional public var left:Null<Float>;
    @:optional public var top:Null<Float>;

    /** Whether or not the object's width is decided by its children's width **/    @:optional public var autoWidth:Null<Bool>;
    /** A hard-coded value for the object's width **/                               @:optional public var width:Null<Float>;
    /** Sets the width of the object to `X` percent of the parent's width **/       @:optional public var percentWidth:Null<Float>;
    /** The thinest this object can get **/                                         @:optional public var minWidth:Null<Float>;
    /** The thinest this object can get, by percentage of its parent's width**/     @:optional public var minPercentWidth:Null<Float>;
    /** The widest this object can get **/                                          @:optional public var maxWidth:Null<Float>;
    /** The widest this object can get, by percentage of its parent's width**/      @:optional public var maxPercentWidth:Null<Float>;
    /** The starting, automatically assigned `width` of this object **/             @:optional public var initialWidth:Null<Float>;
    /** The starting, automatically assigned `percentWidth` of this object **/      @:optional public var initialPercentWidth:Null<Float>;

    /** Whether or not the object's height is decided by its children's height **/  @:optional public var autoHeight:Null<Bool>;
    /** A hard-coded value for the object's height **/                              @:optional public var height:Null<Float>;
    /** sets the width of the object to `X` percent of the parent's height **/      @:optional public var percentHeight:Null<Float>;  
    /** The shorteset this object can get **/                                       @:optional public var minHeight:Null<Float>;
    /** The shortest this object can get, by percentage of its parent's height **/  @:optional public var minPercentHeight:Null<Float>;
    /** The tallest this object can get **/                                         @:optional public var maxHeight:Null<Float>;
    /** The tallest this object can get, by percentage of its parent's height **/   @:optional public var maxPercentHeight:Null<Float>;
    /** The starting, automatically assigned `height` of this object **/            @:optional public var initialHeight:Null<Float>;
    /** The starting, automatically assigned `heightWidth` of this object **/       @:optional public var initialPercentHeight:Null<Float>;

    /** The gap between the container's children, on all sides **/                  @:optional public var padding(default, set):Null<Float>;
    /** The gap between the container's children, on their top **/                  @:optional public var paddingTop:Null<Float>;
    /** The gap between the container's children, on their left side **/            @:optional public var paddingLeft:Null<Float>;
    /** The gap between the container's children, on their right side **/           @:optional public var paddingRight:Null<Float>;
    /** The gap between the container's children, on their bottom **/               @:optional public var paddingBottom:Null<Float>;

    private function set_padding(value:Null<Float>):Null<Float> {
        paddingTop = value;
        paddingLeft = value;
        paddingRight = value;
        paddingBottom = value;
        return value;
    }
    
    /** The amount of offseting to apply for text from the top in pixels **/        @:optional public var marginTop:Null<Float>;
    /** The amount of offseting to apply for text from the left in pixels **/       @:optional public var marginLeft:Null<Float>;
    /** The amount of offseting to apply for text from the right in pixels **/      @:optional public var marginRight:Null<Float>;
    /** The amount of offseting to apply for text from the bottom in pixels **/     @:optional public var marginBottom:Null<Float>;

    /** The anount of spacing between children horizontally, in pixels **/          @:optional public var horizontalSpacing:Null<Float>;
    /** The anount of spacing between children vertically, in pixels **/            @:optional public var verticalSpacing:Null<Float>;

    /** A color to tint the object with **/                                         @:optional public var color:Null<Int>;

    /** The color of the object's background **/                                    @:optional public var backgroundColor:Null<Int>;
    /** A value between 0 and 1 deciding the object's background transparency **/   @:optional public var backgroundOpacity:Null<Float>;
    @:optional public var backgroundColorEnd:Null<Int>;
    @:optional public var backgroundGradientStyle:Null<String>;

    @:optional public var backgroundImage:Variant;
    @:optional public var backgroundImageRepeat:Null<String>;

    @:optional public var backgroundPositionX:Null<Float>;
    @:optional public var backgroundPositionY:Null<Float>;
    
    @:optional public var backgroundImageClipTop:Null<Float>;
    @:optional public var backgroundImageClipLeft:Null<Float>;
    @:optional public var backgroundImageClipBottom:Null<Float>;
    @:optional public var backgroundImageClipRight:Null<Float>;

    @:optional public var backgroundImageSliceTop:Null<Float>;
    @:optional public var backgroundImageSliceLeft:Null<Float>;
    @:optional public var backgroundImageSliceBottom:Null<Float>;
    @:optional public var backgroundImageSliceRight:Null<Float>;

    /** The color of the border **/                                                 @:optional public var borderColor:Null<Int>;
    /** The color of the upper side of the border **/                               @:optional public var borderTopColor:Null<Int>;
    /** The color of the left side of the border **/                                @:optional public var borderLeftColor:Null<Int>;
    /** The color of the lower side of the border **/                               @:optional public var borderBottomColor:Null<Int>;
    /** The color of the righ side of the border **/                                @:optional public var borderRightColor:Null<Int>;
    /** The size of the border, in pixels **/                                       @:optional public var borderSize:Null<Float>;
    /** The size of the upper of the border, in pixels **/                          @:optional public var borderTopSize:Null<Float>;
    /** The size of the left side of the border, in pixels **/                      @:optional public var borderLeftSize:Null<Float>;
    /** The size of the lower side of the border, in pixels **/                     @:optional public var borderBottomSize:Null<Float>;
    /** The size of the right side of the border, in pixels **/                     @:optional public var borderRightSize:Null<Float>;
    /** The amount of rounding to apply to the border **/                           @:optional public var borderRadius:Null<Float>;
    /** The amount of rounding to apply to the top-left of the border **/           @:optional public var borderRadiusTopLeft:Null<Float>;
    /** The amount of rounding to apply to the top-right of the border **/          @:optional public var borderRadiusTopRight:Null<Float>;
    /** The amount of rounding to apply to the bottom-left of the border **/        @:optional public var borderRadiusBottomLeft:Null<Float>;
    /** The amount of rounding to apply to the bottom-right of the border **/       @:optional public var borderRadiusBottomRight:Null<Float>;
    /** A value between 0 and 1 deciding the object's border transparency **/       @:optional public var borderOpacity:Null<Float>;
    /** The style to use for this border's design **/                               @:optional public var borderStyle:Null<String>;

    /** A path to an image file to be shown as an icon inside of the object **/     @:optional public var icon:Variant;
    /** The position of the icon inside the object - `left`, `right`... **/         @:optional public var iconPosition:Null<String>;

    /** Alignment to use for this object: `right`, `center`, `left` **/             @:optional public var horizontalAlign:Null<String>;
    /** Alignment to use for this object: `top`, `center`, `bottom` **/             @:optional public var verticalAlign:Null<String>;
    /** Alignment to use for this object: `right`, `center`, `left`, `justify` **/  @:optional public var textAlign:Null<String>;

    /** A value between 0 and 1, deciding the transparency of this object **/       @:optional public var opacity:Null<Float>;
    @:optional public var clip:Null<Bool>;
    @:optional public var native:Null<Bool>;

    /** A path to a font file to be used for the text inside the object **/         @:optional public var fontName:Null<String>;
    /** The visual size of the font **/                                             @:optional public var fontSize:Null<Float>;
    /** Whether or not this text should use the **bold** variation of it's font **/ @:optional public var fontBold:Null<Bool>;
    /** Whether or not to underline the text **/                                    @:optional public var fontUnderline:Null<Bool>;
    /** Whether or not this text should use the *italic* variation of it's font **/ @:optional public var fontItalic:Null<Bool>;
    @:optional public var fontStrikeThrough:Null<Bool>;

    @:optional public var cursor:Null<String>;
    @:optional public var hidden:Null<Bool>;

    @:optional public var filter:Array<Filter>;
    @:optional public var backdropFilter:Array<Filter>;

    @:optional public var resource:Variant;

    @:optional public var animationName:Null<String>;
    @:optional public var animationOptions:AnimationOptions;

    @:optional public var mode:String;
    @:optional public var pointerEvents:String;

    @:optional public var contentType:String;
    @:optional public var direction:String;

    /** The width of the children inside this container **/                         @:optional public var contentWidth:Null<Float>;
    /** The width of the children, in relation to the width of the container **/    @:optional public var contentWidthPercent:Null<Float>;
    /** The height of the children inside this container **/                        @:optional public var contentHeight:Null<Float>;
    /** The width of the children, in relation to the width of the container **/    @:optional public var contentHeightPercent:Null<Float>;
    
    /** Whether or not the text inside this object should be wrapped **/            @:optional public var wordWrap:Null<Bool>;

    @:optional public var imageRendering:String;

    @:optional public var layout:String;
    
    /** The type of the border. can be `Compound`, `Full` or `None` **/             @:optional public var borderType(get, null):StyleBorderType;
    private function get_borderType():StyleBorderType {
        var t = StyleBorderType.Compound;
        if (borderLeftSize != null && borderLeftSize > 0 && borderLeftSize == borderRightSize && borderLeftSize == borderBottomSize && borderLeftSize == borderTopSize) { // full border
            t = StyleBorderType.Full;
        } else if ((borderLeftSize == null || borderLeftSize <= 0) && (borderRightSize == null || borderRightSize <= 0)  && (borderBottomSize == null || borderRightSize <= 0) && (borderTopSize == null || borderTopSize <= 0)) {
            t = StyleBorderType.None;
        }
        return t;
    }

    /** Whether or not this object has a visible border **/                         @:optional public var hasBorder(get, null):Bool;
    private function get_hasBorder():Bool {
        return borderType != StyleBorderType.None;
    }
    
    /** The size of the border. should only be used when `borderType` is `Full` **/ @:optional public var fullBorderSize(get, null):Null<Float>;
    private function get_fullBorderSize():Null<Float> {
        if (borderType == StyleBorderType.Full) {
            return borderLeftSize;
        }
        return 0;
    }    
    
    public function mergeDirectives(map:Map<String, Directive>) {
        for (key in map.keys()) {
            var v = map.get(key);

            switch (key) {
                case "left":
                    left = ValueTools.calcDimension(v.value);
                case "top":
                    top = ValueTools.calcDimension(v.value);

                case "width":
                    autoWidth = ValueTools.constant(v.value, "auto");
                    width = ValueTools.calcDimension(v.value);
                    percentWidth = ValueTools.percent(v.value);
                case "initial-width":
                    initialWidth = ValueTools.calcDimension(v.value);
                    initialPercentWidth = ValueTools.percent(v.value);
                case "min-width":
                    minWidth = ValueTools.calcDimension(v.value);
                    minPercentWidth = ValueTools.percent(v.value);
                case "max-width":
                    maxWidth = ValueTools.calcDimension(v.value);
                    maxPercentWidth = ValueTools.percent(v.value);

                case "height":
                    autoHeight = ValueTools.constant(v.value, "auto");
                    height = ValueTools.calcDimension(v.value);
                    percentHeight = ValueTools.percent(v.value);
                case "initial-height":
                    initialHeight = ValueTools.calcDimension(v.value);
                    initialPercentHeight = ValueTools.calcDimension(v.value);
                case "min-height":
                    minHeight = ValueTools.calcDimension(v.value);
                    minPercentHeight = ValueTools.percent(v.value);
                case "max-height":
                    maxHeight = ValueTools.calcDimension(v.value);
                    maxPercentHeight = ValueTools.percent(v.value);

                case "padding-top":
                    paddingTop = ValueTools.calcDimension(v.value);
                case "padding-left":
                    paddingLeft = ValueTools.calcDimension(v.value);
                case "padding-right":
                    paddingRight = ValueTools.calcDimension(v.value);
                case "padding-bottom":
                    paddingBottom = ValueTools.calcDimension(v.value);

                case "margin-top":
                    marginTop = ValueTools.calcDimension(v.value);
                case "margin-left":
                    marginLeft = ValueTools.calcDimension(v.value);
                case "margin-right":
                    marginRight = ValueTools.calcDimension(v.value);
                case "margin-bottom":
                    marginBottom = ValueTools.calcDimension(v.value);

                case "horizontal-spacing":
                    horizontalSpacing = ValueTools.calcDimension(v.value);
                case "vertical-spacing":
                    verticalSpacing = ValueTools.calcDimension(v.value);

                case "color":
                    color = ValueTools.int(v.value);

                case "background-color":
                    switch (v.value) {
                        default:
                            backgroundColor = ValueTools.int(v.value);
                            if (map.exists("background-color-end")) {
                                backgroundColorEnd = ValueTools.int(map.get("background-color-end").value);
                            } else {
                                backgroundColorEnd = null;
                            }
                    }
                case "background-color-end":
                    backgroundColorEnd = ValueTools.int(v.value);
                case "background-gradient-style":
                    backgroundGradientStyle = ValueTools.string(v.value);
                case "background-opacity":
                    backgroundOpacity = ValueTools.float(v.value);

                case "background-image":
                    backgroundImage = ValueTools.variant(v.value);
                case "background-image-repeat":
                    backgroundImageRepeat = ValueTools.string(v.value);

                case "background-position-x":
                    backgroundPositionX = ValueTools.calcDimension(v.value);
                case "background-position-y":
                    backgroundPositionY = ValueTools.calcDimension(v.value);
                    
                case "background-image-clip-top":
                    backgroundImageClipTop = ValueTools.calcDimension(v.value);
                case "background-image-clip-left":
                    backgroundImageClipLeft = ValueTools.calcDimension(v.value);
                case "background-image-clip-right":
                    backgroundImageClipRight = ValueTools.calcDimension(v.value);
                case "background-image-clip-bottom":
                    backgroundImageClipBottom = ValueTools.calcDimension(v.value);

                case "background-image-slice-top":
                    backgroundImageSliceTop = ValueTools.calcDimension(v.value);
                case "background-image-slice-left":
                    backgroundImageSliceLeft = ValueTools.calcDimension(v.value);
                case "background-image-slice-right":
                    backgroundImageSliceRight = ValueTools.calcDimension(v.value);
                case "background-image-slice-bottom":
                    backgroundImageSliceBottom = ValueTools.calcDimension(v.value);

                case "border-color":
                    borderColor = ValueTools.int(v.value);
                case "border-top-color":
                    borderTopColor = ValueTools.int(v.value);
                case "border-left-color":
                    borderLeftColor = ValueTools.int(v.value);
                case "border-right-color":
                    borderRightColor = ValueTools.int(v.value);
                case "border-bottom-color":
                    borderBottomColor = ValueTools.int(v.value);

                case "border-top-size" | "border-top-width":
                    if (v.value == VNone) {
                        borderTopSize = 0;
                    } else {
                        borderTopSize = ValueTools.calcDimension(v.value);
                    }
                case "border-left-size" | "border-left-width":
                    if (v.value == VNone) {
                        borderLeftSize = 0;
                    } else {
                        borderLeftSize = ValueTools.calcDimension(v.value);
                    }
                case "border-right-size" | "border-right-width":
                    if (v.value == VNone) {
                        borderRightSize = 0;
                    } else {
                        borderRightSize = ValueTools.calcDimension(v.value);
                    }
                case "border-bottom-size" | "border-bottom-width":
                    if (v.value == VNone) {
                        borderBottomSize = 0;
                    } else {
                        borderBottomSize = ValueTools.calcDimension(v.value);
                    }

                case "border-radius":
                    borderRadius = ValueTools.calcDimension(v.value);
                case "border-top-left-radius":
                    borderRadiusTopLeft = ValueTools.calcDimension(v.value);
                case "border-top-right-radius":
                    borderRadiusTopRight = ValueTools.calcDimension(v.value);
                case "border-bottom-left-radius":
                    borderRadiusBottomLeft = ValueTools.calcDimension(v.value);
                case "border-bottom-right-radius":
                    borderRadiusBottomRight = ValueTools.calcDimension(v.value);

                case "border-opacity":
                    borderOpacity = ValueTools.float(v.value);
                case "border-style":
                    borderStyle = ValueTools.string(v.value);

                case "icon":
                    switch (v.value) {
                        case Value.VNone:
                            icon = null;
                        case _:
                            icon = ValueTools.variant(v.value);
                    }
                case "icon-position":
                    iconPosition = ValueTools.string(v.value);

                case "horizontal-align":
                    horizontalAlign = ValueTools.string(v.value);
                case "vertical-align":
                    verticalAlign = ValueTools.string(v.value);
                case "text-align":
                    textAlign = ValueTools.string(v.value);

                case "opacity":
                    opacity = ValueTools.float(v.value);

                case "font-name" | "font-family":
                    fontName = ValueTools.string(v.value);
                case "font-size":
                    fontSize = ValueTools.calcDimension(v.value);
                case "font-weight":
                    if (ValueTools.string(v.value) != null) {
                        fontBold = ValueTools.string(v.value).toLowerCase() == "bold";
                    }
                case "font-bold":
                    fontBold = ValueTools.bool(v.value);
                case "font-underline":
                    fontUnderline = ValueTools.bool(v.value);
                case "font-italic":
                    fontItalic = ValueTools.bool(v.value);
                case "font-style":
                    if (ValueTools.string(v.value) != null) {
                        fontItalic = ValueTools.string(v.value).toLowerCase() == "italic";
                    }
                case "text-decoration":
                    if (ValueTools.string(v.value) != null) {
                        fontUnderline = ValueTools.string(v.value).toLowerCase() == "underline";
                        fontStrikeThrough = ValueTools.string(v.value).toLowerCase() == "line-through";
                    }

                case "cursor":
                    cursor = ValueTools.string(v.value);
                case "hidden":
                    hidden = ValueTools.bool(v.value);
                case "display":
                    hidden = ValueTools.none(v.value);

                case "clip":
                    clip = ValueTools.bool(v.value);
                case "native":
                    native = ValueTools.bool(v.value);

                case "filter":
                    #if !haxeui_nofilters
                    
                    switch (v.value) {
                        case Value.VCall(f, vl):
                            var arr = ValueTools.array(vl);
                            arr.insert(0, f);
                            filter = [FilterParser.parseFilter(arr)];
                        case Value.VConstant(f):
                            filter = [FilterParser.parseFilter([f])];
                        case Value.VNone:
                            filter = null;
                        case _:
                    }
                    
                    #end

                case "backdrop-filter":
                    #if !haxeui_nofilters
                    
                    switch (v.value) {
                        case Value.VCall(f, vl):
                            var arr = ValueTools.array(vl);
                            arr.insert(0, f);
                            backdropFilter = [FilterParser.parseFilter(arr)];
                        case Value.VConstant(f):
                            backdropFilter = [FilterParser.parseFilter([f])];
                        case Value.VNone:
                            backdropFilter = null;
                        case _:
                    }
                    
                    #end

                case "resource":
                    resource = ValueTools.variant(v.value);
                case "animation-name":
                    animationName = ValueTools.string(v.value);
                case "animation-duration":
                    createAnimationOptions();
                    animationOptions.duration = ValueTools.time(v.value);
                case "animation-timing-function":
                    createAnimationOptions();
                    animationOptions.easingFunction = ValueTools.calcEasing(v.value);
                case "animation-delay":
                    createAnimationOptions();
                    animationOptions.delay = ValueTools.time(v.value);
                case "animation-iteration-count":
                    createAnimationOptions();
                    animationOptions.iterationCount = switch (v.value) {
                        case Value.VConstant(val):
                            (val == "infinite") ? -1 : 0;
                        case _:
                            ValueTools.int(v.value);
                    };
                case "animation-direction":
                    createAnimationOptions();
                    animationOptions.direction = ValueTools.string(v.value);
                case "animation-fill-mode":
                    createAnimationOptions();
                    animationOptions.fillMode = ValueTools.string(v.value);
                case "mode":
                    mode = ValueTools.string(v.value);
                case "pointer-events":
                    switch (v.value) {
                        case VNone:
                            pointerEvents = "none";
                        case _:
                            pointerEvents = ValueTools.string(v.value);
                    }
                case "content-type":
                    contentType = ValueTools.string(v.value);
                case "direction":
                    direction = ValueTools.string(v.value);
                    
                case "content-width":
                    contentWidth = ValueTools.calcDimension(v.value);
                    contentWidthPercent = ValueTools.percent(v.value);
                case "content-height":
                    contentHeight = ValueTools.calcDimension(v.value);
                    contentHeightPercent = ValueTools.percent(v.value);
                case "word-wrap":
                    wordWrap = ValueTools.bool(v.value);
                case "image-rendering":
                    switch (v.value) {
                        case VNone:
                            imageRendering = null;
                        case _:    
                            imageRendering = ValueTools.string(v.value);
                    }
                case "layout":
                    switch (v.value) {
                        case VNone:
                            layout = null;
                        case _:    
                            layout = ValueTools.string(v.value);
                    }
            }
        }
    }

    public function apply(s:Style) {
        if (s.cursor != null) cursor = s.cursor;
        if (s.hidden != null) hidden = s.hidden;

        if (s.left != null) left = s.left;
        if (s.top != null) top = s.top;

        if (s.autoWidth != null) autoWidth = s.autoWidth;
        if (s.autoHeight != null) autoHeight = s.autoHeight;
        if (s.verticalSpacing != null) verticalSpacing = s.verticalSpacing;
        if (s.horizontalSpacing != null) horizontalSpacing = s.horizontalSpacing;

        if (s.width != null) {
            width = s.width;
            autoWidth = false;
        }
        if (s.initialWidth != null) initialWidth = s.initialWidth;
        if (s.initialPercentWidth != null) initialPercentWidth = s.initialPercentWidth;
        if (s.minWidth != null) minWidth = s.minWidth;
        if (s.minPercentWidth != null) minPercentWidth = s.minPercentWidth;
        if (s.maxWidth != null) maxWidth = s.maxWidth;
        if (s.maxPercentWidth != null) maxPercentWidth = s.maxPercentWidth;

        if (s.height != null) {
            height = s.height;
            autoHeight = false;
        }
        if (s.initialHeight != null) initialHeight = s.initialHeight;
        if (s.initialPercentHeight != null) initialPercentHeight = s.initialPercentHeight;
        if (s.minHeight != null) minHeight = s.minHeight;
        if (s.minPercentHeight != null) minPercentHeight = s.minPercentHeight;
        if (s.maxHeight != null) maxHeight = s.maxHeight;
        if (s.maxPercentHeight != null) maxPercentHeight = s.maxPercentHeight;

        if (s.percentWidth != null) {
            percentWidth = s.percentWidth;
            autoWidth = false;
        }
        if (s.percentHeight != null) {
            percentHeight = s.percentHeight;
            autoHeight = false;
        }

        if (s.paddingTop != null) paddingTop = s.paddingTop;
        if (s.paddingLeft != null) paddingLeft = s.paddingLeft;
        if (s.paddingRight != null) paddingRight = s.paddingRight;
        if (s.paddingBottom != null) paddingBottom = s.paddingBottom;

        if (s.marginTop != null) marginTop = s.marginTop;
        if (s.marginLeft != null) marginLeft = s.marginLeft;
        if (s.marginRight != null) marginRight = s.marginRight;
        if (s.marginBottom != null) marginBottom = s.marginBottom;

        if (s.color != null) color = s.color;

        if (s.backgroundColor != null) {
            backgroundColor = s.backgroundColor;
            backgroundColorEnd = null;
        }
        if (s.backgroundColorEnd != null) backgroundColorEnd = s.backgroundColorEnd;
        if (s.backgroundGradientStyle != null) backgroundGradientStyle = s.backgroundGradientStyle;
        if (s.backgroundOpacity != null) backgroundOpacity = s.backgroundOpacity;

        if (s.backgroundImage != null) backgroundImage = s.backgroundImage;
        if (s.backgroundImageRepeat != null) backgroundImageRepeat = s.backgroundImageRepeat;

        if (s.backgroundImageClipTop != null) backgroundImageClipTop = s.backgroundImageClipTop;
        if (s.backgroundImageClipLeft != null) backgroundImageClipLeft = s.backgroundImageClipLeft;
        if (s.backgroundImageClipBottom != null) backgroundImageClipBottom = s.backgroundImageClipBottom;
        if (s.backgroundImageClipRight != null) backgroundImageClipRight = s.backgroundImageClipRight;

        if (s.backgroundImageSliceTop != null) backgroundImageSliceTop = s.backgroundImageSliceTop;
        if (s.backgroundImageSliceLeft != null) backgroundImageSliceLeft = s.backgroundImageSliceLeft;
        if (s.backgroundImageSliceBottom != null) backgroundImageSliceBottom = s.backgroundImageSliceBottom;
        if (s.backgroundImageSliceRight != null) backgroundImageSliceRight = s.backgroundImageSliceRight;

        if (s.borderColor != null) borderColor = s.borderColor;
        if (s.borderTopColor != null) borderTopColor = s.borderTopColor;
        if (s.borderLeftColor != null) borderLeftColor = s.borderLeftColor;
        if (s.borderBottomColor != null) borderBottomColor = s.borderBottomColor;
        if (s.borderRightColor != null) borderRightColor = s.borderRightColor;

        if (s.borderSize != null) borderSize = s.borderSize;
        if (s.borderTopSize != null) borderTopSize = s.borderTopSize;
        if (s.borderLeftSize != null) borderLeftSize = s.borderLeftSize;
        if (s.borderBottomSize != null) borderBottomSize = s.borderBottomSize;
        if (s.borderRightSize != null) borderRightSize = s.borderRightSize;

        if (s.borderRadius != null) borderRadius = s.borderRadius;
        if (s.borderRadiusTopLeft != null) borderRadiusTopLeft = s.borderRadiusTopLeft;
        if (s.borderRadiusTopRight != null) borderRadiusTopRight = s.borderRadiusTopRight;
        if (s.borderRadiusBottomLeft != null) borderRadiusBottomLeft = s.borderRadiusBottomLeft;
        if (s.borderRadiusBottomRight != null) borderRadiusBottomRight = s.borderRadiusBottomRight;
        if (s.borderOpacity != null) borderOpacity = s.borderOpacity;
        if (s.borderStyle != null) borderStyle = s.borderStyle;

        if (s.filter != null) filter = s.filter.copy();
        if (s.backdropFilter != null) backdropFilter = s.backdropFilter.copy();
        if (s.resource != null) resource = s.resource;

        if (s.icon != null) icon = s.icon;
        if (s.iconPosition != null) iconPosition = s.iconPosition;

        if (s.horizontalAlign != null) horizontalAlign = s.horizontalAlign;
        if (s.verticalAlign != null) verticalAlign = s.verticalAlign;
        if (s.textAlign != null) textAlign = s.textAlign;

        if (s.opacity != null) opacity = s.opacity;

        if (s.clip != null) clip = s.clip;
        if (s.native != null) native = s.native;

        if (s.fontName != null) fontName = s.fontName;
        if (s.fontSize != null) fontSize = s.fontSize;
        if (s.fontBold != null) fontBold = s.fontBold;
        if (s.fontUnderline != null) fontUnderline = s.fontUnderline;
        if (s.fontStrikeThrough != null) fontStrikeThrough = s.fontStrikeThrough;
        if (s.fontItalic != null) fontItalic = s.fontItalic;

        if (s.animationName != null) animationName = s.animationName;
        if (s.animationOptions != null) {
            createAnimationOptions();
            if (s.animationOptions.duration != null) animationOptions.duration = s.animationOptions.duration;
            if (s.animationOptions.delay != null) animationOptions.delay = s.animationOptions.delay;
            if (s.animationOptions.iterationCount != null) animationOptions.iterationCount = s.animationOptions.iterationCount;
            if (s.animationOptions.easingFunction != null) animationOptions.easingFunction = s.animationOptions.easingFunction;
            if (s.animationOptions.direction != null) animationOptions.direction = s.animationOptions.direction;
            if (s.animationOptions.fillMode != null) animationOptions.fillMode = s.animationOptions.fillMode;
        }

        if (s.mode != null) mode = s.mode;
        if (s.pointerEvents != null) pointerEvents = s.pointerEvents;
        if (s.contentType != null) contentType = s.contentType;
        if (s.direction != null) direction = s.direction;
        
        if (s.contentWidth != null) contentWidth = s.contentWidth;
        if (s.contentWidthPercent != null) contentWidthPercent = s.contentWidthPercent;
        if (s.contentHeight != null) contentHeight = s.contentHeight;
        if (s.contentHeightPercent != null) contentHeightPercent = s.contentHeightPercent;
        
        if (s.wordWrap != null) wordWrap = s.wordWrap;
        if (s.imageRendering != null) imageRendering = s.imageRendering;
        if (s.layout != null) layout = s.layout;
    }

    public function equalTo(s:Style):Bool {
        if (s.backgroundColor != backgroundColor) return false;
        if (s.backgroundColorEnd != backgroundColorEnd) return false;
        if (s.backgroundGradientStyle != backgroundGradientStyle) return false;
        if (s.backgroundOpacity != backgroundOpacity) return false;

        if (s.borderColor != borderColor) return false;
        if (s.borderTopColor != borderTopColor) return false;
        if (s.borderLeftColor != borderLeftColor) return false;
        if (s.borderBottomColor != borderBottomColor) return false;
        if (s.borderRightColor != borderRightColor) return false;

        if (s.borderSize != borderSize) return false;
        if (s.borderTopSize != borderTopSize) return false;
        if (s.borderLeftSize != borderLeftSize) return false;
        if (s.borderBottomSize != borderBottomSize) return false;
        if (s.borderRightSize != borderRightSize) return false;

        if (s.borderRadius != borderRadius) return false;
        if (s.borderRadiusTopLeft != borderRadiusTopLeft) return false;
        if (s.borderRadiusTopRight != borderRadiusTopRight) return false;
        if (s.borderRadiusBottomLeft != borderRadiusBottomLeft) return false;
        if (s.borderRadiusBottomRight != borderRadiusBottomRight) return false;
        if (s.borderOpacity != borderOpacity) return false;
        if (s.borderStyle != borderStyle) return false;
        
        if (s.color != color) return false;

        if (s.cursor != cursor) return false;
        if (s.hidden != hidden) return false;

        if (s.left != left) return false;
        if (s.top != top) return false;

        if (s.autoWidth != autoWidth) return false;
        if (s.autoHeight != autoHeight) return false;
        if (s.verticalSpacing != verticalSpacing) return false;
        if (s.horizontalSpacing != horizontalSpacing) return false;

        if (s.width != width) return false;
        if (s.initialWidth != initialWidth) return false;
        if (s.initialPercentWidth != initialPercentWidth) return false;
        if (s.minWidth != minWidth) return false;
        if (s.minPercentWidth != minPercentWidth) return false;
        if (s.maxWidth != maxWidth) return false;
        if (s.maxPercentWidth != maxPercentWidth) return false;

        if (s.height != height) return false;
        if (s.initialHeight != initialHeight) return false;
        if (s.initialPercentHeight != initialPercentHeight) return false;
        if (s.minHeight != minHeight) return false;
        if (s.minPercentHeight != minPercentHeight) return false;
        if (s.maxHeight != maxHeight) return false;
        if (s.maxPercentHeight != maxPercentHeight) return false;

        if (s.percentWidth != percentWidth) return false;
        if (s.percentHeight != percentHeight) return false;

        if (s.paddingTop != paddingTop) return false;
        if (s.paddingLeft != paddingLeft) return false;
        if (s.paddingRight != paddingRight) return false;
        if (s.paddingBottom != paddingBottom) return false;

        if (s.marginTop != marginTop) return false;
        if (s.marginLeft != marginLeft) return false;
        if (s.marginRight != marginRight) return false;
        if (s.marginBottom != marginBottom) return false;

        if (s.backgroundImage != backgroundImage) return false;
        if (s.backgroundImageRepeat != backgroundImageRepeat) return false;

        if (s.backgroundImageClipTop != backgroundImageClipTop) return false;
        if (s.backgroundImageClipLeft != backgroundImageClipLeft) return false;
        if (s.backgroundImageClipBottom != backgroundImageClipBottom) return false;
        if (s.backgroundImageClipRight != backgroundImageClipRight) return false;

        if (s.backgroundImageSliceTop != backgroundImageSliceTop) return false;
        if (s.backgroundImageSliceLeft != backgroundImageSliceLeft) return false;
        if (s.backgroundImageSliceBottom != backgroundImageSliceBottom) return false;
        if (s.backgroundImageSliceRight != backgroundImageSliceRight) return false;

        if (s.filter != filter) return false;
        if (s.backdropFilter != backdropFilter) return false;
        if (s.resource != resource) return false;

        if (s.icon != icon) return false;
        if (s.iconPosition != iconPosition) return false;

        if (s.horizontalAlign != horizontalAlign) return false;
        if (s.verticalAlign != verticalAlign) return false;
        if (s.textAlign != textAlign) return false;

        if (s.opacity != opacity) return false;

        if (s.clip != clip) return false;
        if (s.native != native) return false;

        if (s.fontName != fontName) return false;
        if (s.fontSize != fontSize) return false;
        if (s.fontBold != fontBold) return false;
        if (s.fontUnderline != fontUnderline) return false;
        if (s.fontStrikeThrough != fontStrikeThrough) return false;
        if (s.fontItalic != fontItalic) return false;

        if (s.resource != resource) return false;
        if (s.animationName != animationName) return false;
        if (animationOptions != null && animationOptions.compareTo(s.animationOptions) == false) return false;

        if (s.mode != mode) return false;
        if (s.pointerEvents != pointerEvents) return false;
        if (s.contentType != contentType) return false;
        if (s.direction != direction) return false;
        
        if (s.contentWidth != contentWidth) return false;
        if (s.contentWidthPercent != contentWidthPercent) return false;
        if (s.contentHeight != contentHeight) return false;
        if (s.contentHeightPercent != contentHeightPercent) return false;

        if (s.wordWrap != wordWrap) return false;
        if (s.imageRendering != imageRendering) return false;
        if (s.layout != layout) return false;
        
        return true;
    }

    private inline function createAnimationOptions() {
        if (animationOptions == null) animationOptions = {};
    }
    
    public function clone():Style {
        var c:Style = {};
        c.apply(this);
        return c;
    }
}