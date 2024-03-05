package haxe.ui.validation;

import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;
import haxe.ui.events.ValidationEvent;
import haxe.ui.util.EventMap;

class ValidationManager {
    static public var instance(get, null):ValidationManager;
    static private function get_instance():ValidationManager {
        if (instance == null) {
            instance = new ValidationManager();
        }
        return instance;
    }

    public var isValidating(default, null):Bool;
    public var isPending(default, null):Bool;

    private var _queue:Array<IValidating> = [];
    private var _displayQueue:Array<Component> = [];
    private var _events:EventMap;

    private function new() {
        isValidating = false;
        isPending = false;
    }

    public function registerEvent(type:String, listener:Dynamic->Void) {
        if (_events == null) {
            _events = new EventMap();
        }

        _events.add(type, listener);
    }

    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (_events != null) {
            _events.remove(type, listener);
        }
    }

    private function dispatch(event:UIEvent) {
        if (_events != null) {
            _events.invoke(event.type, event);
        }
    }

    public function dispose() {
        isValidating = false;
        _queue.splice(0, _queue.length);
    }

    public function add(object:IValidating) {
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
            var otherDepth:Int = 0;
            while (max > min) {
                i = (min + max) >>> 1;  // division 2 with unsigned int. avoid Std.int cast
                otherDepth = _queue[i].depth;
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

            if (otherDepth >= depth) {
                i += 1;
            }

            this._queue.insert(i, object);
        } else {
            this._queue[queueLength] = object;
            if (isPending == false) {
                isPending = true;
                Toolkit.callLater(process);
            }
        }
    }

    public function addDisplay(item:Component, nextFrame:Bool = true) {
        if (_displayQueue.indexOf(item) == -1) {
            _displayQueue.push(item);
        }
        if (nextFrame == false) {
            process();
        }
    }

    #if profile_validation
    private var _profileCount:Int = 0;
    private var _profileMin:Float = 0xffffff;
    private var _profileMax:Float = 0;
    private var _profileAvg:Float = 0;
    private var _profileTot:Float = 0;
    #end
    
    public function process() {
        if (isValidating == true || isPending == false) {
            return;
        }

        var queueLength:Int = _queue.length;
        if (queueLength == 0) {
            isPending = false;
            return;
        }

        #if profile_validation
        var start = haxe.ui.core.Platform.instance.perf();
        #end
        
        isValidating = true;
        if (queueLength > 1) {
            _queue.sort(queueSortFunction);
        }

        dispatch(new ValidationEvent(ValidationEvent.START));

        //check length every time because add() might have added a new item during the last validation
        while (_queue.length > 0) {
            var item:IValidating = _queue.shift();
            if (item.depth < 0) {
                continue;   //no longer on the display list
            }
            item.validateComponent();
        }

        for (i in 0..._displayQueue.length) {
            var item = _displayQueue[i];
            item.updateComponentDisplay();
        }
        _displayQueue.splice(0, _displayQueue.length);

        isValidating = false;
        
        if (_queue.length > 0) { // lets process any stragglers - items maybe have been added while processing other parts
            isPending = true;
            Toolkit.callLater(process);
        } else {
            isPending = false;
        }
        

        #if profile_validation
        _profileCount++;
        
        var end = haxe.ui.core.Platform.instance.perf();
        var delta = end - start;
        
        if (delta < _profileMin) {
            _profileMin = delta;
        }
        if (delta > _profileMax) {
            _profileMax = delta;
        }
        _profileTot += delta;
        _profileAvg = _profileTot / _profileCount;
        
        trace("InvalidationManager.process: current=" + haxe.ui.util.MathUtil.round(delta, 2) + "ms, avg=" + haxe.ui.util.MathUtil.round(_profileAvg, 2) + "ms, count=" + _profileCount + ", min=" + haxe.ui.util.MathUtil.round(_profileMin, 2) + "ms, max=" + haxe.ui.util.MathUtil.round(_profileMax, 2) + "ms, tot=" + haxe.ui.util.MathUtil.round(_profileTot, 2) + "ms");
        #end
        
        dispatch(new ValidationEvent(ValidationEvent.STOP));
        
    }

    private inline function queueSortFunction(first:IValidating, second:IValidating):Int {
        var difference:Int = second.depth - first.depth;
        //Down to top
        return if (difference > 0) 1; else if (difference < 0) -1; else 0;

        //Top to down
//        return if(difference > 0)           -1;
//        else if(difference < 0)     1;
//        else                        0;
    }
}
