package haxe.ui.core;
import haxe.ui.events.UIEvent;

interface IComponentBase {
    private function mapEvent(type:String, listener:UIEvent->Void):Void;
    private function handleAddComponent(child:Component):Component;
}