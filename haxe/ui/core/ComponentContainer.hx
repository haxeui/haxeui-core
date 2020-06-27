package haxe.ui.core;

import haxe.ui.behaviours.Behaviours;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.ValueBehaviour;
import haxe.ui.layouts.Layout;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;

@:build(haxe.ui.macros.Macros.buildBehaviours())
@:autoBuild(haxe.ui.macros.Macros.buildBehaviours())
class ComponentContainer extends ComponentCommon implements IClonable<ComponentContainer> {
    @:clonable @:behaviour(ComponentDisabledBehaviour, false)       public var disabled:Bool;
    
    private var behaviours:Behaviours;

    /**
     The parent component of this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public var parentComponent:Component = null;
    
    public function new() {
        super();
        behaviours = new Behaviours(cast(this, Component));
    }
    
    private var _ready:Bool = false;
    /**
     Whether the framework considers this component ready or not
    **/
    public var isReady(get, null):Bool;
    private function get_isReady():Bool {
        return _ready;
    }
    
    private var _children:Array<Component>;
    /**
     A list of this components children

     *Note*: this function will return an empty array if the component has no children
    **/
    @:dox(group = "Display tree related properties and methods")
    public var childComponents(get, null):Array<Component>;
    private inline function get_childComponents():Array<Component> {
        if (_children == null) {
            return [];
        }
        return _children;
    }
    
    private function registerBehaviours() {
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
    
    //***********************************************************************************************************
    // Layout related
    //***********************************************************************************************************
    // not idea place for them, but ComponentValidation needs them
    private var _layout:Layout = null;
    
    private var _layoutLocked:Bool = false;
    
    //***********************************************************************************************************
    // Style related
    //***********************************************************************************************************
    private var _style:Style;
    
    //***********************************************************************************************************
    // General
    //***********************************************************************************************************
    @:clonable @:behaviour(DefaultBehaviour)                        public var text:String;
    @:clonable @:behaviour(ComponentValueBehaviour)                 public var value:Dynamic;

    private var _id:String = null;
    /**
     The identifier of this component
    **/
    @:clonable public var id(get, set):String;
    private function get_id():String {
        return _id;
    }
    private function set_id(value:String):String {
        if (_id != value) {
            _id = value;
            //invalidate(InvalidationFlags.STYLE);
            //invalidateDisplay();
        }
        return _id;
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class ComponentDisabledBehaviour extends DataBehaviour {
    public override function get():Variant {
        return _component.hasClass(":disabled");
    }
    
    public override function validateData() {
        _component.disableInteractivity(_value, true, true);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class ComponentValueBehaviour extends ValueBehaviour {
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }

        _value = value;
        _component.text = value;
    }

    public override function get():Variant {
        return _value;
    }

    public override function getDynamic():Dynamic {
        return Variant.toDynamic(_value);
    }
}
