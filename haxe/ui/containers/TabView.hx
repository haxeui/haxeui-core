package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.components.TabBar;
import haxe.ui.core.Component;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Size;
import haxe.ui.core.Behaviour;
import haxe.ui.util.Variant;

@:dox(icon = "/icons/ui-tab-content.png")
class TabView extends Component {
    private var _tabs:TabBar;
    private var _content:VBox;
    private var _views:Array<Component>;

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "removeAllPages" => new RemoveAllPages(this),
            "removePage" => new RemovePage(this),
            "pageCount" => new PageCount(this)
        ]);
        _defaultLayout = new TabViewLayout();
    }

    private override function createChildren() {
        super.createChildren();

        if (_views == null) {
            _views = [];
        }

        if (_content == null) {
            _content = new VBox();
            _content.id = "tabview-content";
            _content.addClass("tabview-content");
            addComponent(_content);
        }

        if (_tabs == null) {
            _tabs = new TabBar();
            _tabs.id = "tabview-tabs";
            _tabs.addClass("tabview-tabs");
            _tabs.registerEvent(UIEvent.BEFORE_CHANGE, _onBeforeTabsChange);
            _tabs.registerEvent(UIEvent.CHANGE, _onTabsChange);
            addComponent(_tabs);
        }
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    public override function addComponent(child:Component):Component {
        var v = null;
        if (child == _tabs) {
            v = super.addComponent(child);
        } else if (child == _content) {
            v = super.addComponent(child);
        } else {
            if (_views != null && _tabs != null) {
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
                invalidateComponentData();

                if (_pageIndex == -1) {
                    pageIndex = 0;
                }
            } else {
                super.addComponent(child);
            }
        }

        return v;
    }

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        var v = null;
        if (child == _tabs) {
            v = super.removeComponent(child, dispose);
        } else if (child == _content) {
            v = super.removeComponent(child, dispose);
        } else if (_views != null) {
            var index = _views.indexOf(child);
            _views.remove(child);
            _content.removeComponent(child);
            _tabs.removeButton(index);
            _pageIndex = _tabs.selectedIndex;
            invalidateComponentData();
            invalidateComponentLayout();
        }
        return v;
    }

    public override function findComponent<T: Component>(criteria:String = null, type:Class<T> = null, recursive:Null<Bool> = null, searchType:String = "id"):Null<T> {
        var match: Component = super.findComponent(criteria, type, recursive, searchType);
        if (match == null && _views != null) {
            for (view in _views) {
                match = view.findComponent(criteria, type, recursive, searchType);
                if (match != null) {
                    break;
                }
            }
        }
        return cast match;
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _currentView:Component;
    private var _pageIndex:Int = -1;
    public var pageIndex(get, set):Int;
    private function get_pageIndex():Int {
        return _pageIndex;
    }
    private function set_pageIndex(value:Int):Int {
        if (value < 0) {
            return value;
        }

        if (_pageIndex == value) {
            return value;
        }

        _pageIndex = value;
        invalidateComponentData();
        invalidateComponentLayout();

        return value;
    }

    public var selectedPage(get, null):Component;
    private function get_selectedPage():Component {
        if (_pageIndex < 0) {
            return null;
        }
        return _views[_pageIndex];
    }

    public var pages(get, null):Array<Component>;
    private function get_pages():Array<Component> {
        return _views;
    }
    
    public var pageCount(get, null):Int;
    private function get_pageCount():Int {
        return behaviourGet("pageCount");
    }

    public function removePage(index:Int) {
        behaviourRun("removePage", index);
    }

    public function removeAllPages() {
        behaviourRun("removeAllPages");
    }

    public var selectedButton(get, null):Button;
    private function get_selectedButton():Button {
        return _tabs.selectedButton;
    }
    
    private var __onBeforeChange:UIEvent->Void;
    /**
     Utility property to add a single `UIEvent.CHANGE` event
    **/
    @:dox(group = "Event related properties and methods")
    public var onBeforeChange(null, set):UIEvent->Void;
    private function set_onBeforeChange(value:UIEvent->Void):UIEvent->Void {
        if (__onBeforeChange != null) {
            unregisterEvent(UIEvent.BEFORE_CHANGE, __onBeforeChange);
            __onBeforeChange = null;
        }
        registerEvent(UIEvent.BEFORE_CHANGE, value);
        __onBeforeChange = value;
        return value;
    }
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************

    private override function validateData() {
        if (native == true) {
            return;
        }
        
        _tabs.selectedIndex = _pageIndex;
        var view:Component = _views[_pageIndex];
        if (view != null) {
            if (_currentView != null) {
                //_content.removeComponent(_currentView, false);
                _currentView.hide();
            }
            if (_content.getComponentIndex(view) == -1) {
                _content.addComponent(view);
            } else {
                view.show();
            }

            _currentView = view;
        }

        dispatch(new UIEvent(UIEvent.CHANGE));
    }
    
    //***********************************************************************************************************
    // Event Handlers
    //***********************************************************************************************************
    private function _onBeforeTabsChange(event:UIEvent) {
        dispatch(new UIEvent(UIEvent.BEFORE_CHANGE));
    }
    
    private function _onTabsChange(event:UIEvent) {
        pageIndex = _tabs.selectedIndex;
    }
}

@:dox(hide)
class TabViewLayout extends DefaultLayout {
    private override function repositionChildren() {
        var tabs:TabBar = component.findComponent("tabview-tabs");
        var content:Component = component.findComponent("tabview-content");
        if (tabs == null || content == null) {
            return;
        }

        tabs.left = paddingLeft;
        tabs.top = paddingTop;

        content.left = paddingLeft;
        if (tabs.componentHeight != null) {
            content.top = tabs.top + tabs.componentHeight - 1;
        }
    }

    private override function resizeChildren() {
        var content:Component = component.findComponent("tabview-content");
        var tabs:TabBar = component.findComponent("tabview-tabs");
        if (tabs == null || content == null) {
            return;
        }

        var usableSize = usableSize;
        tabs.width = usableSize.width;
        
        if (component.autoHeight == false) {
            content.componentHeight = usableSize.height;
        }

        if (component.autoWidth == false) {
            content.componentWidth = component.componentWidth;
        } else {
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var tabs:TabBar = component.findComponent("tabview-tabs");
        if (tabs != null && tabs.componentHeight != null) {
            size.height -= tabs.componentHeight; // - 1;
        }
        return size;
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var size:Size = super.calcAutoSize(exclusions);
        return size;
    }
}

@:dox(hide)
@:access(haxe.ui.containers.TabView)
private class RemovePage extends Behaviour {
    public override function run(param:Variant = null) {
        var tabView:TabView = cast(_component, TabView);
        if (tabView._views != null) {
            var view = tabView._views[param.toInt()];
            tabView.removeComponent(view);
        }
    }
}

@:dox(hide)
@:access(haxe.ui.containers.TabView)
private class RemoveAllPages extends Behaviour {
    public override function run(param:Variant = null) {
        var tabView:TabView = cast(_component, TabView);
        if (tabView._views != null) {
            for (view in tabView._views) {
                tabView.removeComponent(view);
            }
            tabView._views = [];
        }
        tabView._currentView = null;
        tabView._pageIndex = -1;
        if (tabView._content != null) {
            tabView._content.removeAllComponents();
        }
        if (tabView._tabs != null) {
            tabView._tabs.removeAllButtons();
            tabView._tabs.resetSelection();
        }
    }
}

@:dox(hide)
@:access(haxe.ui.containers.TabView)
private class PageCount extends Behaviour {
    public override function get():Variant {
        var tabView:TabView = cast(_component, TabView);
        if (tabView._tabs == null) {
            return 0;
        }
        return tabView._tabs.buttonCount;
    }
}