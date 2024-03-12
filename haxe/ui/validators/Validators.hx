package haxe.ui.validators;

import haxe.ui.core.Component;

@:forward
@:forward.new
abstract Validators(ValidatorsImpl) from ValidatorsImpl {
	@:arrayAccess
	public inline function get(index:Int) {
		return this.list[index];
	}

	@:from
	static function fromArray(list:Array<IValidator>):Validators {
		var ret = new ValidatorsImpl();
		ret.list = list;
		return ret;
	}
}

private class ValidatorsImpl {
	public var list:Array<IValidator> = [];

	public function new() {
    }

    public var length(get, null):Int;
    private function get_length():Int {
        if (list == null) {
            return 0;
        }
        return list.length;
    }

    public function setup(component:Component) {
        for (item in list) {
            if (item == null) {
                continue;
            }
            item.setup(component);
        }
    }

    private var _isValid:Bool = true;
    public var isValid(get, null):Bool;
    private function get_isValid():Bool {
        return _isValid;
    }

    public function validate(component:Component) {
        _isValid = true;
        for (item in list) {
            if (item == null) {
                continue;
            }
            var r = item.validate(component);
            if (r != null && r == false) {
                _isValid = false;
            }
        }
    }

    public function iterator() {
        return new ValidatorsIterator(list);
    }
}

private class ValidatorsIterator {
    private var i:Int;
    private var list:Array<IValidator>;
    
    public function new(list:Array<IValidator>) {
        this.list = list;
        this.i = 0;
    }

    public function hasNext() {
        if (list == null) {
            return false;
        }
        return i < list.length;
    }

    public function next() {
        return list[i++];
    }
}