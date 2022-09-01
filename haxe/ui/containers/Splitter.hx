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
    private function onGripperMouseDown(event:MouseEvent) {
        _currentGripper = cast(event.target, SizerGripper);
        _currentOffset = new Point(event.screenX - _currentGripper.screenLeft, event.screenY - _currentGripper.screenTop);
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
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
            var gripper = new SizerGripper();
            gripper.id = getSplitterClass();
            gripper.addClass(getSplitterClass());
            _splitter.addComponent(gripper);
            _splitter.registerInternalEvents(true);
        }

        if (child.hasClass(getSplitterClass()) == false) {
            child.registerEvent(UIEvent.SHOWN, onComponentShown);
            child.registerEvent(UIEvent.HIDDEN, onComponentHidden);
        }

        if (child.hidden == true) {
            onComponentHidden(null);
        }

        return null;
    }

    public function getSplitterClass():String {
        return "splitter-gripper";
    }

    private function onComponentShown(e:UIEvent) {
        var children = _splitter.childComponents.copy();
        for (c in children) {
            if (c.hidden == true) {
                if ((c is SizerGripper)) {
                    c.show();
                }
                break;
            }
        }

        children.reverse();
        for (c in children) {
            if (c.hidden == true) {
                if ((c is SizerGripper)) {
                    c.show();
                }
                break;
            }
        }
    }

    private function onComponentHidden(e:UIEvent) {
        var children = _splitter.childComponents.copy();
        for (c in children) {
            if (c.hidden == false) {
                if ((c is SizerGripper)) {
                    c.hide();
                }
                break;
            }
        }

        children.reverse();
        for (c in children) {
            if (c.hidden == false) {
                if ((c is SizerGripper)) {
                    c.hide();
                }
                break;
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