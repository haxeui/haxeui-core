package haxe.ui.util;

typedef HSL = {
    var h:Float;
    var s:Float;
    var l:Float;
}

typedef HSV = {
    var h:Float;
    var s:Float;
    var v:Float;
}

typedef RGBF = {
    var r:Float;
    var g:Float;
    var b:Float;
}

// conversion functions extracted from: https://github.com/fponticelli/thx.color

class ColorUtil {
    public static function toHSL(color:Color):HSL {
        var r = color.r / 255;
        var g = color.g / 255;
        var b = color.b / 255;
        
        var min = MathUtil.min([r, g, b]);
        var max = MathUtil.max([r, g, b]);
        var delta = max - min;
        var h:Float = 0;
        var s:Float = 0;
        var l:Float = (max + min) / 2;

        if (delta == 0.0) {
            s = h = 0.0;
        } else {
            s = l < 0.5 ? delta / (max + min) : delta / (2 - max - min);
            if (r == max) {
                h = (g - b) / delta + (g < b ? 6 : 0);
            } else if (g == max) {
                h = (b - r) / delta + 2;
            } else {
                h = (r - g) / delta + 4;
            }
            h *= 60;
        }
        
        return {h: Math.round(h), s: s * 100, l: l * 100};
    }
    
    public static function fromHSL(hue:Float, saturation:Float, luminosity:Float):Color {
        saturation /= 100;
        luminosity /= 100;
        // Based on D3.js by Michael Bostock
        var _c = function(d:Float, s:Float, l:Float):Float {
            var m2:Float = l <= 0.5 ? l * (1 + s): l + s - l * s;
            var m1:Float = 2 * l - m2;
            
            d = MathUtil.wrapCircular(d, 360);
            if (d < 60) {
                return m1 + (m2 - m1) * d / 60;
            } else if (d < 180) {
                return m2;
            } else if (d < 240) {
                return m1 + (m2 - m1) * (240 - d) / 60;
            }
            return m1;
        }
        return Color.fromComponents(Math.round(_c(hue + 120, saturation, luminosity) * 255), 
                                    Math.round(_c(hue, saturation, luminosity) * 255),
                                    Math.round(_c(hue - 120, saturation, luminosity) * 255),
                                    255);
    }
    
    public static function toHSV(color:Color):HSV {
        var r = color.r / 255;
        var g = color.g / 255;
        var b = color.b / 255;
        
        var min = MathUtil.min([r, g, b]);
        var max = MathUtil.max([r, g, b]);
        var delta = max - min;
        var h:Float = 0;
        var s:Float = 0;
        var v:Float = max;
        
        if (delta != 0) {
            s = delta / max;
        } else {
            s = 0;
            h = 0;
            return {h: Math.fround(h), s: s * 100, v: v * 100};
        }
        
        if (r == max) {
            h = (g - b) / delta;
        } else if (g == max) {
            h = 2 + (b - r) / delta;
        } else {
            h = 4 + (r - g) / delta;
        }
        
        h *= 60;
        if (h < 0) {
            h += 360;
        }
        
        return {h: Math.fround(h), s: s * 100, v: v * 100};
    }
    
    public static function fromHSV(hue:Float, saturation:Float, value:Float):Color {
        if (saturation == 0) {
            return Color.fromComponents(Std.int(value), Std.int(value), Std.int(value), 255);
        }

        saturation /= 100;
        value /= 100;
        
        var r:Float, g:Float, b:Float, i:Int, f:Float, p:Float, q:Float, t:Float;
        var h = hue / 60;
        
        i = Math.floor(h);
        f = h - i;
        p = value * (1 - saturation);
        q = value * (1 - f * saturation);
        t = value * (1 - (1 - f) * saturation);
        
        switch (i) {
            case 0: r = value; g = t; b = p;
            case 1: r = q; g = value; b = p;
            case 2: r = p; g = value; b = t;
            case 3: r = p; g = q; b = value;
            case 4: r = t; g = p; b = value;
            default: r = value; g = p; b = q; // case 5
        }
        
        return Color.fromComponents(Math.round(r * 255), 
                                    Math.round(g * 255),
                                    Math.round(b * 255),
                                    255);
    }
    
    public static function hsvToRGBF(hue:Float, saturation:Float, value:Float):RGBF {
        if (hue == 0 && saturation == 0 && value == 100) {
            //return {r: 255, g: 255, b: 255};
        }
        if (saturation == 0) {
            //return {r: value, g: value, b: value};
        }

        saturation /= 100;
        value /= 100;
        
        var r:Float, g:Float, b:Float, i:Int, f:Float, p:Float, q:Float, t:Float;
        var h = hue / 60;
        
        i = Math.floor(h);
        f = h - i;
        p = value * (1 - saturation);
        q = value * (1 - f * saturation);
        t = value * (1 - (1 - f) * saturation);
        
        switch (i) {
            case 0: r = value; g = t; b = p;
            case 1: r = q; g = value; b = p;
            case 2: r = p; g = value; b = t;
            case 3: r = p; g = q; b = value;
            case 4: r = t; g = p; b = value;
            default: r = value; g = p; b = q; // case 5
        }
        
        return {r: r * 255, g: g * 255, b: b * 255};
    }
    
    public static function rgbToGray(r:Float, g:Float, b:Float):Int {
        var g = (0.3 * r) + (0.59 * g) + (0.11 * b);
        return Math.round(g);
    }
    
    public static function rgbfToHSV(r:Float, g:Float, b:Float):HSV {
        if (Math.fround(r) == 255 && Math.fround(g) == 255 && Math.fround(b) == 255) {
            //return {h: 0, s: 0, v: 100}; 
        }
        var r = r / 255;
        var g = g / 255;
        var b = b / 255;
        
        var min = MathUtil.min([r, g, b]);
        var max = MathUtil.max([r, g, b]);
        var delta = max - min;
        var h:Float = 0;
        var s:Float = 0;
        var v:Float = max;
        
        if (delta != 0) {
            s = delta / max;
        } else {
            s = 0;
            h = 0;
            return {h: h, s: s * 100, v: v * 100};
        }
        
        if (r == max) {
            h = (g - b) / delta;
        } else if (g == max) {
            h = 2 + (b - r) / delta;
        } else {
            h = 4 + (r - g) / delta;
        }
        
        h *= 60;
        if (h < 0) {
            h += 360;
        }
        
        if (Math.fround(r) == 255 && Math.fround(g) == 255 && Math.fround(b) == 255) {
            return {h: h, s: 0, v: 100}; 
        }
        
        return {h: h, s: s * 100, v: v * 100};
    }
    
    public static function buildColorArray(startColor:Color, endColor:Color, size:Float):Array<Int> {
        var array:Array<Int> = [];

        var r1 = startColor.r;
        var g1 = startColor.g;
        var b1 = startColor.b;
        var r2 = endColor.r;
        var g2 = endColor.g;
        var b2 = endColor.b;
        var rd = r2 - r1; // deltas
        var gd = g2 - g1; // deltas
        var bd = b2 - b1; // deltas
        var ri:Float = rd / (size - 1); // increments
        var gi:Float = gd / (size - 1); // increments
        var bi:Float = bd / (size - 1); // increments

        var r:Float = r1;
        var g:Float = g1;
        var b:Float = b1;
        var c:Color;
        for (n in 0...cast size) {
            c.set(Math.round(r), Math.round(g), Math.round(b), 0);
            array.push(c);

            r += ri;
            g += gi;
            b += bi;
        }

        return array;
    }

    public static inline function parseColor(s:String):Int {
        if (StringTools.startsWith(s, "#")) {
            s = s.substring(1, s.length);
        } else if (StringTools.startsWith(s, "0x")) {
            s = s.substring(2, s.length);
        }
        return Std.parseInt("0x" + s);
    }
}