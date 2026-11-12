package haxe.ui.containers;

import haxe.ui.components.Image;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;

@:composite(SplitterEvents, SplitterBuilder)
class Splitter extends Box implements IDirectionalComponent {
    private function new() {
        super();
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class SplitterEvents extends haxe.ui.events.Events {
    private var _splitter:Splitter;

    public function new(splitter:Splitter) {
        super(splitter);
        _splitter = splitter;
    }

    public override function register() {
        var builder = cast(_splitter._compositeBuilder, SplitterBuilder);
        var grippers = _splitter.findComponents(builder.getSplitterClass(), Component, 1);
        for (g in grippers) {
            g.registerEvent(MouseEvent.MOUSE_DOWN, onGripperMouseDown);
        }
    }

    public override function unregister() {
        var builder = cast(_splitter._compositeBuilder, SplitterBuilder);
        var grippers = _splitter.findComponents(builder.getSplitterClass(), Component, 1);
        for (g in grippers) {
            g.unregisterEvent(MouseEvent.MOUSE_DOWN, onGripperMouseDown);
        }
    }

    private var _currentGripper:SizerGripper = null;
    private var _currentOffset:Point = null;

    // The drag is measured DIFFERENTIALLY, from where the mouse went down and
    // the sizes the two panes had at that moment, rather than from the
    // splitter's own screen position. Two reasons, and the second is a bug:
    //
    //   A component's `screenLeft` comes from `screenBounds`, which multiplies
    //   every ancestor offset by `Toolkit.scale`, so it is in REAL pixels. A
    //   MouseEvent's `screenX` has already been divided by `Toolkit.scaleX` by
    //   the backend, so it is in LAYOUT units. Subtracting one from the other
    //   is only harmless at scale 1; at 1.5 or 2 the gripper runs away from the
    //   cursor. Comparing two mouse positions mixes no units and needs no
    //   knowledge of the scale at all.
    //
    //   It also makes the arithmetic independent of WHERE the pair sits: the
    //   old form measured from the splitter's left edge, which is only the
    //   previous pane's left edge for the FIRST pair, so every later gripper in
    //   a multi-pane splitter was handed the earlier panes' widths as well.
    private var _dragFromX:Float = 0;
    private var _dragFromY:Float = 0;
    private var _dragPrevCX:Float = 0;
    private var _dragPrevCY:Float = 0;
    private var _dragTotalCX:Float = 0;
    private var _dragTotalCY:Float = 0;

    private function onGripperMouseDown(event:MouseEvent) {
        _currentGripper = cast(event.target, SizerGripper);
        _currentOffset = new Point(event.screenX - _currentGripper.screenLeft, event.screenY - _currentGripper.screenTop);

        _dragFromX = event.screenX;
        _dragFromY = event.screenY;
        var index = _splitter.getComponentIndex(_currentGripper);
        var prev = _splitter.getComponentAt(index - 1);
        var next = _splitter.getComponentAt(index + 1);
        _dragPrevCX = (prev != null) ? prev.width : 0;
        _dragPrevCY = (prev != null) ? prev.height : 0;
        _dragTotalCX = _dragPrevCX + ((next != null) ? next.width : 0);
        _dragTotalCY = _dragPrevCY + ((next != null) ? next.height : 0);

        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
    }

    /**
     * The width a percent-sized pane's percentage will resolve against once the
     * drag's new sizes are in.
     *
     * `layout.usableWidth` is what is left for the PERCENT children: it already
     * has the fixed-width children and the grippers taken out of it. So it is
     * not the amount the two panes share (that is `prev.width + next.width`),
     * and it is not a fixed denominator either — resizing a fixed pane moves it.
     * Both of those were assumed, which is why a splitter pairing a percent pane
     * with a fixed one sized the percent pane against a number that changed
     * underneath it: the pane landed somewhere other than the cursor, and the
     * far half of the travel collapsed the fixed pane to nothing.
     */
    private function usableAfter(usableNow:Float, prev:Component, next:Component, prevCX:Float, nextCX:Float):Float {
        var after = usableNow;
        if (prev != null && prev.percentWidth == null) after += prev.width - prevCX;
        if (next != null && next.percentWidth == null) after += next.width - nextCX;
        return after;
    }

    private function usableAfterV(usableNow:Float, prev:Component, next:Component, prevCY:Float, nextCY:Float):Float {
        var after = usableNow;
        if (prev != null && prev.percentHeight == null) after += prev.height - prevCY;
        if (next != null && next.percentHeight == null) after += next.height - nextCY;
        return after;
    }

    private function onScreenMouseMove(event:MouseEvent) {
        _currentGripper.addClass(":down");
        var index = _splitter.getComponentIndex(_currentGripper);
        var prev = _splitter.getComponentAt(index - 1);
        var next = _splitter.getComponentAt(index + 1);
        handleResize(prev, next, event);
    }

    private function handleResize(prev:Component, next:Component, event:MouseEvent) {
    }

    private function onScreenMouseUp(event:MouseEvent) {
        _currentGripper.removeClass(":down");
        if (_currentGripper.hitTest(event.screenX, event.screenY)) {
            _currentGripper.addClass(":hover");
        }
        _currentGripper = null;
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        #if haxeui_html5
        js.Browser.document.body.style.cursor = null;
        #elseif haxeui_cs
        haxe.ui.backend.cs.ScreenCursor.clear();
        #end
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class SplitterBuilder extends CompositeBuilder {
    private var _splitter:Splitter;

    public function new(splitter:Splitter) {
        super(splitter);
        _splitter = splitter;

    }

    public override function addComponent(child:Component):Component {
        if (_splitter.childComponents.length > 0 && child.hasClass(getSplitterClass()) == false) {
            var before = _splitter.childComponents[_splitter.childComponents.length - 1];
            var gripper = new SizerGripper();
            gripper.id = getSplitterClass();
            gripper.addClass(getSplitterClass());
            // The child is added after this returns, so syncGrippers cannot see it yet: the new
            // gripper goes by its two panes here (a pane declared hidden may never send HIDDEN).
            if (before._hidden == true || child._hidden == true) {
                gripper.hide();
            }
            _splitter.addComponent(gripper);
            _splitter.registerInternalEvents(true);
        }

        if (child.hasClass(getSplitterClass()) == false) {
            child.registerEvent(UIEvent.SHOWN, onComponentShown);
            child.registerEvent(UIEvent.HIDDEN, onComponentHidden);
        }

        return null;
    }

    public function getSplitterClass():String {
        return "splitter-gripper";
    }

    private function onComponentShown(e:UIEvent) {
        syncGrippers();
    }

    private function onComponentHidden(e:UIEvent) {
        syncGrippers();
    }

    /**
     * Shows each gripper exactly when the panes on both sides of it are shown. The panes' own
     * hidden flags, not `hidden`, which also reports a hidden ancestor: a pane coming back while
     * the splitter's page is hidden must not decide anything. (It scanned from each end for the
     * first hidden child instead, so the other pane coming back re-showed the gripper beside a
     * pane still hidden - and dragging it then drew that pane.)
     */
    private function syncGrippers() {
        var children = _splitter.childComponents;
        for (i in 0...children.length) {
            var c = children[i];
            if (!(c is SizerGripper)) {
                continue;
            }
            var before = i > 0 ? children[i - 1] : null;
            var after = i + 1 < children.length ? children[i + 1] : null;
            var shown = before != null && after != null && !(before is SizerGripper) && !(after is SizerGripper)
                && before._hidden == false && after._hidden == false;
            if (shown == c._hidden) {
                shown ? c.show() : c.hide();
            }
        }
    }
}

private class SizerGripper extends InteractiveComponent {
    public function new() {
        super();
        var image = new Image();
        addComponent(image);
    }
}