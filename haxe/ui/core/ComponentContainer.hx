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

    /**
     * Whether to disable interactivity for this component or not.
     * 
     * The user can't interact with disabled components, and they don't
     * send state change events when the user tries to interact with them.
     */
    @:clonable @:behaviour(ComponentDisabledBehaviour)              public var disabled:Bool;

    /**
     * A tooltip to display near the cursor when hovering on top of this component for a while.
     * 
     * @see http://haxeui.org/explorer/#miscellaneous/tooltips
     */
    @:clonable @:behaviour(ComponentToolTipBehaviour, null)         public var tooltip:Dynamic;

    /**
     * Some sort of a "default" tooltip layout used when assigning tooltips. 
     * Might be useful when you want to use complex tooltips.
     * 
     * @see http://haxeui.org/explorer/#miscellaneous/tooltips
     */
    @:clonable @:behaviour(ComponentToolTipRendererBehaviour, null) public var tooltipRenderer:Component;

    private var behaviours:Behaviours;

    /**
        The parent component of this component instance.

        Returns `null` if this component hasn't been added yet, or just doesn't have a parent.
    **/
    @:dox(group = "Display tree related properties and methods")
    public var parentComponent:Component = null;

    public function new() {
        super();
        behaviours = new Behaviours(cast(this, Component));
    }

    public function dispatch(event:UIEvent) {
    }

    @:noCompletion private var _ready:Bool = false;
    /**
        Whether the framework considers this component ready or not.
    **/
    public var isReady(get, null):Bool;
    private function get_isReady():Bool {
        return _ready;
    }

    @:noCompletion private var _children:Array<Component>;
    /**
     *  An array of this component's children.
     *  
     *  Note: If this component has no children, and empty array is returned.
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
        if (parentComponent == null || parentComponent.numComponents <= 1) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, 0);
    }

    public function moveComponentBackward() {
        if (parentComponent == null || parentComponent.numComponents <= 1) {
            return;
        }
        
        var index = parentComponent.getComponentIndex(cast this);
        if (index == 0) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, index - 1);
    }
    
    public function moveComponentToFront() {
        if (parentComponent == null || parentComponent.numComponents <= 1) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, parentComponent.numComponents - 1);
    }

    public function moveComponentFrontward() {
        if (parentComponent == null || parentComponent.numComponents <= 1) {
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
    
    private function postCloneComponent(c:Component):Void {
    }
    
    //***********************************************************************************************************
    // Layout related
    //***********************************************************************************************************
    // not idea place for them, but ComponentValidation needs them
    @:noCompletion private var _layout:Layout = null;

    @:noCompletion private var _layoutLocked:Bool = false;

    //***********************************************************************************************************
    // Style related
    //***********************************************************************************************************
    @:noCompletion private var _style:Style = null;

    //***********************************************************************************************************
    // General
    //***********************************************************************************************************
    @:clonable @:behaviour(ComponentTextBehaviour)                  public var text:String;
    @:clonable @:behaviour(ComponentValueBehaviour)                 public var value:Dynamic;

    @:noCompletion private var _id:String = null;
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
class ComponentDisabledBehaviour extends DefaultBehaviour {
    public function new(component:Component) {
        super(component);
        _value = false;
    }
    
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }
        _value = value;
        if (value != null && value.isNull == false) {
            _component.disableInteractivity(value, true, true);
        }
    }
    
    public override function get():Variant {
        return _component.hasClass(":disabled");
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
        ToolTipManager.instance.unregisterTooltip(_component);
        if (value != null) {
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
