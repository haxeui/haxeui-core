package haxe.ui.containers.dialogs;

import haxe.ui.backend.DialogBase;
import haxe.ui.events.UIEvent;

abstract DialogButton(String) from String {
    public static inline var SAVE:DialogButton = "{{dialog.save}}";
    public static inline var YES:DialogButton = "{{dialog.yes}}";
    public static inline var NO:DialogButton = "{{dialog.no}}";
    public static inline var CLOSE:DialogButton = "{{dialog.close}}";
    public static inline var OK:DialogButton = "{{dialog.ok}}";
    public static inline var CANCEL:DialogButton = "{{dialog.cancel}}";
    public static inline var APPLY:DialogButton = "{{dialog.apply}}";

    @:op(A | B)
    private static inline function bitOr(lhs:DialogButton, rhs:DialogButton):DialogButton {
        var larr = Std.string(lhs).split("|");
        var rarr = Std.string(rhs).split("|");
        for (r in rarr) {
            if (larr.indexOf(r) == -1) {
                larr.push(r);
            }
        }
        return larr.join("|");
    }

    @:op(A == B)
    private static inline function eq(lhs:DialogButton, rhs:DialogButton):Bool {
        var larr = Std.string(lhs).split("|");
        return larr.indexOf(Std.string(rhs)) != -1;
    }

    public function toArray():Array<DialogButton> {
        var a = [];
        for (i in Std.string(this).split("|")) {
            i = StringTools.trim(i);
            if (i.length == 0 || i == "null") {
                continue;
            }
            a.push(i);
        }
        return a;
    }

    public function toString():String {
        return Std.string(this);
    }
}

class DialogEvent extends UIEvent {
    public static inline var DIALOG_CLOSED:String = "dialogClosed";

    public var button:DialogButton;

    public override function clone():DialogEvent {
        var c:DialogEvent = new DialogEvent(this.type);
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        c.button = this.button;
        postClone(c);
        return c;
    }
}

class Dialog extends DialogBase {
    public function new() {
        super();
    }

    private var __onDialogClosed:DialogEvent->Void;
    public var onDialogClosed(null, set):DialogEvent->Void;
    private function set_onDialogClosed(value:DialogEvent->Void):DialogEvent->Void {
        if (__onDialogClosed != null) {
            unregisterEvent(DialogEvent.DIALOG_CLOSED, __onClick);
            __onDialogClosed = null;
        }
        registerEvent(DialogEvent.DIALOG_CLOSED, value);
        __onDialogClosed = value;
        return value;
    }
}