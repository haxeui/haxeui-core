package haxe.ui.components.pickers;

import haxe.ui.components.pickers.ItemPicker;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.DataSource;
import haxe.ui.events.UIEvent;

@:composite(Builder)
@:xml('
<item-picker>
    <listview id="listView" style="border:none;border-radius: 0px;" />
</item-picker>
')
class ListItemPicker extends ItemPicker {
    public var selectedIndex:Int = 0;
    public var selectedItem:Dynamic = null;
}

private class Builder extends ItemPickerBuilder {
    private override function get_handlerClass():Class<ItemPickerHandler> {
        return Handler;
    }
}

private class Handler extends ItemPickerHandler {
    public override function applyDataSource(ds:DataSource<Dynamic>) {
        var listItemPicker:ListItemPicker = cast picker;
        listItemPicker.listView.dataSource = ds;
        var indexToSelect = listItemPicker.selectedIndex;
        if (indexToSelect != -1) {
            listItemPicker.listView.selectedIndex = indexToSelect;
            var r = renderer.findComponent(ItemRenderer);
            if (r != null) {
                r.data = listItemPicker.listView.selectedItem;
            }
        }
    }

    public override function onPanelSelection(event:UIEvent) {
        var listItemPicker:ListItemPicker = cast picker;
        listItemPicker.selectedIndex = listItemPicker.listView.selectedIndex;
        listItemPicker.selectedItem = listItemPicker.listView.selectedItem;
        var r = renderer.findComponent(ItemRenderer);
        if (r != null) {
            r.data = listItemPicker.listView.selectedItem;
        }
    }
}