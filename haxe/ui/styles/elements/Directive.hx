package haxe.ui.styles.elements;

import haxe.ui.styles.Value;

class Directive {
    public var directive:String = null;
    public var value:Value = null;
    public var defective:Bool = false;

    public function new(directive:String, value:Value, defective:Bool = false) {
        this.directive = directive;
        this.value = value;
        this.defective = defective;
    }
}
