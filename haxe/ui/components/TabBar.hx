package haxe.ui.components;

import haxe.ui.containers.HBox;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Variant;

@:composite(Builder, Events, Layout)
class TabBar extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(SelectedIndex, -1)      public var selectedIndex:Int;
    @:behaviour(SelectedTab)            public var selectedTab:Component;
    @:behaviour(TabPosition, "top")     public var tabPosition:String;
    @:behaviour(TabCount)               public var tabCount:Int;
    @:call(RemoveTab)                   public function removeTab(index:Int):Void;
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Layout extends DefaultLayout {
    private override function repositionChildren() {
        super.repositionChildren();
        
        var left:Button = _component.findComponent("tabbar-scroll-left", false);
        var right:Button = _component.findComponent("tabbar-scroll-right", false);
        if (left != null && hidden(left) == false) {
            var x = _component.width - left.width;
            if (right != null) {
                x -= right.width;
            }
            left.left = x + 1;
            left.top = (_component.height / 2) - (left.height / 2);
        }
        
        if (right != null && hidden(right) == false) {
            right.left = _component.width - right.width;
            right.top = (_component.height / 2) - (right.height / 2);
        }
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.Builder)
private class SelectedIndex extends DataBehaviour {
    private override function validateData() {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        if (builder._container == null) {
            return;
        }
        if (_value < 0) {
            return;
        }
        if (_value > builder._container.childComponents.length - 1) {
            _value = builder._container.childComponents.length - 1;
            return;
        }

        var tab:Component = cast(builder._container.getComponentAt(_value), Button);
        if (tab != null) {
            var selectedTab:Component = cast(_component, TabBar).selectedTab;
            if (selectedTab != null) {
                selectedTab.removeClass("tabbar-button-selected");
            }
            tab.addClass("tabbar-button-selected");
            
            var rangeMin = Math.abs(builder._container.left);
            var rangeMax = rangeMin + _component.width;

            var left:Button = _component.findComponent("tabbar-scroll-left", Button);
            var right:Button = _component.findComponent("tabbar-scroll-right", Button);
            if (left != null && left.hidden == false) {
                rangeMax -= left.width;
                rangeMax -= _component.layout.horizontalSpacing;
            }
            if (right != null && right.hidden == false) {
                rangeMax -= right.width;
            }
            
            if (tab.left < rangeMin || (tab.left + tab.width) > rangeMax) {
                var max = -(builder._container.width - _component.width);
                var x = -tab.left + _component.layout.paddingLeft;
                if (left != null && left.hidden == false) {
                    max -= left.width;
                    max -= _component.layout.horizontalSpacing;
                }
                if (right != null && right.hidden == false) {
                    max -= right.width;
                }
                
                if (x < max) {
                    x = max;
                }
                
                builder._containerPosition = x;
                builder._container.left = x;
            }
            
            _component.invalidateComponentLayout();
            _component.dispatch(new UIEvent(UIEvent.CHANGE));
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.Builder)
private class SelectedTab extends DataBehaviour {
    public override function get():Variant {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        return Variant.fromComponent(builder._container.findComponent("tabbar-button-selected", false, "css")); // TODO: didnt happen automatically
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.Builder)
private class TabPosition extends DataBehaviour {
    public override function validateData() {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        if (_value == "bottom") {
            _component.addClass(":bottom");
            for (child in builder._container.childComponents) {
                child.addClass(":bottom");
            }
        } else {
            _component.removeClass(":bottom");
            for (child in builder._container.childComponents) {
                child.removeClass(":bottom");
            }
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.Builder)
private class TabCount extends Behaviour {
    public override function get():Variant {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        return builder._container.childComponents.length;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.Builder)
private class RemoveTab extends Behaviour {
    public override function call(param:Any = null):Variant {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        var index:Int = param;
        if (index < builder._container.childComponents.length) {
            builder._container.removeComponentAt(index);
        }
        return null;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.Builder)
private class Events extends haxe.ui.events.Events {
    private var _tabbar:TabBar;
    
    public function new(tabbar:TabBar) {
        super(tabbar);
        _tabbar = tabbar;
    }
    
    public override function register() {
        var builder:Builder = cast(_tabbar._compositeBuilder, Builder);
        for (t in builder._container.childComponents) {
            if (t.hasEvent(MouseEvent.MOUSE_DOWN, onTabMouseDown) == false) {
                t.registerEvent(MouseEvent.MOUSE_DOWN, onTabMouseDown);
            }
        }
        registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }
    
    public override function unregister() {
        unregisterEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }
    
    private function onMouseWheel(event:MouseEvent) {
        var builder:Builder = cast(_tabbar._compositeBuilder, Builder);
        if (event.delta < 0) {
           builder.scrollLeft();
        } else {
           builder.scrollRight();
        }
    }
    
    private function onTabMouseDown(event:MouseEvent) {
        var builder:Builder = cast(_tabbar._compositeBuilder, Builder);
        _tabbar.selectedIndex = builder._container.getComponentIndex(event.target);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.components.TabBar)
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _tabbar:TabBar;
    private var _container:HBox;
    
    public function new(tabbar:TabBar) {
        super(tabbar);
        _tabbar = tabbar;
        createContainer();
    }
    
    public override function create() {
        createContainer();
    }
    
    private function createContainer() {
        if (_container == null) {
            _container = new HBox();
            _container.id = "tabbar-contents";
            _container.addClass("tabbar-contents");
            _tabbar.addComponent(_container);
            _tabbar.addClass(":bottom");
        }
    }
    
    private function addTab(child:Component):Component {
        child.addClass("tabbar-button");
        if (_tabbar.tabPosition == "bottom") {
            child.addClass(":bottom");
        }
        var v = _container.addComponent(child); 
        _tabbar.registerInternalEvents(Events, true);
        if (_tabbar.selectedIndex < 0) {
            _tabbar.selectedIndex = 0;
        }
        return v;
    }
    
    // TODO: DRY with addTab
    private function addTabAt(child:Component, index:Int):Component {
        child.addClass("tabbar-button");
        var v = _container.addComponentAt(child, index); 
        _tabbar.registerInternalEvents(Events, true);
        if (_tabbar.selectedIndex < 0) {
            _tabbar.selectedIndex = 0;
        }
        return v;
    }
    
    public override function get_numComponents():Int {
        return _container.numComponents;
    }
    
    public override function addComponent(child:Component):Component {
        if (child != _container && child != _scrollLeft && child != _scrollRight) {
            return addTab(child);
        }
        return null;
    }
    
    public override function addComponentAt(child:Component, index:Int):Component {
        if (child != _container && child != _scrollLeft && child != _scrollRight) {
            return addTabAt(child, index);
        }
        return null;
    }
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (child != _container && child != _scrollLeft && child != _scrollRight) {
            return _container.removeComponent(child, dispose, invalidate);
        }
        return null;
    }
    
    public override function getComponentIndex(child:Component):Int {
        if (child != _container && child != _scrollLeft && child != _scrollRight) {
            return _container.getComponentIndex(child);
        }
        return -1;
    }
    
    public override function setComponentIndex(child:Component, index:Int):Component {
        if (child != _container && child != _scrollLeft && child != _scrollRight) {
            return _container.setComponentIndex(child, index);
        }
        return null;
    }
    
    public override function getComponentAt(index:Int):Component {
        return _container.getComponentAt(index);
    }
    
    public override function validateComponentLayout():Bool {
        if (_tabbar.native == true || _container == null) {
            return false;
        }
        
        if (_containerPosition == null) {
            _containerPosition = _tabbar.layout.paddingLeft;
        }
        
        if (_container.width > _tabbar.layout.usableWidth && _tabbar.layout.usableWidth > 0) {
            showScrollButtons();
            _container.left = _containerPosition;
        } else {
            hideScrollButtons();
            _containerPosition = null;
        }
        
        return true;
    }
    
    private var _scrollLeft:Button;
    private var _scrollRight:Button;
    private function showScrollButtons() {
        if (_scrollLeft == null) {
            _scrollLeft = new Button();
            _scrollLeft.id = "tabbar-scroll-left";
            _scrollLeft.addClass("tabbar-scroll-left");
            _scrollLeft.includeInLayout = false;
            _scrollLeft.repeater = true;
            _tabbar.addComponent(_scrollLeft);
            _scrollLeft.onClick = function(e) {
                scrollLeft();
            }
        } else {
            _scrollLeft.show();
        }
        
        if (_scrollRight == null) {
            _scrollRight = new Button();
            _scrollRight.id = "tabbar-scroll-right";
            _scrollRight.addClass("tabbar-scroll-right");
            _scrollRight.includeInLayout = false;
            _scrollRight.repeater = true;
            _tabbar.addComponent(_scrollRight);
            _scrollRight.onClick = function(e) {
                scrollRight();
            }
        } else {
            _scrollRight.show();
        }
    }
    
    private var _containerPosition:Null<Float>;
    private static inline var SCROLL_INCREMENT:Int = 20; // todo: calc based on button width?
    private function scrollLeft() {
        if (_scrollLeft == null || _scrollLeft.hidden == true) {
            return;
        }
        
        var x = _container.left + SCROLL_INCREMENT; 
        if (x > _tabbar.layout.paddingLeft) {
            x = _tabbar.layout.paddingLeft;
        }
        _containerPosition = x;
        _container.left = x;
    }
    
    private function scrollRight() {
        if (_scrollLeft == null || _scrollLeft.hidden == true) {
            return;
        }
        
        var x = _container.left - SCROLL_INCREMENT;
        var max = -(_container.width - _tabbar.width);
        
        var left:Button = _tabbar.findComponent("tabbar-scroll-left", Button);
        var right:Button = _tabbar.findComponent("tabbar-scroll-right", Button);
        if (left != null && left.hidden == false) {
            max -= left.width;
            max -= _tabbar.layout.horizontalSpacing;
        }
        if (right != null && right.hidden == false) {
            max -= right.width;
        }
        
        if (x < max) {
            x = max;
        }
        _containerPosition = x;
        _container.left = x;
    }
    
    private function hideScrollButtons() {
        if (_scrollLeft != null) {
            _scrollLeft.hide();
        }
        if (_scrollRight != null) {
            _scrollRight.hide();
        }
    }
}
