package haxe.ui.components;
import haxe.ds.StringMap;
import haxe.ui.core.Component;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.UIEvent;

class OptionBox2 extends CheckBox2 {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(GroupBehaviour, "defaultGroup")     public var group:String;
    @:behaviour(SelectedBehaviour)                  public var selected:Bool;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class GroupBehaviour extends DataBehaviour {
    public override function validateData() {
        var optionbox:OptionBox2 = cast(_component, OptionBox2);
        if (_value != null) {
            var arr:Array<OptionBox2> = Groups.instance.get(_value);
            if (arr != null) {
                arr.remove(optionbox);
            }
        }
        
        var arr:Array<OptionBox2> = Groups.instance.get(_value);
        if (arr == null) {
            arr = [];
        }
        
        if (arr.indexOf(optionbox) == -1) {
            arr.push(optionbox);
        }
        Groups.instance.set(_value, arr);
        
    }
    
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedBehaviour extends DataBehaviour {
    public override function validateData() {
        var optionbox:OptionBox2 = cast(_component, OptionBox2);
        if (optionbox.group != null && _value == false) { // dont allow false if no other group selection
            var arr:Array<OptionBox2> = Groups.instance.get(optionbox.group);
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
                return;
            }
        }
        
        if (optionbox.group != null && _value == true) { // set all the others in group
            var arr:Array<OptionBox2> = Groups.instance.get(optionbox.group);
            if (arr != null) {
                for (option in arr) {
                    if (option != _component) {
                        option.selected = false;
                    }
                }
            }
        }

        
        var valueComponent:Component = _component.findComponent("optionbox2-value");
        if (_value == true) {
            valueComponent.addClass(":selected");
        } else {
            valueComponent.removeClass(":selected");
        }
        
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

//***********************************************************************************************************
// Util classes
//***********************************************************************************************************
private class Groups { // singleton
    private static var _instance:Groups;
    public static var instance(get, null):Groups;
    private static function get_instance() {
        if (_instance == null) {
            _instance = new Groups();
        }
        return _instance;
    }
    
    private var _groups:StringMap<Array<OptionBox2>> = new StringMap<Array<OptionBox2>>();
    private function new () {
        
    }
    
    public function get(name:String):Array<OptionBox2> {
        return _groups.get(name);
    }
    
    public function set(name:String, options:Array<OptionBox2>) {
        _groups.set(name, options);
    }
}