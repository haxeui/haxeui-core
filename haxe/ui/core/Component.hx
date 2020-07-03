package haxe.ui.core;

import haxe.ui.backend.ComponentImpl;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.debug.CallStackHelper;
import haxe.ui.events.AnimationEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.DelegateLayout;
import haxe.ui.layouts.Layout;
import haxe.ui.scripting.ScriptInterp;
import haxe.ui.styles.Parser;
import haxe.ui.styles.Style;
import haxe.ui.styles.animation.Animation;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.util.Color;
import haxe.ui.util.ComponentUtil;
import haxe.ui.util.MathUtil;
import haxe.ui.util.StringUtil;
import haxe.ui.validation.IValidating;
import haxe.ui.validation.ValidationManager;

/**
 Base class of all HaxeUI controls
**/
@:allow(haxe.ui.backend.ComponentImpl)
@:build(haxe.ui.macros.Macros.build())
@:autoBuild(haxe.ui.macros.Macros.build())
class Component extends ComponentImpl implements IComponentBase implements IValidating {
    public function new() {
        super();

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
        if (native == false || native == null) {
            registerComposite();
        }
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

    private var _compositeBuilderClass:Class<CompositeBuilder>;
    private var _compositeBuilder:CompositeBuilder;
    private function registerComposite() {
    }
    
    private function createDefaults() {
    }
    
    private function createChildren() {

    }

    private function destroyChildren() {
        unregisterInternalEvents();
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
    //private var _behaviourUpdateOrder:Array<String> = [];

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
        customStyle.native = value;
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
    

    /**
     Reference to the `Screen` object this component is displayed on
    **/
    public var screen(get, null):Screen;
    private function get_screen():Screen {
        return Toolkit.screen;
    }

    //***********************************************************************************************************
    // Binding related
    //***********************************************************************************************************
    @:dox(group = "Internal")
    public var bindingRoot:Bool = false;
    //***********************************************************************************************************

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
    public override function addComponent(child:Component):Component {
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

        assignPositionClasses();
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
    public override function addComponentAt(child:Component, index:Int):Component {
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

        assignPositionClasses();
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
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (child == null) {
            return null;
        }
        
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.removeComponent(child, dispose, invalidate);
            if (v != null) {
                return v;
            }
        }
        
        if (_children != null) {
            if (_children.remove(child)) {
                child.parentComponent = null;
                child.depth = -1;
            }
            if (dispose == true) {
                child._isDisposed = true;
                child.removeAllComponents(true);
                child.unregisterEvents();
                child.destroyComponent();
            }
        }
        handleRemoveComponent(child, dispose);
        assignPositionClasses(invalidate);
        if (_children != null && invalidate == true) {
            invalidateComponentLayout();
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
    public override function removeComponentAt(index:Int, dispose:Bool = true, invalidate:Bool = true):Component {
        if (_children == null) {
            return null;
        }
        
        var childCount:Int = _children.length;
        if (_compositeBuilder != null) {
            var compositeChildCount = _compositeBuilder.numComponents;
            if (compositeChildCount != null) {
                childCount = compositeChildCount;
            }
        }
        
        if (index < 0 || index > childCount - 1) {
            return null;
        }
        
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.removeComponentAt(index, dispose, invalidate);
            if (v != null) {
                return v;
            }
        }
        
        handleRemoveComponentAt(index, dispose);
        var child = _children[index];
        if (_children != null) {
            if (_children.remove(child)) {
                child.parentComponent = null;
                child.depth = -1;
            }
            assignPositionClasses(invalidate);
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
    
    private function assignPositionClasses(invalidate:Bool = true) {
        for (i in 0...childComponents.length) {
            var c = childComponents[i];
            if (i == 0) {
                c.swapClass("first", "last", invalidate);
            } else if (childComponents.length > 1 && i == childComponents.length - 1) {
                c.swapClass("last", "first", invalidate);
            } else {
                c.removeClasses(["first", "last"], invalidate);
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
     Walk all children recursively, callback should return "true" if walking should continue
    **/
    public function walkComponents(callback:Component->Bool) {
        if (callback(this) == false) {
            return;
        }
        
        for (child in childComponents) {
            if (callback(child) == false) {
                return;
            }
        }
        
        for (child in childComponents) {
            var cont = true;
            child.walkComponents(function(c) {
                cont = callback(c);
                return cont;
            });
            
            if (cont == false) {
                break;
            }
        }
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

    private function matchesSearch<T>(criteria:String = null, type:Class<T> = null, searchType:String = "id"):Bool {
        if (criteria != null) {
            return searchType == "id" && id == criteria || searchType == "css" && hasClass(criteria) == true;
        } else if (type != null) {
            return Std.is(this, type) == true;
        }
	   return false;
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
            if (child.matchesSearch(criteria, type, searchType)) {
                 match = child;
                 break;
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
            if (match == null && _compositeBuilder != null) {
                match = _compositeBuilder.findComponent(criteria, type,recursive, searchType);
            }
        }

        return cast match;
    }

    public function findComponents<T:Component>(styleName:String = null, type:Class<T> = null, maxDepth:Int = 5):Array<T> {
        if (maxDepth == -1) {
            maxDepth = 100;
        }
        if (maxDepth <= 0) {
            return [];
        }
        
        maxDepth--;
        
        var r:Array<T> = [];
        for (child in childComponents) {
            var match = true;
            if (styleName != null && child.hasClass(styleName) == false) {
                match = false;
            }
            if (type != null && Std.is(child, type) == false) {
                match = false;
            }
            
            if (match == true) {
                r.push(cast child);
            } else {
                var childArray = child.findComponents(styleName, type, maxDepth);
                for (c in childArray) { // r.concat caused issues here on hxcpp
                    r.push(c);
                }
            }
        }
        return r;
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
            if (p.matchesSearch(criteria, type, searchType)) {
                 match = p;
                 break;
            } else {
                 p = p.parentComponent;
            }
        }
        return cast match;
    }
    
    public function findComponentsUnderPoint<T:Component>(screenX:Float, screenY:Float, type:Class<T> = null):Array<Component> {
        var c:Array<Component> = [];
        if (hitTest(screenX, screenY)) {
            for (child in childComponents) {
                if (child.hitTest(screenX, screenY)) {
                    var match = true;
                    if (type != null && Std.is(child, type) == false) {
                        match = false;
                    }
                    if (match == true) {
                        c.push(child);
                    }
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
            var v = _compositeBuilder.getComponentAt(index);
            if (v != null) {
                return v;
            }
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
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.hide();
            if (v == true) {
                return;
            }
        }
        
        if (_hidden == false) {
            handleVisibility(false);
            _hidden = true;
            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }
            
            dispatchRecursively(new UIEvent(UIEvent.HIDDEN));
        }
    }

    /**
     Shows this component and all its children
    **/
    @:dox(group = "Display tree related properties and methods")
    public function show() {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.show();
            if (v == true) {
                return;
            }
        }
        
        if (_hidden == true) {
            handleVisibility(true);
            _hidden = false;
            invalidateComponentLayout();
            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }
            
            dispatchRecursively(new UIEvent(UIEvent.SHOWN));
        }
    }

    private var _hidden:Bool = false;
    /**
     Whether this component is hidden or not
    **/
    @:dox(group = "Display tree related properties and methods")
    @:clonable public var hidden(get, set):Bool;
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

    //***********************************************************************************************************
    // Style related
    //***********************************************************************************************************
    /**
     A custom style object that will appled to this component after any css rules have been matched and applied
    **/
    @:dox(group = "Style related properties and methods")
    public var customStyle(default, set):Style = {};
    function set_customStyle(v:Style) {
        if(v != customStyle) 
            invalidateComponentStyle();
        return customStyle = v;
    }
    @:dox(group = "Style related properties and methods")
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
     Adds a css style names to this component
    **/
    @:dox(group = "Style related properties and methods")
    public function addClasses(names:Array<String>, invalidate:Bool = true, recursive:Bool = false) {
        var needsInvalidate = false;
        for (name in names) {
            if (classes.indexOf(name) == -1) {
                classes.push(name);
                if (invalidate == true) {
                    needsInvalidate = true;
                }
            }
        }
		
        if (needsInvalidate == true) {
            invalidateComponentStyle();
        }
        
		if (recursive == true) {
			for (child in childComponents) {
				child.addClasses(names, invalidate, recursive);
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
     Removes a css style names from this component
    **/
    @:dox(group = "Style related properties and methods")
    public function removeClasses(names:Array<String>, invalidate:Bool = true, recursive:Bool = false) {
        var needsInvalidate = false;
        for (name in names) {
            if (classes.indexOf(name) != -1) {
                classes.remove(name);
                if (invalidate == true) {
                    needsInvalidate = true;
                }
            }
        }

        if (needsInvalidate == true) {
            invalidateComponentStyle();
        }
        
		if (recursive == true) {
			for (child in childComponents) {
				child.removeClasses(names, invalidate, recursive);
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
     Adds a css style name to this component
    **/
    @:dox(group = "Style related properties and methods")
    public function swapClass(classToAdd:String, classToRemove:String = null, invalidate:Bool = true, recursive:Bool = false) {
        var needsInvalidate = false;
        if (classToAdd != null && classes.indexOf(classToAdd) == -1) {
            classes.push(classToAdd);
            needsInvalidate = true;
        }
		
        if (classToRemove != null && classes.indexOf(classToRemove) != -1) {
            classes.remove(classToRemove);
            needsInvalidate = true;
        }
        
        if (invalidate == true && needsInvalidate == true) {
            invalidateComponentStyle();
        }
        
		if (recursive == true) {
			for (child in childComponents) {
				child.swapClass(classToAdd, classToRemove, invalidate, recursive);
			}
		}
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

    //private var _layout:Layout;
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

            behaviours.update();
            Toolkit.callLater(function() {
                invalidateComponentData();
                invalidateComponentStyle();
                
                if (_compositeBuilder != null) {
                    _compositeBuilder.onReady();
                }
                
                onReady();
                
                dispatch(new UIEvent(UIEvent.READY));
            });
        }
    }

    private function onReady() {
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
    #if !(haxeui_flixel || haxeui_heaps)
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
    public function executeScriptCall(expr:String, variables:Map<String, Any> = null) {
        #if allow_script_errors
        try {
        #end
            var parser = new hscript.Parser();
            var line = parser.parseString(expr);
            var interp:ScriptInterp = findScriptInterp();
            interp.variables.set("this", this);
            if (variables != null) {
                for (k in variables.keys()) {
                    interp.variables.set(k, variables.get(k));
                }
            }
            interp.expr(line);
            interp.variables.remove("this");
            if (variables != null) {
                for (k in variables.keys()) {
                    interp.variables.remove(k);
                }
            }
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
    
    public var scriptEvents(get, null):Map<String, String>;
    private function get_scriptEvents():Map<String, String> {
        return _scriptEvents;
    }
    
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
                var variables = new Map<String, Any>();
                variables.set("event", event);
                executeScriptCall(script, variables);
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

    @:event(AnimationEvent.START)       public var onAnimationStart:AnimationEvent->Void;
    @:event(AnimationEvent.END)         public var onAnimationEnd:AnimationEvent->Void;
    
    /**
     Utility property to add a single `MouseEvent.CLICK` event
    **/
    @:event(MouseEvent.CLICK)           public var onClick:MouseEvent->Void;
    
    /**
     Utility property to add a single `MouseEvent.RIGHT_CLICK` event
    **/
    @:event(MouseEvent.RIGHT_CLICK)     public var onRightClick:MouseEvent->Void;
    
    /**
     Utility property to add a single `UIEvent.CHANGE` event
    **/
    @:event(UIEvent.CHANGE)             public var onChange:UIEvent->Void;

    //***********************************************************************************************************
    // Invalidation
    //***********************************************************************************************************

    private function onThemeChanged() {
        _initialSizeApplied = false;
        if (_style != null) {
            if (_style.initialWidth != null) {
                width = 0;
            }
            if (_style.initialPercentWidth != null) {
                percentWidth = null;
            }
            if (_style.initialHeight != null) {
                height = 0;
            }
            if (_style.initialPercentHeight != null) {
                percentHeight = null;
            }
        }
    }
    
    private override function initializeComponent() {
        if (_isInitialized == true) {
            return;
        }

        if (_compositeBuilder != null) {
            _compositeBuilder.onInitialize();
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

    private var _initialSizeApplied:Bool = false;
    private override function validateInitialSize(isInitialized:Bool) {
        if (isInitialized == false && _style != null && _initialSizeApplied == false) {
            if ((_style.initialWidth != null || _style.initialPercentWidth != null) && (width <= 0 && percentWidth == null)) {
                if (_style.initialWidth != null) {
                    width = _style.initialWidth;
                    _initialSizeApplied = true;
                } else  if (_style.initialPercentWidth != null) {
                    percentWidth = _style.initialPercentWidth;
                    _initialSizeApplied = true;
                }
            }
            
            if ((_style.initialHeight != null || _style.initialPercentHeight != null) && (height <= 0 && percentHeight == null)) {
                if (_style.initialHeight != null) {
                    height = _style.initialHeight;
                    _initialSizeApplied = true;
                } else  if (_style.initialPercentHeight != null) {
                    percentHeight = _style.initialPercentHeight;
                    _initialSizeApplied = true;
                }
            }
        }
    }
    
    /**
     Return true if the size has changed.
    **/
    private override function validateComponentLayout():Bool {
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

    private override function validateComponentStyle() {
        var s:Style = Toolkit.styleSheet.buildStyleFor(this);
        s.apply(customStyle);

        if (_style == null || _style.equalTo(s) == false) { // lets not update if nothing has changed
            
            var marginsChanged = false;
            if (parentComponent != null && _style != null) {
                marginsChanged = _style.marginLeft != s.marginLeft || _style.marginRight != s.marginRight ||  _style.marginTop != s.marginTop ||  _style.marginBottom != s.marginBottom;
            }
            
            _style = s;
            applyStyle(s);
            if (marginsChanged == true) {
                parentComponent.invalidateComponentLayout();
            }
        }
    }

    private override function validateComponentPosition() {
        handlePosition(_left, _top, _style);

        onMoved();
        dispatch(new UIEvent(UIEvent.MOVE));
    }

    @:dox(group = "Internal")
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

    private override function applyStyle(style:Style) {
        super.applyStyle(style);

        if (style != null && _initialSizeApplied == false) {
            if ((style.initialWidth != null || style.initialPercentWidth != null) && (width <= 0 && percentWidth == null)) {
                if (style.initialWidth != null) {
                    width = style.initialWidth;
                    _initialSizeApplied = true;
                } else  if (style.initialPercentWidth != null) {
                    percentWidth = style.initialPercentWidth;
                    _initialSizeApplied = true;
                }
            }
            
            if ((style.initialHeight != null || style.initialPercentHeight != null) && (height <= 0 && percentHeight == null)) {
                if (style.initialHeight != null) {
                    height = style.initialHeight;
                    _initialSizeApplied = true;
                } else  if (style.initialPercentHeight != null) {
                    percentHeight = style.initialPercentHeight;
                    _initialSizeApplied = true;
                }
            }
        }
        
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

        if (style.pointerEvents != null && style.pointerEvents != "none") {
            if (hasEvent(MouseEvent.MOUSE_OVER, onPointerEventsMouseOver) == false) {
                customStyle.cursor = "pointer";
                registerEvent(MouseEvent.MOUSE_OVER, onPointerEventsMouseOver);
            }
            if (hasEvent(MouseEvent.MOUSE_OUT, onPointerEventsMouseOut) == false) {
                registerEvent(MouseEvent.MOUSE_OUT, onPointerEventsMouseOut);
            }
            if (hasEvent(MouseEvent.MOUSE_DOWN, onPointerEventsMouseDown) == false) {
                registerEvent(MouseEvent.MOUSE_DOWN, onPointerEventsMouseDown);
            }
            if (hasEvent(MouseEvent.MOUSE_UP, onPointerEventsMouseUp) == false) {
                registerEvent(MouseEvent.MOUSE_UP, onPointerEventsMouseUp);
            }
        } else {
            if (hasEvent(MouseEvent.MOUSE_OVER, onPointerEventsMouseOver) == true) {
                customStyle.cursor = null;
                unregisterEvent(MouseEvent.MOUSE_OVER, onPointerEventsMouseOver);
            }
            if (hasEvent(MouseEvent.MOUSE_OUT, onPointerEventsMouseOut) == true) {
                unregisterEvent(MouseEvent.MOUSE_OUT, onPointerEventsMouseOut);
            }
            if (hasEvent(MouseEvent.MOUSE_DOWN, onPointerEventsMouseDown) == true) {
                unregisterEvent(MouseEvent.MOUSE_DOWN, onPointerEventsMouseDown);
            }
            if (hasEvent(MouseEvent.MOUSE_UP, onPointerEventsMouseUp) == true) {
                unregisterEvent(MouseEvent.MOUSE_UP, onPointerEventsMouseUp);
            }
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

    private function onPointerEventsMouseOver(e:MouseEvent) {
        addClass(":hover", true, true);
    }
    
    private function onPointerEventsMouseOut(e:MouseEvent) {
        removeClass(":hover", true, true);
    }
    
    private function onPointerEventsMouseDown(e:MouseEvent) {
        addClass(":down", true, true);
    }
    
    private function onPointerEventsMouseUp(e:MouseEvent) {
        removeClass(":down", true, true);
    }
    
    //***********************************************************************************************************
    // Animation
    //***********************************************************************************************************

    private function applyAnimationKeyFrame(animationKeyFrames:AnimationKeyFrames, options:AnimationOptions):Void {
        if (_animatable == false || options == null || options.duration == 0 ||
            (_componentAnimation != null && _componentAnimation.name == animationKeyFrames.id && options.compareToAnimation(_componentAnimation) == true)) {
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
    public override function cloneComponent():Component {
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
        if (customStyle != null) {
            if (c.customStyle == null) {
                c.customStyle = {};
            }
            c.customStyle.apply(customStyle);
        }
    }
    
    //***********************************************************************************************************
    // Properties
    //***********************************************************************************************************
    public var cssName(get, null):String;
    private function get_cssName():String {
        var cssName:String = null;
        if (_compositeBuilder != null) {
            cssName = _compositeBuilder.cssName;
        }
        if (cssName == null) {
            cssName = Type.getClassName(Type.getClass(this)).split(".").pop().toLowerCase();
        }
        return cssName;
    }
}

