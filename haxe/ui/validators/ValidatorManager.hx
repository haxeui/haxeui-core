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
    private var _registeredValidators:Map<String, Void->IValidator> = new Map<String, Void->IValidator>();

    private function new() {
    }

    public function registerValidator(id:String, ctor:Void->IValidator) {
        _registeredValidators.set(id, ctor);
    }

    public function createValidator(id:String, config:Dynamic = null):IValidator {
        var ctor = _registeredValidators.get(id);
        if (ctor == null) {
            return null;
        }

        var v = ctor();
        return v;
    }
}