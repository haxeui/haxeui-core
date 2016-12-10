package haxe.ui.containers;

import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;
import haxe.ui.core.BasicItemRenderer;
import haxe.ui.core.Component;
import haxe.ui.core.IClonable;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;

class ListView extends ScrollView implements IDataComponent implements IClonable<ListView> {
    private var _itemRenderer:ItemRenderer;

    public function new() {
        super();
    }

    private override function createChildren():Void {
        super.createChildren();
    }

    private override function createContentContainer() {
        super.createContentContainer();
        _contents.percentWidth = 100;
        _contents.addClass("listview-contents");
    }
    
    private override function onReady() {
        super.onReady();
        if (_itemRenderer == null) {
            addComponent(new BasicItemRenderer());
        }
    }

    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer) && _itemRenderer == null) {
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

    public function resetSelection() {
        if (_currentSelection != null) {
            _currentSelection.removeClass(":selected");
            _currentSelection = null;
        }
    }
    
    public function addItem(data:Dynamic):ItemRenderer {
        if (_itemRenderer == null) {
            return null;
        }

        var r = _itemRenderer.cloneComponent();
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
    
    private var _dataSource:DataSource<Dynamic>;
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        if (_dataSource == null) {
            _dataSource = new ArrayDataSource(new NativeTypeTransformer());
            _dataSource.onChange = onDataSourceChanged;
        }
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        _dataSource = value;
        _dataSource.transformer = new NativeTypeTransformer();
        syncUI();
        _dataSource.onChange = onDataSourceChanged;
        return value;
    }
    
    private function onDataSourceChanged() {
        if (_ready == true) {
            syncUI();
        }
    }
    
    private function syncUI() {
        if (_itemRenderer == null || _dataSource == null) {
            return;
        }
        
        lockLayout();
        
        var delta = _dataSource.size - itemCount;
        if (delta > 0) { // not enough items
            for (n in 0...delta) {
                addComponent(_itemRenderer.cloneComponent());
            }
        } else if (delta < 0) { // too many items
            while (delta < 0) {
                contents.removeComponent(contents.childComponents[contents.childComponents.length - 1]); // remove last
                delta++;
            }
        }
        
        for (n in 0..._dataSource.size) {
            var item:ItemRenderer = cast(contents.childComponents[n], ItemRenderer);
            item.addClass(n % 2 == 0 ? "even" : "odd");
            item.data = _dataSource.get(n);
        }
        
        unlockLayout();
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
