package haxe.ui.core;

import haxe.ui.util.Variant;

@:access(haxe.ui.core.Component)
@:access(haxe.ui.core.Behaviour)
class Behaviours {
    private var _component:Component;
    
    private var _defaults:Map<String, Behaviour> = new Map<String, Behaviour>();
    private var _behaviours:Map<String, Behaviour> = new Map<String, Behaviour>();
    
    private var _cache:Map<String, Variant> = null;
    
    public function new(component:Component) {
        _component = component;
    }

    public function defaults(behaviours:Map<String, Behaviour>) {
        for (id in behaviours.keys()) {
            _defaults.set(id, behaviours.get(id));
        }
    }
    
    public function getBehaviour(id:String):Behaviour {
        var b:Behaviour = _behaviours.get(id);
        if (b != null) {
            return b;
        }
        
        if (_component.native == true) {
            var nativeProps = _component.getNativeConfigProperties('.behaviour[id=${id}]');
            if (nativeProps != null && nativeProps.exists("class")) {
                b = Type.createInstance(Type.resolveClass(nativeProps.get("class")), [_component]);
                b.config = nativeProps;
            }
        }
        
        if (b == null) {
            b = _defaults.get(id);
        }
        
        b.id = id;
        _behaviours.set(id, b);
        return b;
    }
    
    public function detatch(clearDefaults:Bool = false) {
        for (b in _behaviours) {
            b.detatch();
        }
        _behaviours = new Map<String, Behaviour>();
        if (clearDefaults == true) {
            _defaults = new Map<String, Behaviour>();
        }
    }
    
    public function cache() {
        _cache = new Map<String, Variant>();
        for (id in _defaults.keys()) {
            _cache.set(id, _defaults.get(id).get());
        }
        for (id in _behaviours.keys()) {
            _cache.set(id, _behaviours.get(id).get());
        }
    }
    
    public function restore() {
        if (_cache == null) {
            return;
        }
        
        var order:Array<String> = _updateOrder.copy();
        for (key in _cache.keys()) {
            if (order.indexOf(key) == -1) {
                order.push(key);
            }
        }

        for (key in order) {
            var v = _cache.get(key);
            if (v != null) {
                set(key, v);
            }
        }
        
        _cache = null;
    }
    
    private var _updateOrder:Array<String> = [];
    public var updateOrder(get, set):Array<String>;
    private function get_updateOrder():Array<String> {
        return _updateOrder;
    }
    private function set_updateOrder(value:Array<String>):Array<String> {
        _updateOrder = value;
        return value;
    }
    
    public function update() {
        var order:Array<String> = _updateOrder.copy();
        for (key in _behaviours.keys()) {
            if (order.indexOf(key) == -1) {
                order.push(key);
            }
        }
        
        for (key in order) {
            var b = _behaviours.get(key);
            if (b != null) {
                b.update();
            }
        }
    }
    
    public function get(id:String):Variant {
        var b:Behaviour = getBehaviour(id);
        if (b != null) {
            return b.get();
        }
        return null;
    }
    
    public function set(id:String, value:Variant) {
        var b:Behaviour = getBehaviour(id);
        if (b != null) {
            b.set(value);
        }
    }
    
    public function call(id:String, param:Any = null):Variant {
        var r:Variant = null;
        var b:Behaviour = getBehaviour(id);
        if (b != null) {
            r = b.call(param);
        }
        return r;
    }
}