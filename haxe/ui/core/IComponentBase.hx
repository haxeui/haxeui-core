package haxe.ui.core;

interface IComponentBase {
    private function mapEvent(type:String, listener:UIEvent->Void):Void;
    private function handleAddComponent(child:Component):Component;
}