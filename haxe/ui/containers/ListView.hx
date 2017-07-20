package haxe.ui.containers;

import haxe.ui.core.Behaviour;
import haxe.ui.core.ClassFactory;
import haxe.ui.core.BasicItemRenderer;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.util.Variant;

class ListView extends ScrollView implements IDataComponent {
    public function new() {
        super();
    }

    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "dataSource" => new ListViewDefaultDataSourceBehaviour(this)
        ]);
    }


    private override function createChildren() {
        super.createChildren();
    }

    private override function createContentContainer() {
        super.createContentContainer();
        _contents.percentWidth = 100;
        _contents.addClass("listview-contents");
    }

    private override function onReady() {
        super.onReady();
        syncUI();
    }

    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer) && (_itemRenderer == null && _itemRendererFunction == null)) {
            _itemRenderer = cast(child, ItemRenderer);
            #if haxeui_luxe
            _itemRenderer.hide();
            #end
            if (_dataSource != null) {
                syncUI();
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

        var arr = event.target.findComponentsUnderPoint(event.screenX, event.screenY);
        for (a in arr) {
            if (Std.is(a, InteractiveComponent)) {
                return;
            }
        }
        
        selectedItem = cast(event.target, ItemRenderer);
    }

    public var selectedIndex(get, set):Int;
    private function get_selectedIndex():Int {
        if (_currentSelection == null) {
            return -1;
        }
        return contents.childComponents.indexOf(_currentSelection);
    }
    private function set_selectedIndex(value:Int):Int {
        var item:ItemRenderer = cast(contents.childComponents[value], ItemRenderer);
        selectedItem = item;
        return value;
    }

    public var selectedItem(get, set):ItemRenderer;
    private function get_selectedItem():ItemRenderer {
        return _currentSelection;
    }
    private function set_selectedItem(value:ItemRenderer):ItemRenderer {
        if (_currentSelection != null) {
            _currentSelection.removeClass(":selected");
        }

        _currentSelection = value;
        if (_currentSelection != null) {
            _currentSelection.addClass(":selected");
            dispatch(new UIEvent(UIEvent.CHANGE));
        }
        return value;
    }

    public function resetSelection() {
        if (_currentSelection != null) {
            _currentSelection.removeClass(":selected", true, true);
            _currentSelection = null;
        }
    }

    public function addItem(data:Dynamic):ItemRenderer {
        var r = itemToRenderer(data);
        r.percentWidth = 100;
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

    private var _itemRendererFunction:ItemRendererFunction;
    public var itemRendererFunction(get, set):ItemRendererFunction;
    private function get_itemRendererFunction():ItemRendererFunction {
        return _itemRendererFunction;
    }
    private function set_itemRendererFunction(value:ItemRendererFunction):ItemRendererFunction {
        if (_itemRendererFunction != value) {
            _itemRendererFunction = value;

            syncUI();
        }

        return value;
    }

    private var _itemRenderer:ItemRenderer;
	public var itemRendererClass(get, set):Class<ItemRenderer>;
	private function get_itemRendererClass():Class<ItemRenderer> {
		return Type.getClass(_itemRenderer);
	}
	private function set_itemRendererClass(value:Class<ItemRenderer>):Class<ItemRenderer> {
		_itemRenderer = Type.createInstance(value, []);
		if (_ready) {
			syncUI();
		}
		return value;
	}

    private var _dataSource:DataSource<Dynamic>;
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        return behaviourGet("dataSource");
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        behaviourSet("dataSource", value);
        return value;
    }

    private function onDataSourceChanged() {
        if (_ready == true) {
            syncUI();
        }
    }

    private function syncUI() {
        if (_dataSource == null) {
            contents.removeAllComponents();
            return;
        }

        lockLayout();

        for (n in 0..._dataSource.size) {
            var data:Dynamic = _dataSource.get(n);
            var item:ItemRenderer = null;
            if (n < itemCount) {
                item = cast(contents.childComponents[n], ItemRenderer);
                item.removeClass("even");
                item.removeClass("odd");

                if (_itemRendererFunction != null
                    && !Std.is(item, _itemRendererFunction(data).generator)) {
                    contents.removeComponent(item);
                    item = cast addComponent(itemToRenderer(data));  //TODO - addComponentAt
                    contents.setComponentIndex(item, n);
                }
            } else {
                item = cast addComponent(itemToRenderer(data));      //TODO - addComponentAt
                contents.setComponentIndex(item, n);
            }

            item.addClass(n % 2 == 0 ? "even" : "odd");
            item.data = data;
        }

        while (_dataSource.size < itemCount) {
            contents.removeComponent(contents.childComponents[contents.childComponents.length - 1]); // remove last
        }

        unlockLayout();
    }

    private function itemToRenderer(data:Dynamic):ItemRenderer
    {
        if (_itemRendererFunction != null) {
            return _itemRendererFunction(data).newInstance();
        } else {
            if (_itemRenderer == null) {
                _itemRenderer = new BasicItemRenderer();
            }
            return _itemRenderer.cloneComponent();
        }
    }

    //***********************************************************************************************************
    // Clonable
    //***********************************************************************************************************
    public override function cloneComponent():ListView {
        if (_dataSource != null) {
            c.dataSource = _dataSource.clone();
        }
    }
}

typedef ItemRendererFunction = Dynamic->ClassFactory<ItemRenderer>;

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************

@:dox(hide)
@:access(haxe.ui.containers.ListView)
class ListViewDefaultDataSourceBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView = cast(_component, ListView);
        listView._dataSource.onChange = listView.onDataSourceChanged;
        return listView._dataSource;
    }

    public override function set(value:Variant) {
        var listView:ListView = cast(_component, ListView);

        if (listView._dataSource == null) {
            listView._dataSource.onChange = null;
        }

        listView._dataSource = value;

        if (listView._dataSource != null) {
            listView._dataSource.transformer = new NativeTypeTransformer();
            listView._dataSource.onChange = listView.onDataSourceChanged;
        }

		if (listView._ready) {
			listView.syncUI();
		}
    }
}
