package haxe.ui.components;

import haxe.ds.StringMap;
import haxe.ui.core.Component;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;

class OptionBox extends CheckBox {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(GroupBehaviour, "defaultGroup")     public var group:String;
    @:clonable @:behaviour(SelectedBehaviour)                  public var selected:Bool;
    @:clonable @:behaviour(SelectedBehaviour)                  public var value:Variant;
    @:clonable @:behaviour(SelectedOptionBehaviour)            public var selectedOption:Component;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class GroupBehaviour extends DataBehaviour {
    public override function validateData() {
        OptionBoxGroups.instance.add(_value, cast _component);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedBehaviour extends DataBehaviour {
    public override function get():Variant {
        var valueComponent:Component = _component.findComponent("optionbox-value");
        return valueComponent.hasClass(":selected");
    }
    
    public override function validateData() {
        var optionbox:OptionBox = cast(_component, OptionBox);
        
        if (optionbox.group != null && _value == false) { // dont allow false if no other group selection
            var arr:Array<OptionBox> = OptionBoxGroups.instance.get(optionbox.group);
            var hasSelection:Bool = false;
            if (arr != null) {
                for (option in arr) {
                    if (option != _component && option.selected == true) {
                        hasSelection = true;
                        break;
                    }
                }
            }
            if (hasSelection == false) {
                _value = true;
                return;
            }
        }
        
        if (optionbox.group != null && _value == true) { // set all the others in group
            var arr:Array<OptionBox> = OptionBoxGroups.instance.get(optionbox.group);
            if (arr != null) {
                for (option in arr) {
                    if (option != _component) {
                        option.selected = false;
                    }
                }
            }
        }

        
        var valueComponent:Component = _component.findComponent("optionbox-value");
        if (_value == true) {
            valueComponent.addClass(":selected");
            _component.dispatch(new UIEvent(UIEvent.CHANGE));
        } else {
            valueComponent.removeClass(":selected");
        }
        
    }
}

@:dox(hide) @:noCompletion
private class SelectedOptionBehaviour extends DataBehaviour {
    public override function get():Variant {
        var optionbox:OptionBox = cast(_component, OptionBox);
        var arr:Array<OptionBox> = OptionBoxGroups.instance.get(optionbox.group);
        var selectionOption:OptionBox = null;
        if (arr != null) {
            for (test in arr) {
                if (test.selected == true) {
                    selectionOption = test;
                    break;
                }
            }
        }
        return selectionOption;
    }
}

//***********************************************************************************************************
// Util classes
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class OptionBoxGroups { // singleton
    private static var _instance:OptionBoxGroups;
    public static var instance(get, null):OptionBoxGroups;
    private static function get_instance() {
        if (_instance == null) {
            _instance = new OptionBoxGroups();
        }
        return _instance;
    }
    
    //***********************************************************************************************************
    // Instance methods
    //***********************************************************************************************************
    private var _groups:StringMap<Array<OptionBox>> = new StringMap<Array<OptionBox>>();
    private function new () {
        
    }
    
    public function get(name:String):Array<OptionBox> {
        return _groups.get(name);
    }
    
    public function set(name:String, options:Array<OptionBox>) {
        _groups.set(name, options);
    }
    
    public function add(name:String, optionbox:OptionBox) {
        var arr:Array<OptionBox> = get(name);
        if (arr == null) {
            arr = [];
        }
        
        if (arr.indexOf(optionbox) == -1) {
            arr.push(optionbox);
        }
        set(name, arr);
    }
}