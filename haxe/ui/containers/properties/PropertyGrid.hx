package haxe.ui.containers.properties;

import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.VerticalScroll;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.containers.ScrollView.ScrollViewEvents;

@:composite(Events, Builder)
class PropertyGrid extends ScrollView {
    @:behaviour(DefaultBehaviour)                    public var popupStyleNames:String;
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends ScrollViewEvents {
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends ScrollViewBuilder {
    public override function createVScroll():VerticalScroll {
        for (g in _component.findComponents(PropertyGroup)) {
            g.findComponent("property-group-header").addClass("scrolling");
            g.findComponent("property-group-contents").addClass("scrolling");
        }
        return super.createVScroll();
    }
    
    public override function destroyVScroll() {
        for (g in _component.findComponents(PropertyGroup)) {
            g.findComponent("property-group-header").removeClass("scrolling");
            g.findComponent("property-group-contents").removeClass("scrolling");
        }
        super.destroyVScroll();
    }
}