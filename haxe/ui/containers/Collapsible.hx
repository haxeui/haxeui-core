package haxe.ui.containers;

import haxe.ui.animation.AnimationBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.containers.Box;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.layouts.VerticalLayout;

@:composite(Events, CollapsibleBuilder, CollapsibleLayout)
class Collapsible extends Box {
    @:clonable @:behaviour(TextBehaviour)               public var text:String;
    @:clonable @:behaviour(CollapsedBehaviour, true)    public var collapsed:Bool;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TextBehaviour extends DataBehaviour {
    private override function validateData() {
        var label = _component.findComponent("collapsible-label", Label);
        if (label != null) {
            label.text = _value;
        }
    }
}

@:dox(hide) @:noCompletion
private class CollapsedBehaviour extends DataBehaviour {
    private override function validateData() {
        var header = _component.findComponent("collapsible-header");
        var icon = _component.findComponent("collapsible-icon");
        var label = _component.findComponent("collapsible-label");
        if (_value == true) {
            header.swapClass("collapsed", "expanded");
            icon.swapClass("collapsed", "expanded");
            label.swapClass("collapsed", "expanded");
        } else {
            header.swapClass("expanded", "collapsed");
            icon.swapClass("expanded", "collapsed");
            label.swapClass("expanded", "collapsed");
        }
        
        var content = _component.findComponent("collapsible-content", Component);
        if (content != null) {
            // TODO: think about moving this to css animations... yuk.
            if (_component.animatable) {
                if (_value) {
                    //content.opacity = 0;
                    var cy = content.height;
                    var autoHeight = content.autoHeight;
                    var animation = new AnimationBuilder(content, .3, "ease");
                    animation.setPosition(0, "height", cy, true);
                    animation.setPosition(100, "height", 0, true);
                    /*
                    animation.setPosition(0, "opacity", 1, true);
                    animation.setPosition(100, "opacity", 0, true);
                    */
                    animation.onComplete = function() {
                        if (autoHeight) {
                            @:privateAccess content._height = null;
                        }
                        content.hidden = _value;
                        //_component.dispatch(new UIEvent(UIEvent.CHANGE));
                    }
                    animation.play();
                } else {
                    content.hidden = _value;
                    //content.opacity = 0;
                    var cy = content.height;
                    var autoHeight = content.autoHeight;
                    var animation = new AnimationBuilder(content, .3, "ease");
                    animation.setPosition(0, "height", 0, true);
                    animation.setPosition(100, "height", cy, true);
                    /*
                    animation.setPosition(0, "opacity", 0, true);
                    animation.setPosition(100, "opacity", 1, true);
                    */
                    animation.onComplete = function() {
                        if (autoHeight) {
                            @:privateAccess content._height = null;
                        }
                        //_component.dispatch(new UIEvent(UIEvent.CHANGE));
                    }
                    animation.play();
                }
            } else {
                content.hidden = _value;
                //_component.dispatch(new UIEvent(UIEvent.CHANGE));
            }
        }

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
        var header = _collapsible.findComponent("collapsible-header");
        if (header != null && header.hasEvent(MouseEvent.CLICK, onHeaderClicked) == false) {
            header.registerEvent(MouseEvent.CLICK, onHeaderClicked);
        }
    }

    public override function unregister() {
        var header = _collapsible.findComponent("collapsible-header");
        if (header != null) {
            header.unregisterEvent(MouseEvent.CLICK, onHeaderClicked);
        }
    }

    private function onHeaderClicked(event:MouseEvent) {
        var interactives = _collapsible.findComponentsUnderPoint(event.screenX, event.screenY, InteractiveComponent);
        if (interactives.length != 0) {
            return;
        }
        _collapsible.collapsed = !_collapsible.collapsed;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class CollapsibleBuilder extends CompositeBuilder {
    private var _collapsible:Collapsible;

    private var _header:HBox;
    private var _content:VBox;
    private var _originalAnimatable:Bool = false;
    
    private function new(collapsible:Collapsible) {
        super(collapsible);
        _collapsible = collapsible;
        // we'll start off as non-animatable so things dont animate at the start of the component creation
        _originalAnimatable = _collapsible.animatable;
        _collapsible.animatable = false;
        _component.recursivePointerEvents = false;
        _header = new HBox();
        _header.percentWidth = 100;
        _header.id = "collapsible-header";
        _header.addClass("collapsible-header");
        _header.recursivePointerEvents = false;

        var icon = new Image();
        icon.addClass("collapsible-icon");
        icon.id = "collapsible-icon";
        _header.addComponent(icon);

        var label = new Label();
        label.addClass("collapsible-label");
        label.id = "collapsible-label";
        label.text = "Collapsible";
        _header.addComponent(label);

        _collapsible.addComponent(_header);
        
        _content = new VBox();
        _content.addClass("collapsible-content");
        _content.id = "collapsible-content";
        _content.scriptAccess = false;
        _content.hide();
        _collapsible.addComponent(_content);
        
        _collapsible.registerInternalEvents(true);
    }
    
    public override function onReady() {
        super.onReady();
        _collapsible.animatable = _originalAnimatable;
    }

    public override function addComponent(child:Component):Component {
        if ((child is Header)) {
            child.horizontalAlign = "right";
            return _header.addComponent(child);
        }
        if (child != _header && child != _content) {
            return _content.addComponent(child);
        }
        return null;
    }

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if ((child is Header)) {
            return _header.removeComponent(child, dispose, invalidate);
        }
        if (child != _header && child != _content) {
            return _content.removeComponent(child, dispose, invalidate);
        }
        return null;
    }

    public function calculateDepth():Int {
        var depth = 0;

        var parent = _collapsible.parentComponent;
        // TODO: better way to do this??
        while (parent != null) {
            if (parent.hasClass("collapsible-content") && parent.parentComponent != null && (parent.parentComponent is Collapsible)) {
                depth++;
            }
            parent = parent.parentComponent;
        }

        return depth;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class CollapsibleLayout extends VerticalLayout {
    private override function repositionChildren() {
        super.repositionChildren();
        var depth = 0;

        var parent = component.parentComponent;
        // TODO: better way to do this??
        while (parent != null) {
            if (parent.hasClass("collapsible-content") && parent.parentComponent != null && parent.parentComponent is Collapsible) {
                depth++;
            }
            parent = parent.parentComponent;
        }


        var builder = cast(component._compositeBuilder, CollapsibleBuilder);
        var depth = builder.calculateDepth();

        var header = findComponent("collapsible-header");
        var offset = 0;
        if (depth == 0) {
            offset = 5;
        }
        header.paddingLeft = offset + (depth * calcIndentSize());

        var content = findComponent("collapsible-content", false);
        applyIndent(content, depth);
    }

    public function calcIndentSize():Float {
        return 16;
    }

    private function applyIndent(content:Component, depth:Int) {
        if (depth == 0) {
            return;
        }
        for (c in content.childComponents) {
            if (c is Collapsible) {
                continue;
            }
            c.marginLeft = (depth + 1) * 16;
        }
    }
}