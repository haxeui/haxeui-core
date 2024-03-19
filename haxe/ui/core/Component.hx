package haxe.ui.core;

import haxe.ui.backend.ComponentImpl;
import haxe.ui.events.AnimationEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.DelegateLayout;
import haxe.ui.layouts.Layout;
import haxe.ui.locale.LocaleManager;
import haxe.ui.styles.DirectiveHandler;
import haxe.ui.styles.Parser;
import haxe.ui.styles.Style;
import haxe.ui.styles.StyleSheet;
import haxe.ui.styles.animation.Animation;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.util.Color;
import haxe.ui.util.ComponentUtil;
import haxe.ui.util.MathUtil;
import haxe.ui.util.StringUtil;
import haxe.ui.util.Variant;
import haxe.ui.validation.IValidating;
import haxe.ui.validation.InvalidationFlags;
import haxe.ui.validation.ValidationManager;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

/**
 * Base class of all HaxeUI controls
 */
@:allow(haxe.ui.backend.ComponentImpl)
class Component extends ComponentImpl
    #if haxeui_allow_drag_any_component
    implements haxe.ui.extensions.Draggable
    #end
    implements IValidating {

    /**
     * Creates a new, default, HaxeUI `Component`.
     */
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

        #if !haxeui_suppress_warnings
        if (Toolkit.initialized == false) {
            trace("WARNING: You are trying to create a component before the toolkit has been initialized. This could have undefined results.");
        }
        #end
    }

    public var componentTabIndex:Int = 0;
    
    //***********************************************************************************************************
    // Construction
    //***********************************************************************************************************
    @:noCompletion private var _defaultLayoutClass:Class<Layout> = null;
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
        Toolkit.callLater(function() {
            var event = new UIEvent(UIEvent.COMPONENT_CREATED, true);
            event.relatedComponent = this;
            dispatch(event);
        });
        onComponentCreated();
    }

    private function onComponentCreated() {

    }

    @:noCompletion private var _compositeBuilderClass:Class<CompositeBuilder>;
    @:noCompletion private var _compositeBuilder:CompositeBuilder;
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

    @:noCompletion private var _native:Null<Bool> = null;
    /**
     * When enabled, HaxeUI will try  to use a native version of this component.
     */
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

    @:noCompletion private var _animatable:Bool = true;

    /**
     * Whether this component is allowed to animate or not.
     */
    public var animatable(get, set):Bool;
    private function get_animatable():Bool {
        #if haxeui_hxwidgets
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

    @:noCompletion private var _componentAnimation:Animation;

    /**
     * The currently running animation.
     */
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
     * Can be used to store specific data relating to the component, or other things in your application.
     */
    public var userData(default, default):Dynamic = null;

    public function userDataAs<T>(c:Class<T>):T {
        return cast userData;
    }

    //***********************************************************************************************************
    // General
    //***********************************************************************************************************

    /**
     * The `Screen` object this component is displayed on.
     */
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
     * The top-level component of this component's parent tree.
     */
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
     * Gets the number of children added to this component.
     */
    @:dox(group = "Display tree related properties and methods")
    public var numComponents(get, never):Int;
    private function get_numComponents():Int {
        var n = 0;
        if (_compositeBuilder != null) {
            var builderCount = _compositeBuilder.numComponents;
            if (builderCount != null) {
                n = builderCount;
            } else if (_children != null) {
                n = _children.length;
            }
        } else if (_children != null) {
            n = _children.length;
        }
        return n;
    }

    /**
     * Adds a component to the end of this component's display list.
     * 
     * If this component already has children, the given component is added in front of the other children.
     * 
     * @param child The child component to add to this component.
     * @return The added component.
     */
    @:dox(group = "Display tree related properties and methods")
    public override function addComponent(child:Component):Component {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.addComponent(child);
            if (v != null) {
                v.scriptAccess = this.scriptAccess;
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
        if (_componentReady) {
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
        var event = new UIEvent(UIEvent.COMPONENT_ADDED);
        event.relatedComponent = child;
        dispatch(event);
        child.dispatch(new UIEvent(UIEvent.COMPONENT_ADDED_TO_PARENT));

        child.scriptAccess = this.scriptAccess;
        return child;
    }

    /**
     * Returns `true` if the given component is a child of this component, `false` otherwise.
     * 
     * @param child The child component to check against.
     * @return Is the child component a child of this component?
     */
    public override function containsComponent(child:Component):Bool {
        if (child == null) {
            return false;
        }
        var contains = false;
        this.walkComponents(function(c) {
            if (child == c) {
                contains = true;
            }
            return !contains;
        });
        return contains;
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
    @:dox(group = "Display tree related properties and methods")
    public override function addComponentAt(child:Component, index:Int):Component {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.addComponentAt(child, index);
            if (v != null) {
                v.scriptAccess = this.scriptAccess;
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
        if (_componentReady) {
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
        dispatch(new UIEvent(UIEvent.COMPONENT_ADDED));
        child.dispatch(new UIEvent(UIEvent.COMPONENT_ADDED_TO_PARENT));

        child.scriptAccess = this.scriptAccess;
        return child;
    }

    private function onComponentAdded(child:Component) {
    }

    /**
     * Removes a child component from this component's display list, and returns it.
     * 
     * @param child The child component to remove from this component.
     * @param dispose Decides whether or not the child component should be destroyed too.
     * @param invalidate If `true`, the child component updates itself after the removal.
     * @return The removed child component
     */
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
            if (_children.indexOf(child) == -1) {
                var childId = child.className;
                if (child.id != null) {
                    childId += "#" + child.id;
                }
                var thisId = this.className;
                if (this.id != null) {
                    thisId += "#" + this.id;
                }
                trace("WARNING: trying to remove a child (" + childId + ") that is not a child of this component (" + thisId + ")");
                return child;
            }
            if (_children.remove(child)) {
                child.parentComponent = null;
                child.depth = -1;
            }
            if (dispose == true) {
                child.disposeComponent();
            } else {
                child.dispatch(new UIEvent(UIEvent.HIDDEN));
                // sometimes (on some backends, like browser), mouse out doesnt fire when removing from screen
                child.removeClass(":hover", false, true);
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
        var event = new UIEvent(UIEvent.COMPONENT_REMOVED);
        event.relatedComponent = child;
        dispatch(event);
        child.dispatch(new UIEvent(UIEvent.COMPONENT_REMOVED_FROM_PARENT));

        return child;
    }

    /**
     * Removes this component from memory.
     * 
     * Calling methods/using fields on this component after calling `disposeComponent`
     * is undefined behaviour, and could result in a null pointer exception/`x` is null exceptions.
     */
    public function disposeComponent() {
        if (this._isDisposed) {
            return;
        }

        this._isDisposed = true;
        this.removeAllComponents(true);
        this.destroyComponent();
        this.unregisterEventsInternal();
        if (this.hasTextDisplay()) {
            this.getTextDisplay().dispose();
        }
        if (this.hasTextInput()) {
            this.getTextInput().dispose();
        }
        if (this.hasImageDisplay()) {
            this.getImageDisplay().dispose();
        }
        if (behaviours != null) {
            behaviours.dispose();
            behaviours = null;
        }
        if (_layout != null) {
            _layout.component = null;
            _layout = null;
        }
        if (_internalEvents != null) {
            _internalEvents.onDispose();
            @:privateAccess _internalEvents._target = null;
            _internalEvents = null;
        }
        parentComponent = null;
    }
    
    /**
     * Removes the child component at index `index` from this component's display list, and returns it.
     * 
     * @param index The index of the child component to remove from this component.
     * @param dispose Decides whether or not the child component should be destroyed too.
     * @param invalidate If `true`, the child component updates itself after the removal.
     * @return The removed child component
     */
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

        var child = _children[index];
        if (child == null) {
            return null;
        }
        
        if (dispose == true) {
            child._isDisposed = true;
            child.removeAllComponents(true);
        } else {
            child.dispatch(new UIEvent(UIEvent.HIDDEN));
            // sometimes (on some backends, like browser), mouse out doesnt fire when removing from screen
            child.removeClass(":hover", false, true);
        }
        handleRemoveComponentAt(index, dispose);
        if (_children.remove(child)) {
            child.parentComponent = null;
            child.depth = -1;
        }
        if (dispose == true) {
            child.destroyComponent();
            child.unregisterEventsInternal();
        }
        
        assignPositionClasses(invalidate);
        if (invalidate == true) {
            invalidateComponentLayout();
        }

        if (_compositeBuilder != null) {
            _compositeBuilder.onComponentRemoved(child);
        }

        onComponentRemoved(child);
        dispatch(new UIEvent(UIEvent.COMPONENT_REMOVED));
        child.dispatch(new UIEvent(UIEvent.COMPONENT_REMOVED_FROM_PARENT));

        return child;
    }

    private function onComponentRemoved(child:Component) {
    }

    private function assignPositionClasses(invalidate:Bool = true) {
        if (childComponents.length == 1) {
            childComponents[0].addClasses(["first", "last"], invalidate);
            return;
        }
        var effectiveChildCount = 0;
        for (i in 0...childComponents.length) {
            var c = childComponents[i];
            if (!c.includeInLayout) {
                continue;
            }
            effectiveChildCount++;
        }
        var n = 0;
        for (i in 0...childComponents.length) {
            var c = childComponents[i];
            if (!c.includeInLayout) {
                continue;
            }
            if (i == 0) {
                c.swapClass("first", "last", invalidate);
            } else if (i == effectiveChildCount - 1) {
                c.swapClass("last", "first", invalidate);
            } else {
                c.removeClasses(["first", "last"], invalidate);
            }
            n++;
        }
    }

    private function destroyComponent() {
        if (_compositeBuilder != null) {
            _compositeBuilder.destroy();
        }
        LocaleManager.instance.unregisterComponent(this);
        handleDestroy();
        onDestroy();
    }

    private function onDestroy() {
        for (child in childComponents) {
            child.onDestroy();
        }
        dispatch(new UIEvent(UIEvent.HIDDEN));
        dispatch(new UIEvent(UIEvent.DESTROY));
    }

    /**
     * Iterates over the children components and calls `callback()` on each of them, recursively. 
     * The children's children are also included in the walking, and so are those children's children...
     *
     * @param callback a callback that receives one component, and returns whether the walking should continue or not.
     */
    public function walkComponents(callback:Component->Bool) {
        if (callback(this) == false) {
            return;
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
     * Removes all child component from this component's display tree.
     * 
     * @param dispose Decides whether or not the child component should be destroyed too.
     */
    @:dox(group = "Display tree related properties and methods")
    public function removeAllComponents(dispose:Bool = true) {
        if (_compositeBuilder != null) {
            var b = _compositeBuilder.removeAllComponents(dispose);
            if (b == true) {
                return;
            }
        }
        
        if (_children != null) {
            while (_children.length > 0) {
                if (dispose) {
                    _children[0].removeAllComponents(dispose);
                }
                removeComponent(_children[0], dispose, false);
            }
            invalidateComponentLayout();
        }
    }

    private function matchesSearch<T>(criteria:String = null, type:Class<T> = null, searchType:String = "id"):Bool {
        if (criteria != null) {
            if (searchType == "id" && id == criteria ||  searchType == "css" && hasClass(criteria) == true) {
                if (type != null) {
                    return isOfType(this, type);
                }
                return true;
            }
        } else if (type != null) {
            return isOfType(this, type);
        }
        return false;
    }

    /**
     * Finds a specific child in this components display tree (recursively if desired) and can optionally cast the result.
     * 
     * @param criteria The criteria by which to search, the interpretation of this is defined using `searchType` (the default search type is `id`).
     * @param type The component class you wish to cast the result to (defaults to `null`).
     * @param recursive Whether to search this components children and all its children's children till it finds a match (the default depends on the `searchType` param. If `searchType` is `id` the default is *true* otherwise it is `false`)
     * @param searchType Allows you specify how to consider a child a match (defaults to *id*), can be either: **`id`** - The first component that has the id specified in `criteria` will be considered a match, *or*, **`css`** - The first component that contains a style name specified by `criteria` will be considered a match.
     * @return The found component, or `null` if no component was found.
     */
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
                match = _compositeBuilder.findComponent(criteria, type, recursive, searchType);
            }
        }

        return cast match;
    }

    /**
     * Finds all components with a specific style in this components display tree.
     * 
     * @param styleName The style name to search for
     * @param type The component class you wish to cast the result to (defaults to `null`, which means casting to the default, `Component` type).
     * @param maxDepth how many children "deep" should the search go to find components. defaults to `5`.
     * @return An array of the found components.
     */
    public function findComponents<T:Component>(styleName:String = null, type:Class<T> = null, maxDepth:Int = 5):Array<T> {
        if (maxDepth == -1) {
            maxDepth = 100;
        }
        if (maxDepth <= 0) {
            return [];
        }

        maxDepth--;

        var r:Array<T> = [];
        if (_compositeBuilder != null) {
            var childArray = _compositeBuilder.findComponents(styleName, type, maxDepth);
            if (childArray != null) {
                for (c in childArray) { // r.concat caused issues here on hxcpp
                    r.push(c);
                }
            }
        }
        
        for (child in childComponents) {
            var match = true;
            if (styleName != null && child.hasClass(styleName) == false) {
                match = false;
            }
            if (type != null && isOfType(child, type) == false) {
                match = false;
            }

            // bit of a special case here: if we are looking for interactive components
            // we DONT want to include all the interactives that are built out of other
            // interactives, for example, as number stepper has buttons and a textfield,
            // none of which we want when looking for interactives, we would expect just
            // the number stepper
            var continueRecursion = true;
            if ((child is ICompositeInteractiveComponent) && type == cast InteractiveComponent) {
                continueRecursion = false;
            }

            if (match == true) {
                r.push(cast child);
            }

            if (continueRecursion) {
                var childArray = child.findComponents(styleName, type, maxDepth);
                for (c in childArray) { // r.concat caused issues here on hxcpp
                    r.push(c);
                }
            }
    }
        
        return r;
    }

    @:dox(group = "Display tree related properties and methods")
    /**
     * Finds a specific parent in this components display tree and can optionally cast the result
     * 
     * @param criteria The criteria by which to search, the interpretation of this is defined using `searchType` (the default search type is `id`)
     * @param type The component class you wish to cast the result to (defaults to `null`)
     * @param searchType Allows you specify how to consider a parent a match (defaults to `id`), can be either: **`id`** - The first component that has the id specified in `criteria` will be considered a match, *or*, **`css`** - The first component that contains a style name specified by `criteria` will be considered a match
     * @return the found ancestor, or null if no ancestor is found.
     */
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

    /**
      Whether or not a point is inside this components bounds
 
      *Note*: `left` and `top` must be stage (screen) co-ords
     **/
     @:dox(group = "Size related properties and methods")
    public override function hitTest(left:Null<Float>, top:Null<Float>, allowZeroSized:Bool = false):Bool { // co-ords must be stage
        if (hidden) {
            return false;
        }

        return super.hitTest(left, top, allowZeroSized);
    }

     /**
     * Lists components under a specific point in global, screen coordinates.
     * 
     * Note: this function will return *every single* components at a specific point, 
     * even if they have no backgrounds, or haven't got anything drawn onto them. 
     * 
     * @param screenX The global, on-screen `x` position of the point to check for components under
     * @param screenY The global, on-screen `y` position of the point to check for components under
     * @param type Used to filter all components that aren't of a specific type. `null` by default, which means no filter is applied.
     * @return An array of all components that overlap the "global" position `(x, y)`
     */
    public function findComponentsUnderPoint<T:Component>(screenX:Float, screenY:Float, type:Class<T> = null):Array<Component> {
        var c:Array<Component> = [];
        if (hitTest(screenX, screenY, false)) {
            for (child in childComponents) {
                if (child.hitTest(screenX, screenY, false)) {
                    var match = true;
                    if (type != null && isOfType(child, type) == false) {
                        match = false;
                    }
                    if (match == true) {
                        c.push(child);
                    }
                    c = c.concat(child.findComponentsUnderPoint(screenX, screenY, type));
                }
            }
        }
        return c;
    }

    /**
     * Finds out if there is a component under a specific point in global coordinates.
     * 
     * @param screenX The global, on-screen `x` position of the point to check for components under
     * @param screenY The global, on-screen `y` position of the point to check for components under
     * @param type Used to filter all components that aren't of a specific type. `null` by default, which means no filter is applied.
     * @return `true` if there is a component that overlaps the global position `(x, y)`, `false` otherwise.
     */ 
    public function hasComponentUnderPoint<T:Component>(screenX:Float, screenY:Float, type:Class<T> = null):Bool {
        var b = false;
        if (hitTest(screenX, screenY, false)) {
            if (type == null) {
                return true;
            }
            for (child in childComponents) {
                if (child.hitTest(screenX, screenY, false)) {
                    var match = true;
                    if (type != null && isOfType(child, type) == false) {
                        match = false;
                    }
                    if (match == false) {
                        match = child.hasComponentUnderPoint(screenX, screenY, type);
                    }
                    if (match == true) {
                        b = match;
                        break;
                    }
                }
            }
        }
        return b;
    }
    
    /**
     * Gets the index of `child` under this component. Returns `-1` if `child` isn't a child of this component.
     * @param child The child to get the index of.
     * @return It's index, or `-1` if the child wan't found.
     */
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

    /**
     * Sets the index of `child` under this component, essentially moving it forwards/backwards.
     * @param child The child to set the index of.
     * @param index the index to set to.
     * @return the child component.
     */
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
     * Gets the child component at a specific index. If this component has no children, `null` is returned.
     * @param index the child's index
     * @return the child at the given index, or `null` if this component has no children.
     */
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
     * Hides this component, and all it's children.
     */
    @:dox(group = "Display tree related properties and methods")
    public function hide() {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.hide();
            if (v == true) {
                return;
            }
        }

        if (_hidden == false) {
            _hidden = true;
            handleVisibility(false);
            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }

            dispatchRecursively(new UIEvent(UIEvent.HIDDEN));
        }
    }

    private function hideInternal(dispatchChildren:Bool = false) {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.hide();
            if (v == true) {
                return;
            }
        }

        if (_hidden == false) {
            _hidden = true;
            handleVisibility(false);
            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }

            if (dispatchChildren == true) {
                dispatchRecursively(new UIEvent(UIEvent.HIDDEN));
            } else {
                dispatch(new UIEvent(UIEvent.HIDDEN));
            }
        }
    }
    
    // we want to invalidate all child components the first time we are showing a component
    // this isnt needed all the time (hence why we dont want to recursively invalidate every time)
    // but avoids layout issues when sub components are being added (cloned) as hidden and later shown
    private var _invalidateRecursivelyOnShow:Bool = true;
    /**
     * Shows this component and all it's children
     */
    @:dox(group = "Display tree related properties and methods")
    public function show() {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.show();
            if (v == true) {
                return;
            }
        }

        if (_hidden == true) {
            _hidden = false;
            handleVisibility(true);
            invalidateComponentLayout(_invalidateRecursivelyOnShow);
            _invalidateRecursivelyOnShow = false;
            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }

            dispatchRecursively(new UIEvent(UIEvent.SHOWN));
        }
    }

    private function showInternal(dispatchChildren:Bool = false) {
        if (_compositeBuilder != null) {
            var v = _compositeBuilder.show();
            if (v == true) {
                return;
            }
        }

        if (_hidden == true) {
            _hidden = false;
            handleVisibility(true);
            invalidateComponentLayout();
            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }

            if (dispatchChildren == true) {
                dispatchRecursively(new UIEvent(UIEvent.SHOWN));
            } else {
                dispatch(new UIEvent(UIEvent.SHOWN));
            }
        }
    }
    
    /**
     * Applies a fade effect which turns this component from invisible to visible.
     * @param onEnd A function to dispatch when the fade completes
     * @param show When enabled, ensures that this component is actually visible when the fade completes.
     */
    public function fadeIn(onEnd:Void->Void = null, show:Bool = true) {
        if (onEnd != null || show == true) {
            var prevStart = onAnimationStart;
            var prevEnd = onAnimationEnd;
            if (show == true) {
                prevStart = onAnimationStart;
                onAnimationStart = function(e) {
                    this.show();
                    onAnimationStart = prevStart;
                }
            }

            onAnimationEnd = function(e) {
                removeClass("fade-in");
                onAnimationEnd = prevEnd;
                if (onEnd != null) {
                    onEnd();
                }
            }
        }
        swapClass("fade-in", "fade-out");
    }

    /**
     * Applies a fade effect which turns this component from visible to invisible.
     * @param onEnd A function to dispatch when the fade completes
     * @param hide When enabled, ensures that this component is actually invisible when the fade completes.
     */
    public function fadeOut(onEnd:Void->Void = null, hide:Bool = true) {
        if (onEnd != null || hide == true) {
            var prevEnd = onAnimationEnd;
            onAnimationEnd = function(e) {
                if (hide == true) {
                    this.hide();
                }
                onAnimationEnd = prevEnd;
                removeClass("fade-out");
                if (onEnd != null) {
                    onEnd();
                }
            }
        }
        swapClass("fade-out", "fade-in");
    }

    @:noCompletion private var _hidden:Bool = false;

    /**
     * Whether this component is visible or not.
     */
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
        dispatch(new UIEvent(UIEvent.PROPERTY_CHANGE, "hidden"));
        return value;
    }

    //***********************************************************************************************************
    // Style related
    //***********************************************************************************************************

    @:noCompletion private var _customStyle:Style = null;

    /**
     * A custom style object that will applied to this component after any css rules have been matched and applied.
     * 
     * Use this when modifying this component's style through code.
     */
    @:dox(group = "Style related properties and methods")
    public var customStyle(get, set):Style;
    private function get_customStyle():Style {
        if (_customStyle == null) {
            _customStyle = {};
        }
        return _customStyle;
    }
    private function set_customStyle(value:Style):Style {
        if (value != _customStyle) {
            invalidateComponentStyle();
        }
        _customStyle = value;
        return value;
    }
    @:dox(group = "Style related properties and methods")
    private var classes:Array<String> = [];

    private var cascadeActive:Bool = false;
    
    /**
     * Adds a `css` class name to this component.
     * 
     * @param name The `css` class name.
     * @param invalidate Should this component update after adding the class?
     * @param recursive When enabled, recursively adds the class to this component's children.
     */
    @:dox(group = "Style related properties and methods")
    public function addClass(name:String, invalidate:Bool = true, recursive:Bool = false) {
        if (classes.indexOf(name) == -1) {
            classes.push(name);
            if (invalidate == true) {
                invalidateComponentStyle();
            }
        }

        if (recursive == true || (cascadeActive == true && name == ":active")) {
            for (child in childComponents) {
                child.addClass(name, invalidate, recursive);
            }
        }
    }

    /**
     * Adds multiple `css` class names to this component.
     * 
     * @param names The `css` class names.
     * @param invalidate Should this component update after adding the class?
     * @param recursive When enabled, recursively adds the class to this component's children.
     */
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
     * Removes a `css` class name from this component.
     * 
     * @param name The `css` class name.
     * @param invalidate Should this component update after adding the class?
     * @param recursive When enabled, recursively adds the class to this component's children.
     */
    @:dox(group = "Style related properties and methods")
    public function removeClass(name:String, invalidate:Bool = true, recursive:Bool = false) {
        if (classes.indexOf(name) != -1) {
            classes.remove(name);
            if (invalidate == true) {
                invalidateComponentStyle();
            }
        }

        if (recursive == true || (cascadeActive == true && name == ":active")) {
            for (child in childComponents) {
                child.removeClass(name, invalidate, recursive);
            }
        }
    }

    /**
     * Removes multiple `css` class names from this component.
     * 
     * @param names The `css` class names.
     * @param invalidate Should this component update after adding the class?
     * @param recursive When enabled, recursively adds the class to this component's children.
     */
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
     * Returns `true` if this components has the `css` class `name`, `false` otherwise.
     * @param name The `css` class name.
     * @return Does this component contain the given `css` class?
     */
    @:dox(group = "Style related properties and methods")
    public inline function hasClass(name:String):Bool {
        return (classes.indexOf(name) != -1);
    }

    /**
     * Swaps a `css` class with another `css` class.
     * 
     * @param classToAdd The `css` class name to add.
     * @param classToRemove The `css` class name to remove.
     * @param invalidate Should this component update after adding the class?
     * @param recursive When enabled, recursively adds the class to this component's children.
     */
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
     * A string representation of the `css` classes associated with this component
     */
    private var _styleNames:String = null;
    private var _styleNamesList:Array<String> = null;
    @:dox(group = "Style related properties and methods")
    @clonable public var styleNames(get, set):String;
    private function get_styleNames():String {
        return _styleNames;
    }
    private function set_styleNames(value:String):String {
        if (value == _styleNames) {
            return value;
        }

        if (value == null) {
            value = "";
        }

        _styleNames = value;
        var newStyleNamesList = [];
        var classesToAdd = [];
        var requiresInvalidation = false;
        for (x in value.split(" ")) {
            x = StringTools.trim(x);
            if (x.length == 0) {
                continue;
            }
            newStyleNamesList.push(x);
            if (_styleNamesList != null) {
                if (_styleNamesList.indexOf(x) == -1) {
                    classesToAdd.push(x);
                    requiresInvalidation = true;
                }
            } else {
                classesToAdd.push(x);
                requiresInvalidation = true;
            }
        }

        var classesToRemove = [];
        if (_styleNamesList != null) {
            for (x in _styleNamesList) {
                if (newStyleNamesList.indexOf(x) == -1) {
                    classesToRemove.push(x);
                    requiresInvalidation = true;
                }
            }
        }

        _styleNamesList = newStyleNamesList;

        if (requiresInvalidation) {
            for (x in classesToAdd) {
                addClass(x, false, false);
            }
            for (x in classesToRemove) {
                removeClass(x, false, false);
            }

            invalidateComponent(InvalidationFlags.ALL, true);
        }

        return value;
    }

    @:noCompletion private var _styleString:String;

    /**
     * Used to parse an apply an inline `css` string to this component as a custom style.
     */
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

    // were going to cache the ref (which may be null) so we dont have to
    // perform a parent based lookup each for a performance tweak
    @:noCompletion private var _useCachedStyleSheetRef:Bool = false;
    @:noCompletion private var _cachedStyleSheetRef:StyleSheet = null;
    @:noCompletion private var _styleSheet:StyleSheet = null;
    public var styleSheet(get, set):StyleSheet;
    private function get_styleSheet():StyleSheet {
        if (_useCachedStyleSheetRef == true) {
            return _cachedStyleSheetRef;
        }

        var s = null;
        var ref = this;
        while (ref != null) {
            if (ref._styleSheet != null) {
                s = ref._styleSheet;
                break;
            }
            ref = ref.parentComponent;
        }

        _useCachedStyleSheetRef = true;
        _cachedStyleSheetRef = s;

        return s;
    }
    private function set_styleSheet(value:StyleSheet):StyleSheet {
        _styleSheet = value;
        resetCachedStyleSheetRef();
        return value;
    }
    private function resetCachedStyleSheetRef() {
        _cachedStyleSheetRef = null;
        _useCachedStyleSheetRef = false;
        for (c in childComponents) {
            c.resetCachedStyleSheetRef();
        }
    }

    //***********************************************************************************************************
    // Layout related
    //***********************************************************************************************************
    @:noCompletion private var _includeInLayout:Bool = true;
    /**
     * Whether to use this component as part of its part layout
     * 
     * Note*: invisible components are not included in parent layouts
     */
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

    /**
     * The layout of this component
     */
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
     * Tells the framework this component is ready to render
     *
     * *Note*: this is called internally by the framework
     */
    public function ready() {
        depth = ComponentUtil.getDepth(this);

        if (isComponentInvalid()) {
            _invalidateCount = 0;
            ValidationManager.instance.add(this);
        }

        if (_componentReady == false) {
            _componentReady = true;
            handleReady();

            if (childComponents != null) {
                for (child in childComponents) {
                    child.ready();
                }
            }

            invalidateComponent();

            behaviours.ready();
            behaviours.update();
            Toolkit.callLater(function() {
                invalidateComponentData();
                invalidateComponentStyle();

                if (_compositeBuilder != null) {
                    _compositeBuilder.onReady();
                }

                onReady();

                dispatch(new UIEvent(UIEvent.READY));
                if (_hidden == false) {
                    dispatch(new UIEvent(UIEvent.SHOWN));
                }
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
    /** The color of the text **/                                                   @:style                 public var color:Null<Color>;
    #end
    @:style                 public var backgroundColor:Null<Color>;
    @:style                 public var backgroundColorEnd:Null<Color>;
    @:style                 public var backgroundImage:Variant;
    /** The color of the border **/                                                 @:style                 public var borderColor:Null<Color>;
    /** The size of the border, in pixels **/                                       @:style                 public var borderSize:Null<Float>;
    /** The amount of rounding to apply to the border **/                           @:style                 public var borderRadius:Null<Float>;

    /** The gap between the component and its children, on all sides **/            @:style(layout)         public var padding:Null<Float>;
    /** The gap between the component and its children, on the top **/              @:style(layout)         public var paddingLeft:Null<Float>;
    /** The gap between the component and its children, on the left side **/        @:style(layout)         public var paddingRight:Null<Float>;
    /** The gap between the component and its children, on the right side **/       @:style(layout)         public var paddingTop:Null<Float>;
    /** The gap between the component and its children, on the bottom **/           @:style(layout)         public var paddingBottom:Null<Float>;

    /** The horizontal spacing between the component's children in pixels **/       @:style(layout)         public var horizontalSpacing:Null<Float>;
    /** The vertical spacing between the component's children in pixels **/         @:style(layout)         public var verticalSpacing:Null<Float>;

    /** The amount of left offsetting to apply to the calculated position **/       @:style                 public var marginLeft:Null<Float>;
    /** The amount of right offsetting to apply to the calculated position**/       @:style                 public var marginRight:Null<Float>;
    /** The amount of top offsetting to apply to the calculated position **/        @:style                 public var marginTop:Null<Float>;
    /** The amount of bottom offsetting to apply to the calculated position **/     @:style                 public var marginBottom:Null<Float>;
    /** Whether the children are clipped (cut) to the the component boundings **/   @:style                 public var clip:Null<Bool>;

    /** A value between 0 and 1, deciding the transparency of this object **/       @:style                 public var opacity:Null<Float>;

    /** How the component is aligned to the parent: center, left, right **/         @:style(layoutparent)   public var horizontalAlign:String;
    /** How the component is aligned to the parent: center, top, bottom **/         @:style(layoutparent)   public var verticalAlign:String;

    //***********************************************************************************************************
    // Script related
    //***********************************************************************************************************
    
    @:noCompletion private var _scriptAccess:Bool = true;
    @:dox(group = "Script related properties and methods")

    /**
     * Whether or not this component is allowed to be exposed to script interpreters (defaults to `true`)
     */
    public var scriptAccess(get, set):Bool;
    private function get_scriptAccess():Bool {
        return _scriptAccess;
    }
    private function set_scriptAccess(value:Bool):Bool {
        if (value == _scriptAccess) {
            return value;
        }
        
        _scriptAccess = value;
        for (child in childComponents) {
            child.scriptAccess = value;
        }
        
        return value;
    }
    
    @:dox(group = "Script related properties and methods")
    public var namedComponents(get, null):Array<Component>;
    private function get_namedComponents():Array<Component> {
        var list:Array<Component> = [];
        addNamedComponentsFrom(this, list);
        return list;
    }

    public var namedComponentsMap(get, null):Map<String, Component>;
    private function get_namedComponentsMap():Map<String, Component> {
        var map = new Map<String, Component>();
        for (c in namedComponents) {
            map.set(c.id, c);
        }
        return map;
    }

    /**
     * Adds multiple components from `parent`, which name can be found in `list`.
     * 
     * @param parent The parent component. to add from.
     * @param list The name list to check against.
     */
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

    /**
     * Utility property to add a single `AnimationEvent.START` event
     */
    @:event(AnimationEvent.START)       public var onAnimationStart:AnimationEvent->Void;
    
    /**
     * Utility property to add a single `AnimationEvent.FRAME` event
     */
    @:event(AnimationEvent.FRAME)       public var onAnimationFrame:AnimationEvent->Void;
    
    /**
     * Utility property to add a single `AnimationEvent.END` event
     */
    @:event(AnimationEvent.END)         public var onAnimationEnd:AnimationEvent->Void;

    /**
     * Utility property to add a single `MouseEvent.CLICK` event
     */
    @:event(MouseEvent.CLICK)           public var onClick:MouseEvent->Void;

    /**
     * Utility property to add a single `MouseEvent.MOUSE_OVER` event
     */
    @:event(MouseEvent.MOUSE_OVER)      public var onMouseOver:MouseEvent->Void;

    /**
     * Utility property to add a single `MouseEvent.MOUSE_OUT` event
     */
    @:event(MouseEvent.MOUSE_OUT)       public var onMouseOut:MouseEvent->Void;
    
    /**
     * Utility property to add a single `MouseEvent.DBL_CLICK` event
     */
    @:event(MouseEvent.DBL_CLICK)       public var onDblClick:MouseEvent->Void;

    /**
     * Utility property to add a single `MouseEvent.RIGHT_CLICK` event
     */
    @:event(MouseEvent.RIGHT_CLICK)     public var onRightClick:MouseEvent->Void;

    /**
     * Utility property to add a single `UIEvent.CHANGE` event
     */
    @:event(UIEvent.CHANGE)             public var onChange:UIEvent->Void;

    //***********************************************************************************************************
    // Invalidation
    //***********************************************************************************************************

    private function onThemeChanged() {
        /*
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
        */
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

    @:noCompletion private var _initialSizeApplied:Bool = false;
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

    private override function validateComponentData() {
        behaviours.validateData();
        
        if (_compositeBuilder != null) {
            _compositeBuilder.validateComponentData();
        }
    }
    
    /**
     * Return true if the size has changed.
     */
    private override function validateComponentLayout():Bool {
        layout.refresh();

        //TODO - Required. Something is wrong with the autosize order in the first place if we need to do that twice. Revision required for performance.
        while (validateComponentAutoSize()) {
            layout.refresh();
        }

        var sizeChanged = false;
        if (_componentWidth != _actualWidth || _componentHeight != _actualHeight) {
            _actualWidth = _componentWidth;
            _actualHeight = _componentHeight;
            
            enforceSizeConstraints();

            if (parentComponent != null) {
                parentComponent.invalidateComponentLayout();
            }

            onResized();
            #if !(haxeui_hxwidgets) // TODO: temp until better way
            dispatch(new UIEvent(UIEvent.RESIZE));
            #end

            sizeChanged = true;
        }

        if (_compositeBuilder != null) {
            sizeChanged = _compositeBuilder.validateComponentLayout() || sizeChanged;
        }

        return sizeChanged;
    }

    private function enforceSizeConstraints() {
        if (style != null) {
            // enforce min width
            if (style.minWidth != null && _componentWidth < style.minWidth) {
                _componentWidth = _actualWidth = _width = style.minWidth;
            }
            
            // enforce max width
            if (style.maxWidth != null && style.maxPercentWidth == null && _componentWidth > style.maxWidth) {
                _componentWidth = _actualWidth = _width = style.maxWidth;
            } else if (style.maxWidth == null && style.maxPercentWidth != null) {
                var p = this;
                var max:Float = 0;
                while (p != null) {
                    if (p.style != null && p.style.maxPercentWidth == null) {
                        max += p.width;
                        break;
                    }
                    if (p.style != null && p != this) {
                        max -= (p.style.paddingLeft + p.style.paddingRight);
                    }
                    p = p.parentComponent;
                }
                max = (max * style.maxPercentWidth) / 100;
                if (max > 0 && _componentWidth > max) {
                    _componentWidth = _actualWidth = _width = max;
                }
            }
            
            // enforce min height
            if (style.minHeight != null && _componentHeight < style.minHeight) {
                _componentHeight = _actualHeight = _height = style.minHeight;
            }
            
            // enforce max height
            if (style.maxHeight != null && style.maxPercentHeight == null && _componentHeight > style.maxHeight) {
                _componentHeight = _actualHeight = _height = style.maxHeight;
            } else if (style.maxHeight == null && style.maxPercentHeight != null) {
                var p = this;
                var max:Float = 0;
                while (p != null) {
                    if (p.style != null && p.style.maxPercentHeight == null) {
                        max += p.height;
                        break;
                    }
                    if (p.style != null && p != this) {
                        max -= (p.style.paddingTop + p.style.paddingBottom);
                    }
                    p = p.parentComponent;
                }
                max = (max * style.maxPercentHeight) / 100;
                if (max > 0 && _componentHeight > max) {
                    _componentHeight = _actualHeight = _height = max;
                }
            }
        }
    }

    private override function validateComponentStyle() {
        var s:Style = Toolkit.styleSheet.buildStyleFor(this);
        if (this.styleSheet != null) {
            var localStyle = this.styleSheet.buildStyleFor(this);
            s.apply(localStyle);
        }
        s.apply(customStyle);

        if (_style == null || _style.equalTo(s) == false) { // lets not update if nothing has changed

            var marginsChanged = false;
            if (parentComponent != null && _style != null) {
                marginsChanged = _style.marginLeft != s.marginLeft || _style.marginRight != s.marginRight ||  _style.marginTop != s.marginTop ||  _style.marginBottom != s.marginBottom;
            }
            var bordersChanged = false;
            if (_style != null && _style.fullBorderSize != s.fullBorderSize) {
                bordersChanged = true;
            }

            _style = s;
            applyStyle(s);
            if (bordersChanged == true) {
                invalidateComponentLayout();
            }
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
        if (componentWidth == null || componentHeight == null) {
            return;
        }

        handleSize(componentWidth, componentHeight, _style);

        #if (haxeui_hxwidgets) // TODO: temp until better way
        dispatch(new UIEvent(UIEvent.RESIZE));
        #end

        if (_componentClipRect != null ||
            (style != null && style.clip != null && style.clip == true)) {
            handleClipRect(_componentClipRect != null ? _componentClipRect : new Rectangle(0, 0, componentWidth, componentHeight));
        }
    }

    /**
     * Return true if the size calculated has changed and the autosize is enabled.
     */
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

    @:noCompletion 
    private var _pauseAnimationStyleChanges:Bool = false;
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
            _width = null;
            componentWidth = null;
            percentWidth = style.percentWidth;
        }
        if (style.percentHeight != null) {
            _height = null;
            componentHeight = null;
            percentHeight = style.percentHeight;
        }
        if (style.width != null) {
            percentWidth = null;
            width = style.width;
        }
        if (style.height != null) {
            percentHeight = null;
            height = style.height;
        }

        if (style.native != null) {
            native = style.native;
        }

        if (style.hidden != null) {
            hidden = style.hidden;
        }

        if (_pauseAnimationStyleChanges == false) {
            if (style.animationName != null) {
                var animationKeyFrames:AnimationKeyFrames = Toolkit.styleSheet.animations.get(style.animationName);
                applyAnimationKeyFrame(animationKeyFrames, style.animationOptions);
            } else if (componentAnimation != null) {
                componentAnimation = null;
            }
        }

        if (style.pointerEvents != null && style.pointerEvents != "none") {
            if (hasEvent(MouseEvent.MOUSE_OVER, onPointerEventsMouseOver) == false) {
                if (style.cursor == null) {
                    customStyle.cursor = "pointer";
                }
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
            handleFrameworkProperty("allowMouseInteraction", true);
        } else if (style.pointerEvents != null) {
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
            handleFrameworkProperty("allowMouseInteraction", false);
        }
        
        if (style.includeInLayout != null) {
            this.includeInLayout = style.includeInLayout;
        }

        if (style.customDirectives != null) {
            for (directive in style.customDirectives.keys()) {
                if (DirectiveHandler.hasDirectiveHandler(directive)) {
                    var handler = DirectiveHandler.getDirectiveHandler(directive);
                    if (handler != null) {
                        handler.apply(this, style.customDirectives.get(directive));
                    }
                }
            }
        }

        if (_compositeBuilder != null) {
            _compositeBuilder.applyStyle(style);
        }
    }

    private var recursivePointerEvents:Bool = true;
    private function onPointerEventsMouseOver(e:MouseEvent) {
        addClass(":hover", true, recursivePointerEvents);
    }

    private function onPointerEventsMouseOut(e:MouseEvent) {
        removeClass(":hover", true, recursivePointerEvents);
    }

    private function onPointerEventsMouseDown(e:MouseEvent) {
        addClass(":down", true, recursivePointerEvents);
    }

    private function onPointerEventsMouseUp(e:MouseEvent) {
        removeClass(":down", true, recursivePointerEvents);
    }

    //***********************************************************************************************************
    // Animation
    //***********************************************************************************************************

    private function applyAnimationKeyFrame(animationKeyFrames:AnimationKeyFrames, options:AnimationOptions) {
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
    
    /**
     * Gets a complete copy of this component.
     * @return A new component, similar to this one.
     */
    public override function cloneComponent():Component {
        if (_componentReady == false) {
            //ready();
        }

        if (this.layout != null) {
            c.layout = this.layout.cloneLayout();
        }

        if (_hidden == true) {
            c.hide();
        }
        if (autoWidth == false && this.width > 0) {
            c.width = this.width;
        }
        if (autoHeight == false && this.height > 0) {
            c.height = this.height;
        }
        if (customStyle != null) {
            if (c.customStyle == null) {
                c.customStyle = {};
            }
            c.customStyle.apply(customStyle);
        }
    }

    private override function get_isComponentClipped():Bool {
        if (_compositeBuilder != null) {
            return _compositeBuilder.isComponentClipped;
        }
        return (componentClipRect != null);
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

    /**
     * Whether this component has a non-visible graphic added/drawn onto it or not.
     */
    public var isComponentSolid(get, null):Bool;
    private function get_isComponentSolid():Bool {
        if (this.style == null) {
            return false;
        }

        if (this.style.backgroundColor != null || this.style.backgroundImage != null) { // heavily nested so its easier to see whats going on
            if (this.style.opacity == null || this.style.opacity > 0) {
                if (this.style.backgroundOpacity == null || this.style.backgroundOpacity > 0) {
                    return true;
                }
            }
        }

        return false;
    }
}
