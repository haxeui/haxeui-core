package haxe.ui.styles;
import haxe.ui.util.Variant;
import haxe.ui.util.MathUtil;

class Style {
    public function new() {
    }

    @style      public var cursor:Null<String>;
    @style      public var hidden:Null<Bool>;

    @style      public var autoWidth:Null<Bool>;
    @style      public var autoHeight:Null<Bool>;
    @style      public var verticalSpacing:Variant;
    @style      public var horizontalSpacing:Variant;

    @style      public var offsetLeft:Variant;
    @style      public var offsetTop:Variant;

    @style      public var width:Variant;
    @style      public var height:Variant;
    @style      public var percentWidth:Null<Float>;
    @style      public var percentHeight:Null<Float>;

    @style      public var paddingTop:Variant;
    @style      public var paddingLeft:Variant;
    @style      public var paddingRight:Variant;
    @style      public var paddingBottom:Variant;

    @style      public var marginTop:Variant;
    @style      public var marginLeft:Variant;
    @style      public var marginRight:Variant;
    @style      public var marginBottom:Variant;

    @style      public var color:Null<Int>;

    @style      public var backgroundColor:Null<Int>;
    @style      public var backgroundColorEnd:Null<Int>;
    @style      public var backgroundGradientStyle:Null<String>;
    @style      public var backgroundOpacity:Null<Float>;

    @style      public var backgroundImage:Null<String>;
    @style      public var backgroundImageRepeat:Null<String>;

    @style      public var backgroundImageClipTop:Variant;
    @style      public var backgroundImageClipLeft:Variant;
    @style      public var backgroundImageClipBottom:Variant;
    @style      public var backgroundImageClipRight:Variant;

    @style      public var backgroundImageSliceTop:Variant;
    @style      public var backgroundImageSliceLeft:Variant;
    @style      public var backgroundImageSliceBottom:Variant;
    @style      public var backgroundImageSliceRight:Variant;

    @style      public var borderColor:Null<Int>;
    @style      public var borderTopColor:Null<Int>;
    @style      public var borderLeftColor:Null<Int>;
    @style      public var borderBottomColor:Null<Int>;
    @style      public var borderRightColor:Null<Int>;
    @style      public var borderSize:Variant;
    @style      public var borderTopSize:Variant;
    @style      public var borderLeftSize:Variant;
    @style      public var borderBottomSize:Variant;
    @style      public var borderRightSize:Variant;
    @style      public var borderRadius:Variant;
    @style      public var borderOpacity:Null<Float>;

    @style      public var filter:Array<Dynamic>;

    @style      public var icon:Null<String>;
    @style      public var iconPosition:Null<String>;

    @style      public var horizontalAlign:Null<String>;
    @style      public var verticalAlign:Null<String>;
    @style      public var textAlign:Null<String>;

    @style      public var opacity:Null<Float>;

    @style      public var clip:Null<Bool>;
    @style      public var native:Null<Bool>;

    @style      public var fontName:Null<String>;
    @style      public var fontSize:Variant;
    @style      public var fontBold:Null<Bool>;
    @style      public var fontUnderline:Null<Bool>;
    @style      public var fontItalic:Null<Bool>;

    public function apply(s:Style) {
        if (s.cursor != null) cursor = s.cursor;
        if (s.hidden != null) hidden = s.hidden;

        if (s.autoWidth != null) autoWidth = s.autoWidth;
        if (s.autoHeight != null) autoHeight = s.autoHeight;
        if (s.verticalSpacing != null) verticalSpacing = s.verticalSpacing;
        if (s.horizontalSpacing != null) horizontalSpacing = s.horizontalSpacing;

        if (s.offsetLeft != null) offsetLeft = s.offsetLeft;
        if (s.offsetTop != null) offsetTop = s.offsetTop;

        if (s.width != null) {
            width = s.width;
            autoWidth = false;
        }
        if (s.height != null) {
            height = s.height;
            autoHeight = false;
        }
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
        if (s.borderOpacity != null) borderOpacity = s.borderOpacity;

        if (s.filter != null) filter = s.filter.copy();

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
        if (s.fontItalic != null) fontItalic = s.fontItalic;

        assignNulls();
    }

    public function equalTo(s:Style):Bool {
        if (s.cursor != cursor) return false;
        if (s.hidden != hidden) return false;

        if (s.autoWidth != autoWidth) return false;
        if (s.autoHeight != autoHeight) return false;
        if (s.verticalSpacing != verticalSpacing) return false;
        if (s.horizontalSpacing != horizontalSpacing) return false;

        if (s.offsetLeft != offsetLeft) return false;
        if (s.offsetTop != offsetTop) return false;

        if (s.width != width) return false;
        if (s.height != height) return false;
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

        if (s.color != color) return false;

        if (s.backgroundColor != backgroundColor) return false;
        if (s.backgroundColorEnd != backgroundColorEnd) return false;
        if (s.backgroundGradientStyle != backgroundGradientStyle) return false;
        if (s.backgroundOpacity != backgroundOpacity) return false;

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
        if (s.borderOpacity != borderOpacity) return false;

        if (s.filter != filter) return false;

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
        if (s.fontItalic != fontItalic) return false;

        return true;
    }

    private function assignNulls():Void {
        if (color == MathUtil.MIN_INT) color = null;
        if (backgroundColor == MathUtil.MIN_INT) {
            backgroundColor = null;
            backgroundColorEnd = null;
        }
        if (backgroundColorEnd == MathUtil.MIN_INT) {
            backgroundColor = null;
            backgroundColorEnd = null;
        }
        if (borderSize == MathUtil.MIN_INT) borderSize = null;
        if (borderTopSize == MathUtil.MIN_INT) borderTopSize = null;
        if (borderLeftSize == MathUtil.MIN_INT) borderLeftSize = null;
        if (borderBottomSize == MathUtil.MIN_INT) borderBottomSize = null;
        if (borderRightSize == MathUtil.MIN_INT) borderRightSize = null;
        if (borderRadius == MathUtil.MIN_INT) borderRadius = null;
        if (borderColor == MathUtil.MIN_INT) borderColor = null;
        if (borderTopColor == MathUtil.MIN_INT) borderTopColor = null;
        if (borderLeftColor == MathUtil.MIN_INT) borderLeftColor = null;
        if (borderBottomColor == MathUtil.MIN_INT) borderBottomColor = null;
        if (borderRightColor == MathUtil.MIN_INT) borderRightColor = null;
        if (filter != null && filter[0] == "none") filter = null;
        if (icon == "none") icon = null;
    }

    public function padding(v:Variant) {
        this.paddingTop = v;
        this.paddingLeft = v;
        this.paddingRight = v;
        this.paddingBottom = v;
    }

    public function margin(v:Variant) {
        this.marginTop = v;
        this.marginLeft = v;
        this.marginRight = v;
        this.marginBottom = v;
    }

    /*
    public function toString() {
        var fields = [];
        for( f in Type.getInstanceFields(Style) ) {
            var v : Dynamic = Reflect.field(this, f);
            if( v == null || Reflect.isFunction(v) || f == "toString" || f == "apply" )
                continue;
            if( f.toLowerCase().indexOf("color") >= 0 && Std.is(v,Int) )
                v = "#" + StringTools.hex(v, 6);
            fields.push(f + ": " + v);
        }
        return "{" + fields.join(", ") + "}";
    }
    */
}