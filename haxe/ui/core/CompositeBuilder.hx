package haxe.ui.core;

class CompositeBuilder {
    private var _component:Component;
    
    public function new(component:Component) {
        _component = component;
    }

    public function create() {
    }
    
    public function destroy() {
    }
}