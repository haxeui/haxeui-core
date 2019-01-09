package haxe.ui.components;

import haxe.ui.containers.Grid;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.Events;
import haxe.ui.util.Variant;

class CalendarEvent extends UIEvent {
    public static inline var DATE_CHANGE:String = "datechange";
}

@:composite(Events, Builder)
class Calendar extends Grid {
    public function new() {
        super();
        columns = 7; // TODO: this is really strange, cant set it in the builder, its like the parent constructor is never called
        behaviours.register("previousMonth", PreviousMonthBehaviour);
        behaviours.register("nextMonth", NextMonthBehaviour);
		behaviours.register("previousYear", PreviousYearBehaviour);
        behaviours.register("nextYear", NextYearBehaviour);
    }
    
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(DateBehaviour)                  public var date:Date;
    @:clonable @:behaviour(SelectedDateBehaviour)          public var selectedDate:Date;
    
    public function previousMonth() { // TODO: work out a way to use meta data with callable behaviours
        behaviours.call("previousMonth");
    }
    
    public function nextMonth() { // TODO: work out a way to use meta data with callable behaviours
        behaviours.call("nextMonth");
    }
	
	public function previousYear() { // TODO: work out a way to use meta data with callable behaviours
        behaviours.call("previousYear");
    }
    
    public function nextYear() { // TODO: work out a way to use meta data with callable behaviours
        behaviours.call("nextYear");
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
private class PreviousMonthBehaviour extends Behaviour {
    public override function call(param:Any = null):Variant {
        var calendar = cast(_component, Calendar);
        calendar.date = DateUtils.previousMonth(calendar.date);
        return null;
    }
}

private class NextMonthBehaviour extends Behaviour {
    public override function call(param:Any = null):Variant {
        var calendar = cast(_component, Calendar);
        calendar.date = DateUtils.nextMonth(calendar.date);
        return null;
    }
}

private class PreviousYearBehaviour extends Behaviour {
    public override function call(param:Any = null):Variant {
        var calendar = cast(_component, Calendar);
        calendar.date = DateUtils.previousYear(calendar.date);
        return null;
    }
}

private class NextYearBehaviour extends Behaviour {
    public override function call(param:Any = null):Variant {
        var calendar = cast(_component, Calendar);
        calendar.date = DateUtils.nextYear(calendar.date);
        return null;
    }
}

private class SelectedDateBehaviour extends DefaultBehaviour {
    public override function set(value:Variant) {
        super.set(value);
        
        var date:Date = value;
        _component.invalidateComponentData();
        
        var calendar = cast(_component, Calendar);
        calendar.date = calendar.date; // TODO: this is wrong, works, but its wrong... need to split up the code into util classes, one to build the month, another to select it
        
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

@:access(haxe.ui.core.Component)
private class DateBehaviour extends DataBehaviour {
    private override function validateData() {
        var date:Date = _value;
        
        var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        
        var startDay:Int = new Date(year, month, 1, 0, 0, 0).getDay();
        var endDay:Int = DateUtils.getEndDay(month, year);
        
        for (child in _component.childComponents) {
            child.opacity = .3;
            child.removeClass("calendar-off-day");
            child.removeClass("calendar-day");
            child.removeClass("calendar-day-selected");
            child.removeClass(":hover"); // bit of a hack, kinda, when use in a dropdown, it never gets the mouseout as the calendar is removed
        }
        
        var prevMonth = DateUtils.previousMonth(date);
        var last = DateUtils.getEndDay(prevMonth.getMonth(), prevMonth.getFullYear());
        
        var n = (startDay - 1);
        for (i in 0...(startDay)) {
            var item = _component.childComponents[n];
            item.addClass("calendar-off-day");
            n--;
            item.text = "" + last;
            last--;
        }
        
        var selectedDate:Date = cast(_component, Calendar).selectedDate;
        if (selectedDate == null) {
            selectedDate = Date.now();
        }
        for (i in 0...endDay) {
            var item = _component.childComponents[i + startDay];
            item.addClass("calendar-day");
            item.opacity = 1;
            item.hidden = false;
            item.text = "" + (i + 1);
            if (i + 1 == selectedDate.getDate() && month == selectedDate.getMonth() && year == selectedDate.getFullYear()) {
                item.addClass("calendar-day-selected");
            }
            
            last = i + startDay;
        }
        
        last++;
        var n:Int = 0;
        for (i in last..._component.childComponents.length) {
            var item = _component.childComponents[i];
            item.addClass("calendar-off-day");
            item.text = "" + (n + 1);
            n++;
        }
        
        _component.registerInternalEvents(true);
        
        _component.dispatch(new CalendarEvent(CalendarEvent.DATE_CHANGE));
    }
}

//***********************************************************************************************************
// Utils
//***********************************************************************************************************
private class DateUtils {
    public static function getEndDay(month:Int, year:Int):Int {
        var endDay:Int = -1;
        switch (month) {
            case 1: // feb
                if ((year % 400 == 0) ||  ((year % 100 != 0) && (year % 4 == 0))) {
                    endDay = 29;
                } else {
                    endDay = 28;
                }
            case 3, 5, 8, 10: // april, june, sept, nov.
                endDay = 30;
            default:
                endDay = 31;
                    
        }
        return endDay;
    }
    
    public static function previousMonth(date:Date):Date {
        var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        
		month--;
		if (month < 0) {
			month = 11;
			year--;
		}
		day = cast(Math.min(day, getEndDay(month, year)), Int);
		date = new Date(year, month, day, 0, 0, 0);
        return date;
    }
    
    public static function nextMonth(date:Date):Date {
        var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        
		month++;
		if (month > 11) {
			month = 0;
			year++;
		}
		day = cast(Math.min(day, getEndDay(month, year)), Int);
		date = new Date(year, month, day, 0, 0, 0);
        return date;
    }
	
	public static function previousYear(date:Date):Date {
		var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        
		year--;
		day = cast(Math.min(day, getEndDay(month, year)), Int);
		date = new Date(year, month, day, 0, 0, 0);
        return date;
	}
	
	public static function nextYear(date:Date):Date {
		var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        
		year++;
		day = cast(Math.min(day, getEndDay(month, year)), Int);
		date = new Date(year, month, day, 0, 0, 0);
        return date;
	}
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
private class Events extends haxe.ui.events.Events {
    public override function register() {
        unregister();
        for (child in _target.childComponents) {
            if (child.hasEvent(MouseEvent.CLICK, onDayClicked) == false && child.hasClass("calendar-day")) {
                child.registerEvent(MouseEvent.CLICK, onDayClicked);
            }
        }
    }
    
    public override function unregister() {
        for (child in _target.childComponents) {
            child.unregisterEvent(MouseEvent.CLICK, onDayClicked);
        }
    }
    
    private function onDayClicked(event:MouseEvent) {
        var calendar:Calendar = cast(_target, Calendar);
        var day:Int = Std.parseInt(event.target.text);
        var month = calendar.date.getMonth();
        var year = calendar.date.getFullYear();
        calendar.selectedDate = new Date(year, month, day, 0, 0, 0);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
private class Builder extends CompositeBuilder {
    private var _calendar:Calendar;
    
    public function new(calendar:Calendar) {
        super(calendar);
        _calendar = calendar;
    }
    
    public override function create() {
        for (i in 0...6) {
            for (j in 0...7) {
                var item = new Button();
                item.width = 25;
                item.height = 25;
                _calendar.addComponent(item);
            }
        }
        
        _calendar.syncComponentValidation();
        //_calendar.columns = 7; // this is really strange, this does work here!
        _calendar.date = Date.now();
    }
}