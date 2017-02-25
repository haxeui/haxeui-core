package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.components.TabBar;
import haxe.ui.core.Component;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Size;

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
        } else {
        }
        return v;
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

            invalidateLayout();
        }

        dispatch(new UIEvent(UIEvent.CHANGE));

        return value;
    }

    public function removeAllTabs() {
        if (_views != null) {
            for (view in _views) {
                removeComponent(view);
            }
            _views = [];
        }
        _currentView = null;
        _pageIndex = -1;
        if (_content != null) {
            _content.removeAllComponents();
        }
        if (_tabs != null) {
            _tabs.removeAllComponents();
            _tabs.resetSelection();
        }
    }
    
    //***********************************************************************************************************
    // Event Handlers
    //***********************************************************************************************************
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

        if (component.autoHeight == false) {
            content.componentHeight = usableHeight;
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