package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.Events;

@:composite(Events, Builder)
class Accordion extends VBox {
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class Events extends haxe.ui.events.Events {
    public override function register() {
        for (button in _target.childComponents) {
            if (Std.is(button, Button) && !button.hasEvent(MouseEvent.CLICK, onButtonClicked)) {
                button.registerEvent(MouseEvent.CLICK, onButtonClicked);
            }
        }
    }
    
    public override function unregister() {
        for (button in _target.childComponents) {
            button.unregisterEvent(MouseEvent.CLICK, onButtonClicked);
        }
    }
    
    private function onButtonClicked(event:MouseEvent) {
        var button = cast(event.target, Button);
        var index = _target.getComponentIndex(button);
        var builder:Builder = cast(_target._compositeBuilder, Builder);
        var view = builder._views[button.userData];
        if (button.selected) {
            _target.addComponentAt(view, index + 1);
        } else {
            _target.removeComponent(view, false);
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _views:Array<Component> = [];
    
    public override function create() {
        
    }
    
    public override function addComponent(child:Component):Component {
        if (!child.hasClass("accordion-button")) {
            var button = new Button();
            button.text = child.text;
            button.styleNames = "accordion-button";
            button.toggle = true;
            button.scriptAccess = false;
            button.userData = _views.length;
            _component.addComponent(button);
            
            var view = new VBox();
            view.styleNames = "accordion-page";
            view.addComponent(child);
            _views.push(view);
            
            _component.registerInternalEvents(true);
            
            return button;
        }
        return null;
    }
}