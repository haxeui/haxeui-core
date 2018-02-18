package haxe.ui.core;

import haxe.ui.util.Variant;

/**
 Base class that allows property getters and setters to have overridden functionality
**/
@:allow(haxe.ui.core.Component)
class Behaviour {
    private var config:Map<String, String> = null;

    private var _component:Component;

    public function new(component:Component) {
        _component = component;
    }

    /**
     Called when a component property setter is called
    **/
    public function set(value:Variant) {

    }

    /**
     Called when a component property getter is called
    **/
    public function get():Variant {
        return null;
    }

    public function getDynamic():Dynamic {
        return null;
    }

    public function run(param:Variant = null) {
        
    }
    
    /**
     Update this behaviour with its current value
    **/
    public function update() {

    }

    /**
     Make a specific call to an operation
    **/
    public function call(id:String):Variant {
        return null;
    }

    /**
     Utility function to retrieve a string config value for this behaviour
    **/
    public function getConfigValue(name:String, defaultValue:String = null):String {
        if (config == null) {
            return defaultValue;
        }
        if (config.exists(name) == false) {
            return defaultValue;
        }
        return config.get(name);
    }

    /**
     Utility function to retrieve a boolean config value for this behaviour
    **/
    public function getConfigValueBool(name:String, defaultValue:Bool = false):Bool {
        var v:Bool = defaultValue;
        var s = getConfigValue(name);
        if (s != null) {
            v = (s == "true");
        }
        return v;
    }
}