package haxe.ui.core;

class TypeMap {
    public static var typeInfo:Map<String, Map<String, String>> = null;
    public static function addTypeInfo(className:String, property:String, type:String) {
        if (typeInfo == null) {
            typeInfo = new Map<String, Map<String, String>>();
        }

        var classTypeMap = typeInfo.get(className);
        if (classTypeMap == null) {
            classTypeMap = new Map<String, String>();
            typeInfo.set(className, classTypeMap);
        }

        classTypeMap.set(property, type);
    }

    public static function getTypeInfo(className:String, property:String):String {
        if (typeInfo == null) {
            return null;
        }

        var classTypeMap = typeInfo.get(className);
        if (classTypeMap == null) {
            return null;
        }

        return classTypeMap.get(property);
    }
}