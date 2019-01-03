package haxe.ui.core;

import haxe.ui.backend.ComponentBase;
import haxe.ui.behaviours.Behaviours;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.containers.dialogs.Dialog2;
import haxe.ui.events.AnimationEvent;
import haxe.ui.events.Events;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.DelegateLayout;
import haxe.ui.layouts.Layout;
import haxe.ui.scripting.ScriptInterp;
import haxe.ui.styles.Parser;
import haxe.ui.styles.Style;
import haxe.ui.styles.animation.Animation;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.util.CallStackHelper;
import haxe.ui.util.Color;
import haxe.ui.util.ComponentUtil;
import haxe.ui.util.EventMap;
import haxe.ui.util.FunctionArray;
import haxe.ui.util.MathUtil;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Size;
import haxe.ui.util.StringUtil;
import haxe.ui.util.Variant;
import haxe.ui.validation.IValidating;
import haxe.ui.validation.InvalidationFlags;
import haxe.ui.validation.ValidationManager;

/**
 Base class of all HaxeUI controls
**/
@:allow(haxe.ui.backend.ComponentBase)
@:autoBuild(haxe.ui.macros.Macros.buildComposite())
@:build(haxe.ui.macros.Macros.buildStyles())
@:autoBuild(haxe.ui.macros.Macros.buildStyles())
@:build(haxe.ui.macros.Macros.buildBehaviours())
@:autoBuild(haxe.ui.macros.Macros.buildBehaviours())
@:build(haxe.ui.macros.Macros.buildBindings())
@:autoBuild(haxe.ui.macros.Macros.buildBindings())
@:build(haxe.ui.macros.Macros.addClonable())
@:autoBuild(haxe.ui.macros.Macros.addClonable())
class Component extends ComponentBase implements IComponentBase implements IValidating implements IClonable<Component> {
    private var behaviours:Behaviours;
    
    public function new() {
        super();

        behaviours = new Behaviours(this);
        
        #if flash
        addClass("flash", false);
        #end
        #if html5
        addClass("html5", false);
        #end
        addClass(Backend.id, false);

        var c:Class<Dynamic> = Type.getClass(this);
        while (c != null) {
            var css = Type.getClassName(c);
            var className:String = css.split(".").pop();
            addClass(className.toLowerCase(), false);
            addClass(StringUtil.toDashes(className), false);
            if (className.toLowerCase() == "component") {
                break;
            }
            c = Type.getSuperClass(c);
        }        

        //registerBehaviours();
        registerComposite();
        
        // we dont want to actually apply the classes, just find out if native is there or not
        //TODO - we could include the initialization in the validate method
        //var s = Toolkit.styleSheet.applyClasses(this, false);
        var s = Toolkit.styleSheet.buildStyleFor(this);
        if (s.native != null && hasNativeEntry == true) {
            native = s.native;
        } else {
            create();
        }
        
    }

    //***********************************************************************************************************
    // Construction
    //***********************************************************************************************************
    private var _defaultLayoutClass:Class<Layout> = null;
    private function create() {
        createDefaults();
        handleCreate(native);
        destroyChildren();
        registerBehaviours();
        behaviours.replaceNative();

        if (native == false || native == null) {
            if (_compositeBuilderClass != null) {
                if (_compositeBuilder == null) {
                   _compositeBuilder = Type.createInstance(_compositeBuilderClass, [this]); 
                }
                _compositeBuilder.create();
            }
            createChildren();
            if (_internalEventsClass != null && _internalEvents == null) {
                registerInternalEvents(_internalEventsClass);
            }
        } else {
            var builderClass = getNativeConfigProperty(".builder.@class");
            if (builderClass != null) { // TODO: maybe _compositeBuilder isnt the best name if native components can use them
                if (_compositeBuilder == null) {
                   _compositeBuilder = Type.createInstance(Type.resolveClass(builderClass), [this]); 
                }
                _compositeBuilder.create();
            }
        }
        behaviours.applyDefaults();
    }

    private function registerBehaviours() {
    }

    private var _compositeBuilderClass:Class<CompositeBuilder>;
    private var _compositeBuilder:CompositeBuilder;
    private function registerComposite() {
    }
    
    private function createDefaults() {
    }

    private var _internalEvents:Events = null;
    private var _internalEventsClass:Class<Events> = null;
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
    
    private function createChildren() {

    }

    private function destroyChildren() {
        unregisterInternalEvents();
    }

    private var _hasNativeEntry:Null<Bool>;
    private var hasNativeEntry(get, null):Bool;
    private function get_hasNativeEntry():Bool {
        if (_hasNativeEntry == null) {
            _hasNativeEntry = (getNativeConfigProperty(".@id") != null);
        }
        return _hasNativeEntry;
    }

    private function createLayout():Layout {
        var l:Layout = null;
        if (native == true) {
            var sizeProps = getNativeConfigProperties('.size');
            if (sizeProps != null && sizeProps.exists("class")) {
                var size:DelegateLayoutSize = Type.createInstance(Type.resolveClass(sizeProps.get("class")), []);
                size.config = sizeProps;
                l = new DelegateLayout(size);
            } else {
                var layoutProps = getNativeConfigProperties('.layout');
                if (layoutProps != null && layoutProps.exists("class")) {
                    l = Type.createInstance(Type.resolveClass(layoutProps.get("class")), []);
                }
            }
        }

        if (l == null) {
            if (_defaultLayoutClass != null) {
                l = Type.createInstance(_defaultLayoutClass, []);
            } else {
                l = new DefaultLayout();
            }
        }

        return l;
    }
    
    // TODO: these functions should be removed and components should use behaviours.get/set/call/defaults direction
    private var _behaviourUpdateOrder:Array<String> = [];

    private var _native:Null<Bool> = null;
    /**
     Whether to try to use a native version of this component
    **/
    public var native(get, set):Null<Bool>;
    private function get_native():Null<Bool> {
        if (_native == null) {
            return false;
        }
        if (hasNativeEntry == false) {
            return false;
        }
        return _native;
    }
    private function set_native(value:Null<Bool>):Null<Bool> {
        if (hasNativeEntry == false) {
            return value;
        }
        if (_native == value) {
            return value;
        }

        _native = value;
        if (_native == true && hasNativeEntry) {
            addClass(":native");
        } else {
            removeClass(":native");
        }

        behaviours.cache(); // behaviours will most likely lead to different classes now, so lets cache the current ones to get their values
        behaviours.detatch();
        create();
        if (layout != null) {
            layout = createLayout();
        }
        behaviours.restore();
        return value;
    }

    private var _animatable:Bool = true;
    /**
     Whether this component is allowed to animate
    **/
    public var animatable(get, set):Bool;
    private function get_animatable():Bool {
        #if !actuate
            return false;
        #end
        return _animatable;
    }
    private function set_animatable(value:Bool):Bool {
        if (_animatable != value) {
            if (value == false && _componentAnimation != null) {
                _componentAnimation.stop();
                _componentAnimation = null;
            }

            _animatable = value;
        }
        _animatable = value;
        return value;
    }

    private var _componentAnimation:Animation;
    /**
     Current animation running
    **/
    public var componentAnimation(get, set):Animation;
    private function get_componentAnimation():Animation {
        return _componentAnimation;
    }
    private function set_componentAnimation(value:Animation):Animation {
        if (_componentAnimation != value && _animatable == true) {
            if (_componentAnimation != null) {
                _componentAnimation.stop();
            }

            _componentAnimation = value;
        }

        return value;
    }

    /**
     User specific data stored against this component instance
    **/
    public var userData(default, default):Dynamic = null;

    //***********************************************************************************************************
    // General
    //***********************************************************************************************************
    private var _id:String = null;
    /**
     The identifier of this component
    **/
    @clonable public var id(get, set):String;
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

    
    @:clonable @:behaviour(DefaultBehaviour)  public var text:String;
    
    public var value(get, set):Dynamic;
    private function get_value():Dynamic {
        return text;
    }
    private function set_value(value:Dynamic):Dynamic {
        text = value;
        return value;
    }
    

    /**
     Reference to the `Screen` object this component is displayed on
    **/
    public var screen(get, null):Screen;
    private function get_screen():Screen {
        return Toolkit.screen;
    }

    //***********************************************************************************************************
    //{Binding related}
    //***********************************************************************************************************
    public var bindingRoot:Bool = false;
    //***********************************************************************************************************

    //***********************************************************************************************************
    // Clip rect
    //***********************************************************************************************************
    private var _componentClipRect:Rectangle = null;
    /**
     Whether to clip the display of this component
    **/
    public var componentClipRect(get, set):Rectangle;
    private function get_componentClipRect():Rectangle {
        return _componentClipRect;
    }
    private function set_componentClipRect(value:Rectangle):Rectangle {
        _componentClipRect = value;
        invalidateComponentDisplay();
        return value;
    }

    //***********************************************************************************************************
    // Display tree
    //***********************************************************************************************************
    /**
     The top level component of this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public var rootComponent(get, never):Component;
    private function get_rootComponent():Component {
        var r = this;
        while (r.parentComponent != null) {
            r = r.parentComponent;
        }
        return r;
    }

    private var _children:Array<Component>;
    /**
     The parent component of this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public var parentComponent:Component = null;

    /**
     Gets the number of child components under this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public var numComponents(get, never):Int;
    private function get_numComponents():Int {
        return _compositeBuilder != null ? _compositeBuilder.numComponents : _children == null ? 0 : _children.length;
    }

    /**
     Adds a child component to this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public function addComponent(child:Component):Component {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.addComponent(child);
            if (v != null) {
                return v;
            }
        }
        
        if (this.native == true) {
            var allowChildren:Bool = getNativeConfigPropertyBool('.@allowChildren', true);
            if (allowChildren == false) {
                return child;
            }
        }

        child.parentComponent = this;
        child._isDisposed = false;

        if (_children == null) {
            _children = [];
        }
        _children.push(child);

        handleAddComponent(child);
        if (_ready) {
            child.ready();
        }

        invalidateComponentLayout();
        if (disabled) {
            child.disabled = true;
        }
        
        if (_compositeBuilder != null) {
            _compositeBuilder.onComponentAdded(child);
        }
        onComponentAdded(child);
        return child;
    }

    /**
     Adds a child component to this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public function addComponentAt(child:Component, index:Int):Component {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.addComponentAt(child, index);
            if (v != null) {
                return v;
            }
        }
        
        if (this.native == true) {
            var allowChildren:Bool = getNativeConfigPropertyBool('.@allowChildren', true);
            if (allowChildren == false) {
                return child;
            }
        }

        child.parentComponent = this;
        child._isDisposed = false;

        if (_children == null) {
            _children = [];
        }
        _children.insert(index, child);

        handleAddComponentAt(child, index);
        if (_ready) {
            child.ready();
        }

        invalidateComponentLayout();
        if (disabled) {
            child.disabled = true;
        }
        
        if (_compositeBuilder != null) {
            _compositeBuilder.onComponentAdded(child);
        }
        onComponentAdded(child);
        return child;
    }

    private function onComponentAdded(child:Component) {
    }
    
    /**
     Removes the specified child component from this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (child == null) {
            return null;
        }
        
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.removeComponent(child, dispose, invalidate);
            if (v != null) {
                return v;
            }
        }
        
        handleRemoveComponent(child, dispose);
        if (_children != null) {
            if (_children.remove(child)) {
                child.parentComponent = null;
                child.depth = -1;
            }
            if (invalidate == true) {
                invalidateComponentLayout();
            }
            if (dispose == true) {
                child._isDisposed = true;
                child.unregisterEvents();
                child.destroyComponent();
            }
        }

        if (_compositeBuilder != null) {
            _compositeBuilder.onComponentRemoved(child);
        }
        onComponentRemoved(child);
        
        return child;
    }

    /**
     Removes the child component from this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public function removeComponentAt(index:Int, dispose:Bool = true, invalidate:Bool = true):Component {
        if (_children == null) {
            return null;
        }
        
        if (index < 0 || index > _children.length - 1) {
            return null;
        }
        
        handleRemoveComponentAt(index, dispose);
        var child = _children[index];
        if (_children != null) {
            if (_children.remove(child)) {
                child.parentComponent = null;
                child.depth = -1;
            }
            if (invalidate == true) {
                invalidateComponentLayout();
            }
            if (dispose == true) {
                child._isDisposed = true;
                child.unregisterEvents();
                child.destroyComponent();
            }
        }

        if (_compositeBuilder != null) {
            _compositeBuilder.onComponentRemoved(child);
        }
        onComponentRemoved(child);
        
        return child;
    }

    private function onComponentRemoved(child:Component) {
    }
    
    private function unregisterEvents() {
        if (__events != null) {
            var copy:Array<String> = [];
            for (eventType in __events.keys()) {
                copy.push(eventType);
            }
            for (eventType in copy) {
                var listeners = __events.listeners(eventType);
                for (listener in listeners) {
                    __events.remove(eventType, listener);
                }
            }
        }
    }
    
    private function destroyComponent() {
        if (_compositeBuilder != null) {
            _compositeBuilder.destroy();
        }
        onDestroy();
    }
    
    private function onDestroy() {

    }

    /**
     Removes all child components from this component instance
    **/
    @:dox(group = "Display tree related properties and methods")
    public function removeAllComponents(dispose:Bool = true) {
        if (_children != null) {
            while (_children.length > 0) {
                _children[0].removeAllComponents(dispose);
                removeComponent(_children[0], dispose, false);
            }
            invalidateComponentLayout();
        }
    }

    /**
     A list of this components children

     *Note*: this function will return an empty array if the component has no children
    **/
    @:dox(group = "Display tree related properties and methods")
    public var childComponents(get, null):Array<Component>;
    private function get_childComponents():Array<Component> {
        if (_children == null) {
            return [];
        }
        return _children;
    }

    /**
     Finds a specific child in this components display tree (recusively if desired) and can optionally cast the result

     - `criteria` - The criteria by which to search, the interpretation of this is defined using `searchType` (the default search type is *id*)

     - `type` - The component class you wish to cast the result to (defaults to *null*)

     - `recursive` - Whether to search this components children and all its childrens children till it finds a match (the default depends on the `searchType` param. If `searchType` is `id` the default is *true* otherwise it is *false*)

     - `searchType` - Allows you specify how to consider a child a match (defaults to *id*), can be either:

            - `id` - The first component that has the id specified in `criteria` will be considered a match

            - `css` - The first component that contains a style name specified by `criteria` will be considered a match
    **/
    @:dox(group = "Display tree related properties and methods")
    public function findComponent<T:Component>(criteria:String = null, type:Class<T> = null, recursive:Null<Bool> = null, searchType:String = "id"):Null<T> {
        if (recursive == null && criteria != null && searchType == "id") {
            recursive = true;
        }

        var match:Component = null;
        for (child in childComponents) {
            if (criteria != null) {
                if (searchType == "id" && child.id == criteria) {
                    match = cast child;
                    break;
                } else if (searchType == "css" && child.hasClass(criteria) == true) {
                    match = cast child;
                    break;
                }
            } else if (type != null) {
                if (Std.is(child, type) == true) {
                    match = cast child;
                    break;
                }
            }
        }
        if (match == null && recursive == true) {
            for (child in childComponents) {
                var temp:Component = cast child.findComponent(criteria, type, recursive, searchType);
                if (temp != null) {
                    match = temp;
                    break;
                }
            }
        }

        return cast match;
    }

    /**
     Finds a specific parent in this components display tree and can optionally cast the result

     - `criteria` - The criteria by which to search, the interpretation of this is defined using `searchType` (the default search type is *id*)

     - `type` - The component class you wish to cast the result to (defaults to *null*)

     - `searchType` - Allows you specify how to consider a parent a match (defaults to *id*), can be either:

            - `id` - The first component that has the id specified in `criteria` will be considered a match

            - `css` - The first component that contains a style name specified by `criteria` will be considered a match
    **/
    @:dox(group = "Display tree related properties and methods")
    public function findAncestor<T:Component>(criteria:String = null, type:Class<T> = null, searchType:String = "id"):Null<T> {
        var match:Component = null;
        var p = this.parentComponent;
        while (p != null) {
            if (criteria != null) {
                if (searchType == "id" && p.id == criteria) {
                    match = cast p;
                    break;
                } else if (searchType == "css" && p.hasClass(criteria) == true) {
                    match = cast p;
                    break;
                }
            } else if (type != null) {
                if (Std.is(p, type) == true) {
                    match = cast p;
                    break;
                }
            }
            
            p = p.parentComponent;
        }
        return cast match;
    }
    
    public function findComponentsUnderPoint(screenX:Float, screenY:Float):Array<Component> {
        var c:Array<Component> = [];
        if (screenX >= this.screenLeft && screenX <= this.screenLeft + this.width
            && screenY >= this.screenTop && screenY <= this.screenTop + this.height) {
            for (child in childComponents) {
                if (screenX >= child.screenLeft && screenX <= child.screenLeft + child.width
                    && screenY >= child.screenTop && screenY <= child.screenTop + child.height) {
                    c.push(child);
                }
                
                c = c.concat(child.findComponentsUnderPoint(screenX, screenY));
            }
        }
        return c;
    }
    
    /**
     Gets the index of a child component
    **/
    @:dox(group = "Display tree related properties and methods")
    public function getComponentIndex(child:Component):Int {
        if (_compositeBuilder != null) {
            var index = _compositeBuilder.getComponentIndex(child);
            if (index != MathUtil.MIN_INT) {
                return index;
            }
        }
        
        var index:Int = -1;
        if (_children != null && child != null) {
            index = _children.indexOf(child);
        }
        return index;
    }

    public function setComponentIndex(child:Component, index:Int):Component {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.setComponentIndex(child, index);
            if (v != null) {
                return v;
            }
        }
        
        if (index >= 0 && index <= _children.length && child.parentComponent == this) {
            handleSetComponentIndex(child, index);
            _children.remove(child);
            _children.insert(index, child);
            invalidateComponentLayout();
        }
        return child;
    }

    /**
     Gets a child component at a specified index
    **/
    @:dox(group = "Display tree related properties and methods")
    public function getComponentAt(index:Int):Component {
        if (_compositeBuilder != null) {
            return _compositeBuilder.getComponentAt(index);
        }
        if (_children == null) {
            return null;
        }
        return _children[index];
    }

    /**
     Hides this component and all its children
    **/
    @:dox(group = "Display tree related properties and methods")
    public function hide() {
        if (_hidden == false) {
            handleVisibility(false);
            _hidden = true;
            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }
            
            dispatch(new UIEvent(UIEvent.HIDDEN));
        }
    }

    /**
     Shows this component and all its children
    **/
    @:dox(group = "Display tree related properties and methods")
    public function show() {
        if (_hidden == true) {
            handleVisibility(true);
            _hidden = false;
            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }
            
            dispatch(new UIEvent(UIEvent.SHOWN));
        }
    }

    private var _hidden:Bool = false;
    /**
     Whether this component is hidden or not
    **/
    @:dox(group = "Display tree related properties and methods")
    public var hidden(get, set):Bool;
    private function get_hidden():Bool {
        if (_hidden == true) {
            return true;
        }
        if (parentComponent != null) {
            return parentComponent.hidden;
        }
        return false;
    }
    private function set_hidden(value:Bool):Bool {
        if (value == _hidden) {
            return value;
        }
        if (value == true) {
            hide();
        } else {
            show();
        }
        return value;
    }

    @:clonable @:behaviour(ComponentDisabledBehaviour, false)       public var disabled:Bool;
    
    //***********************************************************************************************************
    // Style related
    //***********************************************************************************************************
    /**
     A custom style object that will appled to this component after any css rules have been matched and applied
    **/
    @:dox(group = "Style related properties and methods")
    public var customStyle:Style = new Style();
    @:dox(group = "Style related properties and methods")
    @:allow(haxe.ui.styles_old.Engine)
    private var classes:Array<String> = [];

    /**
     Adds a css style name to this component
    **/
    @:dox(group = "Style related properties and methods")
    public function addClass(name:String, invalidate:Bool = true, recursive:Bool = false) {
        if (classes.indexOf(name) == -1) {
            classes.push(name);
            if (invalidate == true) {
                invalidateComponentStyle();
            }
        }
		
		if (recursive == true) {
			for (child in childComponents) {
				child.addClass(name, invalidate, recursive);
			}
		}
    }

    /**
     Removes a css style name from this component
    **/
    @:dox(group = "Style related properties and methods")
    public function removeClass(name:String, invalidate:Bool = true, recursive:Bool = false) {
        if (classes.indexOf(name) != -1) {
            classes.remove(name);
            if (invalidate == true) {
                invalidateComponentStyle();
            }
        }

		if (recursive == true) {
			for (child in childComponents) {
				child.removeClass(name, invalidate, recursive);
			}
		}
    }

    /**
     Whether or not this component has a css class associated with it
    **/
    @:dox(group = "Style related properties and methods")
    public function hasClass(name:String):Bool {
        return (classes.indexOf(name) != -1);
    }

    /**
     A string representation of the css classes associated with this component
    **/
    @:dox(group = "Style related properties and methods")
    @clonable public var styleNames(get, set):String;
    private function get_styleNames():String {
        return classes.join(" ");
    }
    private function set_styleNames(value:String):String {
        if (value == null) {
            return value;
        }

        for (x in value.split(" ")) {
            addClass(x);
        }
        return value;
    }

    private var _styleString:String;
    /**
     An inline css string that will be parsed and applied as a custom style
    **/
    @:dox(group = "Style related properties and methods")
    @clonable public var styleString(get, set):String;
    private function get_styleString():String {
        return _styleString;
    }
    private function set_styleString(value:String):String {
        if (value == null || value == _styleString) {
            return value;
        }
        var cssString = StringTools.trim(value);
        if (cssString.length == 0) {
            return value;
        }
        if (StringTools.endsWith(cssString, ";") == false) {
            cssString += ";";
        }
        cssString = "_ { " + cssString + "}";
        var s = new Parser().parse(cssString);
        customStyle.mergeDirectives(s.rules[0].directives);
        
        _styleString = value;
        invalidateComponentStyle();
        return value;
    }

    private var _style:Style;
    /**
     The calculated style of this component
    **/
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
    // Events
    //***********************************************************************************************************
    private var __events:EventMap;

    /**
     Register a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function registerEvent(type:String, listener:Dynamic->Void, priority:Int = 0) {
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
    }

    /**
     Returns if this component has a certain event and listener
    **/
    @:dox(group = "Event related properties and methods")
    public function hasEvent(type:String, listener:Dynamic->Void = null):Bool {
        if (__events == null) {
            return false;
        }
        return __events.contains(type, listener);
    }

    /**
     Unregister a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (_disabledEvents != null && !disabled) {
            _disabledEvents.remove(type, listener);
        }
        
        if (__events != null) {
            if (__events.remove(type, listener) == true) {
                unmapEvent(type, _onMappedEvent);
            }
        }
    }

    /**
     Dispatch a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function dispatch(event:UIEvent) {
        if (__events != null) {
            __events.invoke(event.type, event, this);
        }
        
        if (event.bubble == true && event.canceled == false && parentComponent != null) {
            parentComponent.dispatch(event);
        }
    }

    private function _onMappedEvent(event:UIEvent) {
        dispatch(event);
    }

    private var _disabledEvents:EventMap;
    private static var INTERACTIVE_EVENTS:Array<String> = [
        MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT, MouseEvent.MOUSE_DOWN,
        MouseEvent.MOUSE_UP, MouseEvent.MOUSE_WHEEL, MouseEvent.CLICK, KeyboardEvent.KEY_DOWN,
        KeyboardEvent.KEY_UP
    ];
    
    private function isInteractiveEvent(type:String):Bool {
        return INTERACTIVE_EVENTS.indexOf(type) != -1;
    }
    
    private var _disabledInteractivityCounter:Int = 0;
    private function disableInteractivity(disable:Bool) { // You might want to disable interactivity but NOT actually disable visually
        if (disable) {
            _disabledInteractivityCounter++;
        } else {
            _disabledInteractivityCounter--;
        }
        
        if (_disabledInteractivityCounter < 0 || _disabledInteractivityCounter > 1) {
            return;
        }
        
        if (_disabledInteractivityCounter == 1) {
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
        
        for (child in childComponents) {
            child.disableInteractivity(disable);
        }
    }
    
    //***********************************************************************************************************
    // Layout related
    //***********************************************************************************************************
    private var _includeInLayout:Bool = true;
    /**
     Whether to use this component as part of its part layout

     *Note*: invisible components are not included in parent layouts
    **/
    @:dox(group = "Layout related properties and methods")
    public var includeInLayout(get, set):Bool;
    private function get_includeInLayout():Bool {
        if (_hidden == true) {
            return false;
        }
        return _includeInLayout;
    }
    private function set_includeInLayout(value:Bool):Bool {
        _includeInLayout = value;
        return value;
    }

    private var _layout:Layout;
    /**
     The layout of this component
    **/
    @:dox(group = "Layout related properties and methods")
    public var layout(get, set):Layout;
    private function get_layout():Layout {
        return _layout;
    }
    private function set_layout(value:Layout):Layout {
        if (value == null) {
            //_layout = null;
            return value;
        }

        if (_layout != null && Type.getClassName(Type.getClass(value)) == Type.getClassName(Type.getClass(_layout))) {
            return value;
        }

        _layout = value;
        _layout.component = this;
        return value;
    }

    private var _layoutLocked:Bool = false;
    public function lockLayout(recursive:Bool = false) {
        if (_layoutLocked == true) {
            return;
        }

        _layoutLocked = true;
        if (recursive == true) {
            for (child in childComponents) {
                child.lockLayout(recursive);
            }
        }
    }

    public function unlockLayout(recursive:Bool = false) {
        if (_layoutLocked == false) {
            return;
        }

        if (recursive == true) {
            for (child in childComponents) {
                child.unlockLayout(recursive);
            }
        }

        _layoutLocked = false;
        invalidateComponentLayout();
    }

    //***********************************************************************************************************
    // Event handlers
    //***********************************************************************************************************
    private var _ready:Bool = false;
    /**
     Whether the framework considers this component ready or not
    **/
    public var isReady(get, null):Bool;
    private function get_isReady():Bool {
        return _ready;
    }

    /**
     Tells the framework this component is ready

     *Note*: this is called internally by the framework
    **/
    public function ready() {
        depth = ComponentUtil.getDepth(this);

        if (isComponentInvalid()) {
            _invalidateCount = 0;
            ValidationManager.instance.add(this);
        }

        if (_ready == false) {
            _ready = true;
            handleReady();

            initScript();

            if (childComponents != null) {
                for (child in childComponents) {
                    child.ready();
                }
            }

            invalidateComponent();

            onReady();
            dispatch(new UIEvent(UIEvent.READY));
        }
    }

    private function onReady() {
        behaviours.update();
    }
    
    private function onInitialize() {

    }

    private function onResized() {

    }

    private function onMoved() {

    }

    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    #if !flixel
    @:style                 public var color:Null<Color>;
    #end
    @:style                 public var backgroundColor:Null<Color>;
    @:style                 public var borderColor:Null<Color>;
    @:style                 public var borderSize:Null<Float>;
    @:style                 public var borderRadius:Null<Float>;

    @:style                 public var paddingLeft:Null<Float>;
    @:style                 public var paddingRight:Null<Float>;
    @:style                 public var paddingTop:Null<Float>;
    @:style                 public var paddingBottom:Null<Float>;

    @:style                 public var marginLeft:Null<Float>;
    @:style                 public var marginRight:Null<Float>;
    @:style                 public var marginTop:Null<Float>;
    @:style                 public var marginBottom:Null<Float>;
    @:style                 public var clip:Null<Bool>;

    @:style                 public var opacity:Null<Float>;

    @:style(layoutparent)   public var horizontalAlign:String;
    @:style(layoutparent)   public var verticalAlign:String;
    
    //***********************************************************************************************************
    // Size related
    //***********************************************************************************************************
    /**
     Whether this component will automatically resize itself based on it childrens calculated width
    **/
    @:dox(group = "Size related properties and methods")
    public var autoWidth(get, null):Bool;
    private function get_autoWidth():Bool {
        if (_percentWidth != null || _width != null || style == null) {
            return false;
        }
        if (style.autoWidth == null) {
            return false;
        }
        return style.autoWidth;
    }

    /**
     Whether this component will automatically resize itself based on it childrens calculated height
    **/
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
     Resize this components width and height in one call
    **/
    @:dox(group = "Size related properties and methods")
    public function resizeComponent(w:Null<Float>, h:Null<Float>) {
        var invalidate:Bool = false;
        
        if (style != null) {
            if (w != null) {
                if (style.minWidth != null && w < style.minWidth) {
                    w = style.minWidth;
                } else if (style.maxWidth != null && w > style.maxWidth) {
                    w = style.maxWidth;
                }
            }
            
            if (h != null) {
                if (style.minHeight != null && h < style.minHeight) {
                    h = style.minHeight;
                } else if (style.maxHeight != null && h > style.maxHeight) {
                    h = style.maxHeight;
                }
            }
        }
        
        
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
     Autosize this component based on its children
    **/
    @:dox(group = "Size related properties and methods")
    private function autoSize():Bool {
        if (_ready == false || _layout == null) {
           return false;
        }
        return layout.autoSize();
    }

    private var _percentWidth:Null<Float>;
    /**
     What percentage of this components parent to use to calculate its width
    **/
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
        }
        return value;
    }

    private var _percentHeight:Null<Float>;
    /**
     What percentage of this components parent to use to calculate its height
    **/
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
        }
        return value;
    }

    /**
     Whether or not a point is inside this components bounds

     *Note*: `left` and `top` must be stage (screen) co-ords
    **/
    @:dox(group = "Size related properties and methods")
    public function hitTest(left:Float, top:Float):Bool { // co-ords must be stage
        var b:Bool = false;
        var sx:Float = screenLeft;
        var sy:Float = screenTop;
        var cx:Float = 0;
        if (componentWidth != null) {
            cx = componentWidth;
        }
        var cy:Float = 0;
        if (componentHeight != null) {
            cy = componentHeight;
        }

        if (cx <= 0 || cy <= 0) {
            return false;
        }

        if (left >= sx && left < sx + cx && top >= sy && top < sy + cy) {
            b = true;
        }

        return b;
    }

    private var _componentWidth:Null<Float>;
    @:allow(haxe.ui.layouts.Layout)
    @:allow(haxe.ui.core.Screen)
    /**
     The calculated width of this component
    **/
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

    private var _componentHeight:Null<Float>;
    @:allow(haxe.ui.layouts.Layout)
    @:allow(haxe.ui.core.Screen)
    /**
     The calculated height of this component
    **/
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

    #if ((openfl || nme) && !flixel)

    #if flash @:setter(x) #else override #end
    public function set_x(value:Float): #if flash Void #else Float #end {
        #if flash
        super.x = value;
        #else
        super.set_x(value);
        #end
        left = value;
        #if !flash return value; #end
    }
    
    #if flash @:setter(y) #else override #end
    public function set_y(value:Float): #if flash Void #else Float #end {
        #if flash
        super.y = value;
        #else
        super.set_y(value);
        #end
        top = value;
        #if !flash return value; #end
    }
    
    private var _width:Null<Float>;
    #if flash @:setter(width) #else override #end
    private function set_width(value:Float): #if flash Void #else Float #end {
        if (_width == value) {
            return #if !flash value #end;
        }
        if (value == haxe.ui.util.MathUtil.MIN_INT) {
            _width = null;
            componentWidth = null;
        } else {
            _width = value;
            componentWidth = value;
        }
        #if !flash return value; #end
    }

    #if flash @:getter(width) #else override #end
    private function get_width():Float {
        var f:Float = componentWidth;
        return f;
    }

    private var _height:Null<Float>;
    #if flash @:setter(height) #else override #end
    private function set_height(value:Float): #if flash Void #else Float #end {
        if (_height == value) {
            return #if !flash value #end;
        }
        if (value == haxe.ui.util.MathUtil.MIN_INT) {
            _height = null;
            componentHeight = null;
        } else {
            _height = value;
            componentHeight = value;
        }
        #if !flash return value; #end
    }

    #if flash @:getter(height) #else override #end
    private function get_height():Float {
        var f:Float = componentHeight;
        return f;
    }

    #elseif (flixel)

    private var _width:Null<Float>;
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

    private var _height:Null<Float>;
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
     The width of this component
    **/
    @:dox(group = "Size related properties and methods")
    @bindable public var width(get, set):Null<Float>;
    private var _width:Null<Float>;
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
     The height of this component
    **/
    @:dox(group = "Size related properties and methods")
    @bindable public var height(get, set):Null<Float>;
    private var _height:Null<Float>;
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

    private var _actualWidth:Null<Float>;
    private var _actualHeight:Null<Float>;

    //***********************************************************************************************************
    // Position related
    //***********************************************************************************************************
    /**
     Move this components left and top co-ord in one call
    **/
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

    private var _left:Null<Float> = 0;
    /**
     The left co-ord of this component relative to its parent
    **/
    @:dox(group = "Position related properties and methods")
    public var left(get, set):Null<Float>;
    private function get_left():Null<Float> {
        return _left;
    }
    private function set_left(value:Null<Float>):Null<Float> {
        moveComponent(value, null);
        return value;
    }

    private var _top:Null<Float> = 0;
    /**
     The top co-ord of this component relative to its parent
    **/
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
     The left co-ord of this component relative to the screen
    **/
    @:dox(group = "Position related properties and methods")
    public var screenLeft(get, null):Float;
    private function get_screenLeft():Float {
        var c:Component = this;
        var xpos:Float = 0;
        while (c != null) {
            xpos += c.left;

            if (c.componentClipRect != null) {
                xpos -= c.componentClipRect.left;
            }

            c = c.parentComponent;
        }
        return xpos;
    }

    /**
     The top co-ord of this component relative to the screen
    **/
    @:dox(group = "Position related properties and methods")
    public var screenTop(get, null):Float;
    private function get_screenTop():Float {
        var c:Component = this;
        var ypos:Float = 0;
        while (c != null) {
            ypos += c.top;

            if (c.componentClipRect != null) {
                ypos -= c.componentClipRect.top;
            }

            c = c.parentComponent;
        }
        return ypos;
    }

    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    override public function createTextDisplay(text:String = null):TextDisplay {
        super.createTextDisplay();
        _textDisplay.parentComponent = this;
        return _textDisplay;
    }

    override public function createTextInput(text:String = null):TextInput {
        super.createTextInput();
        _textInput.parentComponent = this;
        return _textInput;
    }

    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    override public function createImageDisplay():ImageDisplay {
        super.createImageDisplay();
        _imageDisplay.parentComponent = this;
        return _imageDisplay;
    }

    //***********************************************************************************************************
    // Script related
    //***********************************************************************************************************
    /**
     Whether or not this component is allowed to be exposed to script interpreters (defaults to _true_)
    **/
    @:dox(group = "Script related properties and methods")
    public var scriptAccess:Bool = true;

    private var _interp:ScriptInterp;
    private var _script:String;
    /**
     A script string to associate with this component

     *Note*: setting this to non-null will cause this component to create and maintain its own script interpreter during initialsation
    **/
    @:dox(group = "Script related properties and methods")
    public var script(null, set):String;
    private function set_script(value:String):String {
        _script = value;
        return value;
    }

    /**
     Execute a script call

     *Note*: this component will first attempt to use its own script interpreter if its avialable otherwise it will scan its parents until it finds one
    **/
    @:dox(group = "Script related properties and methods")
    public function executeScriptCall(expr:String) {
        #if allow_script_errors
        try {
        #end
            var parser = new hscript.Parser();
            var line = parser.parseString(expr);
            var interp:ScriptInterp = findScriptInterp();
            interp.variables.set("this", this);
            interp.expr(line);
            interp.variables.remove("this");
        #if allow_script_errors
        } catch (e:Dynamic) {
            trace("Problem executing scriptlet: " + e);
            #if debug
                CallStackHelper.traceExceptionStack();
            #end
        }
        #end
    }

    private function findScriptInterp(refreshNamedComponents:Bool = true):ScriptInterp {
        var interp:ScriptInterp = null;
        var c:Component = this;
        while (c != null && interp == null) {
            if (c._interp != null) {
                interp = c._interp;
                break;
            }
            c = c.parentComponent;
        }

        if (interp == null) {
            c = rootComponent;
            c._interp = new ScriptInterp();
            interp = c._interp;
        }

        if (refreshNamedComponents == true && c != null) {
            var comps:Array<Component> = c.namedComponents;
            for (comp in comps) {
                var safeId = StringUtil.capitalizeHyphens(comp.id);
                interp.variables.set(safeId, comp);
            }
        }

        return interp;
    }

    private function initScript() {
        if (_script != null) {
            try {
                var parser = new hscript.Parser();
                var program = parser.parseString(_script);
                _interp = new ScriptInterp();

                var comps:Array<Component> = namedComponents;
                for (comp in comps) {
                    if (comp.scriptAccess == true) {
                        var safeId = StringUtil.capitalizeHyphens(comp.id);
                        _interp.variables.set(safeId, comp);
                    }
                }

                _interp.execute(program);
            } catch (e:Dynamic) {
                #if neko
                trace("Problem initializing script");
                #else
                trace("Problem initializing script: " + e);
                #end
                CallStackHelper.traceExceptionStack();
            }
        }
    }

    private var _scriptEvents:Map<String, String>;
    /**
     Registers a piece of hscript to be execute when a certain `UIEvent` is fired
    **/
    @:dox(group = "Script related properties and methods")
    public function addScriptEvent(event:String, script:String) {
        event = event.toLowerCase();
        var eventName = StringTools.startsWith(event, "on") ? event.substring(2, event.length) : event;
        if (_scriptEvents == null) {
            _scriptEvents = new Map<String, String>();
        }
        _scriptEvents.set(event, script);
        registerEvent(eventName, _onScriptEvent.bind(event, _));
    }

    private function _onScriptEvent(eventId:String, event:UIEvent) {
        if (_scriptEvents != null) {
            var script:String = _scriptEvents.get(eventId);
            if (script != null) {
                event.cancel();
                executeScriptCall(script);
            }
        }
    }

    /**
     Recursively generates list of all child components that have specified an `id`
    **/
    @:dox(group = "Script related properties and methods")
    public var namedComponents(get, null):Array<Component>;
    private function get_namedComponents():Array<Component> {
        var list:Array<Component> = [];
        addNamedComponentsFrom(this, list);
        return list;
    }

    private static function addNamedComponentsFrom(parent:Component, list:Array<Component>) {
        if (parent == null) {
            return;
        }

        if (parent.id != null) {
            list.push(parent);
        }

        for (child in parent.childComponents) {
            addNamedComponentsFrom(child, list);
        }
    }

    private var __onClick:MouseEvent->Void;
    /**
     Utility property to add a single `UIEvent.CLICK` event
    **/
    @:dox(group = "Event related properties and methods")
    public var onClick(null, set):MouseEvent->Void;
    private function set_onClick(value:MouseEvent->Void):MouseEvent->Void {
        if (__onClick != null) {
            unregisterEvent(MouseEvent.CLICK, __onClick);
            __onClick = null;
        }
        registerEvent(MouseEvent.CLICK, value);
        __onClick = value;
        return value;
    }

    private var __onChange:UIEvent->Void;
    /**
     Utility property to add a single `UIEvent.CHANGE` event
    **/
    @:dox(group = "Event related properties and methods")
    public var onChange(null, set):UIEvent->Void;
    private function set_onChange(value:UIEvent->Void):UIEvent->Void {
        if (__onChange != null) {
            unregisterEvent(UIEvent.CHANGE, __onChange);
            __onChange = null;
        }
        registerEvent(UIEvent.CHANGE, value);
        __onChange = value;
        return value;
    }

    //***********************************************************************************************************
    // Invalidation
    //***********************************************************************************************************

    private var _invalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    private var _delayedInvalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    private var _isAllInvalid:Bool = false;
    private var _isValidating:Bool = false;
    private var _isInitialized:Bool = false;
    private var _isDisposed:Bool = false;
    private var _invalidateCount:Int = 0;

    private var _depth:Int = -1;
    @:dox(hide)
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
     Validate this component and its children on demand.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function syncComponentValidation() {
        var count:Int = 0;
        while(isComponentInvalid()) {
            validateComponent();

            for (child in childComponents) {
                child.syncComponentValidation();
            }

            if (++count >= 10) {
                throw 'The syncValidation returned too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls invalidate() during validation.';
            }
        }
    }

    /**
     This method validates the tasks pending in the component.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function validateComponent() {
        if (_ready == false ||
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

        validateComponentInternal();

        if (isInitialized == false && _style != null) {
            if ((_style.initialWidth != null || _style.initialPercentWidth != null) && width <= 0) {
                if (_style.initialWidth != null) {
                    width = _style.initialWidth;
                } else  if (_style.initialPercentWidth != null) {
                    percentWidth = _style.initialPercentWidth;
                }
            }
            
            if ((_style.initialHeight != null || _style.initialPercentHeight != null) && height <= 0) {
                if (_style.initialHeight != null) {
                    height = _style.initialHeight;
                } else  if (_style.initialPercentHeight != null) {
                    percentHeight = _style.initialPercentHeight;
                }
            }
        }
        
        for (flag in _invalidationFlags.keys()) {
            _invalidationFlags.remove(flag);
        }

        _isAllInvalid = false;

        for (flag in _delayedInvalidationFlags.keys()) {
            if (flag == InvalidationFlags.ALL) {
                _isAllInvalid = true;
            } else {
                _invalidationFlags.set(flag, true);
            }
            _delayedInvalidationFlags.remove(flag);
        }
        _isValidating = false;
    }

    private function initializeComponent() {
        if (_isInitialized == true) {
            return;
        }

        onInitialize();

        if (_layout == null) {
            layout = createLayout();
        }

        _isInitialized = true;

        if (hasEvent(UIEvent.INITIALIZE)) {
            dispatch(new UIEvent(UIEvent.INITIALIZE));
        }
    }

    private function validateComponentInternal() {
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
            ValidationManager.instance.addDisplay(this);    //Update the display from all objects at the same time. Avoids UI flashes.
        }
    }

    private function validateComponentData() {
        behaviours.validateData();
    }

    /**
     Return true if the size has changed.
    **/
    private function validateComponentLayout():Bool {
        layout.refresh();

        //TODO - Required. Something is wrong with the autosize order in the first place if we need to do that twice. Revision required for performance.
        while(validateComponentAutoSize()) {
            layout.refresh();
        }

        var sizeChanged = false;
        if (_componentWidth != _actualWidth || _componentHeight != _actualHeight) {
            _actualWidth = _componentWidth;
            _actualHeight = _componentHeight;

            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }

            onResized();
            dispatch(new UIEvent(UIEvent.RESIZE));

            sizeChanged = true;
        }
        
        if (_compositeBuilder != null) {
            sizeChanged = _compositeBuilder.validateComponentLayout() || sizeChanged;
        }
        
        return sizeChanged;
    }

    private function validateComponentStyle() {
        var s:Style = Toolkit.styleSheet.buildStyleFor(this);
        s.apply(customStyle);

        if (_style == null || _style.equalTo(s) == false) { // lets not update if nothing has changed
            _style = s;
            applyStyle(s);
        }
    }

    private function validateComponentPosition() {
        handlePosition(_left, _top, _style);

        onMoved();
        dispatch(new UIEvent(UIEvent.MOVE));
    }

    public function updateComponentDisplay() {
        if (componentWidth == null || componentHeight == null || componentWidth <= 0 || componentHeight <= 0) {
            return;
        }

        handleSize(componentWidth, componentHeight, _style);
        
        if (_componentClipRect != null ||
            (style != null && style.clip != null && style.clip == true)) {
            handleClipRect(_componentClipRect != null ? _componentClipRect : new Rectangle(0, 0, componentWidth, componentHeight));
        }
    }

    /**
     Return true if the size calculated has changed and the autosize is enabled.
    **/
    private function validateComponentAutoSize():Bool {
        var invalidate:Bool = false;
        if (autoWidth == true || autoHeight == true) {
            var s:Size = layout.calcAutoSize();
            if (autoWidth == true) {
                if (s.width != _componentWidth) {
                    _componentWidth = s.width;
                    invalidate = true;
                }
            }
            if (autoHeight == true) {
                if (s.height != _componentHeight) {
                    _componentHeight = s.height;
                    invalidate = true;
                }
            }
        }

        return invalidate;
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
    public function invalidateComponent(flag:String = InvalidationFlags.ALL) {
        if (_ready == false) {
            return;     //it should be added into the queue later
        }

        var isAlreadyInvalid:Bool = isComponentInvalid();
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

            ValidationManager.instance.add(this);
            return;
        } else if (isAlreadyInvalid == true) {
            return;
        }

        _invalidateCount = 0;
        ValidationManager.instance.add(this);
    }

    /**
     Invalidate the data of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentData() {
        invalidateComponent(InvalidationFlags.DATA);
    }

    /**
     Invalidate this components layout, may result in multiple calls to `invalidateDisplay` and `invalidateLayout` of its children
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentLayout() {
        if (_layout == null || _layoutLocked == true) {
            return;
        }
        invalidateComponent(InvalidationFlags.LAYOUT);
    }

    /**
     Invalidate the position of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentPosition() {
        invalidateComponent(InvalidationFlags.POSITION);
    }

    /**
     Invalidate the visible aspect of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentDisplay() {
        invalidateComponent(InvalidationFlags.DISPLAY);
    }

    /**
     Invalidate and recalculate this components style, may result in a call to `invalidateDisplay`
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentStyle(force:Bool = false) {
        invalidateComponent(InvalidationFlags.STYLE);
        if (force == true) {
            _style = null;
        }
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);

        if (style.left != null) {
            left = style.left;
        }
        if (style.top != null) {
            top = style.top;
        }
        
        if (style.percentWidth != null) {
            percentWidth = style.percentWidth;
        }
        if (style.percentHeight != null) {
            percentHeight = style.percentHeight;
        }
        if (style.width != null) {
            width = style.width;
        }
        if (style.height != null) {
            height = style.height;
        }

        if (style.native != null) {
            native = style.native;
        }

        if (style.hidden != null) {
            hidden = style.hidden;
        }

        if (style.animationName != null) {
            var animationKeyFrames:AnimationKeyFrames = Toolkit.styleSheet.animations.get(style.animationName);
            applyAnimationKeyFrame(animationKeyFrames, style.animationOptions);
        } else if (componentAnimation != null) {
            componentAnimation = null;
        }

        /*
        if (style.clip != null) {
            clipContent = style.clip;
        }

        if (style.native != null) {
            if (style.backgroundImageSliceTop == null
                && style.backgroundImageSliceLeft == null
                && style.backgroundImageSliceBottom == null
                && style.backgroundImageSliceRight == null) {
                native = style.native;
            }
        }

        if (style.backgroundImageSliceTop != null
            && style.backgroundImageSliceLeft != null
            && style.backgroundImageSliceBottom != null
            && style.backgroundImageSliceRight != null) {
            native = false;
        }
        */
        
        if (_compositeBuilder != null) {
            _compositeBuilder.applyStyle(style);
        }
    }

    //***********************************************************************************************************
    // Animation
    //***********************************************************************************************************

    private function applyAnimationKeyFrame(animationKeyFrames:AnimationKeyFrames, options:AnimationOptions):Void {
        if (_animatable == false || options == null || options.duration == 0 ||
            (_componentAnimation != null && options.compareToAnimation(_componentAnimation) == true)) {
            return;
        }

        if (hasEvent(AnimationEvent.START)) {
            dispatch(new AnimationEvent(AnimationEvent.START));
        }

        componentAnimation = Animation.createWithKeyFrames(animationKeyFrames, this, options);
        componentAnimation.run(function(){
            if (hasEvent(AnimationEvent.END)) {
                dispatch(new AnimationEvent(AnimationEvent.END));
            }
        });
    }

    //***********************************************************************************************************
    // Clonable
    //***********************************************************************************************************
    public function cloneComponent():Component {
        if (_ready == false) {
            //ready();
        }
        if (autoWidth == false && this.width > 0) {
            c.width = this.width;
        }
        if (autoHeight == false && this.height > 0) {
            c.height = this.height;
        }
        if (_scriptEvents != null) {
            for (k in _scriptEvents.keys()) {
                c.addScriptEvent(k, _scriptEvents.get(k));
            }
        }
    }

    //***********************************************************************************************************
    // Properties
    //***********************************************************************************************************

    /**
     Gets a property that is associated with all classes of this type
    **/
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

    private var _classProperties:Map<String, String>;
    /**
     Sets a property that is associated with all classes of this type
    **/
    public function setClassProperty(name:String, value:String) {
        if (_classProperties == null) {
            _classProperties = new Map<String, String>();
        }
        _classProperties.set(name, value);
    }

    private function getNativeConfigProperty(query:String, defaultValue:String = null):String {
        query = 'component[id=${className}]${query}';
        return Toolkit.nativeConfig.query(query, defaultValue, this);
    }

    private function getNativeConfigPropertyBool(query:String, defaultValue:Bool = false):Bool {
        query = 'component[id=${className}]${query}';
        return Toolkit.nativeConfig.queryBool(query, defaultValue, this);
    }

    private function getNativeConfigProperties(query:String = ""):Map<String, String> {
        query = 'component[id=${className}]${query}';
        return Toolkit.nativeConfig.queryValues(query, this);
    }

    public var className(get, null):String;
    private function get_className():String {
        if (Std.is(this, Dialog2)) {
            return Type.getClassName(Dialog2);
        }
        return Type.getClassName(Type.getClass(this));
    }

    public var cssName(get, null):String;
    private function get_cssName():String {
        return Type.getClassName(Type.getClass(this)).split(".").pop().toLowerCase();
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
    
    public override function invalidateData() {
        if (_value) {
            _component.addClass(":disabled", true, true);
            _component.dispatch(new UIEvent(UIEvent.DISABLED));
        } else {
            _component.removeClass(":disabled", true, true);
            _component.dispatch(new UIEvent(UIEvent.ENABLED));
        }
        _component.disableInteractivity(_value);
    }
}
