package haxe.ui.components;

import haxe.ui.containers.HBox;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.HorizontalLayout;

/**
 A specially styled list of toggle buttons where one one can be selected at a time
**/
@:dox(icon = "/icons/ui-tab.png")
class TabBar extends Component {
    private var _currentButton:Button;
    private var _container:HBox;

    public function new() {
        super();
        registerEvent(MouseEvent.MOUSE_WHEEL, function(e:MouseEvent) {
            if (e.delta < 0) {
               scrollLeft();
            } else {
               scrollRight();
            }
        }); 
    }

    private function createContainer() {
        if (_container == null) {
            _container = new HBox();
            _container.id = "tabbar-contents";
            _container.addClass("tabbar-contents");
            addComponent(_container);
        }
    }
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new TabBarLayout();
    }
    
    public override function addComponent(child:Component):Component {
        var v = null;

        if (child != _container && child.id != "tabbar-scroll-left" && child.id != "tabbar-scroll-right") {
            createContainer();
            child.addClass("tabbar-button");
            child.registerEvent(MouseEvent.MOUSE_DOWN, _onButtonMouseDown);
            v = _container.addComponent(child);
            if (_selectedIndex == -1) {
                selectedIndex = 0;
            }
        } else {
            v = super.addComponent(child);
        }
        
        return v;
    }

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        var v = null;
        
        if (child != _container) {
            v = _container.removeComponent(child, dispose, invalidate);
        } else {
            v = super.removeComponent(child, dispose, invalidate);
        }
        
        return v;
    }
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************

    private override function validateLayout() {
        var b = super.validateLayout();
        if (native == true || _container == null) {
            return b;
        }
        
        if (_containerPosition == null) {
            _containerPosition = layout.paddingLeft;
        }
        
        if (_container.width > this.layout.usableWidth && this.layout.usableWidth > 0) {
            createScrollButtons();
            _container.left = _containerPosition;
        } else {
            destroyScrollButtons();
        }
        
        return b;
    }
    
    private function createScrollButtons() {
        if (findComponent("tabbar-scroll-left") == null) {
            var button = new Button();
            button.id = "tabbar-scroll-left";
            button.addClass("tabbar-scroll-left");
            button.includeInLayout = false;
            button.repeater = true;
            addComponent(button);
            button.onClick = function(e) {
                scrollLeft();
            }
        }
        if (findComponent("tabbar-scroll-right") == null) {
            var button = new Button();
            button.id = "tabbar-scroll-right";
            button.addClass("tabbar-scroll-right");
            button.includeInLayout = false;
            button.repeater = true;
            addComponent(button);
            button.onClick = function(e) {
                scrollRight();
            }
        }
    }
    
    private var _containerPosition:Null<Float>;
    private static inline var SCROLL_INCREMENT:Int = 20; // todo: calc based on button width?
    private function scrollLeft() {
        var x = _container.left + SCROLL_INCREMENT; 
        if (x > layout.paddingLeft) {
            x = layout.paddingLeft;
        }
        _containerPosition = x;
        _container.left = x;
    }
    
    private function scrollRight() {
        var x = _container.left - SCROLL_INCREMENT;
        var max = -(_container.width - this.width);
        
        var left:Button = findComponent("tabbar-scroll-left", Button);
        var right:Button = findComponent("tabbar-scroll-right", Button);
        if (left != null && left.hidden == false) {
            max -= left.width;
            max -= layout.horizontalSpacing;
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
    
    private function destroyScrollButtons() {
        if (findComponent("tabbar-scroll-left") == null) {
            removeComponent(findComponent("tabbar-scroll-left"));
        }
        if (findComponent("tabbar-scroll-right") == null) {
            removeComponent(findComponent("tabbar-scroll-right"));
        }
    }
    
    private override function validateData() {
        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        event.target = this;
        dispatch(event);
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    private var _selectedIndex:Int = -1;
    /**
     The currently selected button index
    **/
    @bindable public var selectedIndex(get, set):Int;
    private function get_selectedIndex():Int {
        return _selectedIndex;
    }
    private function set_selectedIndex(value:Int):Int {
        if (value < 0 || _selectedIndex == value || _container == null) {
            return value;
        }

        if (_selectedIndex != -1) {
            dispatch(new UIEvent(UIEvent.BEFORE_CHANGE));
        }
        
        _selectedIndex = value;
        invalidateData();

        var button:Button = cast(_container.getComponentAt(_selectedIndex), Button);
        if (button != null) {
            if (_currentButton != null) {
                _currentButton.removeClass("tabbar-button-selected");
            }
            _currentButton = button;
            _currentButton.addClass("tabbar-button-selected");
            invalidateLayout();
        }
        return value;
    }

    public var selectedButton(get, null):Button;
    private function get_selectedButton():Button {
        if (_selectedIndex < 0) {
            return null;
        }
        
        return cast(_container.childComponents[_selectedIndex], Button);
    }
    
    public function resetSelection() {
        _selectedIndex = -1;
        _currentButton = null;
    }
    
    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private function _onButtonMouseDown(event:MouseEvent){
        if (event.target == _currentButton) {
            return;
        }

        selectedIndex = _container.getComponentIndex(event.target);
    }

}

//***********************************************************************************************************
// Layout
//***********************************************************************************************************
@:dox(hide)
class TabBarLayout extends DefaultLayout {
    private override function repositionChildren() {
        super.repositionChildren();
        
        var left:Button = _component.findComponent("tabbar-scroll-left");
        var right:Button = _component.findComponent("tabbar-scroll-right");
        if (left != null && hidden(left) == false) {
            var x = _component.width - left.width;
            if (right != null) {
                x -= right.width;
            }
            left.left = x;
            left.top = (_component.height / 2) - (left.height / 2);
        }
        
        if (right != null && hidden(right) == false) {
            right.left = _component.width - right.width;
            right.top = (_component.height / 2) - (right.height / 2);
        }
    }
}