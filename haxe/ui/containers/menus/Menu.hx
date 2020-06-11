package haxe.ui.containers.menus;

import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;

class MenuEvent extends UIEvent {
    public static inline var MENU_SELECTED:String = "menuselected";
    
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

@:composite(MenuEvents, Builder)
class Menu extends VBox {
    @:behaviour(DefaultBehaviour)           public var menuStyleNames:String;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.menus.Builder)
class MenuEvents extends haxe.ui.events.Events {
    private var _menu:Menu;
    public var currentSubMenu:Menu = null;
    public var parentMenu:Menu = null;
    
    public function new(menu:Menu) {
        super(menu);
        _menu = menu;
    }
    
    public override function register() {
        if (!hasEvent(MouseEvent.MOUSE_OVER, onMouseOver)) {
            registerEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        }
        if (!hasEvent(MouseEvent.MOUSE_OUT, onMouseOut)) {
            registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        }
        
        for (child in _menu.childComponents) {
            if (Std.is(child, MenuItem)) {
                var item:MenuItem = cast(child, MenuItem);
                if (!item.hasEvent(MouseEvent.CLICK, onItemClick)) {
                    item.registerEvent(MouseEvent.CLICK, onItemClick);
                }
                if (!item.hasEvent(MouseEvent.MOUSE_OVER, onItemMouseOver)) {
                    item.registerEvent(MouseEvent.MOUSE_OVER, onItemMouseOver);
                }
                if (!item.hasEvent(MouseEvent.MOUSE_OUT, onItemMouseOut)) {
                    item.registerEvent(MouseEvent.MOUSE_OUT, onItemMouseOut);
                }
            }
        }
        
        if (!hasEvent(UIEvent.HIDDEN, onHidden)) {
            registerEvent(UIEvent.HIDDEN, onHidden);
        }
    }
    
    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_OVER, onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);
        for (child in _menu.childComponents) {
            child.unregisterEvent(MouseEvent.CLICK, onItemClick);
            child.unregisterEvent(MouseEvent.MOUSE_OVER, onItemMouseOver);
            child.unregisterEvent(MouseEvent.MOUSE_OUT, onItemMouseOut);
        }
        
        unregisterEvent(UIEvent.HIDDEN, onHidden);
    }    
    
    private var _over:Bool = false;
    private function onMouseOver(event:MouseEvent) {
        _over = true;
    }
    
    private function onMouseOut(event:MouseEvent) {
        _over = false;
    }
    
    private function onItemClick(event:MouseEvent) {
        var item:MenuItem = cast(event.target, MenuItem);
        if (!item.expandable) {
            var event = new MenuEvent(MenuEvent.MENU_SELECTED);
            event.menu = _menu;
            event.menuItem = item;
            findRootMenu().dispatch(event);
            hideCurrentSubMenu();
            findRootMenu().hide();
        }
    }
    
    private function onItemMouseOver(event:MouseEvent) {
        var builder:Builder = cast(_menu._compositeBuilder, Builder);
        var subMenus:Map<MenuItem, Menu> = builder._subMenus;
        var item:MenuItem = cast(event.target, MenuItem);

        for (child in _menu.childComponents) {
            if (child != item) {
                child.removeClass(":hover", true, true);
            }
        }
        
        if (subMenus.get(item) != null) {
            showSubMenu(cast(subMenus.get(item), Menu), item);
        } else {
            hideCurrentSubMenu();
        }
    }
    
    private function onItemMouseOut(event:MouseEvent) {
        if (currentSubMenu != null) {
            event.target.addClass(":hover", true, true);
            return;
        }
    }
    
    private function showSubMenu(subMenu:Menu, source:MenuItem) {
        hideCurrentSubMenu();
        subMenu.menuStyleNames = _menu.menuStyleNames;
        subMenu.addClass(_menu.menuStyleNames);
        var componentOffset = source.getComponentOffset();
        var left = source.screenLeft + source.actualComponentWidth + componentOffset.x;
        var top = source.screenTop;
        Screen.instance.addComponent(subMenu);
        subMenu.syncComponentValidation();

        if (left + subMenu.actualComponentWidth > Screen.instance.width) {
            left = source.screenLeft - subMenu.actualComponentWidth;
        }
        
        subMenu.left = left;
        subMenu.top = top;
        
        currentSubMenu = subMenu;
    }
    
    private function hideCurrentSubMenu() {
        if (currentSubMenu == null) {
            return;
        }
        
        for (child in currentSubMenu.childComponents) {
            child.removeClass(":hover", true, true);
        }
        
        var subMenuEvents:MenuEvents = cast(currentSubMenu._internalEvents, MenuEvents);
        subMenuEvents.hideCurrentSubMenu();
        Screen.instance.removeComponent(currentSubMenu);
        currentSubMenu = null;
    }
    
    private function onHidden(event:UIEvent) {
        for (child in _menu.childComponents) {
            child.removeClass(":hover", true, true);
        }
        hideCurrentSubMenu();
    }
    
    public function findRootMenu():Menu {
        var root:Menu = null;
        var ref = _menu;
        while (ref != null) {
            var events:MenuEvents = cast(ref._internalEvents, MenuEvents);
            if (events.parentMenu == null) {
                root = events._menu;
                break;
            }
            
            ref = events.parentMenu;
        }
        
        return root;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _menu:Menu;
    private var _subMenus:Map<MenuItem, Menu> = new Map<MenuItem, Menu>();
    
    public function new(menu:Menu) {
        super(menu);
        _menu = menu;
    }
    
    public override function addComponent(child:Component):Component {
        if (Std.is(child, Menu)) {
            var menu = cast(child, Menu);
            var item = new MenuItem();
            item.text = child.text;
            item.icon = menu.icon;
            item.expandable = true;
            _menu.addComponent(item);
            cast(menu._internalEvents, MenuEvents).parentMenu = _menu;
            _subMenus.set(item, menu);
            return child;
        }
        
        return null;
    }
    
    public override function onComponentAdded(child:Component) {
        if (Std.is(child, Menu) || Std.is(child, MenuItem)) {
            _menu.registerInternalEvents(true);
        }
    }
    
    public override function findComponent<T:Component>(criteria:String, type:Class<T>, recursive:Null<Bool>, searchType:String):Null<T> {
        var match = super.findComponent(criteria, type, recursive, searchType);
        if (match == null) {
            for (menu in _subMenus) {
                match = menu.findComponent(criteria, type, recursive, searchType);
                if (menu.matchesSearch(criteria, type, searchType)) {
                    return cast menu;
                } else {
                    match = menu.findComponent(criteria, type, recursive, searchType);
                }
                
                if (match != null) {
                    break;
                }
            }
        }
        return cast match;
    }
}
