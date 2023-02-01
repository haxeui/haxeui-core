package haxe.ui.validators;

import haxe.ui.core.Component;

interface IValidator {
    public var invalidMessage:String;
    public function setup(component:Component):Void;
    public function validate(component:Component):Null<Bool>;
    public function setProperty(name:String, value:Any):Void;
}