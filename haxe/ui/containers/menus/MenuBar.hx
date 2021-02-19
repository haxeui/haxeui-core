package haxe.ui.containers.menus;

import haxe.ui.Toolkit;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.binding.BindingManager;
import haxe.ui.components.Button;
import haxe.ui.containers.HBox;
import haxe.ui.containers.menus.Menu.MenuEvent;
import haxe.ui.containers.menus.Menu.MenuEvents;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.Screen;
import haxe.ui.events.Events;
import haxe.ui.events.MouseEvent;

@:composite(Events, Builder)
class MenuBar extends HBox {
    @:behaviour(DefaultBehaviour)           public var menuStyleNames:String;

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

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.menus.Builder)
private class Events extends haxe.ui.events.Events {
    private var _menubar:MenuBar;
    private var _currentMenu:Menu;
    private var _currentButton:Button;

    public function new(menubar:MenuBar) {
        super(menubar);
        _menubar = menubar;
    }

    public override function register() {
        var builder:Builder = cast(_menubar._compositeBuilder, Builder);
        for (button in builder._buttons) {
            if (!button.hasEvent(MouseEvent.CLICK, onButtonClick)) {
                button.registerEvent(MouseEvent.CLICK, onButtonClick);
            }
            if (!button.hasEvent(MouseEvent.MOUSE_OVER, onButtonOver)) {
                button.registerEvent(MouseEvent.MOUSE_OVER, onButtonOver);
            }
        }
    }

    public override function unregister() {
        var builder:Builder = cast(_menubar._compositeBuilder, Builder);
        for (button in builder._buttons) {
            button.unregisterEvent(MouseEvent.CLICK, onButtonClick);
            button.unregisterEvent(MouseEvent.MOUSE_OVER, onButtonOver);
        }
    }

    private function onCompleteButton(event:MouseEvent) {
        var target:Button = cast(event.target, Button);
        target.unregisterEvent(MouseEvent.MOUSE_OUT, onCompleteButton);
        hideCurrentMenu();
    }
    
    private function onButtonClick(event:MouseEvent) {
        var builder:Builder = cast(_menubar._compositeBuilder, Builder);
        var target:Button = cast(event.target, Button);
        var index = builder._buttons.indexOf(target);
        if (target.toggle == false) {
            var menu = builder._menus[index];
            var newEvent = new MenuEvent(MenuEvent.MENU_SELECTED);
            newEvent.menu = menu;
            _menubar.dispatch(newEvent);
            target.registerEvent(MouseEvent.MOUSE_OUT, onCompleteButton);
            return;
        }
        
        if (target.selected == true) {
            showMenu(index);
        } else if (_currentButton != null) {
            cast(_currentButton._internalEvents, ButtonEvents).lastMouseEvent = event;
            hideCurrentMenu();
        }
    }

    private function onButtonOver(event:MouseEvent) {
        if (_currentMenu == null) {
            return;
        }

        var builder:Builder = cast(_menubar._compositeBuilder, Builder);
        var target:Button = cast(event.target, Button);
        var index = builder._buttons.indexOf(target);
        var menu = builder._menus[index];

        if (menu != _currentMenu) {
            showMenu(index);
        }
    }

    private function showMenu(index:Int) {
        var builder:Builder = cast(_menubar._compositeBuilder, Builder);
        var menu:Menu = builder._menus[index];
        var hasChildren = (menu.childComponents.length > 0);
        
        var target:Button = builder._buttons[index];
        if (_currentMenu == menu) {
            return;
        }

        for (button in builder._buttons) {
            if (button != target) {
                button.selected = false;
            }
        }
        target.selected = true;

        hideCurrentMenu();
        
        for (button in builder._buttons) {
            if (button.hasClass("menubar-button-no-children")) {
                button.swapClass("menubar-button-no-children-active", "menubar-button-no-children");
            }
        }
        
        var rtl = false;
        if (hasChildren == true) {
            var componentOffset = target.getComponentOffset();
            var left = target.screenLeft + componentOffset.x;
            var marginTop:Float = 0;
            if (menu.style != null && menu.style.marginTop != null) {
                marginTop = menu.style.marginTop;
            }
            var top = target.screenTop + (target.actualComponentHeight - Toolkit.scaleY) + componentOffset.y + marginTop;
            menu.menuStyleNames = _menubar.menuStyleNames;
            menu.addClasses([_menubar.menuStyleNames, "expanded"]);
            if (menu.findComponent("menu-filler", false) == null) {
                var filler = new Component();
                filler.horizontalAlign = "right";
                filler.includeInLayout = false;
                filler.addClass("menu-filler");
                filler.id = "menu-filler";
                menu.addComponent(filler);
            }
            menu.show();
            Screen.instance.addComponent(menu);
            menu.syncComponentValidation();

            if (left + menu.actualComponentWidth > Screen.instance.width) {
                left = target.screenLeft - menu.actualComponentWidth + target.actualComponentWidth;
                rtl = true;
            }

            menu.left = left;
            menu.top = top - Toolkit.scaleY;
        }

        _currentButton = target;
        _currentMenu = menu;

        if (hasChildren == true) {
            var cx = menu.width - _currentButton.width;
            var filler:Component = menu.findComponent("menu-filler", false);
            if (cx > 0 && filler != null) {
                cx += 1;
                filler.width = cx;
                if (rtl == false) {
                    filler.left = menu.width - cx;
                }
                filler.hidden = false;
            } else if (filler != null) {
                filler.hidden = true;
            }

            Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
            if (!_currentMenu.hasEvent(MenuEvent.MENU_SELECTED, onMenuSelected)) {
                _currentMenu.registerEvent(MenuEvent.MENU_SELECTED, onMenuSelected);
            }
        }
    }

    private function hideCurrentMenu() {
        if (_currentMenu != null) {
            var builder:Builder = cast(_menubar._compositeBuilder, Builder);
            for (button in builder._buttons) {
                if (button.hasClass("menubar-button-no-children-active")) {
                    button.swapClass("menubar-button-no-children", "menubar-button-no-children-active");
                }
            }
            
            _currentMenu.unregisterEvent(MenuEvent.MENU_SELECTED, onMenuSelected);
            _currentMenu.hide();
            _currentButton.selected = false;
            Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
            Screen.instance.removeComponent(_currentMenu);
            _currentButton = null;
            _currentMenu = null;
        }
    }

    private function onScreenMouseDown(event:MouseEvent) {
        var close:Bool = true;

        if (_currentMenu.hitTest(event.screenX, event.screenY)) {
            close = false;
        } else if (_currentButton.hitTest(event.screenX, event.screenY)) {
            close = false;
        } else {
            var ref = _currentMenu;
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
            hideCurrentMenu();
        }
    }

    private function onMenuSelected(event:MenuEvent) {
        var newEvent = new MenuEvent(MenuEvent.MENU_SELECTED);
        newEvent.menu = event.menu;
        newEvent.menuItem = event.menuItem;
        _menubar.dispatch(newEvent);
        hideCurrentMenu();
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _menubar:MenuBar;

    private var _buttons:Array<Button> = [];
    private var _menus:Array<Menu> = [];

    public function new(menubar:MenuBar) {
        super(menubar);
        _menubar = menubar;
    }

    @:access(haxe.ui.core.Screen)
    public function onThemeChanged() {
        for (menu in _menus) {
            Screen.instance.invalidateChildren(menu);
            Screen.instance.onThemeChangedChildren(menu);
        }
    }

    public override function create() {
    }

    public override function destroy() {
    }

    public override function addComponent(child:Component):Component {
        if ((child is Menu)) {
            var menu = cast(child, Menu);
            var button = new Button();
            var hasChildren = (menu.childComponents.length > 0);
            if (hasChildren == true) {
                button.styleNames = "menubar-button";
            } else {
                button.styleNames = "menubar-button-no-children";
            }
            button.text = menu.text;
            button.icon = menu.icon;
            button.tooltip = menu.tooltip;
            button.toggle = hasChildren;
            BindingManager.instance.cloneBinding(child, button);
            _buttons.push(button);
            _menubar.addComponent(button);
            _menubar.registerInternalEvents(true);

            _menus.push(menu);

            return menu;
        }
        return null;
    }

    public override function addComponentAt(child:Component, index:Int):Component {
        return null;
    }

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        return null;
    }

    public override function getComponentIndex(child:Component):Int {
        return -1;
    }

    public override function setComponentIndex(child:Component, index:Int):Component {
        return null;
    }

    public override function getComponentAt(index:Int):Component {
        return null;
    }

    public override function findComponent<T:Component>(criteria:String, type:Class<T>, recursive:Null<Bool>, searchType:String):Null<T> {
        var match = super.findComponent(criteria, type, recursive, searchType);
        if (match == null) {
            for (menu in _menus) {
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
