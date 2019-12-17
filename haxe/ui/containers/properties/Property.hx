package haxe.ui.containers.properties;

import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.core.IDataComponent;
import haxe.ui.data.DataSource;

class Property extends HBox implements IDataComponent {
    @:clonable @:behaviour(DefaultBehaviour)            public var label:String;
    @:clonable @:behaviour(DefaultBehaviour, "text")    public var type:String;
    @:behaviour(DefaultBehaviour)                       public var dataSource:DataSource<Dynamic>;
}