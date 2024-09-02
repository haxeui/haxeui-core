package haxe.ui.util;

typedef RTTIEntry = {
    @:optional var superClass:String;
    @:optional var properties:Map<String, RTTIProperty>;
}

typedef RTTIProperty = {
    @:optional var propertyName:String;
    @:optional var propertyType:String;
}

class RTTI {
    #if haxeui_experimental_no_cache
    @:persistent
    #end
    public static var classInfo:Map<String, RTTIEntry> = null;
    
    public static function addClassProperty(className:String, propertyName:String, propertyType:String) {
        className = className.toLowerCase();
        propertyName = propertyName.toLowerCase();
        propertyType = propertyType.toLowerCase();
        
        if (propertyType == "null<bool>")   propertyType = "bool";
        if (propertyType == "null<int>")    propertyType = "int";
        if (propertyType == "null<float>")  propertyType = "float";
        if (propertyType == "null<color>")  propertyType = "color";
        
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
    
    public static function setSuperClass(className:String, superClassName:String) {
        if (classInfo == null) {
            classInfo = new Map<String, RTTIEntry>();
        }
        
        className = className.toLowerCase();
        superClassName = superClassName.toLowerCase();
        if (StringTools.startsWith(superClassName, ".")) {
            superClassName = superClassName.substr(1);
        }
        var entry = classInfo.get(className);
        if (entry == null) {
            entry = {
                properties: new Map<String, RTTIProperty>()
            };
            classInfo.set(className, entry);
        }
        entry.superClass = superClassName;
    }
    
    public static function hasSuperClass(className:String, superClassName:String) {
        load();
        className = className.toLowerCase();
        superClassName = superClassName.toLowerCase();
        if (StringTools.startsWith(superClassName, ".")) {
            superClassName = superClassName.substr(1);
        }

        var entry = classInfo.get(className);
        if (entry == null) {
            return false;
        }
        
        if (className == superClassName) {
            return true;
        }
        
        var testSuper = entry.superClass;
        while (testSuper != null) {
            if (testSuper == superClassName) {
                return true;
            }
            entry = classInfo.get(testSuper);
            if (entry == null) {
                return false;
            }
            testSuper = entry.superClass;
        }
        
        return false;
    }
    
    public static function hasClassProperty(className:String, propertyName:String) {
        var props = getClassProperties(className, false, true);
        if (props == null) {
            return false;
        }

        return props.exists(propertyName.toLowerCase());
    }
    
    public static function hasPrimitiveClassProperty(className:String, propertyName:String) {
        var props = getClassProperties(className, true, true);
        if (props == null) {
            return false;
        }

        return props.exists(propertyName.toLowerCase());
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
    
    private static var _allPropertiesCache:Map<String, Map<String, RTTIProperty>> = new Map<String, Map<String, RTTIProperty>>();
    public static function getClassProperties(className:String, primitiveOnly:Bool = false, allProperties:Bool = true):Map<String, RTTIProperty> {
        className = className.toLowerCase();

        var cacheKey = className + "_" + primitiveOnly;

        if (allProperties && _allPropertiesCache.exists(cacheKey)) {
            return _allPropertiesCache.get(cacheKey);
        }

        if (classInfo == null) {
            return null;
        }

        var entry = classInfo.get(className);
        var properties = null;
        if (entry != null) {
            properties = new Map<String, RTTIProperty>();
            for (key in entry.properties.keys()) {
                var entryProp = entry.properties.get(key);
                if (!isPrimitiveProperty(entryProp)) {
                    continue;
                }
                properties.set(key, entryProp);
            }

            var superClass = entry.superClass;
            while (superClass != null) {
                var superEntry = getClassInfo(superClass);
                if (superEntry == null) {
                    break;
                }
                for (key in superEntry.properties.keys()) {
                    var entryProp = superEntry.properties.get(key);
                    if (!isPrimitiveProperty(entryProp)) {
                        continue;
                    }
                    properties.set(key, entryProp);
                }
                superClass = superEntry.superClass;
            }
        }

        if (allProperties && properties != null) {
            _allPropertiesCache.set(cacheKey, properties);
        }

        return properties;
    }

    private static function isPrimitiveProperty(prop:RTTIProperty):Bool {
        if (prop.propertyType == "bool" || prop.propertyType == "int" || prop.propertyType == "float" || prop.propertyType == "string" || prop.propertyType == "variant" || prop.propertyType == "dynamic") {
            return true;
        }
        return false;
    }

    public static function getClassInfo(className:String):RTTIEntry {
        load();
        
        if (classInfo == null) {
            return null;
        }
        
        className = className.toLowerCase();
        
        var entry = classInfo.get(className);
        return entry;
    }
    
    public static function getClassProperty(className:String, propertyName:String):RTTIProperty {
        if (className == null || propertyName == null) //TODO: Investigate why nulls may be passed as arguments
            return null;
        
        className = className.toLowerCase();
        propertyName = propertyName.toLowerCase();
        var entry = getClassInfo(className);
        if (entry == null) {
            return null;
        }
        
        var propInfo:RTTIProperty = null;
        if (entry.properties != null && entry.properties.exists(propertyName)) {
            propInfo = entry.properties.get(propertyName);
        }
        
        if (propInfo == null && entry.superClass != null) {
            propInfo = getClassProperty(entry.superClass, propertyName);
        }
        
        return propInfo;
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
