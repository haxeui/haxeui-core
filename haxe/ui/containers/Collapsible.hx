package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Button;
import haxe.ui.containers.Box;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.UIEvent;

@:composite(Events, Builder)
class Collapsible extends VBox {
    @:clonable @:behaviour(TextBehaviour)               public var text:String;
    @:clonable @:behaviour(CollapsedBehaviour, true)    public var collapsed:Bool;
    
    public function new() {
        super();
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var button = _component.findComponent("collapsible-button", Button);
        if (button != null) {
            button.text = _value;
        }
    }
}

@:dox(hide) @:noCompletion
private class CollapsedBehaviour extends DataBehaviour {
    private override function validateData() {
        var button = _component.findComponent("collapsible-button", Button);
        if (button != null) {
            button.selected = !_value;
        }
        if (button.selected) {
            button.swapClass("expanded", "collapsed");
        } else {
            button.swapClass("collapsed", "expanded");
        }
        
        var content = _component.findComponent("collapsible-content", Component);
        if (content != null) {
            content.hidden = _value;
        }
        
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
private class Events extends haxe.ui.events.Events {
    private var _collapsible:Collapsible;

    private function new(collapsible:Collapsible) {
        super(collapsible);
        _collapsible = collapsible;
    }
    
    public override function register() {
        var button = _collapsible.findComponent("collapsible-button", Button);
        if (button != null && button.hasEvent(UIEvent.CHANGE, onButtonChanged) == false) {
            button.registerEvent(UIEvent.CHANGE, onButtonChanged);
        }
    }

    public override function unregister() {
        var button = _collapsible.findComponent("collapsible-button", Button);
        if (button != null) {
            button.unregisterEvent(UIEvent.CHANGE, onButtonChanged);
        }
    }

    private function onButtonChanged(event:UIEvent) {
        var button = _collapsible.findComponent("collapsible-button", Button);
        _collapsible.collapsed = !button.selected;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _collapsible:Collapsible;

    private var _header:Box;
    private var _content:VBox;
    
    private function new(collapsible:Collapsible) {
        super(collapsible);
        _collapsible = collapsible;
        
        _header = new Box();
        _header.percentWidth = 100;
        var button = new Button();
        button.toggle = true;
        button.text = "Collapsible";
        button.addClass("collapsible-button");
        button.id = "collapsible-button";
        button.scriptAccess = false;
        _header.addComponent(button);
        _collapsible.addComponent(_header);
        
        _content = new VBox();
        _content.addClass("collapsible-content");
        _content.id = "collapsible-content";
        _content.scriptAccess = false;
        _content.hide();
        _collapsible.addComponent(_content);
        
        _collapsible.registerInternalEvents(true);
    }
    
    public override function addComponent(child:Component):Component {
        if (child != _header && child != _content) {
            return _content.addComponent(child);
        }
        return null;
    }
}