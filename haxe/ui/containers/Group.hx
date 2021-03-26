package haxe.ui.containers;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.OptionBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.GUID;
import haxe.ui.util.Variant;

@:composite(Builder)
class Group extends Box {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(DataBehaviour, "group" + GUID.uuid())    public var componentGroup:String;
    @:call(ResetGroup)                                              public function resetGroup():Void;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class ResetGroup extends Behaviour {
    public override function call(param:Any = null):Variant {
        cast(_component._compositeBuilder, Builder).applyInitialValues();
        return null;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _group:Group;

    public function new(group:Group) {
        super(group);
        _group = group;
    }

    public override function addComponent(child:Component):Component { // addComponentAt too
        childAdd(child);

        return super.addComponent(child);
    }

    public override function addComponentAt(child:Component, index:Int):Component { // addComponentAt too
        childAdd(child);

        return super.addComponentAt(child, index);
    }

    private function childAdd(child:Component) {
        if ((child is InteractiveComponent)) {
            processGroupChild(child);
        } else {
            var interactiveChildren = child.findComponents(InteractiveComponent);
            for (interactiveChild in interactiveChildren) {
                processGroupChild(interactiveChild);
            }
        }
    }

    private function processGroupChild(child:Component) {
        if ((child is OptionBox)) {
            // set group name
            if (_group.componentGroup == null) {
                _group.componentGroup = "group" + GUID.uuid();
            }
            var optionbox = cast(child, OptionBox);
            if (optionbox.componentGroup == null || optionbox.componentGroup == "defaultGroup") {
                optionbox.componentGroup = _group.componentGroup;
            }
        }
        cacheInitalValue(child);
        if (child.hasEvent(UIEvent.CHANGE, childChangeHandler) == false) {
            // attach change event
            child.registerEvent(UIEvent.CHANGE, childChangeHandler);
        }
    }
    
    private var _initialValues:Map<Component, Variant> = null;
    private var _initialResets:Map<String, Bool> = null;
    private function cacheInitalValue(c:Component) {
        if ((c is OptionBox)) {
            if (_initialResets == null) {
                _initialResets = new Map<String, Bool>();
            }
            var optionbox = cast(c, OptionBox);
            if (optionbox.selected == true) {
                _initialResets.remove(optionbox.componentGroup);
                if (_initialValues == null) {
                    _initialValues = new Map<Component, Variant>();
                }
                _initialValues.set(c, c.value);
            } else {
                _initialResets.set(optionbox.componentGroup, true);
            }
        } else {
            if (_initialValues == null) {
                _initialValues = new Map<Component, Variant>();
            }
            _initialValues.set(c, c.value);
        }
    }

    public function applyInitialValues() {
        if (_initialValues != null) {
            for (c in _initialValues.keys()) {
                var v = _initialValues.get(c);
                c.value = v;
            }
        }

        if (_initialResets != null) {
            for (k in _initialResets.keys()) {
                OptionBoxGroups.instance.reset(k);
            }
        }
    }
    
    private function childChangeHandler(e:UIEvent) {
        _group.dispatch(e.clone());
    }
}
