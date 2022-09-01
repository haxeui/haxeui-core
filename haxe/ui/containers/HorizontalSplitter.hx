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
        var screenX = _splitter.screenLeft;
        var delta = event.screenX - screenX - _currentOffset.x;
        var ucx = _splitter.layout.usableWidth;
        
        var prevCX = delta;
        var nextCX = ucx - delta;
        
        var prevMinWidth:Float = 0;
        var nextMinWidth:Float = 0;
        
        var prevMaxWidth:Null<Float> = null;
        var nextMaxWidth:Null<Float> = null;
        
        // limit to min sizes
        if (prevCX <= prevMinWidth) {
            prevCX = prevMinWidth;
            nextCX = ucx - prevMinWidth;
        }
        if (nextCX <= nextMinWidth) {
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
        
        // assign new sizes
        if (prev.percentWidth != null) {
            prev.percentWidth = (prevCX / ucx) * 100;
        } else {
            prev.width = prevCX;
        }
        if (next.percentWidth != null) {
            next.percentWidth = (nextCX / ucx) * 100;
        } else {
            next.width = nextCX;
        }
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