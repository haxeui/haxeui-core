package haxe.ui.containers.menus;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.Screen;
import haxe.ui.events.MenuEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Size;
import haxe.ui.layouts.VerticalLayout;
import haxe.ui.util.Timer;
import haxe.ui.util.Variant;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

@:composite(MenuEvents, Builder, Layout)
class Menu extends Box {
    @:behaviour(DefaultBehaviour)            public var menuStyleNames:String;
    @:behaviour(CurrentIndexBehaviour, 0)    public var currentIndex:Int;
    @:behaviour(CurrentItemBehaviour)        public var currentItem:MenuItem;

    public var menuBar:MenuBar = null;

    /**
     Utility property to add a single `MenuEvent.MENU_SELECTED` event
    **/
    @:event(MenuEvent.MENU_SELECTED)        public var onMenuSelected:MenuEvent->Void;
    
    private override function onThemeChanged() {
        super.onThemeChanged();
        var builder:Builder = cast(this._compositeBuilder, Builder);
        builder.onThemeChanged();
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class CurrentIndexBehaviour extends DataBehaviour {

    public override function set(value:Variant) {
        var _menu:Menu = cast _component;
        var itemsNbr = _menu.findComponents(MenuItem, 1).length;
        if (value >= itemsNbr) {
            value = 0;
        }
        super.set(value); 
    }

    private override function validateData() {
        var _menu:Menu = cast _component;
        var items = _menu.findComponents(MenuItem, 1);
        var itemNbr:Int = _value;
        _menu.currentItem = items[itemNbr]; 
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class CurrentItemBehaviour extends DataBehaviour {

    private override function validateData() {
        var _menu:Menu = cast _component;
        var menuItemC:Component = _value;
        var menuItem:MenuItem = cast menuItemC;
        var index = _menu.findComponents(MenuItem, 1).indexOf(menuItem);
        _menu.currentIndex = index;

        for (child in _menu.childComponents) {
            child.removeClass(":hover", true, true);
        }

        var item:Component = _value;
        if (item != null) item.addClass(":hover", true, true);
    }
}


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

    private static inline var TIME_MOUSE_OPENS_MS:Int =400;
    private var _timer:Timer = null;

    public var button:Button = null;
    
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
            if ((child is MenuItem)) {
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
        if (!hasEvent(UIEvent.SHOWN, onShown)) {
            registerEvent(UIEvent.SHOWN, onShown);
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
        unregisterEvent(UIEvent.SHOWN, onShown);
    }

    public override function onDispose() {
        removeScreenMouseDown();
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

            if (_menu.menuBar == null) {
                var beforeCloseEvent = new UIEvent(UIEvent.BEFORE_CLOSE);
                beforeCloseEvent.relatedComponent = item;
                findRootMenu().dispatch(beforeCloseEvent);
                if (beforeCloseEvent.canceled) {
                    return;
                }

                hideMenu();
                removeScreenMouseDown();
            }
            _menu.dispatch(new UIEvent(UIEvent.CLOSE));
        }
    }

    public var lastEventSubMenu:MouseEvent = null;

    private function onItemMouseOver(event:MouseEvent) {
        var builder:Builder = cast(_menu._compositeBuilder, Builder);
        var subMenus:Map<MenuItem, Menu> = builder._subMenus;
        var item:MenuItem = cast(event.target, MenuItem);

        for (child in _menu.childComponents) {
            if (child != item) {
                child.removeClass(":hover", true, true);
            }
        }

        if (parentMenu != null) {
            // so that's is always the parent menu that is visually selected
            // even if you have previously hovered over parent's siblings.
            var menuItem:MenuItem = null;
            for (mi => menu in cast(parentMenu._compositeBuilder, Builder)._subMenus) {
                if (_menu == menu) menuItem = mi;
            }
            parentMenu.currentItem = menuItem;
        }

        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        if (subMenus.get(item) != null) {
            _menu.currentItem = item;
            lastEventSubMenu = event;
            _timer = new Timer(TIME_MOUSE_OPENS_MS, function f() { 
                showSubMenu(cast(subMenus.get(item), Menu), item);
                _timer.stop();
                _timer = null;
            });
        } else {
            if (currentSubMenu != null) {
                if (!isMouseAimingForSubMenu(event)) {
                    hideCurrentSubMenu();
                    lastEventSubMenu = null;
                } else {
                    _timer = new Timer(TIME_MOUSE_OPENS_MS, function f() { 
                        hideCurrentSubMenu();
                        _timer.stop();
                        _timer = null;
                    });
                }
                lastEventSubMenu = event;
            }
        }
    }

    private function isMouseAimingForSubMenu(event:MouseEvent) {
        // We check if the mouse is moving towards the submenu
        // by looking if it's inside the triangle formed by his last position
        // and the top and bottom of the submenu
        if (lastEventSubMenu == null) return true;
        var vX = lastEventSubMenu.screenX;
        var vY = lastEventSubMenu.screenY;
        var v2X = currentSubMenu.screenLeft;
        var v2Y = currentSubMenu.screenTop;
        var v3X = v2X;
        var v3Y = currentSubMenu.screenTop + currentSubMenu.height;

        // https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle
        inline function sign (px:Float, py:Float, p2x:Float, p2y:Float, p3x:Float, p3y:Float)
        {
            return (px - p3x) * (p2y - p3y) - (p2x - p3x) * (py - p3y);
        }

        var d1 = sign(event.screenX, event.screenY,  vX, vY, v2X, v2Y);
        var d2 = sign(event.screenX, event.screenY,  v2X, v2Y, v3X, v3Y);
        var d3 = sign(event.screenX, event.screenY,  v3X, v3Y, vX, vY);

        var hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
        var hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
        return !(hasNeg && hasPos);
    }

    private function onItemMouseOut(event:MouseEvent) {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        if (currentSubMenu != null) {
            _menu.currentItem.addClass(":hover", true, true);
            return;
        } else {
            _menu.currentItem = null;
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
        subMenu.validateNow();

        if (left + subMenu.actualComponentWidth > Screen.instance.width) {
            left = source.screenLeft - subMenu.actualComponentWidth;
        }

        var offsetX:Float = 0;
        var offsetY:Float = 0;
        if (subMenu.style != null) {
            if (subMenu.style.paddingLeft > 1) {
                //offsetX = subMenu.style.paddingLeft - 1;
                offsetX = subMenu.style.paddingLeft / 2;
            } else {
                offsetX = 0;
            }
            if (subMenu.style.paddingTop > 1) {
                offsetY = subMenu.style.paddingTop - 1;
            } else {
                offsetY = 1;
            }
        }
        subMenu.left = left + offsetX;
        subMenu.top = top - offsetY;

        currentSubMenu = subMenu;
    }

    private function hideMenu() {
        var root = findRootMenu();
        if (root == null) {
            return;
        }
        
        var events:MenuEvents = cast(root._internalEvents, MenuEvents);
        
        if (events.button == null) {
            for (child in root.childComponents) {
                child.removeClass(":hover", true, true);
            }
            
            events.hideCurrentSubMenu();
            Screen.instance.removeComponent(root, false);
        }
    }
    
    private function hideCurrentSubMenu() {
        if (currentSubMenu == null) {
            return;
        }

        if (currentSubMenu._isDisposed) { // sub menu could have already been disposed of
            return;
        }

        for (child in currentSubMenu.childComponents) {
            child.removeClass(":hover", true, true);
        }

        var subMenuEvents:MenuEvents = cast(currentSubMenu._internalEvents, MenuEvents);
        subMenuEvents.hideCurrentSubMenu();
        Screen.instance.removeComponent(currentSubMenu, false);
        currentSubMenu = null;
    }

    private function onHidden(event:UIEvent) {
        for (child in _menu.childComponents) {
            child.removeClass(":hover", true, true);
        }
        hideCurrentSubMenu();
    }

    private function onShown(event:UIEvent) {
        addScreenMouseDown();
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

    public var hasScreenMouseDown:Bool = false;
    private function addScreenMouseDown() {
        var root = findRootMenu();
        var events:MenuEvents = cast(root._internalEvents, MenuEvents);
        if (events.hasScreenMouseDown == false) {
            events.hasScreenMouseDown = true;
            Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
            Screen.instance.registerEvent(MouseEvent.RIGHT_MOUSE_DOWN, onScreenMouseDown);
        }
    }
    
    private function removeScreenMouseDown() {
        var root = findRootMenu();
        var events:MenuEvents = cast(root._internalEvents, MenuEvents);
        events.hasScreenMouseDown = false;
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        Screen.instance.unregisterEvent(MouseEvent.RIGHT_MOUSE_DOWN, onScreenMouseDown);
    }
    
    private function onScreenMouseDown(event:MouseEvent) {
        var close:Bool = true;
        if (_menu.hitTest(event.screenX, event.screenY)) {
            close = false;
        } else if (button != null && button.hitTest(event.screenX, event.screenY)) {
            close = false;
        } else {
            var ref = _menu;
            var refEvents:MenuEvents = cast(ref._internalEvents, MenuEvents);
            var refSubMenu = refEvents.currentSubMenu;
            while (refSubMenu != null) {
                if (refSubMenu.hitTest(event.screenX, event.screenY)) {
                    close = false;
                    break;
                }

                ref = refSubMenu;
                refEvents = cast(ref._internalEvents, MenuEvents);
                refSubMenu = refEvents.currentSubMenu;
            }
        }
        
        if (close) {
            hideMenu();
            removeScreenMouseDown();
            _menu.dispatch(new UIEvent(UIEvent.CLOSE));
        }
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

    @:access(haxe.ui.core.Screen)
    public function onThemeChanged() {
        for (menuItem in _subMenus.keys()) {
            var menu = _subMenus.get(menuItem);
            Screen.instance.invalidateChildren(menu);
            Screen.instance.onThemeChangedChildren(menu);
        }
    }

    public override function addComponent(child:Component):Component {
        if ((child is Menu)) {
            var menu = cast(child, Menu);
            var item = new MenuItem();
            item.id = child.id + "Item";
            item.text = child.text;
            item.icon = menu.icon;
            item.tooltip = child.tooltip;
            item.expandable = true;
            _menu.addComponent(item);
            cast(menu._internalEvents, MenuEvents).parentMenu = _menu;
            menu.registerEvent(UIEvent.PROPERTY_CHANGE, onMenuPropertyChanged);
            _subMenus.set(item, menu);
            return child;
        }

        return null;
    }

    private function onMenuPropertyChanged(event:UIEvent) {
        if (event.data == "text") {
            var menu:Menu = cast(event.target, Menu);
            for (item in _subMenus.keys()) {
                var subMenu = _subMenus.get(item);
                if (subMenu == menu) {
                    item.text = event.target.text;
                    break;
                }
            }
        }
    }
    
    public override function onComponentAdded(child:Component) {
        if ((child is Menu) || (child is MenuItem)) {
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
    
    public override function findComponents<T:Component>(styleName:String = null, type:Class<T> = null, maxDepth:Int = 5):Array<T> {
        var r:Array<T> = [];
        for (menu in _subMenus) {
            var match = true;
            if (styleName != null && menu.hasClass(styleName) == false) {
                match = false;
            }
            if (type != null && isOfType(menu, type) == false) {
                match = false;
            }
            
            if (match == true) {
                r.push(cast menu);
            } else {
                var childArray = menu.findComponents(styleName, type, maxDepth);
                for (c in childArray) { // r.concat caused issues here on hxcpp
                    r.push(c);
                }
            }
        }
        return r;
    }
    
    public override function destroy() {
        super.destroy();
        if (_menu != null && _menu._isDisposed == false) {
            Screen.instance.removeComponent(_menu);
        }
        for (subMenu in _subMenus) {
            Screen.instance.removeComponent(subMenu);
        }
    }

    public override function hide() {
        Screen.instance.removeComponent(_menu, false);
        return true;
    }

    public override function show() {
        Screen.instance.addComponent(_menu);
        return true;
    }
}

private class Layout extends VerticalLayout {
    private override function resizeChildren() {
        if (!_component.autoWidth) {
            for (child in component.childComponents) {
                if (child.includeInLayout == false) {
                    continue;
                }

                if (child.percentWidth == null) {
                    child.percentWidth = 100;
                }
            }
            super.resizeChildren();
        } else {
            var usableSize:Size = usableSize;
            var biggest:Float = 0;

            for (child in component.childComponents) {
                if (child.includeInLayout == false) {
                    continue;
                }

                if (child.width <= 0) {
                    child.validateNow();    
                }

                if (child.width > biggest) {
                    biggest = child.width;
                }
            }

            for (child in component.childComponents) {
                if (child.includeInLayout == false) {
                    continue;
                }

                var cx:Null<Float> = null;
                cx = 100;

                child.width = biggest;
            }    
        }
    }
}