package haxe.ui.util;

@:forward(callback, priority)
abstract Listener<T>(ListenerInternal<T>) {
    public inline function new(callback:T, priority:Int){
        this = new ListenerInternal(callback, priority);
    }

    @:op(A == B)
    public static function compareListener<T>(a:Listener<T>, b:Listener<T>):Bool {
        return a.callback == b.callback;
    }

    @:op(A == B)
    @:commutative
    public static function compareFunction<T>(a:Listener<T>, b:T):Bool {
        return a.callback == b;
    }

    @:to
    public function toFunc():T {
        return this.callback;
    }
}

private class ListenerInternal<T> {
    public var callback(default, null):T;
    public var priority(default, null):Int;

    public function new (callback:T, priority:Int) {
        this.callback = callback;
        this.priority = priority;
    }
}