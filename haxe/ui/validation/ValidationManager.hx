package haxe.ui.validation;

import haxe.ui.core.ValidationEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.util.EventMap;
import haxe.ui.util.Timer;

class ValidationManager {
    static public var instance(get, null):ValidationManager;
    static public function get_instance():ValidationManager {
        if(instance == null) {
            instance = new ValidationManager();
        }
        return instance;
    }

    public var isValidating(default, null):Bool;

    private var _queue:Array<IValidating> = [];
    private var _timer:Timer;
    private var _events:EventMap;

    private function new() {
        isValidating = false;
    }

    public function registerEvent(type:String, listener:Dynamic->Void) {
        if (_events == null) {
            _events = new EventMap();
        }

        _events.add(type, listener);
    }

    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (_events == null) {
            _events.remove(type, listener);
        }
    }

    private function dispatch(event:UIEvent) {
        if (_events != null) {
            _events.invoke(event.type, event);
        }
    }

    public function dispose():Void {
        disposeTimer();
        isValidating = false;
        _queue.splice(0, _queue.length);
    }

    public function add(object:IValidating):Void {
        if (_queue.indexOf(object) != -1) {
            return;
        }

        var queueLength:Int = _queue.length;
        if (isValidating == true) {
            //skip queueSortFunction overhead. the queue is already ordered. insertion with binary search
            var depth:Int = object.depth;
            var min:Int = 0;
            var max:Int = queueLength;
            var i:Int = 0;
            while (max > min) {
                i = (min + max) >>> 1;  // division 2 with unsigned int. avoid Std.int cast
                var otherDepth:Int = _queue[i].depth;
                if (otherDepth == depth) {
                    break;
                } else if (otherDepth < depth) {
                    max = i;        //Down to top
                    //min = i + 1;  //Top to down
                } else {
                    min = i + 1;    //Down to top
                    //max = i;      //Top to down
                }
            }

            this._queue.insert(i, object);
        } else {
            this._queue[queueLength] = object;

            if (_timer == null) {
                _timer = new Timer(0, process);
            }
        }
    }

    private function process():Void {
        if (isValidating == true || _timer == null) {
            return;
        }

        disposeTimer();

        var queueLength:Int = _queue.length;
        if (queueLength == 0) {
            return;
        }

        isValidating = true;
        if (queueLength > 1) {
            _queue.sort(queueSortFunction);
        }

        dispatch(new ValidationEvent(ValidationEvent.START));

        //check length every time because add() might have added a new item during the last validation
        while (_queue.length > 0) {
            var item:IValidating = _queue.shift();
            if(item.depth < 0) {
                continue;   //no longer on the display list
            }
            item.validate();
        }

        isValidating = false;

        dispatch(new ValidationEvent(ValidationEvent.STOP));
    }

    private function queueSortFunction(first:IValidating, second:IValidating):Int {
        var difference:Int = second.depth - first.depth;
        //Down to top
        return if (difference > 0)           1;
                else if (difference < 0)     -1;
                else                         0;

        //Top to down
//        return if(difference > 0)           -1;
//        else if(difference < 0)     1;
//        else                        0;
    }

    private function disposeTimer():Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }
}
