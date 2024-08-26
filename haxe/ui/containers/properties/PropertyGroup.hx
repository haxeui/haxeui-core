package haxe.ui.containers.properties;

import haxe.ui.components.Label;
import haxe.ui.containers.Collapsible.CollapsibleBuilder;
import haxe.ui.containers.Collapsible.CollapsibleLayout;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;

@:composite(Builder, Layout)
class PropertyGroup extends Collapsible {
    
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Events extends haxe.ui.events.Events {
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CollapsibleBuilder {
    private var propertyGroup:PropertyGroup;

    public function new(propertyGroup:PropertyGroup) {
        super(propertyGroup);
        this.propertyGroup = propertyGroup;
    }

    public override function onInitialize() {
        super.onInitialize();
        this.propertyGroup.collapsed = !(calculateDepth() == 0);
    }
}

private class Layout extends CollapsibleLayout {
    override function applyIndent(content:Component, depth:Int) {
        //super.applyIndent(content, depth);
        var properties = content.findComponents(Property, 1);
        for (property in properties) {
            var label = property.findComponent("property-label-container", true, "css");
            label.paddingLeft = (depth + 1) * 16;
        }
    }
}