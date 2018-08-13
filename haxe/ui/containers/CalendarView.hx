package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.components.Calendar;
import haxe.ui.components.Label;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;

@:composite(Events, Builder)
class CalendarView extends VBox {
    public static var MONTH_NAMES:Array<String> = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(SelectedDateBehaviour)      public var selectedDate:Date;
}

private class SelectedDateBehaviour extends DefaultBehaviour {
    public override function get():Variant {
        return _component.findComponent(Calendar).selectedDate;
    }
    
    public override function set(value:Variant) {
        _component.findComponent(Calendar).selectedDate = value;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
private class Events extends haxe.ui.core.Events {
    public override function register() {
        var button:Button = _target.findComponent("prev-month");
        if (button != null && button.hasEvent(MouseEvent.CLICK) == false) {
            button.registerEvent(MouseEvent.CLICK, onPrevMonth);
        }
        
        var button:Button = _target.findComponent("next-month");
        if (button != null && button.hasEvent(MouseEvent.CLICK) == false) {
            button.registerEvent(MouseEvent.CLICK, onNextMonth);
        }
        
        if (_target.findComponent(Calendar).hasEvent(CalendarEvent.MONTH_CHANGE, onMonthChange) == false) {
            _target.findComponent(Calendar).registerEvent(CalendarEvent.MONTH_CHANGE, onMonthChange);
        }
        
        if (_target.findComponent(Calendar).hasEvent(UIEvent.CHANGE, onCalendarChange) == false) {
            _target.findComponent(Calendar).registerEvent(UIEvent.CHANGE, onCalendarChange);
        }
    }
    
    private function onPrevMonth(event:MouseEvent) {
        _target.findComponent(Calendar).previousMonth();
    }
    
    private function onNextMonth(event:MouseEvent) {
        _target.findComponent(Calendar).nextMonth();
    }
    
    private function onMonthChange(event:CalendarEvent) {
        var calendar:Calendar = _target.findComponent(Calendar);
        var monthName:String = CalendarView.MONTH_NAMES[calendar.date.getMonth()];
        _target.findComponent("current-month", Label).text = monthName + " " + calendar.date.getFullYear();
    }
    
    private function onCalendarChange(event:CalendarEvent) {
        _target.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
private class Builder extends CompositeBuilder {
    private var _calendarView:CalendarView;
    
    public function new(calendarView:CalendarView) {
        super(calendarView);
        _calendarView = calendarView;
    }
    
    public override function create() {
        var hbox = new HBox();
        hbox.percentWidth = 100;
        var button = new Button();
        button.id = "prev-month";
        hbox.addComponent(button);
        
        var label = new Label();
        label.id = "current-month";
        label.text = "August 2018";
        hbox.addComponent(label);
        
        var button = new Button();
        button.id = "next-month";
        hbox.addComponent(button);
        
        _calendarView.addComponent(hbox);
        
        var calendar = new Calendar();
        _calendarView.addComponent(calendar);
    }
}