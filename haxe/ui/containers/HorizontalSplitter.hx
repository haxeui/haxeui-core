package haxe.ui.containers;

import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.Splitter.SplitterBuilder;
import haxe.ui.containers.Splitter.SplitterEvents;

@:composite(HorizontalSplitterEvents, HorizontalSplitterBuilder)
class HorizontalSplitter extends Splitter {
    public function new() {
        super();
        layoutName = "horizontal";
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class HorizontalSplitterEvents extends SplitterEvents {
    private override function onGripperMouseDown(event:MouseEvent) {
        super.onGripperMouseDown(event);
        #if haxeui_html5
        js.Browser.document.body.style.cursor = "col-resize";
        #end
    }

    private override function handleResize(prev:Component, next:Component, event:MouseEvent) {
        if (prev == null || next == null) {
            return;
        }

        // What the two panes share between them. NOT `layout.usableWidth`,
        // which is only what is left for the PERCENT children — see
        // SplitterEvents.usableAfter.
        var ucx = _dragTotalCX;

        // Measured from the mouse-down, so no component screen coordinate (real
        // pixels) is ever subtracted from a mouse coordinate (layout units).
        var prevCX = _dragPrevCX + (event.screenX - _dragFromX);
        var nextCX = ucx - prevCX;

        // A pane's own limits, which these four have always been named for and
        // never read. Without them a splitter will happily shrink a pane past
        // the width its style says it may have: Component clamps the width it
        // is given, but the splitter goes on believing the pair still adds up,
        // so the surplus is pushed out of the far side of the splitter and the
        // last pane leaves the window.
        var prevMinWidth:Float = minWidthOf(prev);
        var nextMinWidth:Float = minWidthOf(next);

        var prevMaxWidth:Null<Float> = maxWidthOf(prev);
        var nextMaxWidth:Null<Float> = maxWidthOf(next);

        // Two minimums that cannot both be met (a splitter narrower than the
        // pair needs) would clamp against each other forever; share it out.
        if (prevMinWidth + nextMinWidth > ucx) {
            var scale = (prevMinWidth + nextMinWidth > 0) ? ucx / (prevMinWidth + nextMinWidth) : 0;
            prevMinWidth *= scale;
            nextMinWidth *= scale;
        }

        // limit to min sizes
        if (prevCX < prevMinWidth) {
            prevCX = prevMinWidth;
            nextCX = ucx - prevMinWidth;
        }
        if (nextCX < nextMinWidth) {
            prevCX = ucx - nextMinWidth;
            nextCX = nextMinWidth;
        }

        // limit to max sizes
        if (prevMaxWidth != null && prevCX > prevMaxWidth) {
            prevCX = prevMaxWidth;
            nextCX = ucx - prevMaxWidth;
        }
        if (nextMaxWidth != null && nextCX > nextMaxWidth) {
            prevCX = ucx - nextMaxWidth;
            nextCX = nextMaxWidth;
        }

        // bit of a hack to make things look a little nicer
        if (prevCX <= 0) {
            @:privateAccess prev.handleVisibility(false);
        } else {
            @:privateAccess prev.handleVisibility(true);
        }
        if (nextCX <= 0) {
            @:privateAccess next.handleVisibility(false);
        } else {
            @:privateAccess next.handleVisibility(true);
        }

        // assign new sizes. A percentage is worked out against the width it
        // will actually resolve against once the FIXED pane of the pair has
        // taken its new size, which is not the width it resolves against now.
        var after = usableAfter(_splitter.layout.usableWidth, prev, next, prevCX, nextCX);
        if (prev.percentWidth != null) {
            prev.percentWidth = (after > 0) ? (prevCX / after) * 100 : 0;
        } else {
            prev.width = prevCX;
        }
        if (next.percentWidth != null) {
            next.percentWidth = (after > 0) ? (nextCX / after) * 100 : 0;
        } else {
            next.width = nextCX;
        }
    }

    private static function minWidthOf(c:Component):Float {
        if (c == null || c.style == null || c.style.minWidth == null) {
            return 0;
        }
        return c.style.minWidth;
    }

    private static function maxWidthOf(c:Component):Null<Float> {
        if (c == null || c.style == null) {
            return null;
        }
        return c.style.maxWidth;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HorizontalSplitterBuilder extends SplitterBuilder {
    public override function getSplitterClass():String {
        return "horizontal-splitter-gripper";
    }
}