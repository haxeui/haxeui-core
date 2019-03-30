package haxe.ui.core;
import haxe.ui.styles.Style;
import haxe.ui.util.MathUtil;

class CompositeBuilder {
    private var _component:Component;
    
    public function new(component:Component) {
        _component = component;
    }

    public function create() {
    }
    
    public function destroy() {
    }
    
    public var numComponents(get, never):Null<Int>;
    private function get_numComponents():Null<Int> {
        return null;
    }
    
    public var cssName(get, never):String;
    private function get_cssName():String {
        return null;
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
    
    public function removeComponentAt(index:Int, dispose:Bool = true, invalidate:Bool = true):Component {
        return null;
    }
    
    public function getComponentIndex(child:Component):Int {
        return MathUtil.MIN_INT;
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
    
    public function onComponentAdded(child:Component) {
    }
    
    public function onComponentRemoved(child:Component) {
    }
}