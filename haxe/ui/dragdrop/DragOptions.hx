package haxe.ui.dragdrop;

import haxe.ui.geom.Rectangle;
import haxe.ui.core.Component;

typedef DragOptions = {
    /**
     * A component that will trigger dragging - usually the draggable component or a sub-component of it.
     * Default: the draggable component
     */
    @:optional var mouseTarget:Component;

    /**
     * The x offset to be added to the moveTarget during drag in addition to the mouse x offset from the moveTarget's x..
     * Default: 0
     */
    @:optional var dragOffsetX:Float;

    /**
     * The y offset to be added to the moveTarget during drag in addition to the mouse y offset from the moveTarget's y.
     * Default: 0
     */
    @:optional var dragOffsetY:Float;

    /**
     * The distance the mouse must travel while mouseDown on the mouseTarget before drag begins.
     * Default: 1
     */
    @:optional var dragTolerance:Int;

    /**
     * A Rect specifying the bounds in the screen's coordinate space.
     * Default: screen's bounds
     */
    @:optional var dragBounds:Rectangle;

    /**
     * A style name to add to draggable components
     * Default: draggable
     */
    @:optional var draggableStyleName:String;

    /**
     * A style name to add to draggable components while being dragged
     * Default: dragging
     */
    @:optional var draggingStyleName:String;

    /**
     * What the drag carries, for drag and drop. Setting it (or `dragProxy`) makes the drag a
     * drag-and-drop: the component stays where it is, and the drop targets under the mouse
     * (DragManager.registerDropTarget) get DRAG_ENTER, DRAG_LEAVE and DROP events with this as
     * their `data`.
     * Default: null (the component itself is moved, as before)
     */
    @:optional var dragData:Dynamic;

    /**
     * For drag and drop: a component that follows the mouse while dragging, in place of moving
     * the draggable component. It is added to the Screen when the drag starts and removed when it
     * ends, positioned at the mouse plus `dragOffsetX`/`dragOffsetY`.
     * Default: null (nothing follows the mouse)
     */
    @:optional var dragProxy:Component;
}