package haxe.ui.containers;

import haxe.Json;
import haxe.ui.components.Label;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.IClonable;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;

class ListView extends ScrollView implements IDataComponent implements IClonable<ListView> {
    private var _itemRenderer:ItemRenderer;
    
    public function new() {
        super();
    }
    
    private override function createChildren():Void {
        super.createChildren();
        
        var vbox:VBox = new VBox();
        vbox.addClass("listview-contents");
        addComponent(vbox);
    }
    
    private override function onReady() {
        super.onReady();
        if (_itemRenderer == null) {
            addComponent(new BasicItemRenderer());
        }
    }
    
    @:access(haxe.ui.core.Component)
    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer) && _itemRenderer == null) {
            _itemRenderer = cast(child, ItemRenderer);
            if (_data != null) {
                data = _data;
            }
        } else {
            if (Std.is(child, ItemRenderer)) {
                child.registerEvent(MouseEvent.CLICK, onItemClick);
            }
            r = super.addComponent(child);
        }
        return r;
    }

    private var _currentSelection:ItemRenderer;
    private function onItemClick(event:MouseEvent) {
        if (event.target == _currentSelection) {
            return;
        }

        if (_currentSelection != null) {
            _currentSelection.removeClass(":selected");
        }
        
        _currentSelection = cast event.target;
        _currentSelection.addClass(":selected");
        dispatch(new UIEvent(UIEvent.CHANGE));
    }
    
    public var selectedItem(get, null):ItemRenderer;
    private function get_selectedItem():ItemRenderer {
        return _currentSelection;
    }
    
    public function addItem(data:Dynamic):ItemRenderer {
        if (_itemRenderer == null) {
            return null;
        }
        
        var r = _itemRenderer.cloneComponent();
        var n = contents.childComponents.length;
        var item:ItemRenderer = cast addComponent(r);
        item.addClass(n % 2 == 0 ? "even" : "odd");
        item.data = data;
        
        return item;
    }
    
    public var itemCount(get, null):Int;
    private function get_itemCount():Int {
        if (contents == null) {
            return 0;
        }
        return contents.childComponents.length;
    }
    
    public var itemHeight(get, null):Float;
    private function get_itemHeight():Float {
        if (itemCount == 0 || contents == null) {
            return 0;
        }
        var n:Int = 0;
        var cy:Float = contents.layout.paddingTop + contents.layout.paddingBottom;
        var scy:Float = contents.layout.verticalSpacing;
        for (child in contents.childComponents) {
            cy += child.height + scy;
            n++;
            if (n > 100) {
                break;
            }
        }
        if (n > 0) {
            cy -= scy;
        }
        return (cy / n);
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
        
        lockLayout();
        
        if (Std.is(value, String)) {
            var stringValue:String = StringTools.trim('${value}');
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
        
        unlockLayout();
        
        return value;
    }
}

class BasicItemRenderer extends ItemRenderer {
    public function new() {
        super();
        
        addClass("itemrenderer"); // TODO: shouldnt have to do this
        this.percentWidth = 100;
        
        var hbox:HBox = new HBox();
        hbox.percentWidth = 100;
        
        var label:Label = new Label();
        label.id = "text";
        label.percentWidth = 100;
        hbox.addComponent(label);
        
        addComponent(hbox);
    }
}