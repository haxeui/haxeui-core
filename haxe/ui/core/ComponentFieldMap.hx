package haxe.ui.core;

class ComponentFieldMap {
    private static var MAP:Map<String, String> = [
        "group" => "componentGroup",
        "contentLayout" => "contentLayoutName"
    ];

    public static inline function mapField(name:String):String {
        if (MAP.exists(name)) {
            return MAP.get(name);
        }
        return name;
    }
}