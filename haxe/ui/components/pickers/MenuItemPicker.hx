package haxe.ui.components.pickers;

import haxe.ui.components.pickers.ItemPicker;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.menus.MenuSeparator;
import haxe.ui.core.Component;
import haxe.ui.data.DataSource;
import haxe.ui.events.MenuEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Variant;

@:composite(Builder)
@:xml('
<item-picker>
    <hbox id="itemPickerRenderer">
        <image id="itemIcon" verticalAlign="center" />
        <label id="itemText" text="Select Item" verticalAlign="center" />
        <box height="100%" styleName="item-picker-trigger-icon-container">
            <image styleName="item-picker-trigger-icon" />
        </box>
    </hbox>
</item-picker>
')
class MenuItemPicker extends ItemPicker {
    private var _showIcon:Bool = true;
    public var showIcon(get, set):Bool;
    private function get_showIcon():Bool {
        return _showIcon;
    }
    private function set_showIcon(value:Bool):Bool {
        _showIcon = value;
        itemIcon.hidden = !_showIcon;
        return value;
    }

    private var _showText:Bool = true;
    public var showText(get, set):Bool;
    private function get_showText():Bool {
        return _showText;
    }
    private function set_showText(value:Bool):Bool {
        _showText = value;
        if (!_showText) {
            itemText.text = "";
        }
        return value;
    }

    private override function set_text(value:String):String {
        if (showText) {
            itemText.text = value;
            itemText.show();
        }
        return super.set_text(value);
    }

    private var _icon:Variant = null;
    public var icon(get, set):Variant;
    private function get_icon():Variant {
        return _icon;
    }
    private function set_icon(value:Variant):Variant {
        _icon = value;
        if (showIcon == true) {
            itemIcon.resource = value;
            itemIcon.show();
        }
        return value;
    }
}

private class Builder extends ItemPickerBuilder {
    public var menuPicker:MenuItemPicker;
    public var menu:Menu = null;

    public function new(menuPicker:MenuItemPicker) {
        super(menuPicker);
        this.menuPicker = menuPicker;
    }

    public override function create() {
        super.create();
        menu = new Menu();
        menu.id = "primaryPickerMenu";
        menu.styleNames = picker.styleNames;
        menuPicker.addComponent(menu);
    }

    public override function addComponent(child:Component):Component {
        if (child.id != "primaryPickerMenu" && ((child is Menu) || (child is MenuItem) || (child is MenuSeparator))) {
            if ((child is Menu)) {
                child.addClasses(["menuitempicker", "secondary-menu"]);
                child.styleNames = picker.styleNames;
            }
            menu.addComponent(child);
            return child;
        }
        return super.addComponent(child);
    }

    public override function addComponentAt(child:Component, index:Int):Component {
        if (child.id != "primaryPickerMenu" && ((child is Menu) || (child is MenuItem) || (child is MenuSeparator))) {
            menu.addComponentAt(child, index);
            return child;
        }
        return super.addComponentAt(child, index);
    }

    private override function get_panelSelectionEvent():String {
        return MenuEvent.MENU_SELECTED;
    }

    private override function get_handlerClass():Class<ItemPickerHandler> {
        return Handler;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Handler extends ItemPickerHandler {
    public override function onPanelSelection(event:UIEvent) {
        var menuPicker:MenuItemPicker = cast picker;
        var menuEvent:MenuEvent = cast event;
        event.relatedComponent = menuEvent.menuItem;
        var useIcon = false;
        var useText = false;
        if (menuEvent.menuItem.userData != null) {
            if (menuEvent.menuItem.userData.useIcon != null) {
                useIcon = Std.string(menuEvent.menuItem.userData.useIcon) == "true";
            }
            if (menuEvent.menuItem.userData.useText != null) {
                useText = Std.string(menuEvent.menuItem.userData.useText) == "true";
            }
        }
        if (useIcon) {
            menuPicker.icon = menuEvent.menuItem.icon;
        }
        if (useText) {
            menuPicker.text = menuEvent.menuItem.text;
        }
    }

    public override function applyDataSource(ds:DataSource<Dynamic>) {
        if (ds == null) {
            return;
        }
        var builder = cast(picker._compositeBuilder, Builder);
        ds.onChange = onDataSourceChanged;
        for (i in 0...ds.size) {
            var existing = builder.menu.getComponentAt(i);
            var item = ds.get(i);
            var type = item.type;
            if (type == null) {
                type = item.id;
            }
            if (existing == null) {
                switch (type) {
                    case "separator" | "menu-separator":
                        var menuSeparator = new MenuSeparator();
                        picker.addComponentAt(menuSeparator, i);
                    case _:
                        var menuItem = new MenuItem();
                        menuItem.text = item.text;
                        menuItem.icon = Std.string(item.icon);
                        menuItem.id = item.id;
                        menuItem.userData = item;
                        picker.addComponentAt(menuItem, i);
                }
            } else {
                if ((existing is MenuItem) && type != "separator") {
                    var existingMenuItem = cast(existing, MenuItem);
                    existingMenuItem.text = item.text;
                    existingMenuItem.icon = Std.string(item.icon);
                    existingMenuItem.id = item.id;
                    existingMenuItem.userData = item;
                }
            }
        }
    }

    private function onDataSourceChanged() {
        applyDataSource(picker.dataSource);
    }
}
