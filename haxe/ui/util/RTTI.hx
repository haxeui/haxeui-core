package haxe.ui.util;

typedef RTTIEntry = {
    @:optional var properties:Map<String, RTTIProperty>;
}

typedef RTTIProperty = {
    @:optional var propertyName:String;
    @:optional var propertyType:String;
}

class RTTI {
    public static var classInfo:Map<String, RTTIEntry> = null;
    
    public static function addClassProperty(className:String, propertyName:String, propertyType:String) {
        className = className.toLowerCase();
        propertyName = propertyName.toLowerCase();
        propertyType = propertyType.toLowerCase();
        
        if (propertyType == "null<bool>")   propertyType = "bool";
        if (propertyType == "null<int>")    propertyType = "int";
        if (propertyType == "null<float>")  propertyType = "float";
        
        if (classInfo == null) {
            classInfo = new Map<String, RTTIEntry>();
        }
        
        var entry = classInfo.get(className);
        if (entry == null) {
            entry = {};
            classInfo.set(className, entry);
        }
        
        if (entry.properties == null) {
            entry.properties = new Map<String, RTTIProperty>();
        }
        
        entry.properties.set(propertyName, {
            propertyName: propertyName,
            propertyType: propertyType
        });
    }
    
    public static function hasClassProperty(className:String, propertyName:String) {
        if (classInfo == null) {
            return false;
        }
        if (classInfo.exists(className)) {
            return false;
        }
        var entry = classInfo.get(className);
        if (entry == null || entry.properties == null) {
            return false;
        }
        return entry.properties.exists(propertyName);
    }
    
    public static function load() {
        if (classInfo != null) {
            return;
        }

        var s = haxe.Resource.getString("haxeui_rtti");
        if (s == null) {
            return;
        }
        
        var unserializer = new Unserializer(s);
        classInfo = unserializer.unserialize();
    }
    
    public static function getClassInfo(className:String):RTTIEntry {
        load();
        
        className = className.toLowerCase();
        
        var entry = classInfo.get(className);
        return entry;
    }
    
    public static function save() {
        #if macro
        
        var serializer = new Serializer();
        serializer.serialize(classInfo);
        var s = serializer.toString();
        haxe.macro.Context.addResource("haxeui_rtti", haxe.io.Bytes.ofString(s));
        
        #end
    }
}