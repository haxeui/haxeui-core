package haxe.ui.containers;

import haxe.ui.validation.ValidationManager;
import haxe.ui.validation.InvalidationFlags;
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
    static private inline var NO_SELECTION:Int = -1;

    public function new() {
        super();
    }

    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "dataSource" => new ListViewDefaultDataSourceBehaviour(this),
            "selectedIndex" => new DefaultSelectedIndexBehaviour(this)
        ]);
    }

    private override function createContentContainer() {
        if (_contents == null) {
            super.createContentContainer();
            _contents.percentWidth = 100;
            _contents.addClass("listview-contents");
        }
    }
    
    public override function addComponent(child:Component):Component {
        var r = null;
        if (Std.is(child, ItemRenderer) && (_itemRenderer == null && _itemRendererFunction == null)) {
            _itemRenderer = cast(child, ItemRenderer);
            createContentContainer();
            #if haxeui_luxe
            _itemRenderer.hide();
            #end
            if (_dataSource != null) {
                invalidateComponentData();
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

    private var _selectedIndex:Int = NO_SELECTION;
    public var selectedIndex(get, set):Int;
    private function get_selectedIndex():Int {
        return behaviourGet("selectedIndex");
    }
    private function set_selectedIndex(value:Int):Int {
        behaviourSet("selectedIndex", value);
        return value;
    }

    public var selectedItem(get, set):ItemRenderer;
    private function get_selectedItem():ItemRenderer {
        if (contents == null || _selectedIndex == NO_SELECTION || contents.childComponents[_selectedIndex] == null) {
            return null;
        }

        return cast(contents.childComponents[_selectedIndex], ItemRenderer);
    }
    private function set_selectedItem(value:ItemRenderer):ItemRenderer {
        if (_dataSource != null && _contents != null)
        {
            selectedIndex = contents.childComponents.indexOf(value);
        }

        return value;
    }

    public function resetSelection() {
        selectedIndex = NO_SELECTION;
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
        if (_dataSource == null) {
            return 0;
        }
        return _dataSource.size;
    }

    public var itemHeight(get, null):Float;
    private function get_itemHeight():Float {
        if (itemCount == 0 || contents == null) {
            return 0;
        }

        validate();
        return itemHeight;
    }

    private var _itemRendererFunction:ItemRendererFunction;
    public var itemRendererFunction(get, set):ItemRendererFunction;
    private function get_itemRendererFunction():ItemRendererFunction {
        return _itemRendererFunction;
    }
    private function set_itemRendererFunction(value:ItemRendererFunction):ItemRendererFunction {
        if (_itemRendererFunction != value) {
            _itemRendererFunction = value;

            invalidateComponentData();
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
        invalidateComponentData();
		return value;
	}

    private var _dataSource:DataSource<Dynamic>;
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        if (_dataSource == null) {
            _dataSource = new ArrayDataSource(new NativeTypeTransformer());
            //_dataSource.onChange = onDataSourceChanged;
            behaviourGet("dataSource");
        }
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        _dataSource = value;
        _dataSource.transformer = new NativeTypeTransformer();
        invalidateComponentData();
        //_dataSource.onChange = onDataSourceChanged;
        return value;
    }

    private function onDataSourceChanged() {
        invalidateComponentData();
    }

    private function syncUI() {
        if (_dataSource == null) {
            return;
        }

        for (n in 0..._dataSource.size) {
            var data:Dynamic = _dataSource.get(n);
            var item:ItemRenderer = null;
            if (n < contents.childComponents.length) {
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

        while (_dataSource.size < contents.childComponents.length) {
            contents.removeComponent(contents.childComponents[contents.childComponents.length - 1]); // remove last
        }
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
    // Validation
    //***********************************************************************************************************

    /**
     Invalidate the index of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentIndex() {
        invalidateComponent(InvalidationFlags.INDEX);
    }

    private override function validateInternal() {
        var dataInvalid = isInvalid(InvalidationFlags.DATA);
        var indexInvalid = isInvalid(InvalidationFlags.INDEX);
        var styleInvalid = isInvalid(InvalidationFlags.STYLE);
        var positionInvalid = isInvalid(InvalidationFlags.POSITION);
        var displayInvalid = isInvalid(InvalidationFlags.DISPLAY);
        var layoutInvalid = isInvalid(InvalidationFlags.LAYOUT) && _layoutLocked == false;
        var scrollInvalid = isInvalid(InvalidationFlags.SCROLL);

        if (dataInvalid) {
            validateData();
        }

        if (dataInvalid || indexInvalid) {
            validateIndex();
        }

        if (styleInvalid) {
            validateStyle();
        }

        if (positionInvalid) {
            validatePosition();
        }

        if (layoutInvalid) {
            displayInvalid = validateLayout() || displayInvalid;
        }

        if (scrollInvalid || layoutInvalid) {
            validateScroll();
        }

        if (displayInvalid || styleInvalid) {
            ValidationManager.instance.addDisplay(this);    //Update the display from all objects at the same time. Avoids UI flashes.
        }
    }

    private override function validateData() {
        behaviourSet("dataSource", _dataSource);    //TODO - if the index is the only change, the syncUI method is executed anyway

        super.validateData();
    }

    private function validateIndex() {
        var selectedItem = this.selectedItem;
        if(_currentSelection != selectedItem)
        {
            if (_currentSelection != null) {
                _currentSelection.removeClass(":selected", true, true);
            }

            _currentSelection = selectedItem;

            if (_currentSelection != null) {
                _currentSelection.addClass(":selected", true, true);
                dispatch(new UIEvent(UIEvent.CHANGE));
            }
        }
    }

    private override function validateLayout():Bool {
        var result = super.validateLayout();

        createContentContainer();
        if (contents == null) {
            return result;
        }
        
        //ItemHeight
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
        itemHeight = (cy / n);

        return result;
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
        if (listView._dataSource != null) {
            listView._dataSource.onChange = listView.onDataSourceChanged;
        }
        return listView._dataSource;
    }

    public override function set(value:Variant) {
        var listView:ListView = cast(_component, ListView);
        listView.syncUI();
        if (listView._dataSource != null) {
            listView._dataSource.onChange = listView.onDataSourceChanged;
        }
    }
}

@:dox(hide)
@:access(haxe.ui.containers.ListView)
class DefaultSelectedIndexBehaviour extends Behaviour {
    public override function get():Variant {
        var listView:ListView = cast(_component, ListView);
        return listView._selectedIndex;
    }

    public override function set(value:Variant) {
        var listView:ListView = cast(_component, ListView);
        if(listView._dataSource != null && value < listView._dataSource.size && listView._selectedIndex != value) {
            listView._selectedIndex = value;
            listView.invalidateComponentIndex();
        }
    }
}
