package haxe.ui.util;

class TypeConverter {
    public static function convertFrom(input:Any):Any {
        var output = input;

        // if its a string (which it always will be if coming from markup rather than code), lets try and convert it
        switch (Type.typeof(input)) {
            case TClass(String):
                var s = Std.string(input);
                if (s == "true" || s == "false") {
                    output = (s == "true");
                } else if (~/^-?[0-9]*$/i.match(Std.string(s))) {
                    output = Std.parseInt(s);
                } else if (~/^-?[0-9]*\.[0-9]*$/i.match(Std.string(s))) {
                    output = Std.parseFloat(s);
                }
            default:
                // do nothing
        }

        return output;
    }
    
    public static function convertTo(input:Any, type:String):Any {
        if (type == null) {
            return input;
        }
        switch (type.toLowerCase()) {
            case "string":
                return Std.string(input);
            case "bool":
                return Std.string(input) == "true";
            case "int":
                if (input == null) {
                    return 0;
                }
                var r = Std.parseInt(Std.string(input));
                if (r == null) {
                    return 0;
                }
                return r;
            case "float":
                if (input == null) {
                    return 0;
                }
                var r = Std.parseFloat(Std.string(input));
                if (Math.isNaN(r)) {
                    return 0;
                }
                return r;
            case "variant" | "dynamic" | "scalemode":
                return input;
            case _:
                #if debug
                trace("dont know how to convert from type '" + type + "', returning input");
                #end
        }
        
        return input;
    }
}