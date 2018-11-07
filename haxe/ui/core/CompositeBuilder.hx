package haxe.ui.core;
import haxe.ui.styles.Style;

class CompositeBuilder {
    private var _component:Component;
    
    public function new(component:Component) {
        _component = component;
    }

    public function create() {
    }
    
    public function destroy() {
    }
    
    public var numComponents(get, never):Int;
    private function get_numComponents():Int {
        return 0;
    }
    
    public function addComponent(child:Component):Component {
        return null;
    }
    
    public function addComponentAt(child:Component, index:Int):Component {
        return null;
    }
    
    public function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        return null;
    }
    
    public function getComponentIndex(child:Component):Int {
        return -1;
    }
    
    public function setComponentIndex(child:Component, index:Int):Component {
        return null;
    }
    
    public function getComponentAt(index:Int):Component {
        return null;
    }
    
    public function validateComponentLayout():Bool {
        return false;
    }
    
    public function applyStyle(style:Style) {
        
    }
}