package haxe.ui;

import haxe.ui.backend.CallLaterBase;

class CallLater extends CallLaterBase {
    public function new(fn:Void->Void) {
        super(fn);
    }
}