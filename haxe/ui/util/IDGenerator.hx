package haxe.ui.util;

class IDGenerator {
    private static var _counters:Map<String, Int> = new Map<String, Int>();
    
    public static function generateId(cls:Class<Dynamic>):String {
        var fullClassName = Type.getClassName(cls);
        var shortClassName = fullClassName.split(".").pop();
        var current = 0;
        if (_counters.exists(fullClassName)) {
            current = _counters.get(fullClassName) + 1;
        }
        _counters.set(fullClassName, current);
        var id = shortClassName + current;
        return id.toLowerCase();
    }
}