package haxe.ui.components.pickers;

import haxe.ui.components.pickers.ItemPicker;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

@:composite(Builder)
@:xml('
<item-picker panelWidth="300">
    <hbox id="itemPickerRenderer" style="spacing:0px">
        <month-stepper allowFocus="false" id="monthStepper" width="100%" />
        <box id="itemPickerTrigger" height="100%">
            <image styleName="item-picker-trigger-icon" />
        </box>
    </hbox>
</item-picker>
')
class MonthPicker extends ItemPicker {
    public var selectedMonth(get, set):Null<Int>;
    private function get_selectedMonth():Null<Int> {
        return monthStepper.selectedMonth;
    }
    private function set_selectedMonth(value:Null<Int>):Null<Int> {
        monthStepper.selectedMonth = value;
        return value;
    }

    public var selectedYear(get, set):Null<Int>;
    private function get_selectedYear():Null<Int> {
        return monthStepper.selectedYear;
    }
    private function set_selectedYear(value:Null<Int>):Null<Int> {
        monthStepper.selectedYear = value;
        return value;
    }

    public var allowFutureDates(get, set):Bool;
    private function get_allowFutureDates():Bool {
        return monthStepper.allowFutureDates;
    }
    private function set_allowFutureDates(value:Bool):Bool {
        monthStepper.allowFutureDates = value;
        return value;
    }

    public var isMonthDisabled:Int->Int->Bool = null;

    @:bind(monthStepper, UIEvent.CHANGE)
    private function onMonthStepperChanged(event:UIEvent) {
        dispatch(event);
    }
}

private class Builder extends ItemPickerBuilder {
    public var monthPicker:MonthPicker;
    public var monthPickerPanel:MonthPickerPanel;

    public function new(monthPicker:MonthPicker) {
        super(monthPicker);
        this.monthPicker = monthPicker;
    }

    private override function get_handlerClass():Class<ItemPickerHandler> {
        return Handler;
    }

    public override function create() {
        super.create();
        monthPickerPanel = new MonthPickerPanel();
        monthPicker.addComponent(monthPickerPanel);
    }

    public override function onReady() {
        super.onReady();
    }
}

private class Handler extends ItemPickerHandler {
    public override function onPanelShown() {
        var monthPicker:MonthPicker = cast picker;
        var monthPickerPanel:MonthPickerPanel = cast panel;
        monthPickerPanel.monthPicker = monthPicker;
        monthPickerPanel.selectedYear = monthPicker.selectedYear;
        monthPickerPanel.selectedMonth = monthPicker.selectedMonth;
    }

    public override function onPanelHidden() {
    }

    public override function onPanelSelection(event:UIEvent) {
        var monthPicker:MonthPicker = cast picker;
        var monthPickerPanel:MonthPickerPanel = cast panel;
        monthPicker.selectedYear = monthPickerPanel.selectedYear;
        monthPicker.selectedMonth = monthPickerPanel.selectedMonth;
    }
}

@:xml('
<vbox style="padding: 0px;spacing:0;">
    <hbox width="100%" style="padding:10px;padding-top: 15px;padding-bottom:15px;spacing:10px;">
        <image verticalAlign="center" styleName="month-deinc" />
        <grid id="monthButtons" columns="4" width="100%">
            <button text="{{jan}}" styleName="month-button" width="100%" />
            <button text="{{feb}}" styleName="month-button" width="100%" />
            <button text="{{mar}}" styleName="month-button" width="100%" />
            <button text="{{apr}}" styleName="month-button" width="100%" />
            <button text="{{may}}" styleName="month-button" width="100%" />
            <button text="{{jun}}" styleName="month-button" width="100%" />
            <button text="{{jul}}" styleName="month-button" width="100%" />
            <button text="{{aug}}" styleName="month-button" width="100%" />
            <button text="{{sep}}" styleName="month-button" width="100%" />
            <button text="{{oct}}" styleName="month-button" width="100%" />
            <button text="{{nov}}" styleName="month-button" width="100%" />
            <button text="{{dec}}" styleName="month-button" width="100%" />
        </grid>
        <image verticalAlign="center" styleName="month-inc" />
    </hbox>    
    <label id="yearLabel" width="100%" horizontalAlign="center" style="text-align:center;padding: 5px;" />
</vbox>
')
class MonthPickerPanel extends VBox {
    public var monthPicker:MonthPicker;

    public function new() {
        super();
        for (button in monthButtons.childComponents) {
            button.onClick = onMonthClicked;
        }
    }

    private var _selectedMonth:Null<Int> = null;
    public var selectedMonth(get, set):Null<Int>;
    private function get_selectedMonth():Null<Int> {
        return _selectedMonth;
    }
    private function set_selectedMonth(value:Null<Int>):Null<Int> {
        if (_selectedMonth != value) {
            _selectedMonth = value;
            var index = 0;
            var maxDate = monthPicker.monthStepper.maxDate;
            for (button in monthButtons.childComponents) {
                if (index != _selectedMonth) {
                    button.removeClass("selected");
                } else {
                    button.addClass("selected");
                }

                var disabled = false;
                if (monthPicker.isMonthDisabled != null) {
                    disabled = monthPicker.isMonthDisabled(index, _selectedYear);
                }

                if (maxDate != null) {
                    if (_selectedYear > maxDate.getFullYear()) {
                        disabled = true;
                    } else if (_selectedYear == maxDate.getFullYear() && index > maxDate.getMonth()) {
                        disabled = true;
                    }
                }
        
                button.disabled = disabled;
                index++;
            }
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
            yearLabel.text = "" + _selectedYear;
        }
        return value;
    }
    
    private function onMonthClicked(event:MouseEvent) {
        var index = monthButtons.getComponentIndex(event.target);
        selectedMonth = index;
        var event = new UIEvent(UIEvent.CHANGE);
        dispatch(event);
    }
}