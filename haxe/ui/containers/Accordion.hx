package haxe.ui.containers;

import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
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
        panel.swapClass(":expanded", ":collapsed");
        panel.hidden = false;
        button.selected = true;
        for (b in buttons) {
            if (b != button) {
                var tempIndex = _component.getComponentIndex(b);
                var tempPanel = _component.getComponentAt(tempIndex + 1);
                b.selected = false;
                tempPanel.swapClass(":collapsed", ":expanded");
            }
        }
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
            _accordion.addComponent(button);

            child.animatable = false;
            child.percentWidth = 100;
            child.addClass("accordion-page");
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

            var buttonCount = 0;
            var pageCount = 0;
            for (child in _accordion.childComponents) {
                if (child.hasClass("accordion-button")) {
                    if (buttonCount == 0) {
                        child.swapClass("first", "last", false);
                    } else if (_component.childComponents.length / 2 > 1 && buttonCount == (_component.childComponents.length / 2) - 1) {
                        child.swapClass("last", "first", false);
                    } else {
                        child.removeClasses(["first", "last"], false);
                    }

                    buttonCount++;
                } else if (child.hasClass("accordion-page")) {
                    if (pageCount == 0) {
                        child.swapClass("first", "last", false);
                    } else if (_component.childComponents.length / 2 > 1 && pageCount == (_component.childComponents.length / 2) - 1) {
                        child.swapClass("last", "first", false);
                    } else {
                        child.removeClasses(["first", "last"], false);
                    }

                    pageCount++;
                }
            }

            return c;
        }

        return null;
    }
}
