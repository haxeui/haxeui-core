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
        var delta = event.screenX - _currentOffset.x;
        var prevCX = prev.width += delta;
        var nextCX = next.width -= delta;
        var ucx = _splitter.layout.usableWidth;
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