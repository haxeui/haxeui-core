package haxe.ui.styles;

import haxe.ui.util.Variant;
import haxe.ui.styles.Defs;
import haxe.ui.util.MathUtil;

enum Token {
    TIdent( i : String );
    TString( s : String );
    TInt( i : Int );
    TFloat( f : Float );
    TDblDot;
    TSharp;
    TPOpen;
    TPClose;
    TExclam;
    TComma;
    TEof;
    TPercent;
    TSemicolon;
    TBrOpen;
    TBrClose;
    TDot;
    TSpaces;
    TSlash;
    TStar;
}

enum Value {
    VIdent( i : String );
    VString( s : String );
    VUnit( v : Float, unit : String );
    VFloat( v : Float );
    VInt( v : Int );
    VHex( v : String );
    VList( l : Array<Value> );
    VGroup( l : Array<Value> );
    VCall( f : String, vl : Array<Value> );
    VLabel( v : String, val : Value );
    VSlash;
}

class Parser {

    var css : String;
    var s : Style;
    var simp : Style;
    var pos : Int;

    var spacesTokens : Bool;
    var tokens : Array<Token>;

    public function new() {
    }


    // ----------------- style apply ---------------------------

    #if debug
    function notImplemented( ?pos : haxe.PosInfos ) {
        haxe.Log.trace("Not implemented", pos);
    }
    #else
    inline function notImplemented() {
    }
    #end

    function applyStyle( r : String, v : Value, s : Style ) : Bool {
        switch( r ) {
        case "padding":
            switch( v ) {
            case VGroup([a, b]):
                var a = getVariant(a), b = getVariant(b);
                if( a != null && b != null ) {
                    s.paddingTop = s.paddingBottom = a;
                    s.paddingLeft = s.paddingRight = b;
                    return true;
                }
            default:
                var i = getVariant(v);
                if( i != null ) { s.padding = i; return true; }
            }
        case "padding-top":
            var i = getVariant(v);
            if( i != null ) { s.paddingTop = i; return true; }
        case "padding-left":
            var i = getVariant(v);
            if( i != null ) { s.paddingLeft = i; return true; }
        case "padding-right":
            var i = getVariant(v);
            if( i != null ) { s.paddingRight = i; return true; }
        case "padding-bottom":
            var i = getVariant(v);
            if( i != null ) { s.paddingBottom = i; return true; }
        case "margin":
            switch( v ) {
            case VGroup([a, b]):
                var a = getVariant(a), b = getVariant(b);
                if( a != null && b != null ) {
                    s.marginTop = s.marginBottom = a;
                    s.marginLeft = s.marginRight = b;
                    return true;
                }
            default:
                var i = getVariant(v);
                if( i != null ) { s.margin(i); return true; }
            }
        case "margin-top":
            var i = getVariant(v);
            if( i != null ) { s.marginTop = i; return true; }
        case "margin-left":
            var i = getVariant(v);
            if( i != null ) { s.marginLeft = i; return true; }
        case "margin-right":
            var i = getVariant(v);
            if( i != null ) { s.marginRight = i; return true; }
        case "margin-bottom":
            var i = getVariant(v);
            if( i != null ) { s.marginBottom = i; return true; }
        case "width":
            var i = getVal(v);
            if(getIdent(v) == "auto") {
                s.width = null;
                s.percentWidth = null;
                s.autoWidth = true;
                return true;
            } else if( i != null ) {
                s.width = i;
                return true;
            } else {
                var p = getUnit(v);
                if (p != null) {
                    switch (p) {
                        case Percent(x):
                            s.percentWidth = x * 100;
                            return true;
                        case REM(_), VH(_), VW(_):
                            s.width = p;
                            return true;
                        default:
                    }
                }
            }
        case "height":
            var i = getVal(v);
            if(getIdent(v) == "auto") {
                s.height = null;
                s.percentHeight = null;
                s.autoHeight = true;
                return true;
            } else if(i != null) {
                s.height = i;
                return true;
            } else {
                var p = getUnit(v);
                if (p != null) {
                    switch (p) {
                        case Percent(x):
                            s.percentHeight = x * 100;
                            return true;
                        case REM(_), VH(_), VW(_):
                            s.height = p;
                            return true;
                        default:
                    }
                }
            }
            /*
            if( getIdent(v) == "auto" ) {
                s.width = null;
                s.autoWidth = true;
                return true;
            }
            */
        /*
        case "height":
            var i = getVal(v);
            if( i != null ) {
                s.height = i;
                return true;
            }
            if( getIdent(v) == "auto" ) {
                s.height = null;
                s.autoHeight = true;
                return true;
            }
        */
        case "background-color":
            if (getIdent(v) == "none" || getIdent(v) == "transparent") {
                s.backgroundColor = MathUtil.MIN_INT;
                s.backgroundColorEnd = MathUtil.MIN_INT;
                /*
                s.backgroundColor = null;
                s.backgroundColorEnd = null;
                */
                return true;
            }
            var f = getCol(v);
            //var f = getFill(v);
            if( f != null ) {
                s.backgroundColor = f;
                s.backgroundColorEnd = null;
                return true;
            }
        case "background-color-end":
            var f = getCol(v);
            //var f = getFill(v);
            if( f != null ) {
                s.backgroundColorEnd = f;
                return true;
            }
        case "background-gradient-style":
            var v = getIdent(v);
            if (v != null) {
                if (v == "vertical" || v == "horizontal") {
                    s.backgroundGradientStyle = v;
                    return true;
                }
                return true;
            }
        case "background":
            if( applyComposite(["background-color", "background-color-end", "background-gradient-style"], v, s) )
                return true;
            if (getIdent(v) == "none" ) {
                /*
                s.backgroundColor = null;
                s.backgroundColorEnd = null;
                */
                s.backgroundColor = MathUtil.MIN_INT;
                s.backgroundColorEnd = MathUtil.MIN_INT;
                return true;
            }


        case "background-image":
            var x = getString(v);
            if (x != null) {
                s.backgroundImage = x;
                return true;
            }


        case "background-image-repeat":
            var v = getIdent(v);
            if (v != null) {
                if (v == "repeat" || v == "stretch" || v == "none") {
                    if (v == "none") {
                        s.backgroundImageRepeat = null;
                    } else {
                        s.backgroundImageRepeat = v;
                    }
                    return true;
                }
            }


        case "background-image-clip-top":
            var i = getVariant(v);
            if( i != null ) { s.backgroundImageClipTop = i; return true; }
        case "background-image-clip-left":
            var i = getVariant(v);
            if( i != null ) { s.backgroundImageClipLeft = i; return true; }
        case "background-image-clip-bottom":
            var i = getVariant(v);
            if( i != null ) { s.backgroundImageClipBottom = i; return true; }
        case "background-image-clip-right":
            var i = getVariant(v);
            if( i != null ) { s.backgroundImageClipRight = i; return true; }
        case "background-image-clip":
            if (applyComposite(["background-image-clip-top",
                                "background-image-clip-left",
                                "background-image-clip-bottom",
                                "background-image-clip-right"], v, s) )
                return true;
            if( getIdent(v) == "none" ) {
                s.backgroundImageClipTop = null;
                s.backgroundImageClipLeft = null;
                s.backgroundImageClipBottom = null;
                s.backgroundImageClipRight = null;
                return true;
            }


        case "background-image-slice-top":
            var i = getVariant(v);
            if( i != null ) { s.backgroundImageSliceTop = i; return true; }
        case "background-image-slice-left":
            var i = getVariant(v);
            if( i != null ) { s.backgroundImageSliceLeft = i; return true; }
        case "background-image-slice-bottom":
            var i = getVariant(v);
            if( i != null ) { s.backgroundImageSliceBottom = i; return true; }
        case "background-image-slice-right":
            var i = getVariant(v);
            if( i != null ) { s.backgroundImageSliceRight = i; return true; }
        case "background-image-slice":
            if (applyComposite(["background-image-slice-top",
                                "background-image-slice-left",
                                "background-image-slice-bottom",
                                "background-image-slice-right"], v, s) )
                return true;
            if( getIdent(v) == "none" ) {
                s.backgroundImageSliceTop = null;
                s.backgroundImageSliceLeft = null;
                s.backgroundImageSliceBottom = null;
                s.backgroundImageSliceRight = null;
                return true;
            }

        /*
        case "background":
            return applyComposite(["background-color"], v, s);
        case "font-family":
            var l = getFontName(v);
            if( l != null ) {
                s.fontName = l;
                return true;
            }
        case "font-size":
            var i = getUnit(v);
            if( i != null ) {
                switch( i ) {
                case Pix(v):
                    s.fontSize = v;
                default:
                    notImplemented();
                }
                return true;
            }
        */
        case "color":
            if (getIdent(v) == "none") {
                s.color = MathUtil.MIN_INT;
                return true;
            }
            var c = getCol(v);
            if( c != null ) {
                s.color = c;
                return true;
            }
        case "border-radius":
            if (getIdent(v) == "none") {
                s.borderRadius = MathUtil.MIN_INT;
                return true;
            }
            var i = getVariant(v, true, false);
            if( i != null ) {
                s.borderRadius = i;
                return true;
            }
        case "border":
            if( applyComposite(["border-width", "border-style", "border-color"], v, s) )
                return true;
            if (getIdent(v) == "none" ) {
                /*
                s.borderSize = 0;
                s.borderColor = null;// Transparent;
                */
                s.borderTopSize = MathUtil.MIN_INT;
                s.borderLeftSize = MathUtil.MIN_INT;
                s.borderBottomSize = MathUtil.MIN_INT;
                s.borderRightSize = MathUtil.MIN_INT;
                s.borderTopColor = MathUtil.MIN_INT;// Transparent;
                s.borderLeftColor = MathUtil.MIN_INT;// Transparent;
                s.borderBottomColor = MathUtil.MIN_INT;// Transparent;
                s.borderRightColor = MathUtil.MIN_INT;// Transparent;
                return true;
            }
        case "border-top":
            if( applyComposite(["border-top-width", "border-top-color"], v, s) )
                return true;
            if (getIdent(v) == "none" ) {
                s.borderTopSize = MathUtil.MIN_INT;
                s.borderTopColor = MathUtil.MIN_INT;// Transparent;
                return true;
            }
        case "border-left":
            if( applyComposite(["border-left-width", "border-left-color"], v, s) )
                return true;
            if (getIdent(v) == "none" ) {
                s.borderLeftSize = MathUtil.MIN_INT;
                s.borderLeftColor = MathUtil.MIN_INT;// Transparent;
                return true;
            }
        case "border-bottom":
            if( applyComposite(["border-bottom-width", "border-bottom-color"], v, s) )
                return true;
            if (getIdent(v) == "none" ) {
                s.borderBottomSize = MathUtil.MIN_INT;
                s.borderBottomColor = MathUtil.MIN_INT;// Transparent;
                return true;
            }
        case "border-right":
            if( applyComposite(["border-right-width", "border-right-color"], v, s) )
                return true;
            if (getIdent(v) == "none" ) {
                s.borderRightSize = MathUtil.MIN_INT;
                s.borderRightColor = MathUtil.MIN_INT;// Transparent;
                return true;
            }
        case "border-width" | "border-size":
            var i = getVariant(v, true, false);
            if( i != null ) {
//              s.borderSize = i;
                s.borderTopSize = i;
                s.borderLeftSize = i;
                s.borderBottomSize = i;
                s.borderRightSize = i;
                return true;
            }
        case "border-top-width" | "border-top-size":
            var i = getVariant(v, true, false);
            if( i != null ) {
                s.borderTopSize = i;
                return true;
            }
        case "border-left-width" | "border-left-size":
            var i = getVariant(v, true, false);
            if( i != null ) {
                s.borderLeftSize = i;
                return true;
            }
        case "border-bottom-width" | "border-bottom-size":
            var i = getVariant(v, true, false);
            if( i != null ) {
                s.borderBottomSize = i;
                return true;
            }
        case "border-right-width" | "border-right-size":
            var i = getVariant(v, true, false);
            if( i != null ) {
                s.borderRightSize = i;
                return true;
            }
        case "border-style":
            if( getIdent(v) == "solid" )
                return true;
        case "border-color":
            var c = getCol(v);
            //var c = getFill(v);
            if( c != null ) {
                s.borderTopColor = c;
                s.borderLeftColor = c;
                s.borderBottomColor = c;
                s.borderRightColor = c;
                return true;
            }
        case "border-top-color":
            var c = getCol(v);
            //var c = getFill(v);
            if( c != null ) {
                s.borderTopColor = c;
                return true;
            }
        case "border-left-color":
            var c = getCol(v);
            //var c = getFill(v);
            if( c != null ) {
                s.borderLeftColor = c;
                return true;
            }
        case "border-bottom-color":
            var c = getCol(v);
            //var c = getFill(v);
            if( c != null ) {
                s.borderBottomColor = c;
                return true;
            }
        case "border-right-color":
            var c = getCol(v);
            //var c = getFill(v);
            if( c != null ) {
                s.borderRightColor = c;
                return true;
            }
        /*
        case "autosize-width":
            var v = getBool(v);
            if (v != null) {
                s.autoSizeWidth = v;
                return true;
            }
        case "autosize-height":
            var v = getBool(v);
            if (v != null) {
                s.autoSizeHeight = v;
                return true;
            }
        case "autosize":
            var v = getIdent(v);
            if (v != null) {
                if (v == "horizontal" || v == "width") {
                    s.autoSizeWidth = true;
                    s.autoSizeHeight = false;
                } else if (v == "vertical" || v == "height") {
                    s.autoSizeWidth = false;
                    s.autoSizeHeight = true;
                } else if (v == "both" || v == "true" || v == "yes") {
                    s.autoSizeWidth = true;
                    s.autoSizeHeight = true;
                } else {
                    return false;
                }
                return true;
            }
        */
        case "cursor":
            var v = getIdent(v);
            if (v != null) {
                s.cursor = v;
                return true;
            }
            return false;
        case "filter":
            var arr = getCall(v);
            if (arr != null) {
                s.filter = arr;
                return true;
            } else {
                var i = getIdent(v);
                if (i != null) {
                    s.filter = [i];
                    return true;
                }
            }
            return false;
        case "spacing":
            return applyComposite(["vertical-spacing", "horizontal-spacing"], v, s);
        case "horizontal-spacing":
            var i = getVariant(v);
            if( i != null ) {
                s.horizontalSpacing = i;
                return true;
            }
        case "vertical-spacing":
            var i = getVariant(v);
            if( i != null ) {
                s.verticalSpacing = i;
                return true;
            }
        case "icon-position":
            var x = getIdent(v);
            switch(x) {
            case "top" | "left" | "bottom" | "right" | "far-right" | "far-left":
                s.iconPosition = x;
                return true;
            default:
            }
        case "icon":
            var x = getString(v);
            if (getIdent(v) == "none") {
                s.icon = null;
                return true;
            }
            if (x != null) {
                s.icon = x;
                return true;
            }
        case "hidden":
            var b = getBool(v);
            if (b != null) {
                s.hidden = b;
                return true;
            }
        case "clip":
            var b = getBool(v);
            if (b != null) {
                s.clip = b;
                return true;
            }
        case "native":
            var b = getBool(v);
            if (b != null) {
                s.native = b;
                return true;
            }
        case "horizontal-align":
            var x = getIdent(v);
            switch(x) {
            case "left" | "right" | "center":
                s.horizontalAlign = x;
                return true;
            default:
            }
        case "vertical-align":
            var x = getIdent(v);
            switch(x) {
            case "top" | "bottom" | "center":
                s.verticalAlign = x;
                return true;
            default:
            }
        case "text-align":
            var x = getIdent(v);
            switch(x) {
            case "left" | "right" | "center" | "justify":
                s.textAlign = x;
                return true;
            default:
            }
        case "opacity":
            var i = getVal(v);
            if( i != null ) {
                s.opacity = i;
                return true;
            }
        case "background-opacity":
            var i = getVal(v);
            if( i != null ) {
                s.backgroundOpacity = i;
                return true;
            }

        case "offset":
            return applyComposite(["offset-left", "offset-top"], v, s);
        case "offset-left":
            var i = getVariant(v);
            if( i != null ) {
                s.offsetLeft = i;
                return true;
            }
        case "offset-top":
            var i = getVariant(v);
            if ( i != null ) {
                s.offsetTop = i;
                return true;
            }


        case "font":
            return applyComposite(["font-name", "font-size", "font-style"], v, s);
        case "font-name":
            var x = getString(v);
            if (x != null) {
                s.fontName = x;
                return true;
            }
        case "font-size":
            var i = getVariant(v, true, false);
            if ( i != null ) {
                s.fontSize = i;
                return true;
            }
        case "font-style":
            var x = getIdent(v);
            if (x == "bold") {
                s.fontBold = true;
            } else if (x == "italic") {
                s.fontItalic = true;
            }
            return true;
        /*
        case "layout":
            var i = mapIdent(v, [Horizontal, Vertical, Absolute, Dock, Inline]);
            if( i != null ) {
                s.layout = i;
                return true;
            }
        case "spacing":
            return applyComposite(["vertical-spacing", "horizontal-spacing"], v, s);
        case "horizontal-spacing":
            var i = getVal(v);
            if( i != null ) {
                s.horizontalSpacing = i;
                return true;
            }
        case "vertical-spacing":
            var i = getVal(v);
            if( i != null ) {
                s.verticalSpacing = i;
                return true;
            }
        case "increment":
            var i = getVal(v);
            if( i != null ) {
                s.increment = i;
                return true;
            }
        case "max-increment":
            var i = getVal(v);
            if( i != null ) {
                s.maxIncrement = i;
                return true;
            }
        case "tick-color":
            var i = getFill(v);
            if( i != null ) {
                s.tickColor = i;
                return true;
            }
        case "tick-spacing":
            var i = getVal(v);
            if( i != null ) {
                s.tickSpacing = i;
                return true;
            }
        case "dock":
            var i = mapIdent(v, [Top, Bottom, Left, Right, Full]);
            if( i != null ) {
                s.dock = i;
                return true;
            }
        case "cursor-color":
            var i = getColAlpha(v);
            if( i != null ) {
                s.cursorColor = i;
                return true;
            }
        case "selection-color":
            var i = getColAlpha(v);
            if( i != null ) {
                s.selectionColor = i;
                return true;
            }
        case "overflow":
            switch( getIdent(v) ) {
            case "hidden":
                s.overflowHidden = true;
                return true;
            case "visible":
                s.overflowHidden = false;
                return true;
            }
        case "icon":
            var i = getImage(v);
            if( i != null ) {
                s.icon = i;
                return true;
            }
        case "icon-color":
            var c = getColAlpha(v);
            if( c != null ) {
                s.iconColor = c;
                return true;
            }
        case "icon-left":
            var i = getVal(v);
            if( i != null ) {
                s.iconLeft = i;
                return true;
            }
        case "icon-top":
            var i = getVal(v);
            if( i != null ) {
                s.iconTop = i;
                return true;
            }
        case "position":
            switch( getIdent(v) ) {
            case "absolute":
                s.positionAbsolute = true;
                return true;
            case "relative":
                s.positionAbsolute = false;
                return true;
            default:
            }
        case "text-align":
            switch( getIdent(v) ) {
            case "left":
                s.textAlign = Left;
                return true;
            case "right":
                s.textAlign = Right;
                return true;
            case "center":
                s.textAlign = Center;
                return true;
            default:
            }
        case "display":
            switch( getIdent(v) ) {
            case "none":
                s.display = false;
                return true;
            case "block", "inline-block":
                s.display = true;
                return true;
            default:
            }
            */
        default:
            //throw "Not implemented '" + r + "' = " + valueStr(v);
            #if debug
            trace("WARNING: Not implemented '" + r + "' = " + valueStr(v));
            #end
        }
        return false;
    }

    function applyComposite( names : Array<String>, v : Value, s : Style ) {
        var vl = switch( v ) {
        case VGroup(l): l;
        default: [v];
        };

        if (names.length > vl.length) {
            var last = vl[vl.length - 1];
            for (i in 0...(names.length - vl.length)) {
                vl.push(last);
            }
        }

        while( vl.length > 0 ) {
            var found = false;
            for( n in names ) {
                var count = 1;
                if( count > vl.length ) count = vl.length;
                while( count > 0 ) {
                    var v = (count == 1) ? vl[0] : VGroup(vl.slice(0, count));
                    if( applyStyle(n, v, s) ) {
                        found = true;
                        names.remove(n);
                        for( i in 0...count )
                            vl.shift();
                        break;
                    }
                    count--;
                }
                if( found ) break;
            }
            if( !found )
                return false;
        }
        return true;
    }

    function getGroup<T>( v : Value, f : Value -> Null<T> ) : Null<Array<T>> {
        switch(v) {
        case VGroup(l):
            var a = new Array<T>();
            for( v in l ) {
                var v = f(v);
                if( v == null ) return null;
                a.push(v);
            }
            return a;
        default:
            var v = f(v);
            return (v == null) ? null : [v];
        }
    }

    function getList<T>( v : Value, f : Value -> Null<T> ) : Null<Array<T>> {
        switch(v) {
        case VList(l):
            var a = new Array<T>();
            for( v in l ) {
                var v = f(v);
                if( v == null ) return null;
                a.push(v);
            }
            return a;
        default:
            var v = f(v);
            return (v == null) ? null : [v];
        }
    }

    function getInt( v : Value ) : Null<Int> {
        return switch( v ) {
        case VUnit(f, u):
            switch( u ) {
            case "px": Std.int(f);
            case "pt": Std.int(f * 4 / 3);
//            case "rem": Std.int(f * pixelsPerRem);
//            case "vh": Std.int(f / 100 * viewportHeight);
//            case "vw": Std.int(f / 100 * viewportWidth);
            default: null;
            }
        case VInt(v):
            Std.int(v);
        default:
            null;
        };
    }

    function getBool( v : Value ) : Null<Bool> {
        return switch( v ) {
        case VInt(v):
            Std.int(v) == 1;
        case VIdent(v):
            v == "true" || v == "yes";
        default:
            null;
        };
    }

    function getString( v : Value ) : Null<String> {
        return switch( v ) {
        case VString(v):
            v;
        default:
            null;
        };
    }

    function getCall( v : Value ) : Array<Dynamic> {
        return switch( v ) {
        case VCall(v, params):
            var arr:Array<Dynamic> = new Array<Dynamic>();
            arr.push(v);
            for (p in params) {
                var c = getCol(p);
                if (c != null) {
                    arr.push(c);
                } else {
                    switch (p) {
                        case VInt(x):
                            arr.push(x);
                        case VFloat(x):
                            arr.push(x);
                        case VIdent(x):
                            if (x == "true") {
                                arr.push(true);
                            } else if (x == "false") {
                                arr.push(false);
                            } else {
                                arr.push(x);
                            }
                        default:
                    }
                }
            }
            arr;
        default:
            null;
        };
    }

    function getVal( v : Value ) : Null<Float> {
        return switch( v ) {
        case VUnit(f, u):
            switch( u ) {
            case "px": f;
            case "pt": f * 4 / 3;
            default: null;
            }
        case VInt(v):
            v;
        case VFloat(v):
            v;
        default:
            null;
        };
    }

    function getUnit( v : Value ) : Null<Unit> {
        return switch( v ) {
        case VUnit(f, u):
            switch( u ) {
            case "px": Pix(f);
            case "pt": Pix(f * 4 / 3);
            case "%": Percent(f / 100);
            case "rem": REM(f);
            case "vh": VH(f);
            case "vw": VW(f);
            default: null;
            }
        case VInt(v):
            Pix(v);
        case VFloat(v):
            Pix(v);
        default:
            null;
        };
    }

    function getVariant( v : Value, allowRem:Bool=true, allowViewport:Bool=true) : Null<Variant> {
        return switch( v ) {
            case VUnit(f, u):
                switch( u ) {
                    case "px": f;
                    case "pt": f * 4 / 3;
                    case "%": Percent(f / 100);
                    case "rem": allowRem ? REM(f) : null;
                    case "vh": allowViewport ? VH(f) : null;
                    case "vw": allowViewport ? VW(f) : null;
                    default: null;
                }
            case VInt(v):
                v;
            case VFloat(v):
                v;
            default:
                null;
        };
    }

    function mapIdent<T:EnumValue>( v : Value, vals : Array<T> ) : T {
        var i = getIdent(v);
        if( i == null ) return null;
        for( v in vals )
            if( v.getName().toLowerCase() == i )
                return v;
        return null;
    }

    function getIdent( v : Value ) : Null<String> {
        return switch( v ) {
        case VIdent(v): v;
        default: null;
        };
    }

    function getColAlpha( v : Value ) {
        var c = getCol(v);
        if( c != null && c >>> 24 == 0 )
            c |= 0xFF000000;
        return c;
    }

    function getFill( v : Value ) {
        var c = getColAlpha(v);
        if( c != null )
            return Color(c);
        switch( v ) {
        case VCall("gradient", [a, b, c, d]):
            var ca = getColAlpha(a);
            var cb = getColAlpha(b);
            var cc = getColAlpha(c);
            var cd = getColAlpha(d);
            if( ca != null && cb != null && cc != null && cd != null )
                return Gradient(ca, cb, cc, cd);
        case VIdent("transparent"):
            return Transparent;
        default:
        }
        return null;
    }

    function getCol( v : Value ) : Null<Int> {
        return switch( v ) {
        case VHex(v):
            (v.length == 6) ? Std.parseInt("0x" + v) : ((v.length == 3) ? Std.parseInt("0x"+v.charAt(0)+v.charAt(0)+v.charAt(1)+v.charAt(1)+v.charAt(2)+v.charAt(2)) : null);
        case VIdent(i):
            switch( i ) {
            // (DK) everything from https://www.w3schools.com/colors/colors_names.asp
            case "aliceblue": 0xf0f8ff;
            case "antiquewhite": 0xfaebd7;
            case "aqua": 0x00ffff;
            case "aquamarine": 0x7fffd4;
            case "azure": 0xf0ffff;
            case "beige": 0xf5f5dc;
            case "bisque": 0xffe4c4;
            case "black": 0x000000;
            case "blanchedalmond": 0xffebcd;
            case "blue": 0x0000ff;
            case "blueviolet": 0x8a2be2;
            case "brown": 0xa52a2a;
            case "burlywood": 0xdeb887;
            case "cadetblue": 0x5f9ea0;
            case "chartreuse": 0x7fff00;
            case "chocolate": 0xd2691e;
            case "coral": 0xff7f50;
            case "cornflowerblue": 0x6495ed;
            case "cornsilk": 0xfff8dc;
            case "crimson": 0xdc143c;
            case "cyan": 0x00ffff;
            case "darkblue": 0x00008b;
            case "darkcyan": 0x008b8b;
            case "darkgoldenrod": 0xb8860b;
            case "darkgray": 0xa9a9a9;
            case "darkgrey": 0xa9a9a9;
            case "darkgreen": 0x006400;
            case "darkkhaki": 0xbdb76b;
            case "darkmagenta": 0x8b008b;
            case "darkolivegreen": 0x556b2f;
            case "darkorange": 0xff8c00;
            case "darkorchid": 0x9932cc;
            case "darkred": 0x8b0000;
            case "darksalmon": 0xe9967a;
            case "darkseagreen": 0x8fbc8f;
            case "darkslateblue": 0x483d8b;
            case "darkslategray": 0x2f4f4f;
            case "darkslategrey": 0x2f4f4f;
            case "darkturquoise": 0x00ced1;
            case "darkviolet": 0x9400d3;
            case "deeppink": 0xff1493;
            case "deepskyblue": 0x00bfff;
            case "dimgray": 0x696969;
            case "dimgrey": 0x696969;
            case "dodgerblue": 0x1e90ff;
            case "firebrick": 0xb22222;
            case "floralwhite": 0xfffaf0;
            case "forestgreen": 0x228b22;
            case "fuchsia": 0xff00ff;
            case "gainsboro": 0xdcdcdc;
            case "ghostwhite": 0xf8f8ff;
            case "gold": 0xffd700;
            case "goldenrod": 0xdaa520;
            case "gray": 0x808080;
            case "grey": 0x808080;
            case "green": 0x008000;
            case "greenyellow": 0xadff2f;
            case "honeydew": 0xf0fff0;
            case "hotpink": 0xff69b4;
            case "indianred": 0xcd5c5c;
            case "indigo": 0x4b0082;
            case "ivory": 0xfffff0;
            case "khaki": 0xf0e68c;
            case "lavender": 0xe6e6fa;
            case "lavenderblush": 0xfff0f5;
            case "lawngreen": 0x7cfc00;
            case "lemonchiffon": 0xfffacd;
            case "lightblue": 0xadd8e6;
            case "lightcoral": 0xf08080;
            case "lightcyan": 0xe0ffff;
            case "lightgoldenrodyellow": 0xfafad2;
            case "lightgray": 0xd3d3d3;
            case "lightgrey": 0xd3d3d3;
            case "lightgreen": 0x90ee90;
            case "lightpink": 0xffb6c1;
            case "lightsalmon": 0xffa07a;
            case "lightseagreen": 0x20b2aa;
            case "lightskyblue": 0x87cefa;
            case "lightslategray": 0x778899;
            case "lightslategrey": 0x778899;
            case "lightsteelblue": 0xb0c4de;
            case "lightyellow": 0xffffe0;
            case "lime": 0x00ff00;
            case "limegreen": 0x32cd32;
            case "linen": 0xfaf0e6;
            case "magenta": 0xff00ff;
            case "maroon": 0x800000;
            case "mediumaquamarine": 0x66cdaa;
            case "mediumblue": 0x0000cd;
            case "mediumorchid": 0xba55d3;
            case "mediumpurple": 0x9370db;
            case "mediumseagreen": 0x3cb371;
            case "mediumslateblue": 0x7b68ee;
            case "mediumspringgreen": 0x00fa9a;
            case "mediumturquoise": 0x48d1cc;
            case "mediumvioletred": 0xc71585;
            case "midnightblue": 0x191970;
            case "mintcream": 0xf5fffa;
            case "mistyrose": 0xffe4e1;
            case "moccasin": 0xffe4b5;
            case "navajowhite": 0xffdead;
            case "navy": 0x000080;
            case "oldlace": 0xfdf5e6;
            case "olive": 0x808000;
            case "olivedrab": 0x6b8e23;
            case "orange": 0xffa500;
            case "orangered": 0xff4500;
            case "orchid": 0xda70d6;
            case "palegoldenrod": 0xeee8aa;
            case "palegreen": 0x98fb98;
            case "paleturquoise": 0xafeeee;
            case "palevioletred": 0xdb7093;
            case "papayawhip": 0xffefd5;
            case "peachpuff": 0xffdab9;
            case "peru": 0xcd853f;
            case "pink": 0xffc0cb;
            case "plum": 0xdda0dd;
            case "powderblue": 0xb0e0e6;
            case "purple": 0x800080;
            case "rebeccapurple": 0x663399;
            case "red": 0xff0000;
            case "rosybrown": 0xbc8f8f;
            case "royalblue": 0x4169e1;
            case "saddlebrown": 0x8b4513;
            case "salmon": 0xfa8072;
            case "sandybrown": 0xf4a460;
            case "seagreen": 0x2e8b57;
            case "seashell": 0xfff5ee;
            case "sienna": 0xa0522d;
            case "silver": 0xc0c0c0;
            case "skyblue": 0x87ceeb;
            case "slateblue": 0x6a5acd;
            case "slategray": 0x708090;
            case "slategrey": 0x708090;
            case "snow": 0xfffafa;
            case "springgreen": 0x00ff7f;
            case "steelblue": 0x4682b4;
            case "tan": 0xd2b48c;
            case "teal": 0x008080;
            case "thistle": 0xd8bfd8;
            case "tomato": 0xff6347;
            case "turquoise": 0x40e0d0;
            case "violet": 0xee82ee;
            case "wheat": 0xf5deb3;
            case "white": 0xffffff;
            case "whitesmoke": 0xf5f5f5;
            case "yellow": 0xffff00;
            case "yellowgreen": 0x9acd32;
            default: null;
            }
        case VCall("rgba", [r, g, b, a]):
            var r = getVal(r), g = getVal(g), b = getVal(b), a = getVal(a);
            inline function conv(k:Float) {
                var v = Std.int(k * 255);
                if( v < 0 ) v = 0;
                if( v > 255 ) v = 255;
                return v;
            }
            inline function check(k:Float) {
                var v = Std.int(k);
                if( v < 0 ) v = 0;
                if( v > 255 ) v = 255;
                return v;
            }
            if( r != null && g != null && b != null && a != null ) {
                var a = conv(a); if( a == 0 ) a = 1; // prevent setting alpha to FF afterwards
                (a << 24) | (check(r) << 16) | (check(g) << 8) | check(b);
            }
            else
                null;
        default:
            null;
        };
    }

    function getFontName( v : Value ) {
        return switch( v ) {
        case VString(s): s;
        case VGroup(_):
            var g = getGroup(v, getIdent);
            if( g == null ) null else g.join(" ");
        case VIdent(i): i;
        default: null;
        };
    }

    /*
    function getImage( v : Value ) {
        switch( v ) {
        case VCall("url", [VString(url)]):
            if( !StringTools.startsWith(url, "data:image/png;base64,") )
                return null;
            url = url.substr(22);
            if( StringTools.endsWith(url, "=") ) url = url.substr(0, -1);
            var bytes = haxe.crypto.Base64.decode(url);
            return hxd.res.Any.fromBytes("icon",bytes).toImage().getPixels();
        default:
            return null;
        }
    }
    */

    // ---------------------- generic parsing --------------------

    function unexpected( t : Token ) : Dynamic {
        //throw "Unexpected " + Std.string(t);
        return null;
    }

    function expect( t : Token ) {
        var tk = readToken();
        if( tk != t ) unexpected(tk);
    }

    inline function push( t : Token ) {
        tokens.push(t);
    }

    function isToken(t) {
        var tk = readToken();
        if( tk == t ) return true;
        push(tk);
        return false;
    }

    public function parse( css : String, s : Style ) {
        this.css = css;
        this.s = s;
        pos = 0;
        tokens = [];
        parseStyle(TEof);
    }

    function valueStr(v) {
        return switch( v ) {
        case VIdent(i): i;
        case VString(s): '"' + s + '"';
        case VUnit(f, unit): f + unit;
        case VFloat(f): Std.string(f);
        case VInt(v): Std.string(v);
        case VHex(v): "#" + v;
        case VList(l):
            [for( v in l ) valueStr(v)].join(", ");
        case VGroup(l):
            [for( v in l ) valueStr(v)].join(" ");
        case VCall(f,args): f+"(" + [for( v in args ) valueStr(v)].join(", ") + ")";
        case VLabel(label, v): valueStr(v) + " !" + label;
        case VSlash: "/";
        }
    }

    function parseStyle( eof ) {
        while( true ) {
            if( isToken(eof) )
                break;
            var r = readIdent();
            if (r == null) {
                break;
            }
            expect(TDblDot);
            var v = readValue();
            if (v == null) {
                break;
            }
            var s = this.s;
            switch( v ) {
            case VLabel(label, val):
                if( label == "important" ) {
                    v = val;
                    if( simp == null ) simp = new Style();
                    s = simp;
                }
            default:
            }
            if( !applyStyle(r, v, s) )
                //throw "Invalid value " + valueStr(v) + " for css " + r;
                #if debug
                trace("Invalid value " + valueStr(v) + " for css " + r);
                #end
            if( isToken(eof) )
                break;
            expect(TSemicolon);
        }
    }

    public function parseRules( css : String ) {
        this.css = css;
        pos = 0;
        tokens = [];
        var rules = [];
        while( true ) {
            if( isToken(TEof) )
                break;
            var classes = readClasses();
            expect(TBrOpen);
            this.s = new Style();
            this.simp = null;
            parseStyle(TBrClose);
            for( c in classes )
                rules.push( { c : c, s : s, imp : false } );
            if( this.simp != null )
                for( c in classes )
                    rules.push( { c : c, s : simp, imp : true } );
        }
        return rules;
    }

    public function parseClasses( css : String ) {
        this.css = css;
        pos = 0;
        tokens = [];
        var c = readClasses();
        expect(TEof);
        return c;
    }

    // ----------------- class parser ---------------------------

    function readClasses() {
        var classes = [];
        while( true ) {
            spacesTokens = true;
            isToken(TSpaces); // skip
            var c = readClass(null);
            spacesTokens = false;
            if( c == null ) break;
            updateClass(c);
            classes.push(c);
            if( !isToken(TComma) )
                break;
        }
        if( classes.length == 0 )
            unexpected(readToken());
        return classes;
    }

    function updateClass( c : CssClass ) {
        // map html types to comp ones
        switch( c.node ) {
        case "div": c.node = "box";
        case "span": c.node = "label";
        case "h1", "h2", "h3", "h4":
            c.pseudoClass = c.node;
            c.node = "label";
        }
        if( c.parent != null ) updateClass(c.parent);
    }

    function readClass( parent ) : CssClass {
        var c = new CssClass();
        c.parent = parent;
        var def = false;
        var last = null;
        while( true ) {
            var t = readToken();

            if( last == null )
                switch( t ) {
                case TStar: def = true;
                case TDot, TSharp, TDblDot: last = t;
                case TIdent(i): c.node = i; def = true;
                case TSpaces:
                    return def ? readClass(c) : null;
                case TBrOpen, TComma, TEof:
                    push(t);
                    break;
                default:
                    unexpected(t);
                }
            else
                switch( t ) {
                case TIdent(i):
                    switch( last ) {
                    case TDot: c.className = i; def = true;
                    case TSharp: c.id = i; def = true;
                    case TDblDot: c.pseudoClass = i; def = true;
                    default: throw "assert";
                    }
                    last = null;
                case TEof:
                    break;
                default:
                    unexpected(t);
                }
        }
        return def ? c : parent;
    }

    // ----------------- value parser ---------------------------

    function readIdent() {
        var t = readToken();
        return switch( t ) {
        case TIdent(i): i;
        default: unexpected(t);
        }
    }

    function readValue(?opt)  : Value {
        var t = readToken();
        var v = switch( t ) {
        case TSharp:
            VHex(readHex());
        case TIdent(i):
            VIdent(i);
        case TString(s):
            VString(s);
        case TInt(i):
            readValueUnit(i, i);
        case TFloat(f):
            readValueUnit(f, null);
        case TSlash:
            VSlash;
        default:
            if( !opt ) unexpected(t);
            push(t);
            null;
        };
        if( v != null ) v = readValueNext(v);
        return v;
    }

    function readHex() {
        var start = pos;
        while( true ) {
            var c = next();
            if( (c >= "A".code && c <= "F".code) || (c >= "a".code && c <= "f".code) || (c >= "0".code && c <= "9".code) )
                continue;
            pos--;
            break;
        }
        return css.substr(start, pos - start);
    }

    function readValueUnit( f : Float, ?i : Int ) {
        var t = readToken();
        return switch( t ) {
        case TIdent(i):
            VUnit(f, i);
        case TPercent:
            VUnit(f, "%");
        default:
            push(t);
            if( i != null )
                VInt(i);
            else
                VFloat(f);
        };
    }

    function readValueNext( v : Value ) : Value {
        var t = readToken();
        return switch( t ) {
        case TPOpen:
            switch( v ) {
            case VIdent(i):
                switch( i ) {
                case "url":
                    readValueNext(VCall("url",[VString(readUrl())]));
                default:
                    var args = switch( readValue() ) {
                    case VList(l): l;
                    case x: [x];
                    }
                    expect(TPClose);
                    readValueNext(VCall(i, args));
                }
            default:
                push(t);
                v;
            }
        case TExclam:
            var t = readToken();
            switch( t ) {
            case TIdent(i):
                VLabel(i, v);
            default:
                unexpected(t);
            }
        case TComma:
            loopComma(v, readValue());
        default:
            push(t);
            var v2 = readValue(true);
            if( v2 == null )
                v;
            else
                loopNext(v, v2);
        }
    }

    function loopNext(v, v2) {
        return switch( v2 ) {
        case VGroup(l):
            l.unshift(v);
            v2;
        case VList(l):
            l[0] = loopNext(v, l[0]);
            v2;
        case VLabel(lab, v2):
            VLabel(lab, loopNext(v, v2));
        default:
            VGroup([v, v2]);
        };
    }

    function loopComma(v,v2) {
        return switch( v2 ) {
        case VList(l):
            l.unshift(v);
            v2;
        case VLabel(lab, v2):
            VLabel(lab, loopComma(v, v2));
        default:
            VList([v, v2]);
        };
    }

    // ----------------- lexer -----------------------

    inline function isSpace(c) {
        return (c == " ".code || c == "\n".code || c == "\r".code || c == "\t".code);
    }

    inline function isIdentChar(c) {
        return (c >= "a".code && c <= "z".code) || (c >= "A".code && c <= "Z".code) || (c == "-".code) || (c == "_".code);
    }

    inline function isNum(c) {
        return c >= "0".code && c <= "9".code;
    }

    inline function next() {
        return StringTools.fastCodeAt(css, pos++);
    }

    function readUrl() {
        var c0 = next();
        while( isSpace(c0) )
            c0 = next();
        var quote = c0;
        if( quote == "'".code || quote == '"'.code ) {
            pos--;
            switch( readToken() ) {
            case TString(s):
                var c0 = next();
                while( isSpace(c0) )
                    c0 = next();
                if( c0 != ")".code )
                    throw "Invalid char " + c0;//String.fromCharCode(c0);   //FIXME Error. s : String -> haxe.ui.util.VariantType has no field fromCharCode
                return s;
            default: throw "assert";
            }

        }
        var start = pos - 1;
        while( true ) {
            if( StringTools.isEof(c0) )
                break;
            c0 = next();
            if( c0 == ")".code ) break;
        }
        return StringTools.trim(css.substr(start, pos - start - 1));
    }

    #if false
    function readToken( ?pos : haxe.PosInfos ) {
        var t = _readToken();
        haxe.Log.trace(t, pos);
        return t;
    }

    function _readToken() {
    #else
    function readToken() {
    #end
        var t = tokens.pop();
        if( t != null )
            return t;
        while( true ) {
            var c = next();
            if( StringTools.isEof(c) )
                return TEof;
            if( isSpace(c) ) {
                if( spacesTokens ) {
                    while( isSpace(next()) ) {
                    }
                    pos--;
                    return TSpaces;
                }

                continue;
            }
            if( isNum(c) || c == '-'.code ) {
                var i = 0, neg = false;
                if( c == '-'.code ) { c = "0".code; neg = true; }
                do {
                    i = i * 10 + (c - "0".code);
                    c = next();
                } while( isNum(c) );
                if( c == ".".code ) {
                    var f : Float = i;
                    var k = 0.1;
                    while( isNum(c = next()) ) {
                        f += (c - "0".code) * k;
                        k *= 0.1;
                    }
                    pos--;
                    return TFloat(neg? -f : f);
                }
                pos--;
                return TInt(neg ? -i : i);
            }
            if( isIdentChar(c) ) {
                var pos = pos - 1;
                do c = next() while( isIdentChar(c) || isNum(c) );
                this.pos--;
                return TIdent(css.substr(pos,this.pos - pos));
            }
            switch( c ) {
            case ":".code: return TDblDot;
            case "#".code: return TSharp;
            case "(".code: return TPOpen;
            case ")".code: return TPClose;
            case "!".code: return TExclam;
            case "%".code: return TPercent;
            case ";".code: return TSemicolon;
            case ".".code: return TDot;
            case "{".code: return TBrOpen;
            case "}".code: return TBrClose;
            case ",".code: return TComma;
            case "*".code: return TStar;
            case "/".code:
                if( (c = next()) != '*'.code ) {
                    pos--;
                    return TSlash;
                }
                while( true ) {
                    while( (c = next()) != '*'.code ) {
                        if( StringTools.isEof(c) )
                            throw "Unclosed comment";
                    }
                    c = next();
                    if( c == "/".code ) break;
                    if( StringTools.isEof(c) )
                        throw "Unclosed comment";
                }
                return readToken();
            case "'".code, '"'.code:
                var pos = pos;
                var k;
                while( (k = next()) != c ) {
                    if( StringTools.isEof(k) )
                        throw "Unclosed string constant";
                    if( k == "\\".code ) {
                        throw "todo";
                        continue;
                    }
                }
                return TString(css.substr(pos, this.pos - pos - 1));
            default:
            }
            pos--;
            throw "Invalid char " + css.charAt(pos);
        }
        return null;
    }

}
