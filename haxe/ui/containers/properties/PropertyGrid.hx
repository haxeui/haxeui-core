package haxe.ui.containers.properties; 

import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.containers.ScrollView.ScrollViewEvents;
import haxe.ui.core.CompositeBuilder;

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
}