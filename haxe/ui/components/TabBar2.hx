package haxe.ui.components;

import haxe.ui.containers.HBox;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Variant;

class TabBar2 extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(SelectedIndex, -1)      public var selectedIndex:Int;
    @:behaviour(SelectedTab)            public var selectedTab:Component;
    @:behaviour(TabPosition)            public var tabPosition:String;
    @:behaviour(TabCount)               public var tabCount:Int;
    @:call(RemoveTab)                   public function removeTab(index:Int):Void;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {  // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayoutClass = TabBarLayout;
    }
    
    private override function createChildren() {
        super.createChildren();
        registerInternalEvents(Events);
    }
    
    private override function registerComposite() { // TODO: remove this eventually, @:composite(...) or something
       super.registerComposite();
       _compositeBuilderClass = TabBarBuilder;
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TabBarLayout extends DefaultLayout {
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
@:access(haxe.ui.components.TabBarBuilder)
private class SelectedIndex extends DataBehaviour {
    private override function validateData() {
        var builder:TabBarBuilder = cast(_component._compositeBuilder, TabBarBuilder);
        if (builder._container == null) {
            return;
        }
        if (_value < 0 || _value > builder._container.childComponents.length - 1) {
            return;
        }

        var tab:Component = cast(builder._container.getComponentAt(_value), Button);
        if (tab != null) {
            var selectedTab:Component = cast(_component, TabBar2).selectedTab;
            if (selectedTab != null) {
                selectedTab.removeClass("tabbar-button-selected");
            }
            tab.addClass("tabbar-button-selected");
            _component.dispatch(new UIEvent(UIEvent.CHANGE));
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.TabBarBuilder)
private class SelectedTab extends DataBehaviour {
    public override function get():Variant {
        var builder:TabBarBuilder = cast(_component._compositeBuilder, TabBarBuilder);
        return Variant.fromComponent(builder._container.findComponent("tabbar-button-selected", false, "css")); // TODO: didnt happen automatically
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.TabBarBuilder)
private class TabPosition extends DataBehaviour {
    public override function validateData() {
        var builder:TabBarBuilder = cast(_component._compositeBuilder, TabBarBuilder);
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
@:access(haxe.ui.components.TabBarBuilder)
private class TabCount extends Behaviour {
    public override function get():Variant {
        var builder:TabBarBuilder = cast(_component._compositeBuilder, TabBarBuilder);
        return builder._container.childComponents.length;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.TabBarBuilder)
private class RemoveTab extends Behaviour {
    public override function call(param:Any = null):Variant {
        var builder:TabBarBuilder = cast(_component._compositeBuilder, TabBarBuilder);
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
@:access(haxe.ui.components.TabBarBuilder)
private class Events extends haxe.ui.core.Events {
    private var _tabbar:TabBar2;
    
    public function new(tabbar:TabBar2) {
        super(tabbar);
        _tabbar = tabbar;
    }
    
    public override function register() {
        var builder:TabBarBuilder = cast(_tabbar._compositeBuilder, TabBarBuilder);
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
        var builder:TabBarBuilder = cast(_tabbar._compositeBuilder, TabBarBuilder);
        if (event.delta < 0) {
           builder.scrollLeft();
        } else {
           builder.scrollRight();
        }
    }
    
    private function onTabMouseDown(event:MouseEvent) {
        var builder:TabBarBuilder = cast(_tabbar._compositeBuilder, TabBarBuilder);
        _tabbar.selectedIndex = builder._container.getComponentIndex(event.target);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.components.TabBar2)
@:access(haxe.ui.core.Component)
private class TabBarBuilder extends CompositeBuilder {
    private var _tabbar:TabBar2;
    private var _container:HBox;
    
    public function new(tabbar:TabBar2) {
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
        }
    }
    
    private function addTab(child:Component):Component {
        child.addClass("tabbar-button");
        var v = _container.addComponent(child); 
        _tabbar.registerInternalEvents(Events, true);
        if (_tabbar.selectedIndex < 0) {
            _tabbar.selectedIndex = 0;
        }
        return v;
    }
    
    public override function addComponent(child:Component):Component {
        if (Std.is(child, _container) == false && child != _scrollLeft && child != _scrollRight) {
            return addTab(child);
        }
        return null;
    }
    
    public override function addComponentAt(child:Component, index:Int):Component {
        if (Std.is(child, _container) == false && child != _scrollLeft && child != _scrollRight) {
            return addTab(child);
        }
        return null;
    }
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (Std.is(child, _container) == false) {
            return _container.removeComponent(child, dispose, invalidate);
        }
        return null;
    }
    
    public override function setComponentIndex(child:Component, index:Int):Component {
        if (Std.is(child, _container) == false) {
            return _container.setComponentIndex(child, index);
        }
        return null;
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
