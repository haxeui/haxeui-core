package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.HorizontalLayout;

/**
 A specially styled list of toggle buttons where one one can be selected at a time
**/
@:dox(icon = "/icons/ui-tab.png")
class TabBar extends Component {
    private var _currentButton:Button;

    public function new() {
        super();
        layout = new HorizontalLayout(); // TabBarLayout();
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    public override function addComponent(child:Component):Component {
        var v = super.addComponent(child);

        //if (child != _background) {
            child.addClass("tabbar-button");
            child.registerEvent(MouseEvent.MOUSE_DOWN, _onButtonMouseDown);
            if (_selectedIndex == -1) {
                selectedIndex = 0;
            }
        //}
        return v;
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
        if (value < 0) {
            return value;
        }
        if (_selectedIndex == value) {
            return value;
        }

        _selectedIndex = value;

        var button:Button = cast getComponentAt(_selectedIndex); // offset as 0 is background
        if (button != null) {
            if (_currentButton != null) {
                _currentButton.removeClass("tabbar-button-selected");
            }
            _currentButton = button;
            _currentButton.addClass("tabbar-button-selected");
            invalidateLayout();

            var event:UIEvent = new UIEvent(UIEvent.CHANGE);
            event.target = this;
            dispatch(event);
        }
        return value;
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

        selectedIndex = getComponentIndex(event.target); // - 1;
    }

}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
class TabBarLayout extends HorizontalLayout {
    public function new() {
        super();
    }

    private override function resizeChildren() {
        super.resizeChildren();
    }
}