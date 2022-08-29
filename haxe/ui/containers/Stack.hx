package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Variant;

/**
 A `Box` component where only one child is visible at a time
**/
@:dox(icon = "/icons/ui-layered-pane.png")
@:composite(Builder)
class Stack extends Box {
    @:behaviour(SelectedIndex, -1)      public var selectedIndex:Int;
    @:behaviour(SelectedId)             public var selectedId:String;
    
    @:call(PrevPage)                    public function prevPage();
    @:call(NextPage)                    public function nextPage();
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class SelectedIndex extends DataBehaviour {
    private override function validateData() {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        
        if (_value < 0) {
            return;
        }
        if (_value > _component.childComponents.length - 1) {
            _value = _component.childComponents.length - 1;
            return;
        }
        
        if (builder._currentPage != null) {
            builder._currentPage.hide();
        }
        
        builder._currentPage = _component.childComponents[_value.toInt()];
        builder._currentPage.show();
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class SelectedId extends DataBehaviour {
    private var _stack:Stack;
    
    public function new(stack:Stack) {
        super(stack);
        _stack = stack;
    }
    
    private override function validateData() {
        var item = _component.findComponent(_value, Component, false);
        if (item != null) {
            _stack.selectedIndex = _component.getComponentIndex(item);
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class PrevPage extends DataBehaviour {
    private var _stack:Stack;
    
    public function new(stack:Stack) {
        super(stack);
        _stack = stack;
    }
    
    public override function call(param:Any = null):Variant {
        var pageCount = _stack.numComponents;
        var newIndex:Int = _stack.selectedIndex;
        newIndex--;
        if (newIndex < 0) {
            newIndex = pageCount - 1;
        }
        _stack.selectedIndex = newIndex;
        return null;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class NextPage extends DataBehaviour {
    private var _stack:Stack;
    
    public function new(stack:Stack) {
        super(stack);
        _stack = stack;
    }
    
    public override function call(param:Any = null):Variant {
        var pageCount = _stack.numComponents;
        var newIndex:Int = _stack.selectedIndex;
        newIndex++;
        if (newIndex > pageCount - 1) {
            newIndex = 0;
        }
        _stack.selectedIndex = newIndex;
        return null;
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.components.TabBar)
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _stack:Stack;
    private var _currentPage:Component = null;
    
    public function new(stack:Stack) {
        super(stack);
        _stack = stack;
    }

    public override function addComponent(child:Component):Component {
        if (_stack.selectedIndex < 0) {
            _stack.selectedIndex = 0;
        }
        if (_stack.numComponents > 0) {
            child.hide();
        }
        return null;
    }
}