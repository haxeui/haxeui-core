package haxe.ui.core;

import haxe.ui.styles.Style;
import haxe.ui.util.MathUtil;

@:keepSub
class CompositeBuilder {
    private var _component:Component;

    public function new(component:Component) {
        _component = component;
    }

    public function create() {
    }

    public function destroy() {
    }

    public function onInitialize() {
    }

    public function onReady() {
    }

    public function show():Bool {
        return false;
    }

    public function hide():Bool {
        return false;
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

    public function removeAllComponents(dispose:Bool = true):Bool {
        return false;
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

    public function validateComponentData() {
        
    }
    
    public function applyStyle(style:Style) {
    }

    public function onComponentAdded(child:Component) {
    }

    public function onComponentRemoved(child:Component) {
    }

    public function findComponent<T:Component>(criteria:String, type:Class<T>, recursive:Null<Bool>, searchType:String):Null<T> {
        for (i in 0...numComponents) {
            var c = getComponentAt(i);
            var match = c.findComponent(criteria, type, recursive, searchType);
            if (match != null) return match;
        }
        return null;
    }
    
    public function findComponents<T:Component>(styleName:String = null, type:Class<T> = null, maxDepth:Int = 5):Array<T> {
        return null;
    }
    
    public var isComponentClipped(get, null):Bool;
    private function get_isComponentClipped():Bool {
        return (_component.componentClipRect != null);
    }
}
