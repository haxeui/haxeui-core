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
        var screenY = _splitter.screenTop;
        var delta = event.screenY - screenY - _currentOffset.y;
        var ucy = _splitter.layout.usableHeight;
        
        var prevCY = delta;
        var nextCY = ucy - delta;
        
        var prevMinHeight:Float = 0;
        var nextMinHeight:Float = 0;
        
        var prevMaxHeight:Null<Float> = null;
        var nextMaxHeight:Null<Float> = null;
        
        // limit to min sizes
        if (prevCY <= prevMinHeight) {
            prevCY = prevMinHeight;
            nextCY = ucy - prevMinHeight;
        }
        if (nextCY <= nextMinHeight) {
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
        if (prev.percentHeight != null) {
            prev.percentHeight = (prevCY / ucy) * 100;
        } else {
            prev.height = prevCY;
        }
        if (next.percentHeight != null) {
            next.percentHeight = (nextCY / ucy) * 100;
        } else {
            next.height = nextCY;
        }
        
        /*
        var delta = event.screenY - _currentOffset.y;
        var prevCY = prev.height += delta;
        var nextCY = next.height -= delta;
        var ucy = _splitter.layout.usableHeight;
        
        if (prevCY <= 0 || nextCY <= 0) {
            return;
        }
        
        if (prev.percentHeight != null) {
            prev.percentHeight = (prevCY / ucy) * 100;
        } else {
            prev.height = prevCY;
        }

        if (next.percentHeight != null) {
            next.percentHeight = (nextCY / ucy) * 100;
        } else {
            next.height = nextCY;
        }
        */
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