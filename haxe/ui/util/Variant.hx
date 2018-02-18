package haxe.ui.util;

import haxe.ui.core.Screen;
import haxe.ui.styles.Defs.Unit in StyleUnit;
import haxe.ui.data.DataSource;

enum VariantType {
    Int(s:Int);
    Float(s:Float);
    Unit(s:StyleUnit);
    String(s:String);
    Bool(s:Bool);
//    Dynamic(s:Dynamic);
    DataSource(s:DataSource<Dynamic>);
}

abstract Variant(VariantType) from VariantType {
    // ************************************************************************************************************
    // STRINGS
    // ************************************************************************************************************
    @:from static function fromString(s:String):Variant {
        return String(s);
    }

    @:to public function toString():String {
        if (this == null) {
            return null;
        }
        return switch (this) {
            case String(s): s;
            case Int(s): Std.string(s);
            case Float(s): Std.string(s);
            case Unit(s): Std.string(s);
            case Bool(s): Std.string(s);
            //case Dynamic(s): Std.string(s);
            case DataSource(s): Std.string(s);
            default: throw "Variant Type Error";
        }
    }

    public var isString(get, never):Bool;
    private function get_isString():Bool {
        return this.match(String(_));
    }

    // ************************************************************************************************************
    // INTS
    // ************************************************************************************************************
    @:from static function fromInt(s:Int):Variant {
        return Int(s);
    }

    @:to public function toInt():Null<Int> {
        if (isNull) {
            return null;
        }
        return switch (this) {
            case Int(s): s;
            case Float(s): Std.int(s);
            case Unit(s): switch (s) {
                case Pix(v): Std.int(v);
                case REM(v): Std.int(v * Toolkit.pixelsPerRem);
                case VH(v): Std.int(v / 100 * Screen.instance.height);
                case VW(v): Std.int(v / 100 * Screen.instance.width);
                default: throw "Variant Type Error";
            }
            default: throw "Variant Type Error";
        }
    }

    public var isInt(get, never):Bool;
    private inline function get_isInt():Bool {
        return this.match(Int(_));
    }

    // ************************************************************************************************************
    // FLOATS
    // ************************************************************************************************************
    @:from static function fromFloat(s:Float):Variant {
        return Float(s);
    }

    @:to public function toFloat():Null<Float> {
        if (isNull) {
            return null;
        }
        return switch (this) {
            case Float(s): s;
            case Unit(s): switch (s) {
                case Pix(v): v;
                case REM(v): v * Toolkit.pixelsPerRem;
                case VH(v): v / 100 * Screen.instance.height;
                case VW(v): v / 100 * Screen.instance.width;
                default: throw "Variant Typfe Error";
            }
            default: throw "Variant Type Error";
        }
    }

    public var isFloat(get, never):Bool;
    private inline function get_isFloat():Bool {
        return this.match(Float(_));
    }

    // ************************************************************************************************************
    // UNITS
    // ************************************************************************************************************

    @:from static function fromUnit(s:StyleUnit):Variant {
        return Unit(s);
    }

    @:to function toUnit():StyleUnit {
        return switch (this) {
            case Int(s): Pix(s);
            case Float(s): Pix(s);
            case Unit(s): s;
            default: throw "Variant Type Error";
        }
    }

    public var isUnit(get, never):Bool;
    private inline function get_isUnit():Bool {
        return this.match(Unit(_));
    }

    // ************************************************************************************************************
    // NUMBERS
    // ************************************************************************************************************
    public var isNumber(get, never):Bool;
    private inline function get_isNumber():Bool {
        return this.match(Int(_) | Float(_) | Unit(_));
    }

    function toNumber():Float {
        return switch (this) {
            case Int(s): s;
            case Float(s): s;
            case Unit(s): switch (s) {
                case Pix(v): v;
                case REM(v): v * Toolkit.pixelsPerRem;
                case VH(v): v / 100 * Screen.instance.height;
                case VW(v): v / 100 * Screen.instance.width;
                default: throw "Variant Type Error";
            }
            default: throw "Variant Type Error";
        }
    }

    // ************************************************************************************************************
    // BOOLS
    // ************************************************************************************************************
    @:from static function fromBool(s:Bool):Variant {
        return Bool(s);
    }

    @:to function toBool():Bool {
        if (this == null) {
            return false;
        }
        return switch (this) {
            case Bool(s): s;
            default: throw "Variant Type Error";
        }
    }

    public var isBool(get, never):Bool;
    private function get_isBool():Bool {
        switch (this) {
            case Bool(_): return true;
            default:
        }
        return false; // this.match(Bool(_));
    }

    // ************************************************************************************************************
    // BOOLS
    // ************************************************************************************************************
    @:from static function fromDataSource(s:DataSource<Dynamic>):Variant {
        return DataSource(s);
    }

    @:to function toDataSource():DataSource<Dynamic> {
        return switch (this) {
            case DataSource(s): s;
            default: throw "Variant Type Error";
        }
    }

    public var isDataSource(get, never):Bool;
    private function get_isDataSource():Bool {
        switch (this) {
            case DataSource(_): return true;
            default:
        }
        return false; // this.match(Bool(_));
    }

    // ************************************************************************************************************
    // OPERATIONS
    // ************************************************************************************************************
    @:op(A + B)
    private static function addFloat(lhs:Float, rhs:Variant):Float {
        return lhs + rhs.toNumber();
    }

    @:op(A + B)
    private static function addInt(lhs:Int, rhs:Variant):Int {
        return lhs + rhs.toInt();
    }

    @:op(A - B)
    private static function subtractFloat(lhs:Float, rhs:Variant):Float {
        return lhs - rhs.toNumber();
    }

    @:op(A - B)
    private static function subtractInt(lhs:Int, rhs:Variant):Int {
        return lhs - rhs.toInt();
    }

    @:op(A + B)
    private function add(rhs:Variant):Variant {
        if (isNumber && rhs.isNumber) {
            return toNumber() + rhs.toNumber();
        } else if (isString && rhs.isString) {
            return toString() + rhs.toString();
        }

        throw "Variant operation error";
    }

    @:op(A++)
    private inline function postInc():Variant {
        return if (isUnit) {
            switch (this) {
                case Unit(s): switch (s) {
                    case Pix(v): var old = this; this = Unit(Pix(v+1)); old;
                    case REM(v): var old = this; this = Unit(REM(v+1)); old;
                    case VH(v): var old = this; this = Unit(VH(v+1)); old;
                    case VW(v): var old = this; this = Unit(VW(v+1)); old;
                    default: throw "Variant Type Error";
                }
                default: throw "Variant Type Error";
            }
        } else if (isNumber) {
            var old = this;
            this = Float(toNumber()+1);
            old;
        } else {
            throw "Variant operation error";
        }
    }

    @:op(++A)
    private inline function preInc():Variant {
        return if (isUnit) {
            switch (this) {
                case Unit(s): switch (s) {
                    case Pix(v): this = Unit(Pix(v+1));
                    case REM(v): this = Unit(REM(v+1));
                    case VH(v): this = Unit(VH(v+1));
                    case VW(v): this = Unit(VW(v+1));
                    default: throw "Variant Type Error";
                }
                default: throw "Variant Type Error";
            }
        } else if (isNumber) {
            this = Float(toNumber()+1);
        } else {
            throw "Variant operation error";
        }
    }

    @:op(A - B)
    private function subtract(rhs:Variant):Variant {
        if (isNumber && rhs.isNumber) {
            return toNumber() - rhs.toNumber();
        } else if (isString && rhs.isString) {
            return StringTools.replace(toString(), rhs.toString(), "");
        }

        throw "Variant operation error";
    }

    @:op(A--)
    private inline function postDeinc():Variant {
        return if (isUnit) {
            switch (this) {
                case Unit(s): switch (s) {
                    case Pix(v): var old = this; this = Unit(Pix(v-1)); old;
                    case REM(v): var old = this; this = Unit(REM(v-1)); old;
                    case VH(v): var old = this; this = Unit(VH(v-1)); old;
                    case VW(v): var old = this; this = Unit(VW(v-1)); old;
                    default: throw "Variant Type Error";
                }
                default: throw "Variant Type Error";
            }
        } else if (isNumber) {
            var old = this;
            this = Float(toNumber()-1);
            old;
        } else {
            throw "Variant operation error";
        }
    }

    @:op(--A)
    private inline function preDeinc():Variant {
        return if (isUnit) {
            switch (this) {
                case Unit(s): switch (s) {
                    case Pix(v): this = Unit(Pix(v-1));
                    case REM(v): this = Unit(REM(v-1));
                    case VH(v): this = Unit(VH(v-1));
                    case VW(v): this = Unit(VW(v-1));
                    default: throw "Variant Type Error";
                }
                default: throw "Variant Type Error";
            }
        } else if (isNumber) {
            this = Float(toNumber()-1);
        } else {
            throw "Variant operation error";
        }
    }

    @:op(A * B)
    private function multiply(rhs:Variant):Variant {
        if (isNumber && rhs.isNumber) {
            return toNumber() * rhs.toNumber();
        }

        throw "Variant operation error";
    }

    @:op(A / B)
    private function divide(rhs:Variant):Variant {
        if (isNumber && rhs.isNumber) {
            return toNumber() / rhs.toNumber();
        }

        throw "Variant operation error";
    }

    @:op(A > B)
    private function gt(rhs:Variant):Bool {
        if (isNumber) {
            return toNumber() > rhs.toNumber();
        } else if (isString) {
            return toString() > rhs.toString();
        }

        throw "Variant operation error";
    }

    @:op(A >= B)
    private function gte(rhs:Variant):Bool {
        if (isNumber) {
            return toNumber() >= rhs.toNumber();
        } else if (isString) {
            return toString() >= rhs.toString();
        }

        throw "Variant operation error";
    }

    @:op(A < B)
    private function lt(rhs:Variant):Bool {
        if (isNumber) {
            return toNumber() < rhs.toNumber();
        } else if (isString) {
            return toString() < rhs.toString();
        }

        throw "Variant operation error";
    }

    @:op(A <= B)
    private function lte(rhs:Variant):Bool {
        if (isNumber) {
            return toNumber() <= rhs.toNumber();
        } else if (isString) {
            return toString() <= rhs.toString();
        }

        throw "Variant operation error";
    }

    @:op(-A)
    private function negate():Variant {
        if (isNumber) {
            return -toNumber();
        }

        throw "Variant operation error";
    }

    @:op(!A)
    private function invert():Variant {
        if (isBool) {
            var v = toBool();
            v = !v;
            return v;
        }
        throw "Variant operation error";
    }

    // ************************************************************************************************************
    // HELPERS
    // ************************************************************************************************************
    public var isNull(get, never):Bool;
    private function get_isNull():Bool {
        return this == null || toString() == null;
    }

    public static function fromDynamic(r:Dynamic):Variant {
        var v:Variant = null;
        if (r != null) {
            if (containsOnlyDigits(r) && Math.isNaN(Std.parseFloat("" + r)) == false) {
                if (Std.string(r).indexOf(".") != -1) {
                    v = Std.parseFloat("" + r);
                } else {
                    v = Std.parseInt("" + r);
                }
            } else if ((("" + r) == "true" || (r + "") == "false")) {
                v = (("" + r) == "true");
            } else if (Std.is(r, String)) {
                v = Std.string(r);
            } else if (Std.is(r, DataSource)) {
                v =  cast r;
            } else if (Std.is(r, StyleUnit)) {
                v = r;
            } else {
                v = Std.string(r);
            }
        }
        return v;
    }

    private static function containsOnlyDigits(s:Dynamic):Bool {
        if (Std.is(s, Int) || Std.is(s, Float)) {
            return true;
        }

        var t:String = Std.string(s);
        for (i in 0...t.length) {
            var c = t.charAt(i);
            if (c != "0" && c != "1" && c != "2" && c != "3" && c != "4" && c != "5" && c != "6" && c != "7" && c != "8" && c != "9" && c != ".") {
                return false;
            }
        }
        return true;
    }

    public static function toDynamic(v:Variant):Dynamic {
        var d:Dynamic = null;
        if (v != null) {
            switch (v) {
                case VariantType.Int(y):        d = y;
                case VariantType.Float(y):      d = y;
                case VariantType.Unit(y):       d = y;
                case VariantType.String(y):     d = y;
                case VariantType.Bool(y):       d = y;
                //case VariantType.Dynamic(y):    d = y;
                case VariantType.DataSource(y):       d = y;
            }
        }
        return d;
    }
}
