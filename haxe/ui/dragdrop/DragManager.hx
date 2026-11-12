package haxe.ui.dragdrop;

import haxe.ui.Toolkit;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.DragEvent;
import haxe.ui.events.EventType;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;
import haxe.ui.geom.Rectangle;
import haxe.ui.util.MathUtil;

class DragManager {
    private static var _instance:DragManager;
    public static var instance(get, null):DragManager;
    private static function get_instance():DragManager {
        if (_instance == null) {
            _instance = new DragManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************

    /**
     * Whether a component is currently being dragged
     */
    public var isDragging(get, never):Bool;
    function get_isDragging():Bool {
        return _currentComponent != null;
    }

    private var _dragComponents:Map<Component, DragOptions>;
    private var _mouseTargetToDragTarget:Map<Component, Component>;

    private var _currentComponent:Component;
    private var _currentOptions:DragOptions;

    private var _mouseOffset:Point;

    // Drag and drop (DragOptions.dragData / dragProxy): the registered drop targets, whether the
    // current drag has passed its tolerance, the target it is over that accepted it, and a target
    // that refused it (so a refusal is asked once per visit, not on every mouse move).
    private var _dropTargets:Map<Component, DropOptions>;
    private var _dragStarted:Bool = false;
    private var _hoverTarget:Component = null;
    private var _refusedTarget:Component = null;

    public function new() {
        _dragComponents = new Map<Component, DragOptions>();
        _mouseTargetToDragTarget = new Map<Component, Component>();
        _dropTargets = new Map<Component, DropOptions>();
    }

    /**
     * Whether the current drag is a drag-and-drop (it carries data or a proxy) rather than a move
     */
    private function isDragAndDrop():Bool {
        return _currentOptions != null && (_currentOptions.dragData != null || _currentOptions.dragProxy != null);
    }

    /**
     * Registers a component as somewhere a drag-and-drop can be dropped. It gets DRAG_ENTER,
     * DRAG_LEAVE and DROP events (DragEvent), with the drag's data in `data` and the dragged
     * component in `dragSource`; cancelling DRAG_ENTER refuses the drag. When targets are nested,
     * the innermost one under the mouse is the one used.
     * @param component
     * @param dropOptions
     * @return DropOptions
     */
    public function registerDropTarget(component:Component, dropOptions:DropOptions = null):DropOptions {
        pruneDisposed();
        if (dropOptions == null) dropOptions = {};
        if (dropOptions.dropHoverStyleName == null) dropOptions.dropHoverStyleName = "drop-hover";
        _dropTargets.set(component, dropOptions);
        return dropOptions;
    }

    /**
     * Unregisters a previously registered drop target
     * @param component
     */
    public function unregisterDropTarget(component:Component) {
        var dropOptions = _dropTargets.get(component);
        if (dropOptions == null) return;
        if (_hoverTarget == component) {
            component.removeClass(dropOptions.dropHoverStyleName);
            _hoverTarget = null;
        }
        if (_refusedTarget == component) _refusedTarget = null;
        _dropTargets.remove(component);
    }

    /**
     * If a component is registered as a drop target
     * @param component
     * @return Bool
     */
    public function isRegisteredDropTarget(component:Component):Bool {
        return _dropTargets.exists(component);
    }

    /**
     * Forgets draggables and drop targets that have been disposed of, so views that rebuild their
     * children (a list redrawn on every change) do not leave them behind in these maps.
     */
    @:access(haxe.ui.backend.ComponentBase)
    private function pruneDisposed() {
        for (c in [for (k in _dropTargets.keys()) k]) {
            if (c._isDisposed == true && c != _hoverTarget) _dropTargets.remove(c);
        }
        // Not unregisterDraggable: that also drops the screen's mouse listeners, which would end a
        // drag in progress when the view rebuilds under it.
        for (c in [for (k in _dragComponents.keys()) k]) {
            if (c._isDisposed != true || c == _currentComponent) continue;
            var dragOptions = _dragComponents.get(c);
            if (dragOptions.mouseTarget != null) {
                dragOptions.mouseTarget.unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
                _mouseTargetToDragTarget.remove(dragOptions.mouseTarget);
            }
            _dragComponents.remove(c);
        }
    }

    /**
     * The innermost visible drop target under the given screen position, or null
     */
    private function findDropTarget(x:Float, y:Float):Component {
        var found:Component = null;
        var foundDepth = -1;
        for (target in _dropTargets.keys()) {
            if (target.hidden || !target.hitTest(x, y)) continue;
            var depth = 0;
            var p = target.parentComponent;
            while (p != null) { depth++; p = p.parentComponent; }
            if (depth > foundDepth) {
                found = target;
                foundDepth = depth;
            }
        }
        return found;
    }

    private function dragEvent(type:EventType<DragEvent>):DragEvent {
        var event = new DragEvent(type);
        event.data = _currentOptions.dragData;
        event.dragSource = _currentComponent;
        return event;
    }

    /** Moves the hover to whatever target is under the mouse now, with its enter/leave events. */
    private function updateHover(x:Float, y:Float) {
        var target = findDropTarget(x, y);
        if (target == _hoverTarget || (target != null && target == _refusedTarget)) return;
        leaveHover();
        _refusedTarget = null;
        if (target == null) return;
        var enter = dragEvent(DragEvent.DRAG_ENTER);
        target.dispatch(enter);
        if (enter.canceled) {
            _refusedTarget = target;
            return;
        }
        _hoverTarget = target;
        target.addClass(_dropTargets.get(target).dropHoverStyleName);
    }

    private function leaveHover() {
        if (_hoverTarget == null) return;
        var target = _hoverTarget;
        _hoverTarget = null;
        var dropOptions = _dropTargets.get(target);
        if (dropOptions != null) target.removeClass(dropOptions.dropHoverStyleName);
        target.dispatch(dragEvent(DragEvent.DRAG_LEAVE));
    }

    #if haxeui_html5
    // In a browser a press that moves starts the page's own drag (of an image) or a text
    // selection, and either one takes the mouse moves this drag needs. Both are held off while a
    // press on a draggable is down.
    private static function preventNative(e:js.html.Event) {
        e.preventDefault();
    }

    private function holdNativeDrag(hold:Bool) {
        var doc = js.Browser.document;
        if (hold) {
            doc.addEventListener("dragstart", preventNative);
            doc.addEventListener("selectstart", preventNative);
        } else {
            doc.removeEventListener("dragstart", preventNative);
            doc.removeEventListener("selectstart", preventNative);
        }
    }
    #end

    /**
     * Puts the proxy at mouse position (x, y), in the mouse's own units. The proxy is a root
     * component, and a root component's left/top are in screen pixels - which is why a dragged
     * root component's mouse position is multiplied by Toolkit.scaleX/Y below - so at any scale
     * but 1 the proxy has to be too, or it trails the pointer (a third of the way there at 3x).
     */
    private function moveProxy(x:Float, y:Float) {
        var proxy = _currentOptions.dragProxy;
        if (proxy == null) return;
        proxy.left = (x + _currentOptions.dragOffsetX) * Toolkit.scaleX;
        proxy.top = (y + _currentOptions.dragOffsetY) * Toolkit.scaleY;    }

    /**
     * Returns the current DragOptions for a given component previously registered
     * @param component
     * @return DragOptions
     */
    public function getDragOptions(component:Component):DragOptions {
        var dragOptions:DragOptions = _dragComponents.get(component);
        return dragOptions;
    }

    /**
     * Registers a component for drag-drop management
     * @param component
     * @param dragOptions
     * @return DragOptions
     */
    public function registerDraggable(component:Component, dragOptions:DragOptions = null):DragOptions {
        if (isRegisteredDraggable(component)) {
            return null;
        }
        pruneDisposed();

        // Set default DragOptions if not present //
        if (dragOptions == null) dragOptions = {};
        if (dragOptions.mouseTarget == null) dragOptions.mouseTarget = component;
        if (dragOptions.dragOffsetX == null) dragOptions.dragOffsetX = 0;
        if (dragOptions.dragOffsetY == null) dragOptions.dragOffsetY = 0;
        if (dragOptions.dragTolerance == null) dragOptions.dragTolerance = Std.int(Toolkit.scale);
        //if (dragOptions.dragBounds == null) dragOptions.dragBounds = new Rectangle(0, 0, Screen.instance.width, Screen.instance.height);
        if (dragOptions.draggableStyleName == null) dragOptions.draggableStyleName = "draggable";
        if (dragOptions.draggingStyleName == null) dragOptions.draggingStyleName = "dragging";

        // Add component and mouseTarget to respective maps //
        _dragComponents.set(component, dragOptions);
        _mouseTargetToDragTarget.set(dragOptions.mouseTarget, component);

        // Register event(s) //
        if (!dragOptions.mouseTarget.hasEvent(MouseEvent.MOUSE_DOWN, onMouseDown)) {
            dragOptions.mouseTarget.registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        }

        // add styles
        if (dragOptions.draggableStyleName != null) {
            dragOptions.mouseTarget.addClass(dragOptions.draggableStyleName);
        }
        return dragOptions;
    }

    /**
     * Unregisters a previously registered component from drag-drop management
     * @param component
     */
    public function unregisterDraggable(component:Component) {
        if (!isRegisteredDraggable(component)) {
            return;
        }

        var dragOptions:DragOptions = getDragOptions(component);
        if (_currentComponent == component) {
            _currentComponent = null;
        }

        // Unregister events //
        if (dragOptions != null && dragOptions.mouseTarget != null) {
            dragOptions.mouseTarget.unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
            // remove mouseTarget from map
            _mouseTargetToDragTarget.remove(dragOptions.mouseTarget);
            if (dragOptions.draggableStyleName != null) {
                dragOptions.mouseTarget.removeClass(dragOptions.draggableStyleName);
            }
        }
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenCheckForDrag);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenDrag);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);

        // remove component from map
        _dragComponents.remove(component);
    }

    /**
     * If a component is registered to be draggable
     * @param component
     * @return Bool
     */
    public function isRegisteredDraggable(component:Component):Bool {
        return _dragComponents.exists(component);
    }

    // Listeners //
    ///////////////

    private function onMouseDown(e:MouseEvent) {
        if (_currentComponent != null) return;
        _dragStarted = false;
        // set current pending dragging component
        _currentComponent = _mouseTargetToDragTarget.get(e.target);
        if (_currentComponent.parentComponent == null) {
            e.screenX *= Toolkit.scaleX;
            e.screenY *= Toolkit.scaleY;
        }
        
        _currentOptions = getDragOptions(_currentComponent);

        // set _mouseOffset to current mouse position
        _mouseOffset = new Point(e.screenX - _currentComponent.left, e.screenY - _currentComponent.top);

        // register screen events
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenCheckForDrag);
        #if haxeui_html5
        holdNativeDrag(true);
        #end
    }

    private function onScreenCheckForDrag(e:MouseEvent) {
        // Drop targets and a proxy work in the mouse's own units, before any rescaling below.
        var mouseX = e.screenX, mouseY = e.screenY;
        if (_currentComponent.parentComponent == null) {
            e.screenX *= Toolkit.scaleX;
            e.screenY *= Toolkit.scaleY;
        }
        // if the distance the mouse has traveled is greater than the dragTolerance...
        if (MathUtil.distance(e.screenX - _currentComponent.left, e.screenY - _currentComponent.top, _mouseOffset.x, _mouseOffset.y) > _currentOptions.dragTolerance) {
            // stop listening for drag check
            Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenCheckForDrag);
            // add drag listener
            Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenDrag);

            // Adjust mouseOffset //
            _mouseOffset.x -= _currentOptions.dragOffsetX;
            _mouseOffset.y -= _currentOptions.dragOffsetY;

            if (_currentOptions.draggingStyleName != null) {
                _currentComponent.addClass(_currentOptions.draggingStyleName);
            }
            _dragStarted = true;
            if (isDragAndDrop()) {
                var proxy = _currentOptions.dragProxy;
                if (proxy != null) {
                    proxy.includeInLayout = false;
                    Screen.instance.addComponent(proxy);
                    moveProxy(mouseX, mouseY);
                }
            }
            _currentComponent.dispatch(isDragAndDrop() ? dragEvent(DragEvent.DRAG_START) : new DragEvent(DragEvent.DRAG_START));
            if (isDragAndDrop()) updateHover(mouseX, mouseY);
        }
    }

    private function onScreenDrag(e:MouseEvent) {
        if (isDragAndDrop()) {
            // Drag and drop: the component stays put; the proxy follows the mouse and the drop
            // targets under it are told as it comes and goes.
            var event = dragEvent(DragEvent.DRAG);
            event.left = e.screenX + _currentOptions.dragOffsetX;
            event.top = e.screenY + _currentOptions.dragOffsetY;
            _currentComponent.dispatch(event);
            if (event.canceled != true) moveProxy(e.screenX, e.screenY);
            updateHover(e.screenX, e.screenY);
            return;
        }
        // Calculate bounds //
        if (_currentComponent.parentComponent == null) {
            e.screenX *= Toolkit.scaleX;
            e.screenY *= Toolkit.scaleY;
        }
        
        var event = new DragEvent(DragEvent.DRAG);
        if (_currentOptions.dragBounds != null) {
            var boundX = MathUtil.clamp(e.screenX, _currentOptions.dragBounds.left + _mouseOffset.x, _currentOptions.dragBounds.right - _currentComponent.width + _mouseOffset.x);
            var boundY = MathUtil.clamp(e.screenY, _currentOptions.dragBounds.top + _mouseOffset.y, _currentOptions.dragBounds.bottom - _currentComponent.height + _mouseOffset.y);
            event.left = boundX - _mouseOffset.x;
            event.top = boundY - _mouseOffset.y;
        } else {
            var xpos = e.screenX;
            var ypos = e.screenY;
            event.left = xpos - _mouseOffset.x;
            event.top = ypos - _mouseOffset.y;
        }
        _currentComponent.dispatch(event);
        if (event.canceled == true) {
            return;
        }
        _currentComponent.moveComponent(event.left, event.top);
    }

    private function onScreenMouseUp(e:MouseEvent) {
        if (_currentOptions.draggingStyleName != null) {
            _currentComponent.removeClass(_currentOptions.draggingStyleName);
        }
        if (isDragAndDrop()) {
            var end = dragEvent(DragEvent.DRAG_END);
            if (_dragStarted) {
                if (_currentOptions.dragProxy != null) Screen.instance.removeComponent(_currentOptions.dragProxy, false);
                var target = _hoverTarget;
                if (target != null) {
                    var dropOptions = _dropTargets.get(target);
                    _hoverTarget = null;
                    if (dropOptions != null) target.removeClass(dropOptions.dropHoverStyleName);
                    target.dispatch(dragEvent(DragEvent.DROP));
                }
                end.relatedComponent = target;
            }
            _refusedTarget = null;
            _dragStarted = false;
            _currentComponent.dispatch(end);
        } else {
            _currentComponent.dispatch(new DragEvent(DragEvent.DRAG_END));
        }

        // Clear data //
        _currentComponent = null;
        _currentOptions = null;
        _mouseOffset.x = 0;
        _mouseOffset.y = 0;

        // Unregister events //
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenCheckForDrag);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenDrag);
        #if haxeui_html5
        holdNativeDrag(false);
        #end
    }
}
