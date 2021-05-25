package haxe.ui.dragdrop;

import haxe.ui.Toolkit;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;
import haxe.ui.util.MathUtil;
import haxe.ui.geom.Rectangle;
import haxe.ui.core.Screen;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;

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

    private var _dragComponents:Map<Component, DragOptions>;
    private var _mouseTargetToDragTarget:Map<Component, Component>;

    private var _currentComponent:Component;
    private var _currentOptions:DragOptions;

    private var _mouseOffset:Point;

    public function new() {
        _dragComponents = new Map<Component, DragOptions>();
        _mouseTargetToDragTarget = new Map<Component, Component>();
    }

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

        // Unregister events //
        if (dragOptions != null && dragOptions.mouseTarget != null) {
            dragOptions.mouseTarget.unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
            // remove mouseTarget from map
            _mouseTargetToDragTarget.remove(dragOptions.mouseTarget);
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
        e.screenX *= Toolkit.scaleX;
        e.screenY *= Toolkit.scaleY;
        // set current pending dragging component
        _currentComponent = _mouseTargetToDragTarget.get(e.target);
        _currentOptions = getDragOptions(_currentComponent);

        // set _mouseOffset to current mouse position
        _mouseOffset = new Point(e.screenX - _currentComponent.left, e.screenY - _currentComponent.top);

        // register screen events
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenCheckForDrag);
    }

    private function onScreenCheckForDrag(e:MouseEvent) {
        e.screenX *= Toolkit.scaleX;
        e.screenY *= Toolkit.scaleY;
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
            _currentComponent.dispatch(new UIEvent(UIEvent.DRAG_START));
        }
    }

    private function onScreenDrag(e:MouseEvent) {
        // Calculate bounds //
        e.screenX *= Toolkit.scaleX;
        e.screenY *= Toolkit.scaleY;
        if (_currentOptions.dragBounds != null) {
            var boundX = MathUtil.clamp(e.screenX, _currentOptions.dragBounds.left + _mouseOffset.x, _currentOptions.dragBounds.right - _currentComponent.actualComponentWidth + _mouseOffset.x);
            var boundY = MathUtil.clamp(e.screenY, _currentOptions.dragBounds.top + _mouseOffset.y, _currentOptions.dragBounds.bottom - _currentComponent.actualComponentHeight + _mouseOffset.y);
            _currentComponent.moveComponent(boundX - _mouseOffset.x, boundY - _mouseOffset.y);
        } else {
            var xpos = e.screenX;
            var ypos = e.screenY;
            _currentComponent.moveComponent(xpos - _mouseOffset.x, ypos - _mouseOffset.y);
        }
    }

    private function onScreenMouseUp(e:MouseEvent) {
        if (_currentOptions.draggingStyleName != null) {
            _currentComponent.removeClass(_currentOptions.draggingStyleName);
        }
        _currentComponent.dispatch(new UIEvent(UIEvent.DRAG_END));

        // Clear data //
        _currentComponent = null;
        _currentOptions = null;
        _mouseOffset.x = 0;
        _mouseOffset.y = 0;

        // Unregister events //
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenCheckForDrag);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenDrag);
    }
}
