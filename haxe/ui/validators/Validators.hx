package haxe.ui.validators;

import haxe.ui.core.Component;

@:forward
@:forward.new
@:access(haxe.ui.validators.ValidatorsImpl)
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
	private var list:Array<IValidator> = [];
    private var component:Component;

	public function new(component:Component = null) {
        this.component = component;
    }

    public var length(get, null):Int;
    private function get_length():Int {
        if (list == null) {
            return 0;
        }
        return list.length;
    }

    private function setup() {
        for (item in list) {
            if (item == null) {
                continue;
            }
            item.setup(component);
        }
    }

    private var _areValid:Bool = true;
    public var areValid(get, null):Bool;
    private function get_areValid():Bool {
        return _areValid;
    }

    public function validate():Bool {
        _areValid = true;
        for (item in list) {
            if (item == null) {
                continue;
            }
            var r = item.validate(component);
            if (r != null && r == false) {
                _areValid = false;
            }
        }
        return _areValid;
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