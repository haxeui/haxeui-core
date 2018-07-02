package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.components.TabBar2;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.util.Size;

class TabView2 extends Component {
    //***********************************************************************************************************
    // Styles
    //***********************************************************************************************************
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(PageIndexBehaviour)         public var pageIndex:Int;
    @:behaviour(TabPositionBehaviour)       public var tabPosition:String;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {  // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayout = new TabViewLayout();
    }
    
    private override function createChildren() {
        super.createChildren();
        registerInternalEvents(Events);
    }
    
    private override function registerComposite() { // TODO: remove this eventually, @:composite(...) or something
       super.registerComposite();
       _compositeBuilderClass = TabViewBuilder;
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class TabViewLayout extends DefaultLayout {
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
            if (tabs.height != null) {
                tabs.top = component.height - tabs.height - paddingBottom;
            }
        } else {
            tabs.left = paddingLeft;
            tabs.top = paddingTop;

            content.left = paddingLeft;
            if (tabs.height != null) {
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
@:access(haxe.ui.containers.TabViewBuilder)
private class PageIndexBehaviour extends DataBehaviour {
    public override function validateData() {
        if (_component.native == true) {
            return;
        }
        
        var builder:TabViewBuilder = cast(_component._compositeBuilder, TabViewBuilder);
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
private class TabPositionBehaviour extends DataBehaviour {
    public override function validateData() {
        if (_value == "bottom") {
            _component.addClass(":bottom");
        } else {
            _component.removeClass(":bottom");
        }
        _component.findComponent(TabBar2, false).tabPosition = _value;
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
private class TabViewBuilder extends CompositeBuilder {
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
            _views.remove(child);
            /*
            var button:Button = new Button();
            button.text = text;
            button.icon = icon;
            _tabs.removeComponent(button, dispose, invalidate);
            */
            return child;
        }
        return null;
    }
}