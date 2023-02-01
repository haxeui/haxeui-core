package haxe.ui.validators;

class ValidatorManager {
    public static var instance(get, null):ValidatorManager;
    private static function get_instance():ValidatorManager {
        if (instance == null) {
            instance = new ValidatorManager();
        }
        return instance;
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    private var _registeredValidators:Map<String, ValidatorItem> = new Map<String, ValidatorItem>();

    private function new() {
    }

    public function registerValidator(id:String, ctor:Void->IValidator, defaultProperties:Map<String, Any> = null) {
        _registeredValidators.set(id, {
            ctor: ctor,
            defaultProperties: defaultProperties
        });
    }

    public function createValidator(id:String, config:Dynamic = null):IValidator {
        var item = _registeredValidators.get(id);
        if (item == null) {
            return null;
        }

        var v = item.ctor();
        if (item.defaultProperties != null) {
            for (k in item.defaultProperties.keys()) {
                v.setProperty(k, item.defaultProperties.get(k));
            }
        }
        return v;
    }
}

private typedef ValidatorItem = {
    var ctor:Void->IValidator;
    @:optional var defaultProperties:Map<String, Any>;
}