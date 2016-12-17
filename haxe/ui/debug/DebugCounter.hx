package haxe.ui.debug;

import haxe.ui.core.Component;
import haxe.ui.util.CallStackHelper;

class DebugCounter {
    public var name:String;
    private var _counters:Map<String, Int>;
    private var _stacks:Map<String, Int>;

    public function new(name:String = null) {
        this.name = name;
        _counters = new Map<String, Int>();
        _stacks = new Map<String, Int>();
    }

    public function incrementComponent(component:Component, fn:String = null, by:Int = 1) {
        var key:String = buildComponentKey(component);
        if (fn != null) {
            key += '::${fn}';
        }
        if (_counters.exists(key) == false) {
            _counters.set(key, 0);
        }
        _counters.set(key, _counters.get(key) + by);

        var stack:String = CallStackHelper.getCallStackString();
        CallStackHelper.traceCallStack();
        if (_stacks.exists(stack) == false) {
            _stacks.set(stack, 0);
        }
        _stacks.set(stack, _stacks.get(stack) + 1);
    }

    public function list() {
        trace("--------------------------------------------------------------------------------");
        var total:Int = 0;
        for (key in _counters.keys()) {
            trace('${key} - ${_counters.get(key)}');
            total += _counters.get(key);
        }
        trace('total: ${total}');
        trace("--------------------------------------------------------------------------------");
        for (stack in _stacks.keys()) {
            trace(stack);
            trace("STACK COUNT: " + _stacks.get(stack));
            trace("--------------------------------------------------------------------------------");
        }
    }

    private function buildComponentKey(component:Component):String {
        return '${component}#${component.id}';
    }
}