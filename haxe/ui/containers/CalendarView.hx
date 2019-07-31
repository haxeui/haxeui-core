package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.components.Calendar;
import haxe.ui.components.Label;
import haxe.ui.components.Stepper;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;
import haxe.ui.util.Variant;

@:composite(Events, Builder)
class CalendarView extends VBox {
    public static var MONTH_NAMES:Array<String> = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
	
	public static var DATE_FORMAT:String = "%d/%m/%Y";
    
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
private class Events extends haxe.ui.events.Events {
    public override function register() {
        var button:Button = _target.findComponent("prev-month");
        if (button != null && button.hasEvent(MouseEvent.CLICK) == false) {
            button.registerEvent(MouseEvent.CLICK, onPrevMonth);
        }
        
        var button:Button = _target.findComponent("next-month");
        if (button != null && button.hasEvent(MouseEvent.CLICK) == false) {
            button.registerEvent(MouseEvent.CLICK, onNextMonth);
        }
		
		var stepper:Stepper = _target.findComponent("current-year");
		if (stepper != null && stepper.hasEvent(UIEvent.CHANGE) == false) {
            stepper.registerEvent(UIEvent.CHANGE, onYearChange);
        }
        
        if (_target.findComponent(Calendar).hasEvent(CalendarEvent.DATE_CHANGE, onDateChange) == false) {
            _target.findComponent(Calendar).registerEvent(CalendarEvent.DATE_CHANGE, onDateChange);
        }
        
        if (_target.findComponent(Calendar).hasEvent(UIEvent.CHANGE, onCalendarChange) == false) {
            _target.findComponent(Calendar).registerEvent(UIEvent.CHANGE, onCalendarChange);
        }
        
        registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }
    
    private function onPrevMonth(event:MouseEvent) {
        _target.findComponent(Calendar).previousMonth();
    }
    
    private function onNextMonth(event:MouseEvent) {
        _target.findComponent(Calendar).nextMonth();
    }
	
	private function onYearChange(event:UIEvent) {
		var calendar:Calendar = _target.findComponent(Calendar);
		var stepper:Stepper = _target.findComponent("current-year");
		if (stepper.pos > calendar.date.getFullYear()) {
			calendar.nextYear();
		} else if (stepper.pos < calendar.date.getFullYear()) {
			calendar.previousYear();
		}
    }
    
    private function onDateChange(event:CalendarEvent) {
        var calendar:Calendar = _target.findComponent(Calendar);
        var monthName:String = CalendarView.MONTH_NAMES[calendar.date.getMonth()];
        _target.findComponent("current-month", Label).text = monthName + "  " + calendar.date.getFullYear();
    }
    
    private function onCalendarChange(event:CalendarEvent) {
        _target.dispatch(new UIEvent(UIEvent.CHANGE));
    }
    
    private function onMouseWheel(event:MouseEvent) {
        if (event.delta >= 1) {
            _target.findComponent(Calendar).nextMonth();
        } else {
            _target.findComponent(Calendar).previousMonth();
        }
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
		var box = new Box();
        box.percentWidth = 100;
        var button = new Button();
        button.id = "prev-month";
        box.addComponent(button);

        var hbox = new HBox();
        hbox.horizontalAlign = "center";
        var label = new Label();
        label.id = "current-month";
        var now = Date.now();
        label.text = CalendarView.MONTH_NAMES[now.getMonth()] + "  " + now.getFullYear();
        hbox.addComponent(label);

        var stepper = new Stepper();
        stepper.id = "current-year";
		stepper.min = 1000;
		stepper.max = 2999;
		stepper.pos = 2019;
		stepper.repeater = false;
        hbox.addComponent(stepper);

        box.addComponent(hbox);

        var button = new Button();
        button.id = "next-month";
        button.horizontalAlign = "right";
        box.addComponent(button);

        _calendarView.addComponent(box);

        var calendar = new Calendar();
        _calendarView.addComponent(calendar);
    }
}