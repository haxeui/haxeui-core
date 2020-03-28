package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.components.TabBar;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.geom.Size;
import haxe.ui.util.Variant;

@:composite(Builder, Events, Layout)
class TabView extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(PageIndex, -1)      public var pageIndex:Int;
    @:behaviour(SelectedPage, null) public var selectedPage:Component;
    @:behaviour(TabPosition)        public var tabPosition:String;
    @:behaviour(PageCount)          public var pageCount:Int;
    @:behaviour(Closable, false)    public var closable:Bool;
    @:call(RemovePage)              public function removePage(index:Int):Void;
    @:call(RemoveAllPages)          public function removeAllPages():Void;
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Layout extends DefaultLayout {
    private override function repositionChildren() {
        var tabs:TabBar = component.findComponent(TabBar, false);
        var content:Box = component.findComponent(Box, false);
        if (tabs == null || content == null) {
            return;
        }

        if (component.hasClass(":bottom")) {
            content.left = paddingLeft;
            content.top = paddingTop;
            
            tabs.left = paddingLeft;
            if (tabs.height != 0) {
                tabs.top = component.height - tabs.height - paddingBottom;
            }
        } else {
            tabs.left = paddingLeft;
            tabs.top = paddingTop;

            content.left = paddingLeft;
            if (tabs.height != 0) {
                content.top = tabs.top + tabs.height - 1;
            }
        }
    }

    private override function resizeChildren() {
        var tabs:TabBar = component.findComponent(TabBar, false);
        var content:Box = component.findComponent(Box, false);
        if (tabs == null || content == null) {
            return;
        }

        var usableSize = usableSize;
        tabs.width = usableSize.width;
        
        if (component.autoHeight == false) {
            content.height = usableSize.height + 1;
        }

        if (component.autoWidth == false) {
            content.width = component.width;
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var tabs:TabBar = component.findComponent(TabBar, false);
        if (tabs != null && tabs.componentHeight != null) {
            size.height -= tabs.componentHeight;
        }
        return size;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class Closable extends DataBehaviour {
    public override function validateData() {
        if (_component.native == true) {
            return;
        }

        var builder:Builder = cast(_component._compositeBuilder, Builder);
        builder._tabs.closable = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class PageIndex extends DataBehaviour {
    public override function validateData() {
        if (_component.native == true) {
            return;
        }

        var builder:Builder = cast(_component._compositeBuilder, Builder);
        
        if (_value < 0) {
            return;
        }
        if (_value > builder._views.length - 1) {
            _value = builder._views.length - 1;
            return;
        }
        
        builder._tabs.selectedIndex = _value;
        var view:Component = builder._views[_value.toInt()];
        if (view != null) {
            if (builder._currentView != null) {
                //_content.removeComponent(_currentView, false);
                builder._currentView.hide();
            }
            if (builder._content.getComponentIndex(view) == -1) {
                builder._content.addComponent(view);
            } else {
                view.show();
            }

            builder._currentView = view;
        }

        _component.dispatch(new UIEvent(UIEvent.CHANGE));
        
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class SelectedPage extends DefaultBehaviour {
    public override function get():Variant {
        var tabview:TabView = cast(_component, TabView);
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        var view:Component = builder._views[tabview.pageIndex];
        return view;
    }
    
    public override function set(value:Variant) {
        var tabview:TabView = cast(_component, TabView);
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        var view:Component = value;
        var viewIndex = builder._views.indexOf(view);
        if (viewIndex != -1) {
            tabview.pageIndex = viewIndex;
        }
    }
}

@:dox(hide) @:noCompletion
private class TabPosition extends DataBehaviour {
    public override function validateData() {
        if (_value == "bottom") {
            _component.addClass(":bottom");
        } else {
            _component.removeClass(":bottom");
        }
        _component.findComponent(TabBar, false).tabPosition = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class PageCount extends Behaviour {
    public override function get():Variant {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        return builder._tabs.tabCount;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class RemovePage extends Behaviour {
    public override function call(param:Any = null):Variant {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        var index:Int = param;
        if (index < builder._views.length) {
            builder._tabs.removeTab(index);
        }
        return null;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class RemoveAllPages extends Behaviour {
    public override function call(param:Any = null):Variant {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        while (builder._views.length > 0) {
            builder._tabs.removeTab(0);
        }
        cast(_component, TabView).pageIndex = -1;
        builder._tabs.selectedIndex = -1;
        return null;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.TabViewBuilder)
@:access(haxe.ui.containers.Builder)
private class Events extends haxe.ui.events.Events {
    private var _tabview:TabView;
    
    public function new(tabview:TabView) {
        super(tabview);
        _tabview = tabview;
    }
    
    public override function register() {
        var tabs:TabBar = _tabview.findComponent(TabBar, false);
        if (tabs.hasEvent(UIEvent.CHANGE, onTabChanged) == false) {
            tabs.registerEvent(UIEvent.CHANGE, onTabChanged);
        }
        if (tabs.hasEvent(UIEvent.BEFORE_CLOSE, onBeforeTabClosed) == false) {
            tabs.registerEvent(UIEvent.BEFORE_CLOSE, onBeforeTabClosed);
        }
        if (tabs.hasEvent(UIEvent.CLOSE, onTabClosed) == false) {
            tabs.registerEvent(UIEvent.CLOSE, onTabClosed);
        }
    }
    
    public override function unregister() {
        var tabs:TabBar = _tabview.findComponent(TabBar, false);
        tabs.unregisterEvent(UIEvent.CHANGE, onTabChanged);
        tabs.unregisterEvent(UIEvent.BEFORE_CLOSE, onBeforeTabClosed);
    }
    
    private function onBeforeTabClosed(event:UIEvent) {
        _tabview.dispatch(event);
    }
    
    private function onTabClosed(event:UIEvent) {
        var builder:Builder = cast(_tabview._compositeBuilder, Builder);
        var view = builder._views[event.data];
        builder._views.remove(view);
        builder._content.removeComponent(view);
        
        _tabview.dispatch(new UIEvent(UIEvent.CLOSE, event.data));
    }
    
    private function onTabChanged(event:UIEvent) {
        var tabs:TabBar = _tabview.findComponent(TabBar, false);
        _tabview.pageIndex = -1;
        _tabview.pageIndex = tabs.selectedIndex;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.components.TabBar)
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _tabview:TabView;
    
    private var _tabs:TabBar;
    private var _content:Box;
    
    private var _currentView:Component = null;
    private var _views:Array<Component> = [];
    
    public function new(tabview:TabView) {
        super(tabview);
        _tabview = tabview;
    }
    
    public override function create() {
        if (_content == null) {
            _content = new Box();
            _content.id = "tabview-content";
            _content.addClass("tabview-content");
            _content.layout = LayoutFactory.createFromName("vertical");
            _tabview.addComponent(_content);
        }
        
        if (_tabs == null) {
            _tabs = new TabBar();
            _tabs.id = "tabview-tabs";
            _tabs.addClass("tabview-tabs");
            _tabview.addComponent(_tabs);
        }
    }
    
    public override function get_numComponents():Null<Int> {
        return _views.length;
    }
    
    public override function addComponent(child:Component):Component {
        if (child != _content && child != _tabs) {
            var text:String = child.text;
            var icon:String = null;
            if (Std.is(child, Box)) {
                icon = cast(child, Box).icon;
            }
            _views.push(child);
            var button:Button = new Button();
            button.text = text;
            button.icon = icon;
            _tabs.addComponent(button);
            
            return child;
        }
        return null;
    }
    
    public override function addComponentAt(child:Component, index:Int):Component {
        if (child != _content && child != _tabs) {
            var text:String = child.text;
            var icon:String = null;
            if (Std.is(child, Box)) {
                icon = cast(child, Box).icon;
            }
            _views.insert(index, child);
            var button:Button = new Button();
            button.text = text;
            button.icon = icon;
            _tabs.addComponentAt(button, index);
            return child;
        }
        return null;
    }
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (child != _content && child != _tabs) {
            switch _views.indexOf(child) {
                case -1:
                case i:
                    _views.splice(i, 1);
                    _tabs.removeComponentAt(i, dispose, invalidate);
                    return child;
            }
        }
        return null;
    }
    
    public override function removeComponentAt(index:Int, dispose:Bool = true, invalidate:Bool = true):Component {
        _views.splice(index, 1);
        return _tabs.removeComponentAt(index, dispose, invalidate);
    }
    
    public override function getComponentIndex(child:Component):Int {
        return _views.indexOf(child);
    }
    
    public override function setComponentIndex(child:Component, index:Int):Component {
        if (child != _content && child != _tabs) {
            switch _views.indexOf(child) {
                case -1:
                case i:
                    _views.splice(i, 1);
                    _views.insert(index, child);
                    _tabs.setComponentIndex(_tabs.getComponentAt(i), index);
                    return child;
            }
        }
        return null;
    }
    
    public override function getComponentAt(index:Int):Component {
        return _views[index];
    }
    
    
    public override function findComponent<T:Component>(criteria:String, type:Class<T>, recursive:Null<Bool>, searchType:String):Null<T> {
        var match = super.findComponent(criteria, type, recursive, searchType);
        if (match == null) {
            for (view in _views) {
                match = view.findComponent(criteria, type, recursive, searchType);
                if (view.matchesSearch(criteria, type, searchType)) {
                    return cast view;
			 } else {
                    match = view.findComponent(criteria, type, recursive, searchType);
                }
                if (match != null) {
                    break;
                }
            }
        }
        return cast match;
    }
}