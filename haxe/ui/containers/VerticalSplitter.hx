package haxe.ui.containers;

import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.Splitter.SplitterBuilder;
import haxe.ui.containers.Splitter.SplitterEvents;

@:composite(VerticalSplitterEvents, VerticalSplitterBuilder)
class VerticalSplitter extends Splitter {
    public function new() {
        super();
        layoutName = "vertical";
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class VerticalSplitterEvents extends SplitterEvents {
    private override function onGripperMouseDown(event:MouseEvent) {
        super.onGripperMouseDown(event);
        #if haxeui_html5
        js.Browser.document.body.style.cursor = "row-resize";
        #end
    }

    private override function handleResize(prev:Component, next:Component, event:MouseEvent) {
        if (prev == null || next == null) {
            return;
        }

        // The horizontal twin carries the account of both fixes.
        var ucy = _dragTotalCY;
        var prevCY = _dragPrevCY + (event.screenY - _dragFromY);
        var nextCY = ucy - prevCY;

        // See the horizontal twin: these four have always been named for the
        // panes' own limits and never read them.
        var prevMinHeight:Float = minHeightOf(prev);
        var nextMinHeight:Float = minHeightOf(next);

        var prevMaxHeight:Null<Float> = maxHeightOf(prev);
        var nextMaxHeight:Null<Float> = maxHeightOf(next);

        if (prevMinHeight + nextMinHeight > ucy) {
            var scale = (prevMinHeight + nextMinHeight > 0) ? ucy / (prevMinHeight + nextMinHeight) : 0;
            prevMinHeight *= scale;
            nextMinHeight *= scale;
        }

        // limit to min sizes
        if (prevCY < prevMinHeight) {
            prevCY = prevMinHeight;
            nextCY = ucy - prevMinHeight;
        }
        if (nextCY < nextMinHeight) {
            prevCY = ucy - nextMinHeight;
            nextCY = nextMinHeight;
        }

        // limit to max sizes
        if (prevMaxHeight != null && prevCY > prevMaxHeight) {
            prevCY = prevMaxHeight;
            nextCY = ucy - prevMaxHeight;
        }
        if (nextMaxHeight != null && nextCY > nextMaxHeight) {
            prevCY = ucy - nextMaxHeight;
            nextCY = nextMaxHeight;
        }

        // bit of a hack to make things look a little nicer
        if (prevCY <= 0) {
            @:privateAccess prev.handleVisibility(false);
        } else {
            @:privateAccess prev.handleVisibility(true);
        }
        if (nextCY <= 0) {
            @:privateAccess next.handleVisibility(false);
        } else {
            @:privateAccess next.handleVisibility(true);
        }

        // assign new sizes
        var after = usableAfterV(_splitter.layout.usableHeight, prev, next, prevCY, nextCY);
        if (prev.percentHeight != null) {
            prev.percentHeight = (after > 0) ? (prevCY / after) * 100 : 0;
        } else {
            prev.height = prevCY;
        }
        if (next.percentHeight != null) {
            next.percentHeight = (after > 0) ? (nextCY / after) * 100 : 0;
        } else {
            next.height = nextCY;
        }
    }

    private static function minHeightOf(c:Component):Float {
        if (c == null || c.style == null || c.style.minHeight == null) {
            return 0;
        }
        return c.style.minHeight;
    }

    private static function maxHeightOf(c:Component):Null<Float> {
        if (c == null || c.style == null) {
            return null;
        }
        return c.style.maxHeight;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class VerticalSplitterBuilder extends SplitterBuilder {
    public override function getSplitterClass():String {
        return "vertical-splitter-gripper";
    }
}