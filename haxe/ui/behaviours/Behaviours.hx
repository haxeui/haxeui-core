package haxe.ui.behaviours;

import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Variant;

typedef BehaviourInfo = {
    var id:String;
    var cls:Class<Behaviour>;
    @:optional var defaultValue:Variant;
    @:optional var config:Map<String, String>;
    var isSet:Bool;
}

@:access(haxe.ui.core.Component)
@:access(haxe.ui.behaviours.Behaviour)
class Behaviours {
    private var _component:Component;
    
    private var _registry:Map<String, BehaviourInfo> = new Map<String, BehaviourInfo>();
    private var _instances:Map<String, Behaviour> = new Map<String, Behaviour>();
    
    public function new(component:Component) {
        _component = component;
    }
    
    public function register(id:String, cls:Class<Behaviour>, defaultValue:Variant = null) {
        var info:BehaviourInfo = {
            id: id,
            cls: cls,
            defaultValue: defaultValue,
            isSet: false
        }
        
        _registry.set(id, info);
        _updateOrder.remove(id);
        _updateOrder.push(id);
        _actualUpdateOrder = null;
    }
    
    public function isRegistered(id:String):Bool {
        return _registry.exists(id);
    }
    
    public function replaceNative() {
        if (_component.native == false || _component.hasNativeEntry == false) {
            return;
        }
        
        var ids = [];
        for (id in _registry.keys()) { // make a copy of ids as we might end up modifying the iterator
            ids.push(id);
        } 
        for (id in ids) {
            var nativeProps = _component.getNativeConfigProperties('.behaviour[id=${id}]');
            if (nativeProps != null && nativeProps.exists("class")) {
                var registered = _registry.get(id);
                var info:BehaviourInfo = {
                    id: id,
                    cls: cast Type.resolveClass(nativeProps.get("class")),
                    defaultValue: registered.defaultValue,
                    config: nativeProps,
                    isSet: false
                }
                _registry.set(id, info);
            } else {
                #if debug
                //trace("WARNING: no native behaviour found for " + Type.getClassName(Type.getClass(_component)) + "::" + id + ", using DefaultBehaviour");
                #end
                /*
                var registered = _registry.get(id);
                var info:BehaviourInfo = {
                    id: id,
                    cls: DefaultBehaviour,
                    defaultValue: registered.defaultValue,
                    config: new Map<String, String>(),
                    isSet: false
                }
                _registry.set(id, info);
                */
            }
        }
    }
    
    public function validateData() {
        for (key in actualUpdateOrder) {
            var b = _instances.get(key);
            if (Std.is(b, DataBehaviour)) {
                cast(b, DataBehaviour).validate();
            }
        }
    }
    
    private var _updateOrder:Array<String> = [];
    public var updateOrder(get, set):Array<String>;
    private function get_updateOrder():Array<String> {
        return _updateOrder;
    }
    private function set_updateOrder(value:Array<String>):Array<String> {
        _updateOrder = value;
        _actualUpdateOrder = null;
        return value;
    }
    
    private var _actualUpdateOrder:Array<String> = null;
    private var actualUpdateOrder(get, null):Array<String>;
    private function get_actualUpdateOrder():Array<String> {
        if (_actualUpdateOrder == null) {
            _actualUpdateOrder = _updateOrder.copy();
            for (key in _instances.keys()) {
                if (_actualUpdateOrder.indexOf(key) == -1) {
                    _actualUpdateOrder.push(key);
                }
            }
        }
        return _actualUpdateOrder;
    }
    
    public function update() {
        for (key in actualUpdateOrder) {
            var b = _instances.get(key);
            if (b != null) {
                b.update();
            }
        }
    }
    
    public function find(id, create:Bool = true):Behaviour {
        var b = _instances.get(id);
        if (b == null && create == true) {
            var info = _registry.get(id);
            if (info != null) {
                b = Type.createInstance(info.cls, [_component]);
                if (b != null) {
                    b.config = info.config;
                    b.id = id;
                    _instances.set(id, b);
                    _actualUpdateOrder = null;
                } else {
                    trace("WARNING: problem creating behaviour class '" + info.cls +"' for '" + Type.getClassName(Type.getClass(_component)) + ":" + id + "'");
                }
            }
        }

        if (b == null) {
            throw 'behaviour ${id} not found';
        }
        
        return b;
    }
    
    private var _cache:Map<String, Variant>;
    public function cache() {
        _cache = new Map<String, Variant>();
        for (registeredKey in _registry.keys()) {
            var v = _registry.get(registeredKey).defaultValue;
            var instance = _instances.get(registeredKey);
            if (instance != null) {
                v = instance.get();
            }
            if (v != null) {
                _cache.set(registeredKey, v);
            }
        }
    }

    public function detatch() {
        for (b in _instances) {
            b.detatch();
        }
        _instances = new Map<String, Behaviour>();
    }
    
    public function restore() {
        if (_cache == null) {
            return;
        }
        
        for (key in actualUpdateOrder) {
            var v = _cache.get(key);
            if (v != null) {
                set(key, v);
            }
        }
        
        _cache = null;
    }
    
    private function lock() {
    }
    
    private function unlock() {
    }
    
    public function set(id:String, value:Variant) {
        lock();
        var b = find(id);
        var changed:Null<Bool> = null;
        if (Std.is(b, ValueBehaviour)) {
            var v = @:privateAccess cast(b, ValueBehaviour)._value;
            changed = (v != value);
        }
        
        b.set(value);
        var info = _registry.get(id);
        info.isSet = true;
        
        unlock();
            
        var autoDispatch = b.getConfigValue("autoDispatch", null);
        if (autoDispatch != null) {
            var arr = autoDispatch.split(".");
            var eventName = arr.pop().toLowerCase();
            var cls = arr.join(".");
            
            #if hxcs // hxcs issue
            var event:UIEvent = Type.createInstance(Type.resolveClass(cls), [null]);
            event.type = eventName;
            #else
            var event = Type.createInstance(Type.resolveClass(cls), [eventName]);
            #end
            
            if (eventName != UIEvent.CHANGE) {
                b._component.dispatch(event);  
            } else if (changed == true || changed == null) {
                b._component.dispatch(event);
            }
        }
    }
    
    public function get(id):Variant {
        lock();
        
        var b = find(id);
        var v = null;
        if (b != null) {
            var info = _registry.get(id);
            if (info.isSet == false && info.defaultValue != null && Type.getClass(b) == haxe.ui.behaviours.DefaultBehaviour) {
                v = info.defaultValue;
            } else {
                v = b.get();
            }
        }
        
        unlock();
        return v;
    }
    
    public function getDynamic(id):Dynamic {
        lock();
        
        var b = find(id);
        var v = null;
        if (b != null) {
            v = b.getDynamic();
        }
        
        unlock();
        return v;
    }
    
    public function call(id, param:Any = null):Variant {
        return find(id).call(param);
    }
    
    public function applyDefaults() {
        var order:Array<String> = _updateOrder.copy();
        for (key in _registry.keys()) {
            if (order.indexOf(key) == -1) {
                order.push(key);
            }
        }
        
        for (key in order) {
            var r = _registry.get(key);
            if (r.defaultValue != null) {
                set(key, r.defaultValue);
            }
        }
    }
}

