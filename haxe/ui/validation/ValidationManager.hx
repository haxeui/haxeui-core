package haxe.ui.validation;

import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;
import haxe.ui.events.ValidationEvent;
import haxe.ui.util.EventMap;

@:access(haxe.ui.backend.ComponentBase)
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
    // What's in each queue is marked on the items (`IValidating.validationQueued`, `Component._displayQueued`), so
    // adding doesn't search it: on hxcpp, indexOf on these arrays compares every element dynamically, which was the
    // biggest single cost in a large screen's first layout; and maps of them allocated as items came and went.
    // `process` as a function made once, for queuing it each time.
    private var _processFn:Void->Void = null;
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

    // The event is made only when something listens: nothing does, as a rule, and process runs every frame.
    private function dispatch(type:String) {
        if (_events != null) {
            _events.invoke(type, new ValidationEvent(type));
        }
    }

    public function dispose() {
        isValidating = false;
        for (item in _queue) {
            item.validationQueued = false;
        }
        _queue.splice(0, _queue.length);
    }

    public function add(object:IValidating) {
        if (object.validationQueued) {
            return;
        }
        object.validationQueued = true;

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
                if (_processFn == null) {
                    _processFn = process;
                }
                Toolkit.callLater(_processFn);
            }
        }
    }

    public function addDisplay(item:Component, nextFrame:Bool = true) {
        if (!item._displayQueued) {
            item._displayQueued = true;
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

        dispatch(ValidationEvent.START);

        //check length every time because add() might have added a new item during the last validation
        while (_queue.length > 0) {
            var item:IValidating = _queue.shift();
            item.validationQueued = false;
            if (item.depth < 0) {
                continue;   //no longer on the display list
            }
            _passValidations++;
            if (_passValidations > COUNT_AFTER && countValidation(item) > MAX_VALIDATIONS_PER_PASS) {
                abandonValidation(item);
                continue;
            }
            item.validateComponent();
        }
        if (_passValidations > COUNT_AFTER) {
            _passCounts.clear();
        }
        _passValidations = 0;

        for (i in 0..._displayQueue.length) {
            var item = _displayQueue[i];
            item.updateComponentDisplay();
        }
        // Marked until the pass ends, as a map of them was: one queued again while its display updates stays once.
        for (item in _displayQueue) {
            item._displayQueued = false;
        }
        _displayQueue.splice(0, _displayQueue.length);

        isValidating = false;
        
        if (_queue.length > 0) { // lets process any stragglers - items maybe have been added while processing other parts
            isPending = true;
            if (_processFn == null) {
                _processFn = process;
            }
            Toolkit.callLater(_processFn);
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
        
        dispatch(ValidationEvent.STOP);
        
    }

    // A normal pass validates a component fewer than 20 times (a 200-item list peaks at 11), so more than this
    // means components keep invalidating each other and the pass would never end.
    private static inline var MAX_VALIDATIONS_PER_PASS:Int = 100;
    // Each component's validations are counted only once a pass has made this many, so the passes of a scroll or an
    // animation, a few components each frame, don't allocate the counts: a loop is still caught, a little later.
    private static inline var COUNT_AFTER:Int = 1000;
    private var _passValidations:Int = 0;
    private var _passCounts:haxe.ds.ObjectMap<IValidating, Int> = new haxe.ds.ObjectMap();
    private var _reportedLoops:Map<String, Bool> = new Map();

    private function countValidation(item:IValidating):Int {
        var count = _passCounts.get(item);
        count = (count == null) ? 1 : count + 1;
        _passCounts.set(item, count);
        return count;
    }

    // Drops only the looping component's pending work, so the rest of the pass still finishes. Clearing its flags
    // lets its next invalidation queue it again; a component left marked invalid would never be validated again.
    private function abandonValidation(item:IValidating) {
        if (!(item is Component)) {
            return;
        }
        var component:Component = cast item;
        var name = Type.getClassName(Type.getClass(component)) + "#" + component.id;
        if (!_reportedLoops.exists(name)) {
            _reportedLoops.set(name, true);
            trace('Validation loop: $name was validated more than $MAX_VALIDATIONS_PER_PASS times in one pass, so its layout was left as it was. Something keeps invalidating it, often the layout or resize handler of another component.');
        }
        component._invalidationFlags.clear();
        component._delayedInvalidationFlags.clear();
        component._isAllInvalid = false;
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
