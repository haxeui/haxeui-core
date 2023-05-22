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
        var indexToSelect = 0;
        if (indexToSelect != -1) {
            listItemPicker.listView.selectedIndex = indexToSelect;
            var r = renderer.findComponent(ItemRenderer);
            r.data = listItemPicker.listView.selectedItem;
        }
    }

    public override function onPanelSelection(event:UIEvent) {
        var listItemPicker:ListItemPicker = cast picker;
        var r = renderer.findComponent(ItemRenderer);
        r.data = listItemPicker.listView.selectedItem;
    }
}