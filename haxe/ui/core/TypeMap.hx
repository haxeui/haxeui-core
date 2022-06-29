package haxe.ui.core;

import haxe.ui.util.RTTI;

using StringTools;

class TypeMap {
    public static function getTypeInfo(className:String, property:String):String {
        var propInfo = RTTI.getClassProperty(className, property);
        if (propInfo == null) {
            return null;
        }
        
        return propInfo.propertyType;
    }
}