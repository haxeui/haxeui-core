package haxe.ui.util;

import haxe.ui.core.Component;
import haxe.ui.data.DataSource;

enum VariantType {
    Int(s:Int);
    Float(s:Float);
    String(s:String);
    Bool(s:Bool);
    DataSource(s:DataSource<Dynamic>);
    Component(s:Component);
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
            case Bool(s): Std.string(s);
            case Component(s): Std.string(s);
            case DataSource(s): Std.string(s);
            default: throw "Variant Type Error";
        }
    }

    public var isString(get, never):Bool;
    private function get_isString():Bool {
        return this.match(String(_));
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
            case Int(s): s;
            case Float(s): Std.int(s);
            default: throw "Variant Type Error";
        }
    }

    public var isFloat(get, never):Bool;
    private inline function get_isFloat():Bool {
        return this.match(Float(_));
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
            default: throw "Variant Type Error";
        }
    }

    public var isInt(get, never):Bool;
    private inline function get_isInt():Bool {
        return this.match(Int(_));
    }

    // ************************************************************************************************************
    // NUMBERS
    // ************************************************************************************************************
    public var isNumber(get, never):Bool;
    private inline function get_isNumber():Bool {
        return this.match(Int(_) | Float(_));
    }

    function toNumber():Float {
        return switch (this) {
            case Int(s): s;
            case Float(s): s;
            default: throw "Variant Type Error";
        }
    }

    // ************************************************************************************************************
    // BOOLS
    // ************************************************************************************************************
    @:from static function fromBool(s:Bool):Variant {
        return Bool(s);
    }

    @:to public function toBool():Bool {
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
        return false;
    }

    // ************************************************************************************************************
    // COMPONENT
    // ************************************************************************************************************
    @:from static function fromComponent(s:Component):Variant {
        return Component(s);
    }

    @:to function toComponent():Component {
        return switch (this) {
            case Component(s): s;
            default: throw "Variant Type Error";
        }
    }

    public var isComponent(get, never):Bool;
    private function get_isComponent():Bool {
        switch (this) {
            case Component(_): return true;
            default:
        }
        return false;
    }

    // ************************************************************************************************************
    // DATA SOURCE
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
        return if (isNumber) {
            var old = this;
            this = Float(toNumber()+1);
            old;
        } else {
            throw "Variant operation error";
        }
    }

    @:op(++A)
    private inline function preInc():Variant {
        return if (isNumber) {
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
        return if (isNumber) {
            var old = this;
            this = Float(toNumber()-1);
            old;
        } else {
            throw "Variant operation error";
        }
    }

    @:op(--A)
    private inline function preDeinc():Variant {
        return if (isNumber) {
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
            } else if (Std.is(r, Component)) {
                v =  cast r;
            } else if (Std.is(r, DataSource)) {
                v =  cast r;
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
                case VariantType.Int(y):            d = y;
                case VariantType.Float(y):          d = y;
                case VariantType.String(y):         d = y;
                case VariantType.Bool(y):           d = y;
                case VariantType.Component(y):      d = y;
                case VariantType.DataSource(y):     d = y;
            }
        }
        return d;
    }
}
