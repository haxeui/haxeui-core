package haxe.ui.backend;

import haxe.ui.backend.ComponentSurface;
import haxe.ui.behaviours.Behaviours;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.ValueBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.IClonable;
import haxe.ui.core.IComponentContainer;
import haxe.ui.core.IEventDispatcher;
import haxe.ui.core.IScroller;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.Screen;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.events.EventType;
import haxe.ui.events.Events;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;
import haxe.ui.geom.Rectangle;
import haxe.ui.layouts.Layout;
import haxe.ui.styles.Style;
import haxe.ui.tooltips.ToolTipManager;
import haxe.ui.util.EventMap;
import haxe.ui.util.FunctionArray;
import haxe.ui.util.Variant;
import haxe.ui.validation.InvalidationFlags;
import haxe.ui.validation.ValidationManager;

@:build(haxe.ui.macros.Macros.buildBehaviours())
@:autoBuild(haxe.ui.macros.Macros.buildBehaviours())
@:build(haxe.ui.macros.Macros.build())
@:autoBuild(haxe.ui.macros.Macros.build())
class ComponentBase extends ComponentSurface implements IClonable<ComponentBase> implements IEventDispatcher<UIEvent> implements IComponentContainer {
    /**
     * Creates a new `ComponentContainer`.
     */
     public function new() {
        super();
        behaviours = new Behaviours(cast(this, Component));
    }

    //***********************************************************************************************************
    // Behaviours
    //***********************************************************************************************************
    /**
    * The text displayed inside this component.
    */
    @:clonable @:behaviour(ComponentTextBehaviour)                  public var text:String;
    
    /**
    * `value` is used as a universal way to access the "core" value a component is based on. 
    *  For example, in a label component, it will be the text.
    */
    @:clonable @:behaviour(ComponentValueBehaviour)                 public var value:Dynamic;

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
 
    private function registerBehaviours() {}

    //***********************************************************************************************************
    // General
    //***********************************************************************************************************
    @:noCompletion private var _componentReady:Bool = false;
    /**
         Whether the framework considers this component ready or not.
     **/
    public var isReady(get, null):Bool;
    private function get_isReady():Bool {
        return _componentReady;
    }
 
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

    //***********************************************************************************************************
    // Display Tree
    //***********************************************************************************************************
     /**
         The parent component of this component instance.
 
         Returns `null` if this component hasn't been added yet, or just doesn't have a parent.
     **/
    private var _parentComponent:Component = null;
    @:dox(group = "Display tree related properties and methods")
    public var parentComponent(get, set):Component;
    @:noCompletion
    private function get_parentComponent():Component {
        return _parentComponent;
    }
    @:noCompletion
    private function set_parentComponent(value:Component):Component {
        _parentComponent = value;
        if (value != null) {
            onParentComponentSet();
        }
        return value;
    }
 

    private function onParentComponentSet() {

    }

    @:noCompletion
    private var isInScroller(get, null):Bool;
    @:noCompletion
    private function get_isInScroller():Bool {
        var scroller = findScroller();
        if (scroller == null) {
            return false;
        }

        return scroller.isScrollable;
    }

    @:noCompletion
    private function findScroller():IScroller {
        var view:IScroller = null;
        var ref:ComponentBase = this;
        while (ref != null) {
            if ((ref is IScroller)) {
                view = cast(ref, IScroller);
                break;
            }
            ref = ref.parentComponent;
        }
        return view;
    }

    public function containsChildComponent(child:Component, recursive:Bool = false):Bool {
        var contains = (_children != null && _children.indexOf(child) != -1);
        if (recursive && !contains && _children != null) {
            for (c in _children) {
                contains = c.containsChildComponent(child, recursive);
                if (contains) {
                    break;
                }
            }
        }
        return contains;
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
 
     public function containsComponent(child:Component):Bool {
         return false;
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
    // Events
    //***********************************************************************************************************
    @:noCompletion private var _internalEvents:Events = null;
    @:noCompletion private var _internalEventsClass:Class<Events> = null;
    private function registerInternalEvents(eventsClass:Class<Events> = null, reregister:Bool = false) {
        if (_internalEvents == null && eventsClass != null) {
            _internalEvents = Type.createInstance(eventsClass, [this]);
            _internalEvents.register();
        } if (reregister == true && _internalEvents != null) {
            _internalEvents.register();
        }
    }
    private function unregisterInternalEvents() {
        if (_internalEvents == null) {
            return;
        }
        _internalEvents.unregister();
        _internalEvents = null;
    }

    @:noCompletion private var __events:EventMap;

    /**
     Register a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function registerEvent<T:UIEvent>(type:EventType<T>, listener:T->Void, priority:Int = 0) {
        if (cast(this, Component).hasClass(":mobile")
            // TODO: would be nice not to have the Std.string, and really, would make sense to review 
            // the whole concept of "block over / out if mobile"
            && (Std.string(type) == Std.string(MouseEvent.MOUSE_OVER) || Std.string(type) == Std.string(MouseEvent.MOUSE_OUT))) {
            return;
        }

        if (disabled == true && isInteractiveEvent(type) == true) {
            if (_disabledEvents == null) {
                _disabledEvents = new EventMap();
            }
            _disabledEvents.add(type, listener, priority);
            return;
        }

        if (__events == null) {
            __events = new EventMap();
        }
        if (__events.add(type, listener, priority) == true) {
            mapEvent(type, _onMappedEvent);
        }
        checkWatchForMoveEvents();
    }

    /**
     Returns if this component has a certain event and listener
    **/
    @:dox(group = "Event related properties and methods")
    public function hasEvent<T:UIEvent>(type:EventType<T>, listener:T->Void = null):Bool {
        if (__events == null) {
            return false;
        }
        return __events.contains(type, listener);
    }

    /**
     Unregister a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function unregisterEvent<T:UIEvent>(type:EventType<T>, listener:T->Void) {
        if (_disabledEvents != null && !_interactivityDisabled) {
            _disabledEvents.remove(type, listener);
        }

        if (__events != null) {
            if (__events.remove(type, listener) == true) {
                unmapEvent(type, _onMappedEvent);
            }
            checkWatchForMoveEvents();
        }
    }

    /**
     Unregister a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function unregisterEvents<T:UIEvent>(type:EventType<T>) {
        if (_disabledEvents != null && !_interactivityDisabled) {
            _disabledEvents.removeAll(type);
        }

        if (__events != null) {
            __events.removeAll(type);
            unmapEvent(type, _onMappedEvent);
        }
    }

    /**
     Dispatch a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function dispatch<T:UIEvent>(event:T, target:Component = null) {
        if (_pausedEvents != null && _pausedEvents.indexOf(event.type) != -1) {
            return;
        }
        if (event != null) {
            if (__events != null) {
                __events.invoke(event.type, event, cast(this, Component));  // TODO: avoid cast
            }

            if (event.bubble == true && event.canceled == false && parentComponent != null) {
                parentComponent.dispatch(event);
            }
        }
    }

    private function dispatchRecursively<T:UIEvent>(event:T) {
        dispatch(event);
        for (child in childComponents) {
            child.dispatchRecursively(event);
        }
    }

    public function removeAllListeners() {
        if (__events != null) {
            __events.removeAll();
        }
    }

    private function dispatchRecursivelyWhen<T:UIEvent>(event:T, condition:Component->Bool) {
        if (condition(cast this) == true) {
            dispatch(event);
        }
        for (child in childComponents) {
            if (condition(child) == true) {
                child.dispatchRecursivelyWhen(event, condition);
            }
        }
    }
    
    @:noCompletion 
    private function checkWatchForMoveEvents() {
        if (hasEvent(MouseEvent.MOUSE_OVER) || hasEvent(MouseEvent.MOUSE_OUT)) {
            if (!hasEvent(UIEvent.MOVE, _onMoveInternal)) {
                registerEvent(UIEvent.MOVE, _onMoveInternal);
            }
        }
    }

    @:noCompletion 
    private function _onMoveInternal(_) {
        checkComponentBounds();
    }

    @:noCompletion 
    private function checkComponentBounds(checkNextFrame:Bool = true) {
        if (Screen.instance.currentMouseX == null || Screen.instance.currentMouseY == null) {
            return;
        }
        // is it valid to assume it must have :hover?
        var hasHover = cast(this, Component).hasClass(":hover"); // TODO: might want to move "hasClass" et al to this class to avoid cast
        if (!hasHover && screenBounds.containsPoint(Screen.instance.currentMouseX, Screen.instance.currentMouseY)) {
            var mouseEvent = new MouseEvent(MouseEvent.MOUSE_OVER);
            mouseEvent.screenX = Screen.instance.currentMouseX;
            mouseEvent.screenY = Screen.instance.currentMouseY;
            dispatch(mouseEvent);
        } else if (hasHover && !screenBounds.containsPoint(Screen.instance.currentMouseX, Screen.instance.currentMouseY)) {
            var mouseEvent = new MouseEvent(MouseEvent.MOUSE_OUT);
            mouseEvent.screenX = Screen.instance.currentMouseX;
            mouseEvent.screenY = Screen.instance.currentMouseY;
            dispatch(mouseEvent);
        }

        if (checkNextFrame) { // find any stragglers
            Toolkit.callLater(function() {
                checkComponentBounds(false);
            });
        }
    }

    @:noCompletion 
    private function _onMappedEvent<T:UIEvent>(event:T) {
        dispatch(event);
    }

    @:noCompletion private var _disabledEvents:EventMap;
    private static var INTERACTIVE_EVENTS:Array<String> = [
        MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT, MouseEvent.MOUSE_DOWN,
        MouseEvent.MOUSE_UP, MouseEvent.MOUSE_WHEEL, MouseEvent.CLICK, MouseEvent.DBL_CLICK, KeyboardEvent.KEY_DOWN,
        KeyboardEvent.KEY_UP
    ];

    private function isInteractiveEvent(type:String):Bool {
        return INTERACTIVE_EVENTS.indexOf(type) != -1;
    }

    private function disableInteractiveEvents(disable:Bool) {
        if (disable == true) {
            if (__events != null) {
                for (eventType in __events.keys()) {
                    if (!isInteractiveEvent(eventType)) {
                        continue;
                    }
                    var listeners:FunctionArray<UIEvent->Void> = __events.listeners(eventType);
                    if (listeners != null) {
                        for (listener in listeners.copy()) {
                            if (_disabledEvents == null) {
                                _disabledEvents = new EventMap();
                            }
                            _disabledEvents.add(eventType, listener);
                            unregisterEvent(eventType, listener);
                        }
                    }
                }
            }
        } else {
            if (_disabledEvents != null) {
                for (eventType in _disabledEvents.keys()) {
                    var listeners:FunctionArray<UIEvent->Void> = _disabledEvents.listeners(eventType);
                    if (listeners != null) {
                        for (listener in listeners.copy()) {
                            registerEvent(eventType, listener);
                        }
                    }
                }
                _disabledEvents = null;
            }
        }
    }
    
    @:noCompletion private var _interactivityDisabled:Bool = false;
    @:noCompletion private var _interactivityDisabledCounter:Int = 0;
    #if haxeui_html5
    private var _lastCursor:String = null;
    #end
    private function disableInteractivity(disable:Bool, recursive:Bool = true, updateStyle:Bool = false, force:Bool = false) { // You might want to disable interactivity but NOT actually disable visually
        if (force == true) {
            _interactivityDisabledCounter = 0;
        }
        if (disable == true) {
            _interactivityDisabledCounter++;
        } else {
            _interactivityDisabledCounter--;
        }

        if (_interactivityDisabledCounter > 0 && _interactivityDisabled == false) {
            _interactivityDisabled = true;
            if (updateStyle == true) {
                cast(this, Component).swapClass(":disabled", ":hover");
            }
            handleDisabled(true);
            disableInteractiveEvents(true);
            dispatch(new UIEvent(UIEvent.DISABLED));
            #if haxeui_html5
            _lastCursor = cast(this, Component).element.style.cursor;
            cast(this, Component).element.style.removeProperty("cursor");
            #end
        } else if (_interactivityDisabledCounter < 1 && _interactivityDisabled == true) {
            _interactivityDisabled = false;
            if (updateStyle == true) {
                cast(this, Component).removeClass(":disabled");
            }
            handleDisabled(false);
            disableInteractiveEvents(false);
            dispatch(new UIEvent(UIEvent.ENABLED));
            #if haxeui_html5
            if (_lastCursor != null) {
                cast(this, Component).element.style.cursor = _lastCursor;
            }
            #end
        }

        if (recursive == true) {
            for (child in childComponents) {
                child.disableInteractivity(disable, recursive, updateStyle);
            }
        }
    }

    private function unregisterEventsInternal() {
        if (__events != null) {
            var copy:Array<String> = [];
            for (eventType in __events.keys()) {
                copy.push(eventType);
            }
            for (eventType in copy) {
                var listeners = __events.listeners(eventType);
                if (listeners != null) {
                    for (listener in listeners) {
                        if (listener != null) {
                            if (__events.remove(eventType, listener) == true) {
                                unmapEvent(eventType, _onMappedEvent);
                            }
                        }
                    }
                }
            }
        }
    }

    @:noCompletion private var _pausedEvents:Array<String> = null;
    public function pauseEvent(type:String, recursive:Bool = false) {
        if (_pausedEvents == null) {
            _pausedEvents = [];
        }
        if (_pausedEvents.indexOf(type) == -1) {
            _pausedEvents.push(type);
        }
        
        if (recursive == true) {
            for (c in childComponents) {
                c.pauseEvent(type, recursive);
            }
        }
    }
    
    public function resumeEvent(type:String, nextFrame:Bool = false, recursive:Bool = false) {
        if (nextFrame) {
            Toolkit.callLater(function() {
                resumeEvent(type, false, recursive);
            });
        } else {
            if (_pausedEvents != null && _pausedEvents.indexOf(type) != -1) {
                _pausedEvents.remove(type);
            }

            if (recursive == true) {
                for (c in childComponents) {
                    c.resumeEvent(type, false, recursive);
                }
            }
        }
    }
    
    //***********************************************************************************************************
    // Layout related
    //***********************************************************************************************************
    // not idea place for them, but ComponentValidation needs them
    @:noCompletion private var _layout:Layout = null;

    @:noCompletion private var _layoutLocked:Bool = false;

    //***********************************************************************************************************
    // Size related
    //***********************************************************************************************************

    /**
     * When enabled, this component will automatically resize itself based on it's children's calculated width.
     * 
     * For example, if this component's padding is `5`, and it has one child, `150` pixels wide, 
     * and `autoWidth` is set to `true`, this component's width should be `160`
     */
     @:dox(group = "Size related properties and methods")
     public var autoWidth(get, null):Bool;
     private function get_autoWidth():Bool {
         if (_percentWidth != null || _width != null) {
             return false;
         }
         
         if (style == null) {
             return true;
         }
         
         if (style.autoWidth == null) {
             return false;
         }
         return style.autoWidth;
     }
 
     /**
      * When enabled, this component will automatically resize itself based on it's children's calculated height.
      * 
      * For example, if this component's padding is `5`, and it has one child, `200` pixels tall, 
      * and `autoHeight` is set to `true`, this component's height should be `210`
      */
     @:dox(group = "Size related properties and methods")
     public var autoHeight(get, null):Bool;
     private function get_autoHeight():Bool {
         if (_percentHeight != null || _height  != null || style == null) {
             return false;
         }
         if (style.autoHeight == null) {
             return false;
         }
         return style.autoHeight;
     }
 
     /**
      * Resizes a component to be `w` pixels wide and `h` pixels tall.
      * 
      * Useful if you want to resize the component in both the X & Y axis, 
      * and don't want to call the resizing logic twice.
      * @param w The component's new width.
      * @param h The component's new height.
      */
     @:dox(group = "Size related properties and methods")
     public function resizeComponent(w:Null<Float>, h:Null<Float>) {
         var invalidate:Bool = false;
 
         if (w != null && _componentWidth != w) {
             _componentWidth = w;
             invalidate = true;
         }
 
         if (h != null && _componentHeight != h) {
             _componentHeight = h;
             invalidate = true;
         }
 
         if (invalidate == true && isComponentInvalid(InvalidationFlags.LAYOUT) == false) {
             invalidateComponentLayout();
         }
     }
 
     /**
      * The component's true width on screen. 
      * 
      * May differ from `componentWidth` if `Toolkit.scaleX != 1` 
      */
     public var actualComponentWidth(get, null):Float;
     private function get_actualComponentWidth():Float {
         return componentWidth * Toolkit.scaleX;
     }
 
     /**
      * The component's true height on screen. 
      * 
      * May differ from `componentHeight` if `Toolkit.scaleY != 1` 
      */
     public var actualComponentHeight(get, null):Float;
     private function get_actualComponentHeight():Float {
         return componentHeight * Toolkit.scaleY;
     }
 
     @:noCompletion private var _componentWidth:Null<Float>;
     @:allow(haxe.ui.layouts.Layout)
     @:allow(haxe.ui.core.Screen)
 
     /**
      * This component's calculated width.
      */
     @:dox(group = "Size related properties and methods")
     @:clonable private var componentWidth(get, set):Null<Float>;
     private function get_componentWidth():Null<Float> {
         if (_componentWidth == null) {
             return 0;
         }
         return _componentWidth;
     }
     private function set_componentWidth(value:Null<Float>):Null<Float> {
         resizeComponent(value, null);
         return value;
     }
 
     @:noCompletion private var _componentHeight:Null<Float>;
     @:allow(haxe.ui.layouts.Layout)
     @:allow(haxe.ui.core.Screen)
 
     /**
      * This component's calculated height.
      */
     @:dox(group = "Size related properties and methods")
     @:clonable private var componentHeight(get, set):Null<Float>;
     private function get_componentHeight():Null<Float> {
         if (_componentHeight == null) {
             return 0;
         }
         return _componentHeight;
     }
     private function set_componentHeight(value:Null<Float>):Null<Float> {
         resizeComponent(null, value);
         return value;
     }
 
     @:noCompletion private var _percentWidth:Null<Float>;
 
     /**
      * When set, sets this component's width to be `percentWidth`% percent of it's parent's width.
      */
     @:dox(group = "Size related properties and methods")
     @clonable @bindable public var percentWidth(get, set):Null<Float>;
     private function get_percentWidth():Null<Float> {
         return _percentWidth;
     }
     private function set_percentWidth(value:Null<Float>):Null<Float> {
         if (_percentWidth == value) {
             return value;
         }
 
         _percentWidth = value;
 
         if (parentComponent != null) {
             parentComponent.invalidateComponentLayout();
         } else {
             Screen.instance.resizeRootComponents();
         }
         return value;
     }
 
     @:noCompletion private var _percentHeight:Null<Float>;
 
     /**
      * When set, sets this component's height to be `percentHeight`% percent of it's parent's height.
      */
     @:dox(group = "Size related properties and methods")
     @clonable @bindable public var percentHeight(get, set):Null<Float>;
     private function get_percentHeight():Null<Float> {
         return _percentHeight;
     }
     private function set_percentHeight(value:Null<Float>):Null<Float> {
         if (_percentHeight == value) {
             return value;
         }
         _percentHeight = value;
 
         if (parentComponent != null) {
             parentComponent.invalidateComponentLayout();
         } else {
             Screen.instance.resizeRootComponents();
         }
         return value;
     }
 
     @:noCompletion private var _cachedPercentWidth:Null<Float> = null;
     @:noCompletion private var _cachedPercentHeight:Null<Float> = null;
     private function cachePercentSizes(clearExisting:Bool = true) {
         if (_percentWidth != null) {
             _cachedPercentWidth = _percentWidth;
             if (clearExisting == true) {
                 _percentWidth = null;
             }
         }
         if (_percentHeight != null) {
             _cachedPercentHeight = _percentHeight;
             if (clearExisting == true) {
                 _percentHeight = null;
             }
         }
     }
     
     private function restorePercentSizes() {
         if (_cachedPercentWidth != null) {
             percentWidth = _cachedPercentWidth;
         }
         if (_cachedPercentHeight != null) {
             percentHeight = _cachedPercentHeight;
         }
     }
     
     #if ((haxeui_openfl || haxeui_nme) && !haxeui_flixel)
 
     #if flash override #else override #end
     private function set_x(value:Float): #if flash Float #else Float #end {
         #if flash
         super.x = value;
         #else
         super.set_x(value);
         #end
         left = value;
         #if !flash return value; #else return value; #end
     }
 
     #if flash override #else override #end
     public function set_y(value:Float): #if flash Float #else Float #end {
         #if flash
         super.y = value;
         #else
         super.set_y(value);
         #end
         top = value;
         #if !flash return value; #else return value; #end
     }
 
     @:noCompletion private var _width:Null<Float>;
     #if flash override #else override #end
     private function set_width(value:Float): #if Float Void #else Float #end {
         if (_width == value) {
             return #if !flash value #else value #end;
         }
         if (value == haxe.ui.util.MathUtil.MIN_INT) {
             _width = null;
             componentWidth = null;
         } else {
             _width = value;
             componentWidth = value;
         }
         #if !flash return value; #else return value; #end
     }
 
     #if flash override #else override #end
     private function get_width():Float {
         var f:Float = componentWidth;
         return f;
     }
 
     @:noCompletion private var _height:Null<Float>;
     #if flash override #else override #end
     private function set_height(value:Float): #if flash Float #else Float #end {
         if (_height == value) {
             return #if !flash value #else value #end;
         }
         if (value == haxe.ui.util.MathUtil.MIN_INT) {
             _height = null;
             componentHeight = null;
         } else {
             _height = value;
             componentHeight = value;
         }
         #if !flash return value; #else return value; #end
     }
 
     #if flash override #else override #end
     private function get_height():Float {
         var f:Float = componentHeight;
         return f;
     }
 
     #elseif (haxeui_flixel)
 
     @:noCompletion private var _width:Null<Float>;
     private override function set_width(value:Float):Float {
         if (value == 0) {
             return value;
         }
         if (_width == value) {
             return value;
         }
         _width = value;
         componentWidth = value;
         return value;
     }
 
     private override function get_width():Float {
         var f:Float = componentWidth;
         return f;
     }
 
     @:noCompletion private var _height:Null<Float>;
     private override function set_height(value:Float):Float {
         if (value == 0) {
             return value;
         }
         if (_height == value) {
             return value;
         }
         _height = value;
         componentHeight = value;
         return value;
     }
 
     private override function get_height() {
         var f:Float = componentHeight;
         return f;
     }
 
     #else
 
     /**
         This component's width. similar to `componentWidth`
     **/
     @:dox(group = "Size related properties and methods")
     @bindable public var width(get, set):Null<Float>;
     @:noCompletion private var _width:Null<Float>;
     private function set_width(value:Null<Float>):Null<Float> {
         if (_width == value) {
             return value;
         }
         _width = value;
         componentWidth = value;
         return value;
     }
 
     private function get_width():Null<Float> {
         var f:Float = componentWidth;
         return f;
     }
 
     /**
         This component's height. similar to `componentHeight`
     **/
     @:dox(group = "Size related properties and methods")
     @bindable public var height(get, set):Null<Float>;
     @:noCompletion private var _height:Null<Float>;
     private function set_height(value:Null<Float>):Null<Float> {
         if (_height == value) {
             return value;
         }
         _height = value;
         componentHeight = value;
         return value;
     }
 
     private function get_height():Null<Float> {
         var f:Float = componentHeight;
         return f;
     }
 
     #end
 
     @:noCompletion private var _actualWidth:Null<Float>;
     @:noCompletion private var _actualHeight:Null<Float>;
 
     @:noCompletion private var _hasScreen:Null<Bool> = null;
 
     /**
      * Whether this component, or one if it's parents, has a screen.
      */
     public var hasScreen(get, null):Bool;
     private function get_hasScreen():Bool {
         var p = this;
         while (p != null) {
             if (p._hasScreen == false) {
                 return false;
             }
             p = p.parentComponent;
         }
         return true;
     }
 
     /**
      Whether or not a point is inside this components bounds
 
      *Note*: `left` and `top` must be stage (screen) co-ords
     **/
     @:dox(group = "Size related properties and methods")
     public function hitTest(left:Null<Float>, top:Null<Float>, allowZeroSized:Bool = false):Bool { // co-ords must be stage
         if (left == null || top == null) {
            return false;
         }

         if (hasScreen == false) {
             return false;
         }
 
         left *= Toolkit.scale;
         top *= Toolkit.scale;
 
         var b:Bool = false;
         var bounds = screenBounds;
         var sx:Float = bounds.left;
         var sy:Float = bounds.top;
 
         var cx:Float = 0;
         if (componentWidth != null) {
             cx = actualComponentWidth;
         }
         var cy:Float = 0;
         if (componentHeight != null) {
             cy = actualComponentHeight;
         }
 
         if (allowZeroSized == true) {
             /*
             var c = cast(this, Component);
             if (c.layout != null) {
                 var us = c.layout.usableSize;
                 if (us.width <= 0 || us.height <= 0) {
                     return true;
                 }
             }
             */
             if (this.width <= 0 || this.height <= 0) {
                 return true;
             }
         }
 
         if (left >= sx && left < sx + cx && top >= sy && top < sy + cy) {
             b = true;
         }
 
         return b;
     }
 
     /**
      Autosize this component based on its children
     **/
     @:dox(group = "Size related properties and methods")
     private function autoSize():Bool {
         if (_componentReady == false || _layout == null) {
             return false;
         }
         return _layout.autoSize();
     }
 
     //***********************************************************************************************************
     // Position related
     //***********************************************************************************************************
     /**
      Move this components left and top co-ord in one call
     **/
     /**
      * Moves this component to the position (`left`, `top`) in one function call.
      * 
      * A more performant alternative to doing:
      * 
      *      component.x = value;
      *      component.y = anotherValue;
      * 
      * @param left The x position of the top-left corner of this component
      * @param top The y position of the top-left corner of this component
      */
     @:dox(group = "Position related properties and methods")
     public function moveComponent(left:Null<Float>, top:Null<Float>) {
         var invalidate:Bool = false;
         if (left != null && _left != left) {
             _left = left;
             invalidate = true;
         }
         if (top != null && _top != top) {
             _top = top;
             invalidate = true;
         }
 
         if (invalidate == true && isComponentInvalid(InvalidationFlags.POSITION) == false) {
             invalidateComponentPosition();
         }
     }
 
     @:noCompletion private var _left:Null<Float> = 0;
     /**
      * The position of this component on the horizontal, x-axis.
      * 
      * This position is relative to this component's parent.
      */
     @:dox(group = "Position related properties and methods")
     public var left(get, set):Null<Float>;
     private function get_left():Null<Float> {
         return _left;
     }
     private function set_left(value:Null<Float>):Null<Float> {
         moveComponent(value, null);
         return value;
     }
 
     @:noCompletion private var _top:Null<Float> = 0;
     /**
      * The position of this component on the vertical, y-axis.
      * 
      * This position is relative to this component's parent.
      */
     @:dox(group = "Position related properties and methods")
     public var top(get, set):Null<Float>;
     private function get_top():Null<Float> {
         return _top;
     }
     private function set_top(value:Null<Float>):Null<Float> {
         moveComponent(null, value);
         return value;
     }
 
     /**
      * The **on-screen** position of this component on the horizontal, x-axis. 
      */
     @:dox(group = "Position related properties and methods")
     public var screenLeft(get, null):Float;
     private function get_screenLeft():Float {
         return screenBounds.left;
     }
 
     public var screenRight(get, null):Float;
     private function get_screenRight():Float {
        return screenLeft + width;
     }

     /**
      * The **on-screen** position of this component on the vertical, y-axis. 
      */
     @:dox(group = "Position related properties and methods")
     public var screenTop(get, null):Float;
     private function get_screenTop():Float {
         return screenBounds.top;
     }
 
     public var screenBottom(get, null):Float;
     private function get_screenBottom():Float { 
        return screenTop + height;
     }

     private var _screenBounds:Rectangle = null; // we'll use the same rect over and over as to not create new objects all the time
     public var screenBounds(get, null):Rectangle;
     private function get_screenBounds():Rectangle {
        if (_screenBounds == null) { 
            _screenBounds = new Rectangle(); 
        }

        var c = this;
        var xpos:Float = 0;
        var ypos:Float = 0;
        while (c != null) {
            var l = c.left;
            var t = c.top;
            if (c.parentComponent != null) {
                l *= Toolkit.scale;
                t *= Toolkit.scale;
            }
            xpos += l;
            ypos += t;

            if (c.componentClipRect != null) {
                xpos -= c.componentClipRect.left * Toolkit.scaleX;
                ypos -= c.componentClipRect.top * Toolkit.scaleY;
            }

            c = c.parentComponent;
        }

        _screenBounds.set(xpos, ypos, width, height);

        return _screenBounds;
     }

     //***********************************************************************************************************
     // Clip rect
     //***********************************************************************************************************
     @:noCompletion private var _componentClipRect:Rectangle = null;
 
     /**
      * When set to a non-null value, restricts the component's "rendering zone"
      * to only render inside the bounds of the given rectangle, effectively "clipping" the component.
      */
     public var componentClipRect(get, set):Rectangle;
     private function get_componentClipRect():Rectangle {
         if (style != null && style.clip != null && style.clip == true) {
             return new Rectangle(0, 0, componentWidth, componentHeight);
         }
         return _componentClipRect;
     }
     private function set_componentClipRect(value:Rectangle):Rectangle {
         _componentClipRect = value;
         if (!isComponentInvalid(InvalidationFlags.DISPLAY)) {
            invalidateComponentDisplay();
         }
         return value;
     }
 
     /**
      * Whether this component has a non-null clipping rectangle or not.
      */
     public var isComponentClipped(get, null):Bool;
     private function get_isComponentClipped():Bool {
         return (componentClipRect != null);
     }
     
     /**
      * `true` if this component's area intersects with the screen, `false` otherwise.
      * 
      * clipRect is not taken into consideration - that means, if a clipRect turns a component from being
      * visible on screen to being invisible on screen, `isComponentOffScreen` should still be `false`.
      * 
      */
     public var isComponentOffscreen(get, null):Bool;
     private function get_isComponentOffscreen():Bool {
         if (this.width == 0 && this.height == 0) {
             return false;
         }
         var x:Float = screenLeft;
         var y:Float = screenTop;
         var w:Float = this.width;
         var h:Float = this.height;
         
         var thisRect = new Rectangle(x, y, w, h);
         var screenRect = new Rectangle(0, 0, Screen.instance.width, Screen.instance.height);
         return !screenRect.intersects(thisRect);
     }
 
    //***********************************************************************************************************
    // Style related
    //***********************************************************************************************************
    @:noCompletion private var _style:Style = null;
    @:dox(group = "Style related properties and methods")
    public var style(get, set):Style;
    private function get_style():Style {
        return _style;
    }

    private function set_style(value):Style {
        _style = value;
        return value;
    }

    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    @:noCompletion private var _invalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    @:noCompletion private var _delayedInvalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    @:noCompletion private var _isAllInvalid:Bool = false;
    @:noCompletion private var _isValidating:Bool = false;
    @:noCompletion private var _isInitialized:Bool = false;
    @:noCompletion private var _isDisposed:Bool = false;
    @:noCompletion private var _invalidateCount:Int = 0;

    @:noCompletion private var _depth:Int = -1;
    @:dox(group = "Internal")
    public var depth(get, set):Int;
    private function get_depth():Int {
        return _depth;
    }
    private function set_depth(value:Int):Int {
        if (_depth == value) {
            return value;
        }

        _depth = value;

        return value;
    }

    /**
     Check if the component is invalidated with some `flag`.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function isComponentInvalid(flag:String = InvalidationFlags.ALL):Bool {
        if (_isAllInvalid == true) {
            return true;
        }

        if (flag == InvalidationFlags.ALL) {
            for (value in _invalidationFlags) {
                return true;
            }

            return false;
        }

        return _invalidationFlags.exists(flag);
    }

    /**
     Invalidate this components with the `InvalidationFlags` indicated. If it hasn't parameter then the component will be invalidated completely.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function invalidateComponent(flag:String = InvalidationFlags.ALL, recursive:Bool = false) {
        if (_componentReady == false) {
            return;     //it should be added into the queue later
        }

        var isAlreadyInvalid:Bool = isComponentInvalid(flag);
        var isAlreadyDelayedInvalid:Bool = false;
        if (_isValidating == true) {
            for (value in _delayedInvalidationFlags) {
                isAlreadyDelayedInvalid = true;
                break;
            }
        }

        if (flag == InvalidationFlags.ALL) {
            if (_isValidating == true) {
                _delayedInvalidationFlags.set(InvalidationFlags.ALL, true);
            } else {
                _isAllInvalid = true;
            }
        } else {
            if (_isValidating == true) {
                _delayedInvalidationFlags.set(flag, true);
            } else if (flag != InvalidationFlags.ALL && !_invalidationFlags.exists(flag)) {
                _invalidationFlags.set(flag, true);
            }
        }

        if (_isValidating == true) {
            //it is already in queue
            if (isAlreadyDelayedInvalid == true) {
                return;
            }

            _invalidateCount++;

            //we track the invalidate count to check if we are in an infinite loop or serious bug because it affects performance
            if (this._invalidateCount >= 10) {
                throw 'The validation queue returned too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls invalidate() during validation.';
            }

            ValidationManager.instance.add(cast(this, Component)); // TODO: avoid cast
            return;
        } else if (isAlreadyInvalid == true) {
            if (recursive == true) {
                for (child in childComponents) {
                    child.invalidateComponent(flag, recursive);
                }
            }
            return;
        }

        _invalidateCount = 0;
        ValidationManager.instance.add(cast(this, Component)); // TODO: avoid cast
        
        if (recursive == true) {
            for (child in childComponents) {
                child.invalidateComponent(flag, recursive);
            }
        }
    }

    /**
     Invalidate the data of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentData(recursive:Bool = false) {
        invalidateComponent(InvalidationFlags.DATA, recursive);
    }

    /**
     Invalidate this components layout, may result in multiple calls to `invalidateDisplay` and `invalidateLayout` of its children
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentLayout(recursive:Bool = false) {
        if (_layout == null || _layoutLocked == true) {
            return;
        }
        invalidateComponent(InvalidationFlags.LAYOUT, recursive);
    }

    /**
     Invalidate the position of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentPosition(recursive:Bool = false) {
        invalidateComponent(InvalidationFlags.POSITION, recursive);
    }

    /**
     Invalidate the visible aspect of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentDisplay(recursive:Bool = false) {
        invalidateComponent(InvalidationFlags.DISPLAY, recursive);
    }

    /**
     Invalidate and recalculate this components style, may result in a call to `invalidateDisplay`
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentStyle(force:Bool = false, recursive:Bool = false) {
        invalidateComponent(InvalidationFlags.STYLE, recursive);
        if (force == true) {
            _style = null;
        }
    }

    /**
     This method validates the tasks pending in the component.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function validateComponent(nextFrame:Bool = true) {
        if (_componentReady == false ||
            _isDisposed == true ||      //we don't want to validate disposed components, but they may have been left in the queue.
            _isValidating == true ||    //we were already validating, the existing validation will continue.
            isComponentInvalid() == false) {     //if none is invalid, exit.
            return;
        }

        var isInitialized = _isInitialized;
        if (isInitialized == false) {
            initializeComponent();
        }

        _isValidating = true;

        validateComponentInternal(nextFrame);
        validateInitialSize(isInitialized);

        #if (haxe_ver < 4)
        _invalidationFlags = new Map<String, Bool>();
        #else
        _invalidationFlags.clear();
        #end

        _isAllInvalid = false;

        for (flag in _delayedInvalidationFlags.keys()) {
            if (flag == InvalidationFlags.ALL) {
                _isAllInvalid = true;
            } else {
                _invalidationFlags.set(flag, true);
            }
        }
        #if (haxe_ver < 4)
        _delayedInvalidationFlags = new Map<String, Bool>();
        #else
        _delayedInvalidationFlags.clear();
        #end

        _isValidating = false;
    }

    /**
     Validate this component and its children on demand.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function validateNow() {
        for (child in childComponents) {
            child.validateNow();
        }
        invalidateComponent();
        syncComponentValidation(false);
    }

    /**
     Validate this component and its children on demand.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function syncComponentValidation(nextFrame:Bool = true) {
        var count:Int = 0;
        while (isComponentInvalid()) {
            validateComponent(nextFrame);

            for (child in childComponents) {
                child.syncComponentValidation(nextFrame);
            }

            if (++count >= 10) {
                if (this._isDisposed) {
                    #if debug
                    trace('There was a problem validating this component as it has already been destroyed (${Type.getClassName(Type.getClass(this))}#${this.id})');
                    #end
                    throw 'There was a problem validating this component as it has already been destroyed (${Type.getClassName(Type.getClass(this))}#${this.id})';
                } else {
                    #if debug
                    trace('The syncValidation returned too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls invalidate() during validation (${Type.getClassName(Type.getClass(this))}#${this.id}).');
                    #end
                    throw 'The syncValidation returned too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls invalidate() during validation (${Type.getClassName(Type.getClass(this))}#${this.id}).';
                }
            }
        }
    }

    private function validateComponentInternal(nextFrame:Bool = true) {
        var dataInvalid = isComponentInvalid(InvalidationFlags.DATA);
        var styleInvalid = isComponentInvalid(InvalidationFlags.STYLE);
        var textDisplayInvalid = isComponentInvalid(InvalidationFlags.TEXT_DISPLAY) && hasTextDisplay();
        var textInputInvalid = isComponentInvalid(InvalidationFlags.TEXT_INPUT) && hasTextInput();
        var imageDisplayInvalid = isComponentInvalid(InvalidationFlags.IMAGE_DISPLAY) && hasImageDisplay();
        var positionInvalid = isComponentInvalid(InvalidationFlags.POSITION);
        var displayInvalid = isComponentInvalid(InvalidationFlags.DISPLAY);
        var layoutInvalid = isComponentInvalid(InvalidationFlags.LAYOUT) && _layoutLocked == false;

        if (dataInvalid) {
            validateComponentData();
        }

        if (styleInvalid) {
            validateComponentStyle();
        }

        if (textDisplayInvalid) {
            getTextDisplay().validateComponent();
        }

        if (textInputInvalid) {
            getTextInput().validateComponent();
        }

        if (imageDisplayInvalid) {
            getImageDisplay().validateComponent();
        }

        if (positionInvalid) {
            validateComponentPosition();
        }

        if (layoutInvalid) {
            displayInvalid = validateComponentLayout() || displayInvalid;
        }

        if (displayInvalid || styleInvalid) {
            ValidationManager.instance.addDisplay(cast(this, Component), nextFrame);    //Update the display from all objects at the same time. Avoids UI flashes.
        }
    }

    private function initializeComponent() {

    }

    private function validateInitialSize(isInitialized:Bool) {

    }

    private function validateComponentData() {
    }

    private function validateComponentLayout():Bool {
        return false;
    }

    private function validateComponentStyle() {

    }

    private function validateComponentPosition() {

    }

    //***********************************************************************************************************
    // Backend
    //***********************************************************************************************************
    @:dox(group = "Backend")
    private function handleCreate(native:Bool) {
    }

    @:dox(group = "Backend")
    private function handleDestroy() {
    }

    @:dox(group = "Backend")
    private function handlePosition(left:Null<Float>, top:Null<Float>, style:Style) {
    }

    @:dox(group = "Backend")
    public function handlePreReposition() {
    }

    @:dox(group = "Backend")
    public function handlePostReposition() {
    }

    @:dox(group = "Backend")
    private function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
    }

    @:dox(group = "Backend")
    private function handleReady() {
    }

    @:dox(group = "Backend")
    private function handleClipRect(value:Rectangle) {
    }

    @:dox(group = "Backend")
    private function handleVisibility(show:Bool) {
    }

    @:dox(group = "Backend")
    private function handleDisabled(show:Bool) {
    }

    @:dox(group = "Backend")
    private function handleSetComponentIndex(child:Component, index:Int) {
    }

    @:dox(group = "Backend")
    private function handleAddComponent(child:Component):Component {
        return child;
    }

    @:dox(group = "Backend")
    private function handleAddComponentAt(child:Component, index:Int):Component {
        return child;
    }

    @:dox(group = "Backend")
    private function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
        return child;
    }

    @:dox(group = "Backend")
    private function handleRemoveComponentAt(index:Int, dispose:Bool = true):Component {
        return null;
    }

    @:dox(group = "Backend")
    private function applyStyle(style:Style) {
    }

    @:dox(group = "Backend")
    private function mapEvent(type:String, listener:UIEvent->Void) {
    }

    @:dox(group = "Backend")
    private function unmapEvent(type:String, listener:UIEvent->Void) {
    }

    private function getComponentOffset():Point {
        return new Point(0, 0);
    }

    private var isNativeScroller(get, null):Bool;
    private function get_isNativeScroller():Bool {
        return false;
    }

    private function handleFrameworkProperty(id:String, value:Any) {

    }

    //***********************************************************************************************************
    // Backend - Text related
    //***********************************************************************************************************
    @:noCompletion private var _textDisplay:TextDisplay;
    @:dox(group = "Backend")
    public function createTextDisplay(text:String = null):TextDisplay {
        if (_textDisplay == null) {
            _textDisplay = new TextDisplay();
            _textDisplay.parentComponent = cast(this, Component);
        }
        if (text != null) {
            _textDisplay.text = text;
        }
        return _textDisplay;
    }

    @:dox(group = "Backend")
    public function getTextDisplay():TextDisplay {
        return createTextDisplay();
    }

    @:dox(group = "Backend")
    public function hasTextDisplay():Bool {
        return (_textDisplay != null);
    }

    @:noCompletion private var _textInput:TextInput;
    @:dox(group = "Backend")
    public function createTextInput(text:String = null):TextInput {
        if (_textInput == null) {
            _textInput = new TextInput();
            _textInput.parentComponent = cast(this, Component);
        }
        if (text != null) {
            _textInput.text = text;
        }
        return _textInput;
    }

    @:dox(group = "Backend")
    public function getTextInput():TextInput {
        return createTextInput();
    }

    @:dox(group = "Backend")
    public function hasTextInput():Bool {
        return (_textInput != null);
    }

    //***********************************************************************************************************
    // Backend - Image related
    //***********************************************************************************************************
    @:noCompletion private var _imageDisplay:ImageDisplay;
    @:dox(group = "Backend")
    public function createImageDisplay():ImageDisplay {
        if (_imageDisplay == null) {
            _imageDisplay = new ImageDisplay();
            _imageDisplay.parentComponent = cast(this, Component);
        }
        return _imageDisplay;
    }

    @:dox(group = "Backend")
    public function getImageDisplay():ImageDisplay {
        return createImageDisplay();
    }

    @:dox(group = "Backend")
    public function hasImageDisplay():Bool {
        return (_imageDisplay != null);
    }

    @:dox(group = "Backend")
    public function removeImageDisplay() {
        if (_imageDisplay != null) {
            _imageDisplay.dispose();
            _imageDisplay = null;
        }
    }

    //***********************************************************************************************************
    // Properties
    //***********************************************************************************************************
    /**
     Gets a property that is associated with all classes of this type
    **/
    @:dox(group = "Internal")
    public function getClassProperty(name:String):String {
        var v = null;
        if (_classProperties != null) {
            v = _classProperties.get(name);
        }
        if (v == null) {
            var c = Type.getClassName(Type.getClass(this)).toLowerCase() + "." + name;
            v = Toolkit.properties.get(c);
        }
        return v;
    }

    @:noCompletion private var _classProperties:Map<String, String>;
    /**
     Sets a property that is associated with all classes of this type
    **/
    @:dox(group = "Internal")
    public function setClassProperty(name:String, value:String) {
        if (_classProperties == null) {
            _classProperties = new Map<String, String>();
        }
        _classProperties.set(name, value);
    }

    @:noCompletion private var _hasNativeEntry:Null<Bool>;
    private var hasNativeEntry(get, null):Bool;
    private function get_hasNativeEntry():Bool {
        if (_hasNativeEntry == null) {
            _hasNativeEntry = (getNativeConfigProperty(".@id") != null);
        }
        return _hasNativeEntry;
    }

    private function getNativeConfigProperty(query:String, defaultValue:String = null):String {
        query = 'component[id=${nativeClassName}]${query}';
        return Toolkit.nativeConfig.query(query, defaultValue, this);
    }

    private function getNativeConfigPropertyBool(query:String, defaultValue:Bool = false):Bool {
        query = 'component[id=${nativeClassName}]${query}';
        return Toolkit.nativeConfig.queryBool(query, defaultValue, this);
    }

    private function getNativeConfigProperties(query:String = ""):Map<String, String> {
        query = 'component[id=${nativeClassName}]${query}';
        return Toolkit.nativeConfig.queryValues(query, this);
    }

    @:noCompletion private var _className:String = null;
    public var className(get, null):String;
    private function get_className():String {
        if (_className != null) {
            return _className;
        }
        _className = Type.getClassName(Type.getClass(this));
        return _className;
    }

    @:noCompletion private var _nodeName:String = null;
    @:noCompletion private var nodeName(get, null):String;
    @:noCompletion private function get_nodeName():String {
        if (_nodeName != null) {
            return _nodeName;
        }
        _nodeName = className.split(".").pop().toLowerCase();
        return _nodeName;
    }
    
    @:noCompletion private var _nativeClassName:String = null;
    private var nativeClassName(get, null):String;
    private function get_nativeClassName():String {
        if (_nativeClassName != null) {
            return _nativeClassName;
        }

        var r:Class<Dynamic> = Type.getClass(this);
        while (r != null) {
            var c = Type.getClassName(r);
            var t = Toolkit.nativeConfig.query('component[id=${c}].@class', null, this);
            if (t != null) {
                _nativeClassName = c;
                break;
            }
            r = Type.getSuperClass(r);
            if (r == Component) {
                break;
            }
        }

        if (_nativeClassName == null) {
            _nativeClassName = className;
        }

        return _nativeClassName;
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
