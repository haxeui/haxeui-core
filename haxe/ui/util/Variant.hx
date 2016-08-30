package haxe.ui.util;
import haxe.ui.data.DataSource;

enum VariantType {
    Int(s:Int);
    Float(s:Float);
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

    @:to public function toString() {
        return switch(this) {
            case String(s): s;
            case Int(s): return Std.string(s);
            case Float(s): return Std.string(s);
            case Bool(s): return Std.string(s);
            //case Dynamic(s): return Std.string(s);
            case DataSource(s): return Std.string(s);
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

    @:to function toInt() {
        return switch(this) {
            case Int(s): return s;
            case Float(s): return Std.int(s);
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

    @:to function toFloat() {
        return switch(this) {
            case Float(s): return s;
            default: throw "Variant Type Error";
        }
    }

    public var isFloat(get, never):Bool;
    private inline function get_isFloat():Bool {
        return this.match(Float(_));
    }

    // ************************************************************************************************************
    // NUMBERS
    // ************************************************************************************************************
    public var isNumber(get, never):Bool;
    private inline function get_isNumber():Bool {
        return this.match(Int(_) | Float(_));
    }

    function toNumber():Float {
        return switch(this) {
            case Int(s): return s;
            case Float(s): return s;
            default: throw "Variant Type Error";
        }
    }

    // ************************************************************************************************************
    // BOOLS
    // ************************************************************************************************************
    @:from static function fromBool(s:Bool):Variant {
        return Bool(s);
    }

    @:to function toBool() {
        return switch(this) {
            case Bool(s): return s;
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

    @:to function toDataSource() {
        return switch(this) {
            case DataSource(s): return s;
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
        if (isNumber) {
            var v = toNumber();
            v++;
            this = Float(v);
            return v;
        }
        throw "Variant operation error";
    }

    @:op(++A)
    private inline function preInc():Variant {
        if (isNumber) {
            var v = toNumber();
            ++v;
            this = Float(v);
            return v;
        }
        throw "Variant operation error";
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
        if (isNumber) {
            var v = toNumber();
            v--;
            this = Float(v);
            return v;
        }
        throw "Variant operation error";
    }

    @:op(--A)
    private inline function preDeinc():Variant {
        if (isNumber) {
            var v = toNumber();
            --v;
            this = Float(v);
            return v;
        }
        throw "Variant operation error";
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
        return toString() == null;
    }

    public static function fromDynamic(r:Dynamic):Variant {
        var v:Variant = null;
        if (r != null) {
            if (Math.isNaN(Std.parseFloat("" + r)) == false) {
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
            } else {
                v = Std.string(r);
            }
        }
        return v;
    }

    public static function toDynamic(v:Variant):Dynamic {
        var d:Dynamic = null;
        if (v != null) {
            switch (v) {
                case VariantType.Int(y):        d = y;
                case VariantType.Float(y):      d = y;
                case VariantType.String(y):     d = y;
                case VariantType.Bool(y):       d = y;
                //case VariantType.Dynamic(y):    d = y;
                case VariantType.DataSource(y):       d = y;
            }
        }
        return d;
    }
}
