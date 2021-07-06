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
        }
        
        return input;
    }
}