package haxe.ui.events;

import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class MenuEvent extends UIEvent {
    public static final MENU_SELECTED:EventType<MenuEvent> = EventType.name("menuselected");
    public static final MENU_OPENED:EventType<MenuEvent> = EventType.name("menuopened");
    public static final MENU_CLOSED:EventType<MenuEvent> = EventType.name("menuclosed");

    public var menu:Menu = null;
    public var menuItem:MenuItem = null;

    public function new(type:String, bubble:Null<Bool> = false, data:Dynamic = null) {
        super(type, true, data);
    }

    public override function clone():MenuEvent {
        var c:MenuEvent = new MenuEvent(this.type);
        c.menu = this.menu;
        c.menuItem = this.menuItem;
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        postClone(c);
        return c;
    }
}
