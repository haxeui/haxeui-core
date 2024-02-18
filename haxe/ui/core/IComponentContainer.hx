package haxe.ui.core;

interface IComponentContainer {
    public function addComponent(child:Component):Component;
    public function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component;
    public function containsComponent(child:Component):Bool;
}