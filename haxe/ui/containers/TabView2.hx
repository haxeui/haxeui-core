package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.components.TabBar2;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;

@:composite(Builder, Events, Layout)
class TabView2 extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(PageIndex)      public var pageIndex:Int;
    @:behaviour(TabPosition)    public var tabPosition:String;
    @:behaviour(PageCount)      public var pageCount:Int;
    @:call(RemovePage)          public function removePage(index:Int):Void;
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Layout extends DefaultLayout {
    private override function repositionChildren() {
        var tabs:TabBar2 = component.findComponent(TabBar2, false);
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
        var tabs:TabBar2 = component.findComponent(TabBar2, false);
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
        var tabs:TabBar2 = component.findComponent(TabBar2, false);
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
private class PageIndex extends DataBehaviour {
    public override function validateData() {
        if (_component.native == true) {
            return;
        }

        var builder:Builder = cast(_component._compositeBuilder, Builder);
        
        if (_value < 0) {
            _value = 0;
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
private class TabPosition extends DataBehaviour {
    public override function validateData() {
        if (_value == "bottom") {
            _component.addClass(":bottom");
        } else {
            _component.removeClass(":bottom");
        }
        _component.findComponent(TabBar2, false).tabPosition = _value;
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
            var view = builder._views[index];
            builder._views.remove(view);
            builder._content.removeComponent(view);
            builder._tabs.removeTab(index);
        }
        return null;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.components.TabViewBuilder)
private class Events extends haxe.ui.core.Events {
    private var _tabview:TabView2;
    
    public function new(tabview:TabView2) {
        super(tabview);
        _tabview = tabview;
    }
    
    public override function register() {
        var tabs:TabBar2 = _tabview.findComponent(TabBar2, false);
        if (tabs.hasEvent(UIEvent.CHANGE, onTabChanged) == false) {
            tabs.registerEvent(UIEvent.CHANGE, onTabChanged);
        }
    }
    
    public override function unregister() {
        var tabs:TabBar2 = _tabview.findComponent(TabBar2, false);
        tabs.unregisterEvent(UIEvent.CHANGE, onTabChanged);
    }
    
    private function onTabChanged(event:UIEvent) {
        var tabs:TabBar2 = _tabview.findComponent(TabBar2, false);
        _tabview.pageIndex = tabs.selectedIndex;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.components.TabBar2)
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _tabview:TabView2;
    
    private var _tabs:TabBar2;
    private var _content:Box;
    
    private var _currentView:Component = null;
    private var _views:Array<Component> = [];
    
    public function new(tabview:TabView2) {
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
            _tabs = new TabBar2();
            _tabs.id = "tabview-tabs";
            _tabs.addClass("tabview-tabs");
            _tabview.addComponent(_tabs);
        }
    }
    
    private function addTab(child:Component, add:Component->Void):Void {
        var text:String = child.text;
        var icon:String = null;
        if (Std.is(child, Box)) {
            icon = cast(child, Box).icon;
        }
        _views.push(child);
        var button:Button = new Button();
        button.text = text;
        button.icon = icon;
        add(button);
    }
    
    public override function get_numComponents():Int {
        return _views.length;
    }
    
    inline function isInternal(c:Component) {
        return c == _content || c == _tabs;
    }
    
    public override function addComponent(child:Component):Component {
        if (!isInternal(child)) {
            addTab(child, _tabs.addComponent);
            return child;
        }
        return null;
    }
    
    public override function addComponentAt(child:Component, index:Int):Component {
        if (!isInternal(child)) {
            addTab(child, _tabs.addComponentAt.bind(_, index));
            return child;
        }
        return null;
    }
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (!isInternal(child)) {
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
    
    public override function getComponentIndex(child:Component):Int {
        return _views.indexOf(child);
    }
    
    public override function setComponentIndex(child:Component, index:Int):Component {
        if (!isInternal(child)) {
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
}