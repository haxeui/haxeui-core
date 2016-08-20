package haxe.ui.containers;

import haxe.Json;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.IClonable;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;

class ListView extends ScrollView implements IDataComponent implements IClonable<ListView> {
    public function new() {
        super();
    }
    
    private override function createChildren():Void {
        super.createChildren();
        
        var vbox:VBox = new VBox();
        vbox.addClass("listview-contents");
        addComponent(vbox);
    }
    
    private var _itemRenderer:ItemRenderer;
    
    @:access(haxe.ui.core.Component)
    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer) && _itemRenderer == null) {
            _itemRenderer = cast(child, ItemRenderer);
            if (_data != null) {
                data = _data;
            }
        } else {
            r = super.addComponent(child);
        }
        return r;
    }
    
    public function addItem(data:Dynamic):ItemRenderer {
        if (_itemRenderer == null) {
            trace("NOPE!");
            return null;
        }
        
        var r = _itemRenderer.cloneComponent();
        var n = contents.childComponents.length;
        var item:ItemRenderer = cast addComponent(r);
        item.addClass(n % 2 == 0 ? "even" : "odd");
        item.data = data;
        
        return item;
    }
    
    private var _data:Dynamic;
    public var data(get, set):Dynamic;
    private function get_data():Dynamic {
        return null;
    }
    private function set_data(value:Dynamic):Dynamic {
        _data = value;
        if (_itemRenderer == null) {
            return value;
        }
        
        if (Std.is(value, String)) {
            var stringValue:String = StringTools.trim('${value}');
            trace(stringValue);
            if (StringTools.startsWith(stringValue, "<")) { // xml
                var xml:Xml = Xml.parse(stringValue).firstElement();
                for (el in xml.elements()) {
                    var o:Dynamic = { };
                    Reflect.setField(o, "id", el.nodeName);
                    for (attr in el.attributes()) {
                        Reflect.setField(o, attr, el.get(attr));
                    }
                    addItem(o);
                }
            } else if (StringTools.startsWith(stringValue, "[")) { // json array
                var json:Array<Dynamic> = Json.parse(StringTools.replace(stringValue, "'", "\""));
                for (o in json) {
                    addItem(o);
                }
            }
        }
        return value;
    }
}
