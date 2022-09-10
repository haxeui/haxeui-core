package haxe.ui.util;

import haxe.ui.backend.ImageData;
import haxe.ui.core.Component;
import haxe.ui.data.DataSource;

enum VariantType {
    VT_Int(s:Int);
    VT_Float(s:Float);
    VT_String(s:String);
    VT_Bool(s:Bool);
    VT_Array(s:Array<Dynamic>);
    VT_DataSource(s:DataSource<Dynamic>);
    VT_Component(s:Component);
    VT_Date(s:Date);
    VT_ImageData(s:ImageData);
}

@:transitive
abstract Variant(VariantType) from VariantType {
    // ************************************************************************************************************
    // STRINGS
    // ************************************************************************************************************
    @:from static function fromString(s:String):Variant {
        return VT_String(s);
    }

    @:to public function toString():String {
        if (this == null) {
            return null;
        }
        return switch (this) {
            case VT_String(s): s;
            case VT_Int(s): Std.string(s);
            case VT_Float(s): Std.string(s);
            case VT_Bool(s): Std.string(s);
            case VT_Array(s): Std.string(s);
            case VT_Component(s): s == null ? null : "";
            case VT_DataSource(s): s == null ? null : "";
            case VT_Date(s): Std.string(s);
            case VT_ImageData(s): s == null ? null : "";
            default: throw "Variant Type Error";
        }
    }

    public var isString(get, never):Bool;
    private function get_isString():Bool {
        return this.match(VT_String(_));
    }

    // ************************************************************************************************************
    // FLOATS
    // ************************************************************************************************************
    @:from static function fromFloat(s:Float):Variant {
        return VT_Float(s);
    }

    @:to public function toFloat():Null<Float> {
        if (isNull) {
            return null;
        }
        return switch (this) {
            case VT_Int(s): s;
            case VT_Float(s): s;
            default: throw "Variant Type Error";
        }
    }

    public var isFloat(get, never):Bool;
    private inline function get_isFloat():Bool {
        return this.match(VT_Float(_));
    }

    // ************************************************************************************************************
    // INTS
    // ************************************************************************************************************
    @:from static function fromInt(s:Int):Variant {
        return VT_Int(s);
    }

    @:to public function toInt():Null<Int> {
        if (isNull) {
            return null;
        }
        return switch (this) {
            case VT_Int(s): s;
            case VT_Float(s): Std.int(s);
            default: throw "Variant Type Error " + this;
        }
    }

    public var isInt(get, never):Bool;
    private inline function get_isInt():Bool {
        return this.match(VT_Int(_));
    }

    // ************************************************************************************************************
    // NUMBERS
    // ************************************************************************************************************
    public var isNumber(get, never):Bool;
    private inline function get_isNumber():Bool {
        return this.match(VT_Int(_) | VT_Float(_));
    }

    function toNumber():Float {
        return switch (this) {
            case VT_Int(s): s;
            case VT_Float(s): s;
            default: throw "Variant Type Error";
        }
    }

    // ************************************************************************************************************
    // BOOLS
    // ************************************************************************************************************
    @:from static function fromBool(s:Bool):Variant {
        return VT_Bool(s);
    }

    @:to public function toBool():Bool {
        if (this == null) {
            return false;
        }
        return switch (this) {
            case VT_Bool(s): s;
            case VT_String(s): s == "true";
            default: throw "Variant Type Error";
        }
    }

    public var isBool(get, never):Bool;
    private function get_isBool():Bool {
        switch (this) {
            case VT_Bool(_): return true;
            default:
        }
        return false;
    }

    // ************************************************************************************************************
    // ARRAYS
    // ************************************************************************************************************
    @:from static function fromArray<T>(s:Array<T>):Variant {
        return s == null ? null : VT_Array(s);
    }

    @:to public function toArray<T>():Array<T> {
        if (this == null) {
            return null;
        }
        return switch (this) {
            case VT_Array(s): cast s;
            default: throw "Variant Type Error";
        }
    }

    public var isArray(get, never):Bool;
    private function get_isArray():Bool {
        switch (this) {
            case VT_Array(_): return true;
            default:
        }
        return false;
    }

    // ************************************************************************************************************
    // DATES
    // ************************************************************************************************************
    @:from static function fromDate(s:Date):Variant {
        return VT_Date(s);
    }

    @:to public function toDate():Date {
        if (this == null) {
            return null;
        }
        return switch (this) {
            case VT_Date(s): s;
            default: throw "Variant Type Error";
        }
    }

    public var isDate(get, never):Bool;
    private function get_isDate():Bool {
        switch (this) {
            case VT_Date(_): return true;
            default:
        }
        return false;
    }

    // ************************************************************************************************************
    // COMPONENT
    // ************************************************************************************************************
    @:from public static function fromComponent(s:Component):Variant {
        return VT_Component(s);
    }

    @:to public function toComponent():Component {
        if (this == null) {
            return null;
        }
        return switch (this) {
            case VT_Component(s): s;
            default: throw "Variant Type Error";
        }
    }

    public var isComponent(get, never):Bool;
    private function get_isComponent():Bool {
        switch (this) {
            case VT_Component(_): return true;
            default:
        }
        return false;
    }

    // ************************************************************************************************************
    // IMAGE DATA
    // ************************************************************************************************************
    @:from public static function fromImageData(s:ImageData):Variant {
        return VT_ImageData(s);
    }

    @:to public function toImageData():ImageData {
        if (this == null) {
            return null;
        }
        return switch (this) {
            case VT_ImageData(s): s;
            default: throw "Variant Type Error";
        }
    }

    public var isImageData(get, never):Bool;
    private function get_isImageData():Bool {
        switch (this) {
            case VT_ImageData(_): return true;
            default:
        }
        return false;
    }

    // ************************************************************************************************************
    // DATA SOURCE
    // ************************************************************************************************************
    @:from static function fromDataSource<T>(s:DataSource<T>):Variant {
        return VT_DataSource(s);
    }

    @:to function toDataSource<T>():DataSource<T> {
        if (this == null) {
            return null;
        }

        return switch (this) {
            case VT_DataSource(s): cast s;
            default: throw "Variant Type Error";
        }
    }

    public var isDataSource(get, never):Bool;
    private function get_isDataSource():Bool {
        switch (this) {
            case VT_DataSource(_): return true;
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
        return if (isNumber) {
            var old = this;
            this = VT_Float(toNumber() + 1);
            old;
        } else {
            throw "Variant operation error";
        }
    }

    @:op(++A)
    private inline function preInc():Variant {
        return if (isNumber) {
            this = VT_Float(toNumber() + 1);
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
        return if (isNumber) {
            var old = this;
            this = VT_Float(toNumber() - 1);
            old;
        } else {
            throw "Variant operation error";
        }
    }

    @:op(--A)
    private inline function preDeinc():Variant {
        return if (isNumber) {
            this = VT_Float(toNumber() - 1);
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

    @:op(A == B)
    private function eq(rhs:Variant):Bool {
        if (isNull && rhs.isNull) {
            return true;
        }

        if (isNull && !rhs.isNull) {
            return false;
        }

        if (!isNull && rhs.isNull) {
            return false;
        }

        if (isNumber && rhs.isNumber) {
            return toNumber() == rhs.toNumber();
        } else if (isBool && rhs.isBool) {
            return toBool() == rhs.toBool();
        } else if (isString && rhs.isString) {
            return toString() == rhs.toString();
        }

        return false;
    }

    @:op(A != B)
    private function neq(rhs:Variant):Bool {
        return !eq(rhs);
    }

    // ************************************************************************************************************
    // HELPERS
    // ************************************************************************************************************
    public var isNull(get, never):Bool;
    private function get_isNull():Bool {
        if (this == null) {
            return true;
        }
        return toString() == null;
    }

    public static function fromDynamic<T>(r:Dynamic):Variant {
        var v:Variant = null;
        if (r != null) {
            var unstringable = ((r is Component) || (r is ImageData) || (r is Array) || (r is DataSource));
            if (unstringable == false) {
                if (containsOnlyDigits(r) && Math.isNaN(Std.parseFloat("" + r)) == false) {
                    if (Std.string(r).indexOf(".") != -1) {
                        v = Std.parseFloat("" + r);
                    } else {
                        v = Std.parseInt("" + r);
                    }
                } else if ((("" + r) == "true" || (r + "") == "false")) {
                    v = (("" + r) == "true");
                } else if ((r is String)) {
                    v = cast(r, String);
                } else {
                    #if hl
                    v = null;
                    #else
                    v = r;
                    #end
                }
            } else {
                if ((r is Component)) {
                    v = cast(r, Component);
                } else if ((r is DataSource)) {
                    v = cast r;
                } else if ((r is Array)) {
                    v = cast r;
                } else if ((r is Date)) {
                    v = cast(r, Date);
                } else if ((r is ImageData)) {
                    v = cast(r, ImageData);
                } else {
                    #if hl
                    v = null;
                    #else
                    v = r;
                    #end
                }                
            }
        }
        return v;
    }

    private static function containsOnlyDigits(s:Dynamic):Bool {
        if ((s is Component) || (s is ImageData) || (s is Array) || (s is DataSource)) {
            return false;
        }
        if ((s is Int) || (s is Float)) {
            return true;
        }

        var t:String = Std.string(s);
        for (i in 0...t.length) {
            var c = t.charAt(i);
            if (c != "0" && c != "1" && c != "2" && c != "3" && c != "4" && c != "5" && c != "6" && c != "7" && c != "8" && c != "9" && c != "." && c != "-") {
                return false;
            }
        }
        return true;
    }

    public static function toDynamic(v:Variant):Dynamic {
        var d:Dynamic = v;
        if (v != null) {
            switch (v) {
                case VariantType.VT_Int(y):            d = y;
                case VariantType.VT_Float(y):          d = y;
                case VariantType.VT_String(y):         d = y;
                case VariantType.VT_Bool(y):           d = y;
                case VariantType.VT_Array(y):          d = y;
                case VariantType.VT_Component(y):      d = y;
                case VariantType.VT_DataSource(y):     d = y;
                case VariantType.VT_Date(y):           d = y;
                case VariantType.VT_ImageData(y):      d = y;
            }
        }
        return d;
    }
}
