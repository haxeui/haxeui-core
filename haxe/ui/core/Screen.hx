package haxe.ui.core;

import haxe.ui.backend.ScreenImpl;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.util.EventMap;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

#if haxeui_expose_all
@:expose
#end
class Screen extends ScreenImpl {

    private static var _instance:Screen;
    /**
     * References the main application's screen, in a cross-framework way.
     */
    public static var instance(get, never):Screen;
    private static function get_instance():Screen {
        if (_instance == null) {
            _instance = new Screen();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance
    //***********************************************************************************************************
    private var _eventMap:EventMap = new EventMap();

    /**
     * The `x` position of the mouse on screen.
     * 
     * A lower value means the mouse is at the left side of the screen,
     * whie a higher value means the mouse is at the right side of the screen.
     */
    public var currentMouseX:Null<Float> = null;
    
    /**
     * The `y` position of the mouse on screen.
     * 
     * A lower value means the mouse is closer to the top of the screen,
     * whie a higher value means the mouse is closer to the bottom of the screen.
     */
    public var currentMouseY:Null<Float> = null;
    
    /**
     * Creates a new `Screen`.
     * 
     * Usually, you wouldn't want to create a screen yourself, but to use the one in `Screen.instance`.
     * Double check if thats what your'e trying to do.
     */
    public function new() {
        super();
        registerEvent(MouseEvent.MOUSE_MOVE, function(e:MouseEvent) {
            currentMouseX = e.screenX;
            currentMouseY = e.screenY;
        });
    }

    /**
     * Adds a component/container to the screen. 
     * 
     * When using this via `Screen.instance.addComponent()`, This method acts as some sort of a cross-framework way
     * to draw components/containers onto the main application's screen.
     * 
     * @param component The component to add to the screen.
     * @return The added component.
     */
    public override function addComponent(component:Component):Component {
        var wasReady = component.isReady;
        @:privateAccess component._hasScreen = true;
        super.addComponent(component);
        #if !(haxeui_javafx || haxeui_android)
        component.ready();
        #end
        if (rootComponents.indexOf(component) == -1) {
            rootComponents.push(component);
        }
        FocusManager.instance.pushView(component);
        if (component.hasEvent(UIEvent.RESIZE, _onRootComponentResize) == false) {
            component.registerEvent(UIEvent.RESIZE, _onRootComponentResize);
        }
        
        if (wasReady && component.hidden == false) {
            component.dispatch(new UIEvent(UIEvent.SHOWN));
        }
        
        return component;
    }

    /**
     * Removes a component/container from the screen. 
     * 
     * When using this via `Screen.instance.removeComponent()`, 
     * This method acts as some sort of a cross-framework way
     * to remove components/containers from the main application's screen.
     * 
     * @param component The component to add to the screen.
     * @return The added component.
     */
    public override function removeComponent(component:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (rootComponents.indexOf(component) == -1) {
            if (dispose) {
                component.disposeComponent();
            }
            return component;
        }
        @:privateAccess component._hasScreen = false;
        super.removeComponent(component, dispose);
        component.depth = -1;
        rootComponents.remove(component);
        FocusManager.instance.removeView(component);
        component.unregisterEvent(UIEvent.RESIZE, _onRootComponentResize);
        if (dispose) {
            component.disposeComponent();
        } else {
            component.dispatch(new UIEvent(UIEvent.HIDDEN));
            // sometimes (on some backends, like browser), mouse out doesnt fire when removing from screen
            component.removeClass(":hover", false, true);
        }
        return component;
    }

    public override function containsComponent(child:Component):Bool {
        if (child == null) {
            return false;
        }

        for (rootComponent in rootComponents) {
            if (rootComponent == child) {
                return true;
            }
        }

        return false;
    }

    /**
     * Sets the index of a component, essentially moving it forwards/backwards, 
     * or, in front/behind other components.
     * 
     * For example, setting the index of a child of a `VBox` to 0 will put that child at the top of the `VBox`, 
     * "behind" the rest of the children.
     * 
     * @param child The component to move.
     * @param index The index to move that component to.
     * @return The moved component.
     */
    public function setComponentIndex(child:Component, index:Int):Component {
        if (index >= 0 && index <= rootComponents.length) {
            handleSetComponentIndex(child, index);
            rootComponents.remove(child);
            rootComponents.insert(index, child);
        }
        return child;
    }

    /**
     * Moves a component to the front of the screen.
     * 
     * @param child The component to move to the front of the screen.
     */
    public function moveComponentToFront(child:Component) {
        if (rootComponents.indexOf(child) != -1) {
            setComponentIndex(child, rootComponents.length - 1);
        }
    }
    
    /**
     * Finds a specific child in the whole display tree (recursively if desired) and can optionally cast the result.
     * 
     * @param criteria The criteria by which to search, the interpretation of this is defined using `searchType` (the default search type is `id`).
     * @param type The component class you wish to cast the result to (defaults to `null`).
     * @param recursive Whether to search this components children and all its children's children till it finds a match (the default depends on the `searchType` param. If `searchType` is `id` the default is *true* otherwise it is `false`)
     * @param searchType Allows you specify how to consider a child a match (defaults to *id*), can be either: **`id`** - The first component that has the id specified in `criteria` will be considered a match, *or*, **`css`** - The first component that contains a style name specified by `criteria` will be considered a match.
     * @return The found component, or `null` if no component was found.
     */
    public function findComponent<T:Component>(criteria:String = null, type:Class<T> = null, recursive:Null<Bool> = null, searchType:String = "id"):Null<T> {
        for (rootComponent in rootComponents) {
            var result = rootComponent.findComponent(criteria, type, recursive, searchType);
            if (result != null) {
                return cast result;
            }
        }
        return null;
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
    public function findComponentsUnderPoint<T:Component>(screenX:Null<Float>, screenY:Null<Float>, type:Class<T> = null):Array<Component> {
        if (screenX == null || screenY == null) {
            return [];
        }
        var c:Array<Component> = [];
        for (r in rootComponents) {
            if (r.hitTest(screenX, screenY)) {
                var match = true;
                if (type != null && isOfType(r, type) == false) {
                    match = false;
                }
                if (match == true) {
                    c.push(r);
                }
            }
            c = c.concat(r.findComponentsUnderPoint(screenX, screenY, type));
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
    public function hasComponentUnderPoint<T:Component>(screenX:Null<Float>, screenY:Null<Float>, type:Class<T> = null):Bool {
        if (screenX == null || screenY == null) {
            return false;
        }
        for (r in rootComponents) {
            if (r.hasComponentUnderPoint(screenX, screenY, type) == true) {
                return true;
            }
        }
        return false;
    }
   
    /**
     * Lists components under a specific point in global, screen coordinates.
     * 
     * Note: this function will only return components "solid" components - components that have
     * some sort of a background/image, and are not transparent.
     * 
     * @param screenX The global, on-screen `x` position of the point to check for components under
     * @param screenY The global, on-screen `y` position of the point to check for components under
     * @param type Used to filter all components that aren't of a specific type. `null` by default, which means no filter is applied.
     * @return An array of all solid components that overlap the "global" position `(x, y)`
     */
    public function findSolidComponentUnderPoint<T:Component>(screenX:Null<Float>, screenY:Null<Float>, type:Class<T> = null):Array<Component> {
        if (screenX == null || screenY == null) {
            return [];
        }
        var solidComponents = [];
        var components = findComponentsUnderPoint(screenX, screenY, type);
        for (c in components) {
            if (c.isComponentSolid) {
                solidComponents.push(c);
            }
        }
        return solidComponents;
    }

    /**
     * Finds out if there is a solid component under a specific point in global coordinates.
     * 
     * Note: a solid component is a component that has
     * some sort of a background/image, and is not transparent.
     * 
     * @param screenX The global, on-screen `x` position of the point to check for components under
     * @param screenY The global, on-screen `y` position of the point to check for components under
     * @param type Used to filter all components that aren't of a specific type. `null` by default, which means no filter is applied.
     * @return `true` if there is a solid component that overlaps the global position `(x, y)`, `false` otherwise.
     */ 
    public function hasSolidComponentUnderPoint<T:Component>(screenX:Null<Float>, screenY:Null<Float>, type:Class<T> = null):Bool {
        if (screenX == null || screenY == null) {
            return false;
        }
        return (findSolidComponentUnderPoint(screenX, screenY, type).length > 0);
    }

    private function onThemeChanged() {
        for (c in rootComponents) {
            onThemeChangedChildren(c);
        }
    }

    @:access(haxe.ui.core.Component)
    private function onThemeChangedChildren(c:Component) {
        for (child in c.childComponents) {
            onThemeChangedChildren(child);
        }
        c.onThemeChanged();
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************

    /**
     * Adds an event listener, that listens to a certain type of event.
     * 
     * @param type The name of the event to listen to
     * @param listener a function with one argument that returns nothing
     * @param priority A higher value will make this event dispatch "sooner", while a lower value does the opposite.
     */
    public function registerEvent(type:String, listener:Dynamic->Void, priority:Int = 0) {
        if (supportsEvent(type) == true) {
            if (_eventMap.add(type, listener, priority) == true) {
                mapEvent(type, _onMappedEvent);
            }
        } else {
            #if debug
            trace('WARNING: Screen event "${type}" not supported');
            #end
        }
    }

    public function hasEvent(type:String, listener:Dynamic->Void):Bool {
        return _eventMap.contains(type, listener);
    }

    /**
     * Removes an event listener from a specific type of event.
     * 
     * @param type The name of the event to listen to
     * @param listener a function with one argument that returns nothing
     */
    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (_eventMap.remove(type, listener) == true) {
            unmapEvent(type, _onMappedEvent);
        }
    }

    private function _onMappedEvent(event:UIEvent) {
        _eventMap.invoke(event.type, event);
    }
}
