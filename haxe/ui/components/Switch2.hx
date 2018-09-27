package haxe.ui.components;

import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.InteractiveComponent;

class Switch2 extends InteractiveComponent {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(DefaultBehaviour)          public var selected:Bool;
    @:clonable @:behaviour(DefaultBehaviour)          public var text:String;
    @:clonable @:behaviour(DefaultBehaviour)          public var textOn:String;
    @:clonable @:behaviour(DefaultBehaviour)          public var textOff:String;
}