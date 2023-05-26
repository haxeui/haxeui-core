package haxe.ui.components;

import haxe.ds.StringMap;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.CheckBox.CheckBoxBuilder;
import haxe.ui.components.CheckBox.CheckBoxValue;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Variant;

@:composite(OptionBoxBuilder)
class OptionBox extends CheckBox {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    /**
        A group name, used to group multiple option elements together, utilizing the "optioning" functionality.

        @see http://haxeui.org/explorer/#basic/option_boxes
    **/
    @:clonable @:behaviour(GroupBehaviour, "defaultGroup")      public var componentGroup:String;

    /**
        Whether this option box is selected or not.
    **/
    @:clonable @:behaviour(SelectedBehaviour)                   public var selected:Bool;

    /**
        Gets the currently selected option from this `OptionBox`'s component group.
    **/
    @:clonable @:behaviour(SelectedOptionBehaviour)             public var selectedOption:Component;

    /**
        Whether or not this option box is selected or not.

        `value` is used as a universal way to access the "core" value a component is based on. 
        in this case, its whether or not this option box is selected.
    **/
    @:clonable @:value(selected)                                public var value:Any;
    /**
        Makes every single option box in the current `componentGroup` unselected.
    **/
    @:call(ResetGroup)                                          public function resetGroup():Void;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class GroupBehaviour extends DataBehaviour {
    public override function set(value:Variant) {
        super.set(value);
        if (_previousValue != null && !_previousValue.isNull && _previousValue.toString() != _value.toString()) {
            OptionBoxGroups.instance.remove(_previousValue, cast _component);    
        }
        OptionBoxGroups.instance.add(value, cast _component);
    }

    public override function validateData() {
        if (_previousValue != null && !_previousValue.isNull && _previousValue.toString() != _value.toString()) {
            OptionBoxGroups.instance.remove(_previousValue, cast _component);    
        }
        OptionBoxGroups.instance.add(_value, cast _component);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedBehaviour extends DataBehaviour {
    public override function validateData() {
        var optionbox:OptionBox = cast(_component, OptionBox);
        cast(_component._compositeBuilder, OptionBoxBuilder).setSelection(optionbox, _value);
    }
}

@:dox(hide) @:noCompletion
private class SelectedOptionBehaviour extends DataBehaviour {
    public override function get():Variant {
        var optionbox:OptionBox = cast(_component, OptionBox);
        var arr:Array<OptionBox> = OptionBoxGroups.instance.get(optionbox.componentGroup);
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

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class ResetGroup extends Behaviour {
    public override function call(param:Any = null):Variant {
        var optionbox:OptionBox = cast(_component, OptionBox);
        OptionBoxGroups.instance.reset(optionbox.componentGroup);
        return null;
    }
}
//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class OptionBoxBuilder extends CheckBoxBuilder {
    private override function get_cssName():String {
        return "optionbox";
    }
    
    public function setSelection(optionbox:OptionBox, value:Bool, allowDeselection:Bool = false) {
        if (optionbox.componentGroup != null && value == false && allowDeselection == false) { // dont allow false if no other group selection
            var arr:Array<OptionBox> = OptionBoxGroups.instance.get(optionbox.componentGroup);
            var hasSelection:Bool = false;
            if (arr != null) {
                for (option in arr) {
                    if (option != optionbox && option.selected == true) {
                        hasSelection = true;
                        break;
                    }
                }
            }
            if (hasSelection == false && allowDeselection == false) {
                optionbox.behaviours.softSet("selected", true);
                return;
            }
        }

        if (optionbox.componentGroup != null && value == true) { // set all the others in group
            var arr:Array<OptionBox> = OptionBoxGroups.instance.get(optionbox.componentGroup);
            if (arr != null) {
                for (option in arr) {
                    if (option != optionbox) {
                        option.selected = false;
                    }
                }
            }
        }

        if (allowDeselection == true && value == false) {
            optionbox.behaviours.softSet("selected", false);
        }
        
        var valueComponent:CheckBoxValue = optionbox.findComponent("optionbox-value", CheckBoxValue);
        if (valueComponent == null) {
            return;
        }
        valueComponent.createIcon();
        if (value == true) {
            valueComponent.addClass(":selected");
            optionbox.dispatch(new UIEvent(UIEvent.CHANGE));
        } else {
            valueComponent.removeClass(":selected");
        }
    }
    
    public override function destroy() {
        super.destroy();
        var optionbox:OptionBox = cast(_component, OptionBox);
        OptionBoxGroups.instance.remove(optionbox.componentGroup, optionbox);        
    }
}

//***********************************************************************************************************
// Util classes
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class OptionBoxGroups { // singleton
    private static var _instance:OptionBoxGroups;
    public static var instance(get, null):OptionBoxGroups;
    private static function get_instance():OptionBoxGroups {
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
    
    public function remove(name:String, optionbox:OptionBox) {
        var arr:Array<OptionBox> = get(name);
        if (arr == null) {
            return;
        }
        
        arr.remove(optionbox);
        if (arr.length == 0) {
            _groups.remove(name);
        }
    }
    
    public function reset(name:String) {
        var arr:Array<OptionBox> = get(name);
        if (arr == null) {
            return;
        }
        
        var selection = null;
        for (item in arr) {
            if (item.selected == true) {
                selection = item;
                break;
            }
        }
        
        if (selection == null) {
            return;
        }
        
        cast(selection._compositeBuilder, OptionBoxBuilder).setSelection(selection, false, true);
    }
}