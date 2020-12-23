package haxe.ui.dragdrop;

import haxe.ui.geom.Rectangle;
import haxe.ui.core.Component;

typedef DragOptions = {
    /**
     * A component that will trigger dragging - usually the draggable component or a sub-component of it.
     * Default: the draggable component
     */
    var ?mouseTarget:Component;

    /**
     * The x offset to be added to the moveTarget during drag in addition to the mouse x offset from the moveTarget's x..
     * Default: 0
     */
    var ?dragOffsetX:Float;

    /**
     * The y offset to be added to the moveTarget during drag in addition to the mouse y offset from the moveTarget's y.
     * Default: 0
     */
    var ?dragOffsetY:Float;

    /**
     * The distance the mouse must travel while mouseDown on the mouseTarget before drag begins.
     * Default: 1
     */
    var ?dragTolerance:Int;

    /**
     * A Rect specifying the bounds in the screen's coordinate space.
     * Default: screen's bounds
     */
    var ?dragBounds:Rectangle;

    /**
     * A style name to add to draggable components
     * Default: draggable
     */
    var ?draggableStyleName:String;

    /**
     * A style name to add to draggable components while being dragged
     * Default: dragging
     */
    var ?draggingStyleName:String;
}