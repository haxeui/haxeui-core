package haxe.ui.containers;

import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.AnimationEvent;
import haxe.ui.events.Events;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Variant;

@:composite(Events, Builder)
class Accordion extends VBox {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(PageIndex, -1)          public var pageIndex:Int;
    @:behaviour(DefaultBehaviour)       public var selectedPage:Component;
}

//***********************************************************************************************************
// Accordion Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class PageIndex extends DefaultBehaviour {
    public override function set(value:Variant) {
        if (value == _value) {
            return;
        }

        _value = value;

        if (_value == -1) {
            return;
        }

        var buttons = _component.findComponents(Button, 1);
        var selectedIndex:Int = value;
        var button = buttons[selectedIndex];
        var panel = _component.getComponentAt(_component.getComponentIndex(button) + 1);

        panel.registerEvent(AnimationEvent.START, function(event) {
            panel.unregisterEvents(AnimationEvent.START);
            _component.dispatch(event);
        });
        panel.registerEvent(AnimationEvent.END, function(event) {
            panel.unregisterEvents(AnimationEvent.END);
            _component.dispatch(event);
        });
        
        panel.swapClass(":expanded", ":collapsed");
        panel.hidden = false;

        cast(_component, Accordion).selectedPage = panel;
        button.selected = true;
        for (b in buttons) {
            if (b != button) {
                var tempIndex = _component.getComponentIndex(b);
                var tempPanel = _component.getComponentAt(tempIndex + 1);
                b.selected = false;
                tempPanel.swapClass(":collapsed", ":expanded");
            }
        }
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

//***********************************************************************************************************
// Accordion Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class Events extends haxe.ui.events.Events {
    private var _accordion:Accordion;

    private function new(accordion:Accordion) {
        super(accordion);
        _accordion = accordion;
    }

    public override function register() {
        var buttons = _target.findComponents(Button, 1);
        for (button in buttons) {
            if (button.hasEvent(UIEvent.CHANGE, onButtonChanged) == false) {
                button.registerEvent(UIEvent.CHANGE, onButtonChanged);
            }
        }
    }

    public override function unregister() {
        var buttons = _target.findComponents(Button, 1);
        for (button in buttons) {
            button.unregisterEvent(UIEvent.CHANGE, onButtonChanged);
        }
    }

    private function onButtonChanged(event:UIEvent) {
        var buttons = _target.findComponents(Button, 1);
        var button = cast(event.target);
        var index = buttons.indexOf(button);
        if (button.selected == true) {
            if (index == _accordion.pageIndex) {
                return;
            }
            _accordion.pageIndex = index;
        } else if (index == _accordion.pageIndex) {
            button.selected = true;
        }
    }

    private function onPageAnimationStart(event:AnimationEvent) {
        trace("start");
    }

    private function onPageAnimationEnd(event:AnimationEvent) {
        trace("end");
    }
}

//***********************************************************************************************************
// Accordion Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _accordion:Accordion;

    private function new(accordion:Accordion) {
        super(accordion);
        _accordion = accordion;
    }

    public override function onReady() {
        super.onReady();
        for (c in _accordion.childComponents) {
            c.animatable = true;
        }
    }

    public override function addComponent(child:Component):Component {
        if (!child.hasClass("accordion-button") && !child.hasClass("accordion-page")) {
            var button = new Button();
            button.text = child.text;
            button.addClass("accordion-button");
            button.toggle = true;
            button.scriptAccess = false;
            if (child.id != null) {
                button.id = child.id + "Button";
            }
            _accordion.addComponent(button);

            if (child.disabled == true) {
                button.disabled = true;
            }
            if (!_accordion.isReady) {
                child.animatable = false;
            } else {
                child.animatable = false;
                Toolkit.callLater(function() {
                    child.animatable = true;
                });
            }
            child.percentWidth = 100;
            child.addClass("accordion-page");
            child.registerEvent(UIEvent.PROPERTY_CHANGE, onPagePropertyChanged);
            var c = _accordion.addComponent(child);

            if (_accordion.pageIndex == -1) {
                child.percentHeight = 100;
                _accordion.pageIndex = 0;
            } else {
                child.hidden = true;
            }

            child.onAnimationEnd = function(e) {
                if (e.target.hasClass(":collapsed")) {
                    e.target.hidden = true;
                }
            }

            _component.registerInternalEvents(true);

            return c;
        }

        return null;
    }

    private function onPagePropertyChanged(event:UIEvent) {
        if (event.data == "text") {
            var index = _component.getComponentIndex(event.target);
            var button = _component.getComponentAt(index - 1);
            if (button != null &&  button.text != event.target.text) {
                button.text = event.target.text;
            }
        } else if (event.data == "disabled") {
            var index = _component.getComponentIndex(event.target);
            var button = _component.getComponentAt(index - 1);
            if (button != null &&  button.disabled != cast(event.target, Box).disabled) {
                button.disabled = cast(event.target, Box).disabled;
            }
        }
    }
}
