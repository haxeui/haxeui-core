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
        var delta = event.screenY - _currentOffset.y;
        var prevCY = prev.height += delta;
        var nextCY = next.height -= delta;
        var ucy = _splitter.layout.usableHeight;
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