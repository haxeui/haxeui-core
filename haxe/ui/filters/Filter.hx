package haxe.ui.filters;

class Filter {
    private static var unitEReg:EReg = ~/^(-?\d*\.?\d+)(%|deg|grad|rad|turn)$/;

    public function new() {
    }

    public function parse(filterDetails:Array<Any>) {
        trace("WARNING: css filter '" + Type.getClassName(Type.getClass(this)) + "' has not implemented parse function");
    }

    /**
        Converts a percentage or angle param (eg: "50%" or "90deg") to a number, any other param is returned as is.
        Percentages are scaled so that 100% is `fullPercent`, angles are converted to degrees.
    **/
    private static function convertUnits(param:Any, fullPercent:Float):Any {
        if ((param is String) && unitEReg.match(param)) {
            var n = Std.parseFloat(unitEReg.matched(1));
            switch (unitEReg.matched(2)) {
                case "%":
                    return n / 100 * fullPercent;
                case "grad":
                    return n * 0.9;
                case "rad":
                    return n * 180 / Math.PI;
                case "turn":
                    return n * 360;
                case _:
                    return n;
            }
        }
        return param;
    }

    private static function applyDefaults(params:Array<Any>, defaults:Array<Any>, fullPercent:Float = 1):Array<Any> {
        var copy:Array<Any> = [];

        if (defaults != null) {
            for (p in defaults) {
                copy.push(p);
            }
        }
        if (params != null) {
            var n:Int = 0;
            for (p in params) {
                copy[n] = convertUnits(p, fullPercent);
                n++;
            }
        }

        return copy;
    }
}