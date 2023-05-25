package haxe.ui.components;

import haxe.ui.animation.AnimationTools;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.events.UIEvent;
import haxe.ui.util.DateUtil;
import haxe.ui.util.Variant;

class MonthStepper extends OptionStepper {
    public function new() {
        super();
        var now = Date.now();
        selectedMonth = now.getMonth();
        selectedYear = now.getFullYear();
    }

    @:call(IncrementValue)                              public override function incrementValue():Void;
    @:call(DeincrementValue)                            public override function deincrementValue():Void;

    public var maxDate:Date = null;
    public var minDate:Date = null;

    private var _allowFutureDates:Bool = true;
    public var allowFutureDates(get, set):Bool;
    private function get_allowFutureDates():Bool {
        return _allowFutureDates;
    }
    private function set_allowFutureDates(value:Bool):Bool {
        _allowFutureDates = value;
        if (_allowFutureDates) {
            maxDate = null;
        } else {
            var now = Date.now();
            maxDate = new Date(now.getFullYear(), now.getMonth(), DateUtil.DAYS_IN_MONTH[now.getMonth()], 23, 59, 59);
        }
        return value;
    }


    private var _selectedMonth:Null<Int> = null;
    public var selectedMonth(get, set):Null<Int>;
    private function get_selectedMonth():Null<Int> {
        return _selectedMonth;
    }
    private function set_selectedMonth(value:Null<Int>):Null<Int> {
        if (_selectedMonth != value) {
            _selectedMonth = value;
            updateSelectedMonth();
        }
        return value;
    }

    private var _selectedYear:Null<Int> = null;
    public var selectedYear(get, set):Null<Int>;
    private function get_selectedYear():Null<Int> {
        return _selectedYear;
    }
    private function set_selectedYear(value:Null<Int>):Null<Int> {
        if (_selectedYear != value) {
            _selectedYear = value;
            updateSelectedMonth();
        }
        return value;
    }

    private override function create() {
        super.create();
        updateSelectedMonth();
    }

    private function updateSelectedMonth() {
        if (_selectedMonth == null || _selectedYear == null) {
            return;
        }

        var monthName = DateUtil.MONTH_NAMES[_selectedMonth];

        var display = monthName + ", " + _selectedYear;
        var value = findComponent("value", Label);
        if (value != null) {
            value.text = display;
        }
    }
}

//***********************************************************************************************************
// Composite Behaviours
//***********************************************************************************************************
private class IncrementValue extends Behaviour {
    public override function call(param:Any = null):Variant {
        var dispatchEvent = true;
        var stepper:MonthStepper = cast _component;
        var selectedMonth = stepper.selectedMonth;
        var selectedYear = stepper.selectedYear;
        selectedMonth++;
        if (selectedMonth > 11) {
            selectedMonth = 0;
            selectedYear++;
        }
        var maxDate = stepper.maxDate;
        if (maxDate != null) {
            if (selectedYear > maxDate.getFullYear()) {
                selectedMonth = stepper.selectedMonth;
                selectedYear = stepper.selectedYear;
                dispatchEvent = false;
                AnimationTools.shake(stepper);
            } else if (selectedYear == maxDate.getFullYear() && selectedMonth > maxDate.getMonth()) {
                selectedMonth = stepper.selectedMonth;
                selectedYear = stepper.selectedYear;
                dispatchEvent = false;
                AnimationTools.shake(stepper);
            }
        }
        stepper.selectedMonth = selectedMonth;
        stepper.selectedYear = selectedYear;

        if (dispatchEvent == true) {
            stepper.dispatch(new UIEvent(UIEvent.CHANGE));
        }
        return null;
    }
}

private class DeincrementValue extends Behaviour {
    public override function call(param:Any = null):Variant {
        var dispatchEvent = true;
        var stepper:MonthStepper = cast _component;
        var selectedMonth = stepper.selectedMonth;
        var selectedYear = stepper.selectedYear;
        selectedMonth--;
        if (selectedMonth < 0) {
            selectedMonth = 11;
            selectedYear--;
        }
        stepper.selectedMonth = selectedMonth;
        stepper.selectedYear = selectedYear;

        if (dispatchEvent == true) {
            stepper.dispatch(new UIEvent(UIEvent.CHANGE));
        }
        return null;
    }
}
