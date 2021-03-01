package haxe.ui.core;

import haxe.ui.behaviours.Behaviours;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.ValueBehaviour;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.Layout;
import haxe.ui.styles.Style;
import haxe.ui.tooltips.ToolTipManager;
import haxe.ui.util.Variant;

@:build(haxe.ui.macros.Macros.buildBehaviours())
@:autoBuild(haxe.ui.macros.Macros.buildBehaviours())
class ComponentContainer extends ComponentCommon implements IClonable<ComponentContainer> {
    @:clonable @:behaviour(ComponentDisabledBehaviour)              public var disabled:Bool;
    @:clonable @:behaviour(ComponentToolTipBehaviour, null)         public var tooltip:Dynamic;
    @:clonable @:behaviour(ComponentToolTipRendererBehaviour, null) public var tooltipRenderer:Component;

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

    public function dispatch(event:UIEvent) {
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

    public function moveComponentToBack() {
        if (parentComponent == null && parentComponent.numComponents <= 1) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, 0);
    }

    public function moveComponentBackward() {
        if (parentComponent == null && parentComponent.numComponents <= 1) {
            return;
        }
        
        var index = parentComponent.getComponentIndex(cast this);
        if (index == 0) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, index - 1);
    }
    
    public function moveComponentToFront() {
        if (parentComponent == null && parentComponent.numComponents <= 1) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, parentComponent.numComponents - 1);
    }

    public function moveComponentFrontward() {
        if (parentComponent == null && parentComponent.numComponents <= 1) {
            return;
        }
        
        var index = parentComponent.getComponentIndex(cast this);
        if (index == parentComponent.numComponents - 1) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, index + 1);
    }
    
    public var bottomComponent(get, null):Component;
    private function get_bottomComponent():Component {
        if (_children == null || _children.length == 0) {
            return null;
        }
        return cast _children[0];
    }
    
    public var topComponent(get, null):Component;
    private function get_topComponent():Component {
        if (_children == null || _children.length == 0) {
            return null;
        }
        return cast _children[_children.length - 1];
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
    @:clonable @:behaviour(ComponentTextBehaviour)                  public var text:String;
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
class ComponentTextBehaviour extends DefaultBehaviour {
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }

        _value = value;

        super.set(value);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class ComponentDisabledBehaviour extends DataBehaviour {
    public function new(component:Component) {
        super(component);
        _value = false;
    }
    
    public override function validateData() {
        if (_value != null && _value.isNull == false) {
            _component.disableInteractivity(_value, true, true);
        }
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

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class ComponentToolTipBehaviour extends DataBehaviour {
    public override function validateData() {
        if (_value == null || _value.isNull) {
            ToolTipManager.instance.unregisterTooltip(_component);
        } else {
            ToolTipManager.instance.registerTooltip(_component, {
                tipData: Variant.toDynamic(_value),
                renderer: cast _component.tooltipRenderer
            });
        }
    }

    public override function setDynamic(value:Dynamic) {
        if (value == null) {
            ToolTipManager.instance.unregisterTooltip(_component);
        } else {
            ToolTipManager.instance.registerTooltip(_component, {
                tipData: value,
                renderer: cast _component.tooltipRenderer
            });
        }
    }

    public override function getDynamic():Dynamic {
        var options = ToolTipManager.instance.getTooltipOptions(_component);
        if (options == null) {
            return null;
        }
        return options.tipData;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class ComponentToolTipRendererBehaviour extends DataBehaviour {
    public override function validateData() {
        if (_value == null || _value.isNull) {
            ToolTipManager.instance.updateTooltipRenderer(_component, null);
        } else {
            ToolTipManager.instance.updateTooltipRenderer(_component, cast _value.toComponent());
        }
    }
}