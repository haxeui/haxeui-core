package haxe.ui.styles;

import haxe.ui.core.Platform;
import haxe.ui.styles.StyleLookupMap;
import haxe.ui.themes.ThemeManager;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;
import haxe.ui.util.ColorUtil;

using haxe.ui.util.ColorUtil;
class CssFunctions {
    private static var _cssFunctions:Map<String, Array<Value>->Any> = new Map<String, Array<Value>->Any>();

    public static function registerCssFunction(name:String, fn:Array<Value>->Any) {
        _cssFunctions.set(name, fn);
    }

    public static inline function hasCssFunction(name:String):Bool {
        return _cssFunctions.exists(name);
    }

    public static inline function getCssFunction(name:String):Array<Value>->Any {
        return _cssFunctions.get(name);
    }

    public static function calc(vl:Array<Value>):Any {
        #if hscript

        var parser = new hscript.Parser();
        var program = parser.parseString(ValueTools.string(vl[0]));

        var interp = new hscript.Interp();
        return interp.expr(program);

        #else

        return null;

        #end
    }

    public static function min(vl:Array<Value>):Any {
        var minv:Float = Math.POSITIVE_INFINITY;
        for (val in vl) {
            var num:Null<Float> = ValueTools.calcDimension(val);
            if (num == null)
                return null;
            else if (num < minv)
                minv = num;
        }
        return minv;
    }

    public static function max(vl:Array<Value>):Any {
        var maxv:Float = Math.NEGATIVE_INFINITY;
        for (val in vl) {
            var num:Null<Float> = ValueTools.calcDimension(val);
            if (num == null)
                return null;
            else if (num > maxv)
                maxv = num;
        }
        return maxv;
    }

    public static function clamp(vl:Array<Value>):Any {
        var valNum:Null<Float> = ValueTools.calcDimension(vl[0]);
        var minNum:Null<Float> = ValueTools.calcDimension(vl[1]);
        var maxNum:Null<Float> = ValueTools.calcDimension(vl[2]);

        if (valNum == null || minNum == null || maxNum == null)
            return null;
        else if (valNum < minNum)
            return minNum;
        else if (valNum > maxNum)
            return maxNum;
        else
            return valNum;
    }

    public static function platformColor(vl:Array<Value>):Any {
        return Platform.instance.getColor(ValueTools.string(vl[0]));
    }

    public static function themeIcon(vl:Array<Value>):Any {
        return ThemeManager.instance.image(ValueTools.string(vl[0]));
    }

    public static function rgb(vl:Array<Value>):Any {
        return Color.fromComponents(ValueTools.int(vl[0]), ValueTools.int(vl[1]), ValueTools.int(vl[2]), 0).toInt();
    }

    public static function lookup(vl:Array<Value>):Any {
        return Variant.toDynamic(StyleLookupMap.instance.get(ValueTools.string(vl[0])));
    }

    public static function lighten(vl:Array<Value>):Any {
        var color:Color = ValueTools.int(vl[0]);
        var amount:Int = ValueTools.int(vl[1]);

        var hsl = color.toHSL();
        var diffL = (100 - hsl.l) * amount / 100;

        var newColor:Color = ColorUtil.fromHSL(hsl.h, hsl.s, hsl.l + diffL);

        return newColor;
    }

    public static function darken(vl:Array<Value>):Any {
        var color:Color = ValueTools.int(vl[0]);
        var amount:Int = ValueTools.int(vl[1]);

        var hsl = color.toHSL();
        var diffL = hsl.l * amount / 100;

        var newColor:Color = ColorUtil.fromHSL(hsl.h, hsl.s, hsl.l - diffL);

        return newColor;
    }

}