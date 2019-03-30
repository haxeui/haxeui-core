package haxe.ui;

import haxe.ui.backend.CallLaterImpl;

class CallLater extends CallLaterImpl {
    public function new(fn:Void->Void) {
        super(fn);
    }
}