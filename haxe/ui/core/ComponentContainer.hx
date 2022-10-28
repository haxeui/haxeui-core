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

    /**
     * Creates a new `ComponentContainer`.
     */
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

    private function registerBehaviours() {}

    /**
     * Adds a component to the end of this component's display list.
     * 
     * If this component already has children, the given component is added in front of the other children.
     * 
     * @param child The child component to add to this component.
     * @return The added component.
     */
    public function addComponent(child:Component):Component {
        return null;
    }

    /**
     * Inserts a child component after `index` children, effectively adding it "in front" of `index` children, and "behind" the rest.
     * 
     * If `index` is below every other child's index, the added component will render behind this component's children.  
     * If `index` is above every other child's index, the added component will render in front of this component's children.
     * 
     * For example, inserting a child into a `VBox` at `index = 0` will place it at the top, "behind" all other children
     * 
     * @param child The child component to add to this component.
     * @param index The index at which the child component should be added.
     * @return The added component.
     */
    public function addComponentAt(child:Component, index:Int):Component {
        return null;
    }

    /**
     * Removes a child component from this component's display list, and returns it.
     * 
     * @param child The child component to remove from this component.
     * @param dispose Decides whether or not the child component should be destroyed too.
     * @param invalidate If `true`, the child component updates itself after the removal.
     * @return The removed child component
     */
    public function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        return null;
    }

    /**
     * Removes the child component at index `index` from this component's display list, and returns it.
     * 
     * @param index The index of the child component to remove from this component.
     * @param dispose Decides whether or not the child component should be destroyed too.
     * @param invalidate If `true`, the child component updates itself after the removal.
     * @return The removed child component
     */
    public function removeComponentAt(index:Int, dispose:Bool = true, invalidate:Bool = true):Component {
        return null;
    }

    /**
     * Sets this component's z-index to `0`, 
     * effectively putting it behind every single one of the parent's children.
     */
    public function moveComponentToBack() {
        if (parentComponent == null || parentComponent.numComponents <= 1) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, 0);
    }

    /**
     * Moves this component behind the child component behind it.
     */
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
    
    /**
     * Sets this component's z-index to `parentComponent.numComponents - 1`, 
     * effectively putting it after in front of every single one of the parent's children.
     */
    public function moveComponentToFront() {
        if (parentComponent == null || parentComponent.numComponents <= 1) {
            return;
        }
        
        parentComponent.setComponentIndex(cast this, parentComponent.numComponents - 1);
    }

    /**
     * Moves this component to the front of the child component in front of it.
     */
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
    
    /**
     * Gets the child component at the bottom of this component
     */
    public var bottomComponent(get, null):Component;
    private function get_bottomComponent():Component {
        if (_children == null || _children.length == 0) {
            return null;
        }
        return cast _children[0];
    }
    
    /**
     * Gets the child component at the top of this component
     */
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

    /**
     * The text displayed inside this component.
     */
    @:clonable @:behaviour(ComponentTextBehaviour)                  public var text:String;
    /**
     * The text displayed inside the label.
     * 
     * `value` is used as a universal way to access the "core" value a component is based on. 
     * in this case, its the component's text.
     */
    @:clonable @:behaviour(ComponentValueBehaviour)                 public var value:Dynamic;

    @:noCompletion private var _id:String = null;
    /**
     * This component's identifier.
     */
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
