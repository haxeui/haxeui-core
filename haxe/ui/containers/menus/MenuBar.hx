package haxe.ui.containers.menus;

import haxe.ui.components.Button;
import haxe.ui.containers.HBox;
import haxe.ui.containers.menus.Menu.MenuEvent;
import haxe.ui.containers.menus.Menu.MenuEvents;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.events.Events;

@:composite(Events, Builder)
class MenuBar extends HBox {
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
    
    private function onButtonClick(event:MouseEvent) {
        var builder:Builder = cast(_menubar._compositeBuilder, Builder);
        var target:Button = cast(event.target, Button);
        var index = builder._buttons.indexOf(target);
        if (target.selected == true) {
            showMenu(index);
        } else {
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
        var target:Button = builder._buttons[index];
        var menu:Menu  = builder._menus[index];
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
        var left = target.screenLeft;
        var top =  target.screenTop + target.height;
        menu.show();
        Screen.instance.addComponent(menu);
        menu.syncComponentValidation();
        
        if (left + menu.width > Screen.instance.width) {
            left = target.screenLeft - menu.width + target.width;
        }
        
        menu.left = left;
        menu.top = top - 1;
        
        _currentButton = target;
        _currentMenu = menu;
        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        if (!_currentMenu.hasEvent(MenuEvent.MENU_SELECTED, onMenuSelected)) {
            _currentMenu.registerEvent(MenuEvent.MENU_SELECTED, onMenuSelected);
        }
    }
    
    private function hideCurrentMenu() {
        if (_currentMenu != null) {
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
    
    public override function create() {
    }
    
    public override function destroy() {
    }
    
    public override function addComponent(child:Component):Component {
        if (Std.is(child, Menu)) {
            var menu = cast(child, Menu);
            var button = new Button();
            button.styleNames = "menubar-button";
            button.text = menu.text;
            button.icon = menu.icon;
            button.toggle = true;
            _buttons.push(button);
            _menubar.addComponent(button);
            _menubar.registerInternalEvents(true);
            
            _menus.push(cast(child, Menu));
            
            return child;
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
}
