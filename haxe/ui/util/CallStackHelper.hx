package haxe.ui.util;

import haxe.CallStack;

class CallStackHelper {
    public static function traceCallStack() {
        var arr:Array<haxe.StackItem> = CallStack.callStack();
        if (arr == null) {
            trace("Callstack is null!");
            return;
        }
        trace(CallStack.toString(arr));
        trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>> END >>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }

    public static function traceExceptionStack() {
        var arr:Array<haxe.StackItem> = CallStack.exceptionStack();
        if (arr == null) {
            trace("Callstack is null!");
            return;
        }
        trace(CallStack.toString(arr));
        trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>> END >>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }

    public static function getCallStackString():String {
        var arr:Array<haxe.StackItem> = CallStack.callStack();
        if (arr == null) {
            throw "Callstack is null!";
        }
        return CallStack.toString(arr);
    }
}