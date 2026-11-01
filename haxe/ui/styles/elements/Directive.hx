package haxe.ui.styles.elements;

import haxe.ui.styles.Value;

class Directive {
    public var directive(default, set):String = null;
    private function set_directive(value:String):String {
        _id = -2;
        return directive = value;
    }

    /**
        Its number (`DirectiveId`), for a style to switch on rather than compare its name with each one it knows; -1 for
        a name it doesn't know. Worked out from the name once.
    **/
    public var id(get, never):Int;
    private var _id:Int = -2;
    private function get_id():Int {
        if (_id == -2) {
            _id = DirectiveId.of(directive);
        }
        return _id;
    }

    public var value:Value = null;
    public var defective:Bool = false;

    public function new(directive:String, value:Value, defective:Bool = false) {
        this.directive = directive;
        this.value = value;
        this.defective = defective;
    }
}
