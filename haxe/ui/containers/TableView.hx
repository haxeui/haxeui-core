package haxe.ui.containers;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.behaviours.LayoutBehaviour;
import haxe.ui.components.Column;
import haxe.ui.components.Label;
import haxe.ui.components.VerticalScroll;
import haxe.ui.constants.SelectionMode;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.containers.ScrollView.ScrollViewEvents;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.events.SortEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Size;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.layouts.VerticalVirtualLayout;
import haxe.ui.util.MathUtil;
import haxe.ui.util.Variant;

@:composite(Events, Builder, Layout)
class TableView extends ScrollView implements IDataComponent implements IVirtualContainer {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(DataSourceBehaviour)                             public var dataSource:DataSource<Dynamic>;
    @:clonable @:behaviour(LayoutBehaviour, -1)                             public var itemWidth:Float;
    @:clonable @:behaviour(LayoutBehaviour, -1)                             public var itemHeight:Float;
    @:clonable @:behaviour(LayoutBehaviour, -1)                             public var itemCount:Int;
    @:clonable @:behaviour(LayoutBehaviour, false)                          public var variableItemSize:Bool;
    @:clonable @:behaviour(SelectedIndexBehaviour, -1)                      public var selectedIndex:Int;
    @:clonable @:behaviour(SelectedItemBehaviour)                           public var selectedItem:Dynamic;
    @:clonable @:behaviour(SelectedIndicesBehaviour)                        public var selectedIndices:Array<Int>;
    @:clonable @:behaviour(SelectedItemsBehaviour)                          public var selectedItems:Array<Dynamic>;
    @:clonable @:behaviour(SelectionModeBehaviour, SelectionMode.ONE_ITEM)  public var selectionMode:SelectionMode;
    @:clonable @:behaviour(DefaultBehaviour, 500)                           public var longPressSelectionTime:Int;  //ms
    @:clonable @:behaviour(GetHeader)                                       public var header:Component;

    @:call(ClearTable)                                                      public function clearContents(clearHeader:Bool = false);
    @:call(AddColumn)                                                       public function addColumn(text:String):Component;
    @:call(RemoveColumn)                                                    public function removeColumn(text:String);

    @:event(ItemEvent.COMPONENT_EVENT)                                      public var onComponentEvent:ItemEvent->Void;

    private var _itemRendererClass:Class<ItemRenderer>;
    @:clonable public var itemRendererClass(get, set):Class<ItemRenderer>;
    private function get_itemRendererClass():Class<ItemRenderer> {
        return _itemRendererClass;
    }
    private function set_itemRendererClass(value:Class<ItemRenderer>):Class<ItemRenderer> {
        if (_itemRendererClass != value) {
            _itemRendererClass = value;
            invalidateComponentLayout();
        }

        return value;
    }

    private var _itemRenderer:ItemRenderer;
    @:clonable public var itemRenderer(get, set):ItemRenderer;
    private function get_itemRenderer():ItemRenderer {
        return _itemRenderer;
    }
    private function set_itemRenderer(value:ItemRenderer):ItemRenderer {
        if (_itemRenderer != value) {
            _itemRenderer = value;
            invalidateComponentLayout();
        }

        return value;
    }
}

private class CompoundItemRenderer extends ItemRenderer {
    public function new() {
        super();
        this.layout = LayoutFactory.createFromName("horizontal");
        this.styleString = "spacing: 2px;";
        removeClass("itemrenderer");
    }
    
    private override function onDataChanged(data:Dynamic) {
        var renderers = findComponents(ItemRenderer);
        for (r in renderers) {
            r.onDataChanged(data);
        }
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Events extends ScrollViewEvents {
    private var _tableview:TableView;

    public function new(tableview:TableView) {
        super(tableview);
        //tableview.clip = true;
        _tableview = tableview;
    }

    public override function register() {
        super.register();
        registerEvent(ScrollEvent.CHANGE, onScrollChange);
        registerEvent(UIEvent.RENDERER_CREATED, onRendererCreated);
        registerEvent(UIEvent.RENDERER_DESTROYED, onRendererDestroyed);
    }

    public override function unregister() {
        super.unregister();
        unregisterEvent(ScrollEvent.CHANGE, onScrollChange);
        unregisterEvent(UIEvent.RENDERER_CREATED, onRendererCreated);
        unregisterEvent(UIEvent.RENDERER_DESTROYED, onRendererDestroyed);
    }

    private function onScrollChange(e:ScrollEvent) {
        _tableview.invalidateComponentLayout();
    }

    private function onRendererCreated(e:UIEvent) {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.registerEvent(MouseEvent.MOUSE_DOWN, onRendererMouseDown);
        instance.registerEvent(MouseEvent.CLICK, onRendererClick);
        instance.registerEvent(MouseEvent.RIGHT_CLICK, onRendererClick);
        if (_tableview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            var builder:Builder = cast(_tableview._compositeBuilder, Builder);
            builder.addItemRendererClass(instance, ":selected");
        }
    }

    private function onRendererDestroyed(e:UIEvent) {
        var instance:ItemRenderer = cast(e.data, ItemRenderer);
        instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onRendererMouseDown);
        instance.unregisterEvent(MouseEvent.CLICK, onRendererClick);
        instance.unregisterEvent(MouseEvent.RIGHT_CLICK, onRendererClick);
        if (_tableview.selectedIndices.indexOf(instance.itemIndex) != -1) {
            var builder:Builder = cast(_tableview._compositeBuilder, Builder);
            builder.addItemRendererClass(instance, ":selected", false);
        }
    }

    private function onRendererMouseDown(e:MouseEvent) {
        switch (_tableview.selectionMode) {
            case SelectionMode.MULTIPLE_LONG_PRESS:
                if (_tableview.selectedIndices.length == 0) {
                    startLongPressSelection(e);
                }

            default:
        }
    }

    private function startLongPressSelection(e:MouseEvent) {
        var timerClick:Timer = null;
        var currentMouseX:Float = e.screenX;
        var currentMouseY:Float = e.screenY;
        var renderer:ItemRenderer = cast(e.target, ItemRenderer);
        var __onMouseMove:MouseEvent->Void = null;
        var __onMouseUp:MouseEvent->Void = null;
        var __onMouseClick:MouseEvent->Void = null;

        __onMouseMove = function (_e:MouseEvent) {
            currentMouseX = _e.screenX;
            currentMouseY = _e.screenY;
        }

        __onMouseUp = function (_e:MouseEvent) {
            if (timerClick != null) {
                timerClick.stop();
                timerClick = null;
            }

            renderer.screen.unregisterEvent(MouseEvent.MOUSE_MOVE, __onMouseMove);
            renderer.screen.unregisterEvent(MouseEvent.MOUSE_UP, __onMouseUp);
        }

        __onMouseClick = function(_e:MouseEvent) {
            _e.cancel();    //Avoid toggleSelection onRendererClick method

            renderer.unregisterEvent(MouseEvent.CLICK, __onMouseClick);
        }

        renderer.screen.registerEvent(MouseEvent.MOUSE_MOVE, __onMouseMove);
        renderer.screen.registerEvent(MouseEvent.MOUSE_UP, __onMouseUp);

        timerClick = Timer.delay(function(){
            if (timerClick != null) {
                timerClick = null;

                if (renderer.hitTest(currentMouseX, currentMouseY) &&
                    MathUtil.distance(e.screenX, e.screenY, currentMouseX, currentMouseY) < 2 * Toolkit.pixelsPerRem) {
                    toggleSelection(renderer);
                    renderer.registerEvent(MouseEvent.CLICK, __onMouseClick, 1);
                }
            }
        }, _tableview.longPressSelectionTime);
    }

    private override function onContainerEventsStatusChanged() {
        super.onContainerEventsStatusChanged();
        if (_containerEventsPaused == true) {
            _tableview.findComponent("tableview-contents", Component, true, "css").removeClass(":hover", true, true);
        } else if (_lastMousePos != null) {
            /* TODO: may be ill concieved, doesnt look good on mobile
            var items = _tableview.findComponentsUnderPoint(_lastMousePos.x, _lastMousePos.y, ItemRenderer);
            for (i in items) {
                i.addClass(":hover", true, true);
            }
            */
        }
    }

    private function onRendererClick(e:MouseEvent) {
        if (_containerEventsPaused == true) {
            return;
        }

        var components = e.target.findComponentsUnderPoint(e.screenX, e.screenY);
        for (component in components) {
            if ((component is InteractiveComponent) && cast(component, InteractiveComponent).allowInteraction == true) {
                return;
            }
        }

        var renderer:ItemRenderer = cast(e.target, ItemRenderer);
        switch (_tableview.selectionMode) {
            case SelectionMode.DISABLED:

            case SelectionMode.ONE_ITEM:
                _tableview.selectedIndex = renderer.itemIndex;

            case SelectionMode.ONE_ITEM_REPEATED:
                _tableview.selectedIndices = [renderer.itemIndex];

            case SelectionMode.MULTIPLE_MODIFIER_KEY, SelectionMode.MULTIPLE_CLICK_MODIFIER_KEY:
                if (e.ctrlKey == true) {
                    toggleSelection(renderer);
                } else if (e.shiftKey == true) {
                    var selectedIndices:Array<Int> = _tableview.selectedIndices;
                    var fromIndex:Int = selectedIndices.length > 0 ? selectedIndices[selectedIndices.length - 1]: 0;
                    var toIndex:Int = renderer.itemIndex;
                    if (fromIndex < toIndex) {
                        for (i in selectedIndices) {
                            if (i < fromIndex) {
                                fromIndex = i;
                            }
                        }
                    } else {
                        var tmp:Int = fromIndex;
                        fromIndex = toIndex;
                        toIndex = tmp;
                    }

                    selectRange(fromIndex, toIndex);
                } else if (_tableview.selectionMode == SelectionMode.MULTIPLE_CLICK_MODIFIER_KEY) {
                    _tableview.selectedIndex = renderer.itemIndex;
                }

            case SelectionMode.MULTIPLE_LONG_PRESS:
                var selectedIndices:Array<Int> = _tableview.selectedIndices;
                if (selectedIndices.length > 0) {
                    toggleSelection(renderer);
                }

            default:
                //Nothing
        }
    }

    private function toggleSelection(renderer:ItemRenderer) {
        var itemIndex:Int = renderer.itemIndex;
        var selectedIndices = _tableview.selectedIndices.copy();
        var index:Int;
        if ((index = selectedIndices.indexOf(itemIndex)) == -1) {
            selectedIndices.push(itemIndex);
        } else {
            selectedIndices.splice(index, 1);
        }
        _tableview.selectedIndices = selectedIndices;
    }

    private function selectRange(fromIndex:Int, toIndex:Int) {
        _tableview.selectedIndices = [for (i in fromIndex...toIndex + 1) i];
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends ScrollViewBuilder {
    private var _tableview:TableView;
    private var _header:Header;

    public function new(tableview:TableView) {
        super(tableview);
        _tableview = tableview;
    }

    public override function create() {
        createContentContainer(_tableview.virtual ? "absolute" : "vertical");
    }

    public override function onInitialize() {
        if (_header == null) {
            return;
        }
        if (_tableview.itemRenderer == null) {
            buildDefaultRenderer();
        } else {
            fillExistingRenderer();
        }
    }

    public override function onReady() {
        if (_header == null) {
            return;
        }
        if (_tableview.itemRenderer == null) {
            buildDefaultRenderer();
        } else {
            fillExistingRenderer();
        }

        _component.invalidateComponentLayout();
    }

    private override function createContentContainer(layoutName:String) {
        if (_contents == null) {
            super.createContentContainer(layoutName);
            _contents.addClass("tableview-contents");
        }
    }

    public override function addComponent(child:Component):Component {
        var r = null;
        if ((child is ItemRenderer)) {
            var itemRenderer = _tableview.itemRenderer;
            if (itemRenderer == null) {
                itemRenderer = new CompoundItemRenderer();
                _tableview.itemRenderer = itemRenderer;
            }
            itemRenderer.addComponent(child);

            return child;
        } else if ((child is Header)) {
            _header = cast(child, Header);
            _header.registerEvent(UIEvent.COMPONENT_ADDED, onColumnAdded);
            _header.registerEvent(SortEvent.SORT_CHANGED, onSortChanged);

            /*
            if (_tableview.itemRenderer == null) {
                buildDefaultRenderer();
            } else {
                fillExistingRenderer();
            }
            */

            r = null;
        } else {
            r = super.addComponent(child);
        }
        return r;
    }

    private function onColumnAdded(e) {
        if (_tableview.itemRenderer == null) {
            buildDefaultRenderer();
        } else {
            fillExistingRenderer();
        }

        _component.invalidateComponentLayout();
    }

    private function onSortChanged(e:SortEvent) {
        var column = cast(e.target, Column);
        var field = column.id;
        if (column.sortField != null) {
            field = column.sortField;
        }
        _tableview.dataSource.sort(field, e.direction);
    }
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if ((child is Header) == true) {
            _header = null;
            return null;
        }
        return super.removeComponent(child, dispose, invalidate);
    }

    private function createRenderer(id:String):ItemRenderer {
        var itemRenderer:ItemRenderer = null;
        if (_tableview.itemRendererClass == null) {
            itemRenderer = new ItemRenderer();
        } else {
            itemRenderer = Type.createInstance(_tableview.itemRendererClass, []);
        }
        
        if (itemRenderer.childComponents.length == 0) {
            var label = new Label();
            label.id = id;
            label.percentWidth = 100;
            label.verticalAlign = "center";
            itemRenderer.addComponent(label);
        }
        return itemRenderer;
    }
    
    public function buildDefaultRenderer() {
        var r = new CompoundItemRenderer();
        if (_header != null) {
            for (column in _header.findComponents(Column)) {
                if (column.id == null) {
                    continue;
                }
                var itemRenderer = createRenderer(column.id);
                r.addComponent(itemRenderer);
            }
        }
        _tableview.itemRenderer = r;
    }

    public function fillExistingRenderer() {
        var i = 0;
        for (column in _header.findComponents(Column)) {
            if (column.id == null) {
                continue;
            }
            var existing = _tableview.itemRenderer.findComponent(column.id, ItemRenderer, true);
            if (existing == null) {
                var temp = _tableview.itemRenderer.findComponent(column.id, Component, true);
                if (temp != null) {
                    if ((temp is ItemRenderer)) {
                        existing = cast(temp, ItemRenderer);
                    } else {
                        existing = temp.findAncestor(ItemRenderer);
                    }
                    _tableview.itemRenderer.setComponentIndex(existing, i);
                } else {
                    var itemRenderer = createRenderer(column.id);
                    _tableview.itemRenderer.addComponentAt(itemRenderer, i);
                }
            } else {
                _tableview.itemRenderer.setComponentIndex(existing, i);
            }
            i++;
        }

        /* NOT SURE WHAT THIS IS, OR WHY ITS HERE, IT SEEMS LIKE TEST CODE THAT
         * HAS BEEN LEFT IN, COMMENTING FOR NOW, BUT LOOK TO REMOVE LATER IF
         * NO USE HAS BEEN FOUND
        var data = _component.findComponent("tableview-contents", Box, true, "css");
        if (data != null) {
            for (item in data.childComponents) {
                for (column in _header.childComponents) {
                    var existing = item.findComponent(column.id, ItemRenderer, true);
                    if (existing == null) {
                        var temp = _tableview.itemRenderer.findComponent(column.id, Component, true);
                        var renderer:ItemRenderer = null;
                        if ((temp is ItemRenderer)) {
                            renderer = cast(temp, ItemRenderer);
                        } else {
                            renderer = temp.findAncestor(ItemRenderer);
                        }
                        var index = _tableview.itemRenderer.getComponentIndex(renderer);
                        var instance = renderer.cloneComponent();
                        if (index < 0) {
                            item.addComponent(instance);
                        } else {
                            item.addComponentAt(instance, index);
                        }
                    }
                }
            }
        }
        */
    }

    private override function verticalConstraintModifier():Float {
        if (_header == null) {
            return 0;
        }

        return _header.height;
    }

    public override function onVirtualChanged() {
        _contents.layoutName = _tableview.virtual ? "absolute" : "vertical";
    }

    private override function get_virtualHorizontal():Bool {
        return false;
    }

    public function addItemRendererClass(child:Component, className:String, add:Bool = true) {
        child.walkComponents(function(c) {
            if ((c is ItemRenderer)) {
                if (add == true) {
                    c.addClass(className);
                } else {
                    c.removeClass(className);
                }
            } else {
                c.invalidateComponentStyle(); // we do want to invalidate the other components incase the css rule applies indirectly
            }
            return true;
        });
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
private class Layout extends VerticalVirtualLayout {
    private override function itemClass(index:Int, data:Dynamic):Class<ItemRenderer> {
        return CompoundItemRenderer;
    }

    public override function repositionChildren() {
        var header = findComponent(Header, true);
        if (header == null) {
            return;
        }

        super.repositionChildren();

        header.left = paddingLeft + borderSize; // + marginLeft(header);
        header.top = paddingTop + borderSize; // + marginTop(header);
        var vscroll = _component.findComponent(VerticalScroll);
        if (vscroll != null && vscroll.hidden == false) {
            header.addClass("scrolling");
            header.invalidateComponent(true);
        } else {
            header.removeClass("scrolling");
            header.invalidateComponent(true);
        }
        var rc:Rectangle = new Rectangle(cast(_component, ScrollView).hscrollPos + 1, 1, usableWidth, header.height);
        header.componentClipRect = rc;

        var data = findComponent("tableview-contents", Box, true, "css");
        if (data != null) {
            //data.lockLayout(true);
            for (item in data.childComponents) {
                var headerChildComponents = header.findComponents(Column);
                for (column in headerChildComponents) {
                    if (column.id == null) {
                        continue;
                    }
                    var isLast = (headerChildComponents.indexOf(column) == (headerChildComponents.length - 1));
                    var itemRenderer = item.findComponent(column.id, Component);
                    if (itemRenderer != null && (itemRenderer is ItemRenderer) == false) {
                        itemRenderer = itemRenderer.findAncestor(ItemRenderer);
                    }
                    if (itemRenderer != null) {
                        itemRenderer.percentWidth = null;
                        if (isLast == false) {
                            itemRenderer.width = column.width - item.layout.horizontalSpacing;
                        } else {
                            itemRenderer.width = column.width;
                        }
                    }
                }
            }

            data.left = paddingLeft + borderSize;
            data.top = header.top + header.height - 1;
            data.componentWidth = header.width;
            //data.unlockLayout(true);
        }
    }

    private override function resizeChildren() {
        var header = findComponent(Header, true);
        if (header == null) {
            return;
        }

        super.resizeChildren();
    }

    private override function verticalConstraintModifier():Float {
        var header = findComponent(Header, true);
        if (header == null) {
            return 0;
        }

        return header.height;
    }
    
    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var size = super.calcAutoSize();
        size.height += 1;
        return size;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class DataSourceBehaviour extends DataBehaviour {
    private var _firstPass:Bool = true; // may not have any any children at first, so a height of 1 causes loads of renderers to be created
    public override function set(value:Variant) {
        super.set(value);
        var dataSource:DataSource<Dynamic> = _value;
        if (dataSource != null) {
            dataSource.transformer = new NativeTypeTransformer();
            dataSource.onDataSourceChange = function() {
                _component.invalidateComponentLayout();
                if (_firstPass == true) {
                    _component.syncComponentValidation();
                    _firstPass = false;
                    _component.invalidateComponentLayout();
                }
            }
            _component.invalidateComponentLayout();
        } else {
            _component.invalidateComponentLayout();
        }
    }

    public override function get():Variant {
        if (_value == null || _value.isNull) {
            _value = new ArrayDataSource<Dynamic>();
            set(_value);
        }
        return _value;
    }
}

@:dox(hide) @:noCompletion
private class SelectedIndexBehaviour extends Behaviour {
    public override function get():Variant {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        return selectedIndices != null && selectedIndices.length > 0 ? selectedIndices[selectedIndices.length - 1] : -1;
    }

    public override function set(value:Variant) {
        var tableView:TableView = cast(_component, TableView);
        tableView.selectedIndices = value != -1 ? [value] : null;
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemBehaviour extends Behaviour {
    public override function getDynamic():Dynamic {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        return selectedIndices.length > 0 ? tableView.dataSource.get(selectedIndices[selectedIndices.length - 1]) : null;
    }

    public override function set(value:Variant) {
        var tableView:TableView = cast(_component, TableView);
        var index:Int = tableView.dataSource.indexOf(value);
        if (index != -1 && tableView.selectedIndices.indexOf(index) == -1) {
            tableView.selectedIndices = [index];
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedIndicesBehaviour extends DataBehaviour {
    public override function get():Variant {
        return _value.isNull ? [] : _value;
    }

    private override function validateData() {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        var itemToEnsure:ItemRenderer = null;
        var builder:Builder = cast(_component._compositeBuilder, Builder);

        for (child in contents.childComponents) {
            if (selectedIndices.indexOf(cast(child, ItemRenderer).itemIndex) != -1) {
                itemToEnsure = cast(child, ItemRenderer);
                builder.addItemRendererClass(child, ":selected");
            } else {
                builder.addItemRendererClass(child, ":selected", false);
            }
        }

        if (itemToEnsure != null && tableView.virtual == false) {  // TODO: virtual scroll into view
            var vscroll:VerticalScroll = tableView.findComponent(VerticalScroll);
            if (vscroll != null) {
                var vpos:Float = vscroll.pos;
                var contents:Component = tableView.findComponent("tableview-contents", "css");
                if (itemToEnsure.top + itemToEnsure.height > vpos + contents.componentClipRect.height) {
                    vscroll.pos = ((itemToEnsure.top + itemToEnsure.height) - contents.componentClipRect.height);
                } else if (itemToEnsure.top < vpos) {
                    vscroll.pos = itemToEnsure.top;
                }
            }
        }

        if (tableView.selectedIndex != -1 && tableView.selectedIndices.length != 0) {
            _component.dispatch(new UIEvent(UIEvent.CHANGE));
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemsBehaviour extends Behaviour {
    public override function get():Variant {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        if (selectedIndices != null && selectedIndices.length > 0) {
            var selectedItems:Array<Dynamic> = [];
            for (i in selectedIndices) {
                if ((i < 0) || (i >= tableView.dataSource.size)) {
                    continue;
                }
                var data:Dynamic = tableView.dataSource.get(i);
                selectedItems.push(data);
            }

            return selectedItems;
        } else {
            return [];
        }
    }

    public override function set(value:Variant) {
        var tableView:TableView = cast(_component, TableView);
        var selectedItems:Array<Dynamic> = value;
        if (selectedItems != null && selectedItems.length > 0) {
            var selectedIndices:Array<Int> = [];
            var index:Int;
            for (item in selectedItems) {
                if ((index = tableView.dataSource.indexOf(item)) != -1) {
                    selectedIndices.push(index);
                }
            }

            tableView.selectedIndices = selectedIndices;
        } else {
            tableView.selectedIndices = [];
        }
    }
}

@:dox(hide) @:noCompletion
private class SelectionModeBehaviour extends DataBehaviour {
    private override function validateData() {
        var tableView:TableView = cast(_component, TableView);
        var selectedIndices:Array<Int> = tableView.selectedIndices;
        if (selectedIndices.length == 0) {
            return;
        }

        var selectionMode:SelectionMode = cast _value;
        switch (selectionMode) {
            case SelectionMode.DISABLED:
                tableView.selectedIndices = null;

            case SelectionMode.ONE_ITEM:
                if (selectedIndices.length > 1) {
                    tableView.selectedIndices = [selectedIndices[0]];
                }

            default:
        }
    }
}

@:dox(hide) @:noCompletion
private class GetHeader extends DefaultBehaviour {
    public override function get():Variant {
        var header:Header = _component.findComponent(Header);
        return header;
    }
}

@:dox(hide) @:noCompletion
private class ClearTable extends Behaviour {
    public override function call(param:Any = null):Variant {
        if (param == true) {
            if (cast(_component, TableView).itemRenderer != null) {
                cast(_component, TableView).itemRenderer.removeAllComponents();
            }
            var header:Header = _component.findComponent(Header);
            if (header != null) {
                header.removeAllComponents();
            }
        }
        var contents = _component.findComponent("tableview-contents", Box, true, "css");
        if (contents != null) {
            contents.removeAllComponents();
        }
        return null;
    }
}

@:dox(hide) @:noCompletion
private class AddColumn extends Behaviour {
    public override function call(param:Any = null):Variant {
        var header:Header = _component.findComponent(Header);
        if (header == null) {
            header = new Header();
            _component.addComponent(header);
        }
        var column = new Column();
        column.text = param;
        column.id = StringTools.replace(param, " ", "_");
        header.addComponent(column);
        return column;
    }
}

@:dox(hide) @:noCompletion
private class RemoveColumn extends Behaviour {
    public override function call(param:Any = null):Variant {
        var header:Header = _component.findComponent(Header);
        if (header == null) {
            return null;
        }
        for (c in header.findComponents(Column)) {
            if (c.id == null) {
                continue;
            }
            if (c.text == param) {
                header.removeComponent(c);
                break;
            }
        }
        return null;
    }
}
