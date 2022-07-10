package haxe.ui.components;

import haxe.ui.actions.ActionType;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.data.DataSource;
import haxe.ui.events.ActionEvent;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;

/**
 * A stepper that allows the user to switch between items using the visual arrow buttons/arrow keys.
 */
@:composite(Events, Builder, Layout)
class OptionStepper extends InteractiveComponent implements IDataComponent {

    /**
     * The index of the currently selected item.
     */
    @:clonable @:behaviour(SelectedIndexBehaviour, 0)   public var selectedIndex:Int;

    /**
     * The selected item
     */
    @:behaviour(SelectedItemBehaviour)                  public var selectedItem:Dynamic;

    /**
     * The data from which the items are taken.
     *
     * Usage:
     * ```haxe
     * stepper.dataSource.add({text: "exampleText"});
     * ```
     */
    @:clonable @:behaviour(DataSourceBehaviour)         public var dataSource:DataSource<Dynamic>;

    /**
     * The index of the currently selected item
     * 
     * `value` is used as a universal way to access the value a component is based on. 
     * in this case its the index of the selected item inside the stepper.
     */
    @:clonable @:value(selectedIndex)                   public var value:Dynamic;
}

//***********************************************************************************************************
// Composite Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class DataSourceBehaviour extends DefaultBehaviour {
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class SelectedIndexBehaviour extends DataBehaviour {
    private override function validateData() {
        var stepper:OptionStepper = cast(_component, OptionStepper);
        var ds = stepper.dataSource;
        if (ds == null) {
            return;
        }
        var v:Dynamic = ds.get(_value);
        if (v == null) {
            return;
        }
        
        #if hl
        if (Reflect.hasField(v, "value")) {
            v = Std.string(v.value);
        } else if (Reflect.hasField(v, "text")) {
            v = Std.string(v.text);
        }
        #else
        if (v.value != null) {
            v = Std.string(v.value);
        } else if (v.text != null) {
            v = Std.string(v.text);
        }
        #end
        
        var value:Label = stepper.findComponent("value", Label);
        value.text = v;
        
        var event = new UIEvent(UIEvent.CHANGE);
        event.previousValue = _previousValue;
        event.value = _value;
        _component.dispatch(event);
        
    }
}

@:dox(hide) @:noCompletion
private class SelectedItemBehaviour extends Behaviour {
    public override function getDynamic():Dynamic {
        var stepper:OptionStepper = cast(_component, OptionStepper);
        var ds = stepper.dataSource;
        return ds.get(stepper.selectedIndex);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _stepper:OptionStepper;

    public function new(stepper:OptionStepper) {
        super(stepper);
        _stepper = stepper;
    }
    
    public override function create() {
        var value = new Label();
        value.id = "value";
        value.addClass("stepper-value");
        value.scriptAccess = false;
        _stepper.addComponent(value);
        
        var deinc = new Button();
        deinc.id = "deinc";
        deinc.addClass("stepper-deinc");
        deinc.allowFocus = false;
        deinc.scriptAccess = false;
        deinc.repeater = true;
        _stepper.addComponent(deinc);

        var inc = new Button();
        inc.id = "inc";
        inc.addClass("stepper-inc");
        inc.allowFocus = false;
        inc.scriptAccess = false;
        inc.repeater = true;
        _stepper.addComponent(inc);
    }
    
    public override function applyStyle(style:Style) {
        var value:Label = _stepper.findComponent("value", Label);
        if (value != null &&
            (value.customStyle.color != style.color ||
            value.customStyle.fontName != style.fontName ||
            value.customStyle.fontSize != style.fontSize ||
            value.customStyle.cursor != style.cursor ||
            value.customStyle.textAlign != style.textAlign)) {

            value.customStyle.color = style.color;
            value.customStyle.fontName = style.fontName;
            value.customStyle.fontSize = style.fontSize;
            value.customStyle.cursor = style.cursor;
            value.customStyle.textAlign = style.textAlign;
            value.invalidateComponentStyle();
        }
    }
}

//***********************************************************************************************************
// Composite Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Events extends haxe.ui.events.Events {
    private var _stepper:OptionStepper;

    public function new(stepper:OptionStepper) {
        super(stepper);
        _stepper = stepper;
    }
    
    public override function register() {
        if (!_stepper.hasEvent(MouseEvent.CLICK, onClick)) {
            _stepper.registerEvent(MouseEvent.CLICK, onClick);
        }
        if (!_stepper.hasEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel)) {
            _stepper.registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }
        
        var deinc:Button = _stepper.findComponent("deinc", Button);
        if (!deinc.hasEvent(MouseEvent.CLICK, onDeinc)) {
            deinc.registerEvent(MouseEvent.CLICK, onDeinc);
        }
        
        var inc:Button = _stepper.findComponent("inc", Button);
        if (!inc.hasEvent(MouseEvent.CLICK, onInc)) {
            inc.registerEvent(MouseEvent.CLICK, onInc);
        }
        if (!hasEvent(ActionEvent.ACTION_START, onActionStart)) {
            registerEvent(ActionEvent.ACTION_START, onActionStart);
        }
    }
    
    public override function unregister() {
        _stepper.unregisterEvent(MouseEvent.CLICK, onClick);
        _stepper.unregisterEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            
        var deinc:Button = _stepper.findComponent("deinc", Button);
        deinc.unregisterEvent(MouseEvent.CLICK, onDeinc);
        
        var inc:Button = _stepper.findComponent("inc", Button);
        inc.unregisterEvent(MouseEvent.CLICK, onInc);
        unregisterEvent(ActionEvent.ACTION_START, onActionStart);
    }
    
    private function onClick(_) {
        _stepper.focus = true;
    }
    
    private function onDeinc(event:MouseEvent) {
        _stepper.focus = true;
        deincrementValue();
    }
    
    private function onInc(event:MouseEvent) {
        _stepper.focus = true;
        incrementValue();
    }

    private function isInScroller():Bool {
        var p = _stepper.parentComponent;
        while (p != null) {
            if (p.isScroller) {
                var vscroll = p.findComponent("scrollview-vscroll", Component);
                if (vscroll != null && vscroll.hidden == false) {
                    return true;
                }
            }
            p = p.parentComponent;
        }
        return false;
    }
    
    private function onMouseWheel(event:MouseEvent) {
        if (isInScroller() && _stepper.focus == false) {
            return;
        }
        
        event.cancel();
        _stepper.focus = true;
        if (event.delta > 0) {
            incrementValue();
        } else {
            deincrementValue();
        }
    }
    
    
    private function onActionStart(event:ActionEvent) {
        switch (event.action) {
            case ActionType.DOWN:
                deincrementValue();
                event.repeater = true;
            case ActionType.UP:
                incrementValue();
                event.repeater = true;
            case ActionType.LEFT:    
                deincrementValue();
                event.repeater = true;
            case ActionType.RIGHT:    
                incrementValue();
                event.repeater = true;
            case _:      
        }
    }
    
    private function incrementValue() {
        if (_stepper.dataSource == null) {
            return;
        }
        var n = _stepper.selectedIndex;
        var m = _stepper.dataSource.size;
        
        n++;
        
        if (n > m - 1) {
            n = 0;
        }
        
        _stepper.selectedIndex = n;
    }
    
    
    private function deincrementValue() {
        if (_stepper.dataSource == null) {
            return;
        }
        var n = _stepper.selectedIndex;
        var m = _stepper.dataSource.size;
        
        n--;
        
        if (n < 0) {
            n = m -1;
        }
        
        _stepper.selectedIndex = n;
    }
}

//***********************************************************************************************************
// Layouts
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Layout extends DefaultLayout {
    private override function resizeChildren() {
        var value = findComponent("value", Label);
        var deinc = findComponent("deinc", Button);
        var inc = findComponent("inc", Button);
        
        var u = usableSize;
        
        deinc.height = u.height - (borderSize * 2);
        value.width = u.width - (deinc.width + inc.width);
        inc.height = u.height - (borderSize * 2);
    }
    
    private override function repositionChildren() {
        var value = findComponent("value", Label);
        var deinc = findComponent("deinc", Button);
        var inc = findComponent("inc", Button);
        
        deinc.left = paddingLeft + borderSize;
        deinc.top = paddingTop + borderSize;
        
        value.left = deinc.left + deinc.width;
        value.top = paddingTop + marginTop(value);
        
        inc.left = value.left + value.width - borderSize - borderSize;
        inc.top = paddingTop + borderSize;
    }
    
    private override function get_borderSize():Float {
        if (_component.style == null) {
            return 0;
        }

        var n = _component.style.fullBorderSize;
        return n;
    }
}
