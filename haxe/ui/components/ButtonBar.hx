package haxe.ui.components;

import haxe.ui.core.Behaviour;
import haxe.ui.components.HButtonBar.HButtonBarLayout;
import haxe.ui.components.Button;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.data.DataSource;
import haxe.ui.util.Variant;

class ButtonBar extends InteractiveComponent implements IDataComponent {
    static public inline var NO_SELECTION:Int = -1;

    public function new() {
        super();

        layout = new HButtonBarLayout();
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function get_value():Variant {
        return selectedIndex != NO_SELECTION ? childComponents[selectedIndex].text : null;
    }

    private override function set_value(value:Variant):Variant {
        if (value == null) {
            return null;
        }
        for (i in 0...childComponents.length) {
            var child = childComponents[i];
            if (child.text == value.toString()) {
                selectedIndex = i;
                break;
            }
        }
        return value;
    }

    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "dataSource" => new ButtonBarDefaultDataSourceBehaviour(this),
            "selectedIndex" => new ButtonBarDefaultSelectedIndexBehaviour(this),
            "selectedItem" => new ButtonBarDefaultSelectedItemBehaviour(this)
        ]);
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    private var _dataSource:DataSource<Dynamic>;
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        if (_dataSource != null) {
            _dataSource.onChange = null;
        }

        _dataSource = value;
        behaviourSet("dataSource", value);

        if (_dataSource != null) {
            _dataSource.onChange = onDataSourceChanged;
        }

        syncUI();

        if (_requireSelection == true && _dataSource != null && _selectedIndex < 0) {
            selectedIndex = 0;
        }

        return value;
    }

    private var _selectedIndex:Int = NO_SELECTION;
    @bindable public var selectedIndex(get, set):Int;
    private function get_selectedIndex():Int {
        return _selectedIndex;
    }
    private function set_selectedIndex(value:Int):Int {
        if (_dataSource == null || value >= _dataSource.size) {
            return value;
        }

        if (_selectedIndex == value) {
            return value;
        }

        _selectedIndex = value;

        if (_dataSource != null) {
            if (_requireSelection == true && _selectedIndex < 0 && _dataSource.size > 0) {
                _selectedIndex = 0;
            }
        } else {
            this.value = null;
        }

        behaviourSet("selectedIndex", _selectedIndex);

        dispatch(new UIEvent(UIEvent.CHANGE));

        return _selectedIndex;
    }

    public var selectedItem(get, null):Dynamic;
    private function get_selectedItem():Dynamic {
        return behaviourGetDynamic("selectedItem");
    }

    private var _requireSelection:Bool = true;
    public var requireSelection(get, set):Bool;
    private function get_requireSelection():Bool {
        return _requireSelection;
    }
    private function set_requireSelection(value:Bool):Bool {
        if (_requireSelection != value) {
            _requireSelection = value;
            if (_requireSelection == true && _dataSource != null && _selectedIndex < 0) {
                selectedIndex = 0;
            }
        }

        return value;
    }

    public var itemCount(get, null):Int;
    private function get_itemCount():Int {
        return childComponents.length;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************

    private function onButtonClick(event:MouseEvent):Void {
        var button:Button = cast(event.target, Button);
        var index:Int = childComponents.indexOf(button);
        if(selectedIndex == index && requireSelection && !button.selected) {  //Prevent deselect
            button.selected = true;
        }
        else {
            selectedIndex = index;
        }
    }

    private function onDataSourceChanged() {
        if (_ready == true) {
            syncUI();
        }
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************

    private function syncUI():Void {
        lockLayout();

        if (_dataSource == null) {
            removeAllComponents();
        } else {
            var size = _dataSource.size;
            var delta = size - itemCount;
            if (delta > 0) { // not enough items
                for (n in 0...delta) {
                    var button:Button = new Button();
                    button.addClass('buttonbar-button');
                    button.toggle = requireSelection;
                    button.registerEvent(MouseEvent.CLICK, onButtonClick);
                    addComponent(button);
                }
            } else if (delta < 0) { // too many items
                while (delta < 0) {
                    removeComponent(childComponents[childComponents.length - 1]); // remove last
                    delta++;
                }
            }

            for (n in 0...size) {
                var button:Button = cast(childComponents[n], Button);
                if (n == 0 && size > 1) {
                    button.addClass('buttonbar-button-first');
                } else if (n == size-1 && size > 1) {
                    button.addClass('buttonbar-button-last');
                } else {
                    button.addClass('buttonbar-button-middle');
                }

                button.selected = n == _selectedIndex;

                var data = _dataSource.get(n);
                for (f in Reflect.fields(data)) {
                    var v = Reflect.field(data, f);
                    switch (f) {
                        case "value", "text":
                            button.text = Variant.fromDynamic(v);

                        case "icon":
                            button.icon = Variant.fromDynamic(v);
                    }
                }
            }
        }

        unlockLayout();
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.components.ButtonBar)
class ButtonBarDefaultDataSourceBehaviour extends Behaviour {
    public override function set(value:Variant) {

    }
}

@:dox(hide)
@:access(haxe.ui.components.ButtonBar)
class ButtonBarDefaultSelectedIndexBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var buttonBar:ButtonBar = cast _component;
        buttonBar.syncUI();
    }
}

@:dox(hide)
@:access(haxe.ui.components.ButtonBar)
class ButtonBarDefaultSelectedItemBehaviour extends Behaviour {
    public override function getDynamic():Dynamic {
        var buttonBar:ButtonBar = cast _component;
        if (buttonBar._dataSource == null || buttonBar._selectedIndex == ButtonBar.NO_SELECTION) {
            return null;
        }
        return buttonBar.dataSource.get(buttonBar._selectedIndex);
    }
}