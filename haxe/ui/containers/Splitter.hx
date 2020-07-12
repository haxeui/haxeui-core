package haxe.ui.containers;

import haxe.ui.components.Image;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.geom.Point;

@:composite(SplitterEvents, SplitterBuilder)
class Splitter extends Box implements IDirectionalComponent {
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
        _currentOffset = new Point(event.screenX, event.screenY);
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
    }
    
    private function onScreenMouseMove(event:MouseEvent) {
        _currentGripper.addClass(":hover");
        var index = _splitter.getComponentIndex(_currentGripper);
        var prev = _splitter.getComponentAt(index - 1);
        var next = _splitter.getComponentAt(index + 1);

        handleResize(prev, next, event);
        
        _currentOffset = new Point(event.screenX, event.screenY);
    }
    
    private function handleResize(prev:Component, next:Component, event:MouseEvent) {
        
    }
    
    private function onScreenMouseUp(event:MouseEvent) {
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
        return null;
    }
    
    public function getSplitterClass():String {
        return "splitter-gripper";
    }
}

private class SizerGripper extends InteractiveComponent {
    public function new() {
        super();
        registerEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        
        var image = new Image();
        addComponent(image);
    }
    
    private function onMouseOver(event:MouseEvent) {
        addClass(":hover");
    }
    
    private function onMouseOut(event:MouseEvent) {
        removeClass(":hover");
    }
}