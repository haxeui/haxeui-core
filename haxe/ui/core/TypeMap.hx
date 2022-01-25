package haxe.ui.core;

import haxe.ui.util.RTTI;

class TypeMap {
    public static function getTypeInfo(className:String, property:String):String {
        var entry = RTTI.getClassInfo(className);
        if (entry == null) {
            return null;
        }
        
        if (entry.properties == null) {
            return null;
        }
        
        var propInfo = entry.properties.get(property.toLowerCase());
        if (propInfo == null) {
            return null;
        }
        
        return propInfo.propertyType;
    }
}