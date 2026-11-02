package haxe.ui.validation;

/**
    The invalidation flags a component (or its text or image display) has set. The flags `InvalidationFlags` names are
    bits of an Int, so setting, checking and clearing them allocates nothing; a flag of another name goes in a map, made
    when the first one is set. A map of every flag allocated as each was set and as it was walked to see whether any
    was, which was over a third of what a scrolling page allocated in each frame.
**/
@:noCompletion
class InvalidationSet {
    private static inline var ALL_BIT:Int = 1;

    private var _bits:Int = 0;
    private var _others:Map<String, Bool> = null;
    private var _otherCount:Int = 0;

    public function new() {
    }

    /** The flag's bit, or 0 for a name `InvalidationFlags` doesn't have. **/
    private static function bitOf(flag:String):Int {
        return switch (flag) {
            case InvalidationFlags.ALL: ALL_BIT;
            case InvalidationFlags.DATA: 1 << 1;
            case InvalidationFlags.DISPLAY: 1 << 2;
            case InvalidationFlags.IMAGE_DISPLAY: 1 << 3;
            case InvalidationFlags.INDEX: 1 << 4;
            case InvalidationFlags.LAYOUT: 1 << 5;
            case InvalidationFlags.MEASURE: 1 << 6;
            case InvalidationFlags.POSITION: 1 << 7;
            case InvalidationFlags.SCROLL: 1 << 8;
            case InvalidationFlags.STYLE: 1 << 9;
            case InvalidationFlags.TEXT_DISPLAY: 1 << 10;
            case InvalidationFlags.TEXT_INPUT: 1 << 11;
            default: 0;
        }
    }

    public inline function isEmpty():Bool {
        return _bits == 0 && _otherCount == 0;
    }

    public function exists(flag:String):Bool {
        var bit = bitOf(flag);
        if (bit != 0) {
            return (_bits & bit) != 0;
        }
        return _otherCount > 0 && _others.exists(flag);
    }

    public function set(flag:String) {
        var bit = bitOf(flag);
        if (bit != 0) {
            _bits |= bit;
            return;
        }
        if (_others == null) {
            _others = new Map<String, Bool>();
        }
        if (!_others.exists(flag)) {
            _others.set(flag, true);
            _otherCount++;
        }
    }

    public function clear() {
        _bits = 0;
        if (_otherCount > 0) {
            _others.clear();
            _otherCount = 0;
        }
    }

    /** Sets every flag of this set in `into`, but `InvalidationFlags.ALL`, which a component keeps apart. **/
    public function addTo(into:InvalidationSet) {
        into._bits |= _bits & ~ALL_BIT;
        if (_otherCount > 0) {
            for (flag in _others.keys()) {
                into.set(flag);
            }
        }
    }
}
