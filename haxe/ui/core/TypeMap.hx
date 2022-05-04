package haxe.ui.core;

import haxe.ui.util.RTTI;

using StringTools;

class TypeMap {
    public static function getTypeInfo(className:String, property:String):String {
        var entry = RTTI.getClassInfo(className);
        if (entry == null) {
            var parts = className.split(".");
            var name = parts.pop();
            if (name.startsWith("Horizontal")) {
                return getTypeInfo(parts.join(".") + "." + name.substr("Horizontal".length), property);
            } else if (name.startsWith("Vertical")) {
                return getTypeInfo(parts.join(".") + "." + name.substr("Vertical".length), property);
            }
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