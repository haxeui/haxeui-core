package haxe.ui.scripting;

class ConditionEvaluator {
    private static var _parser:hscript.Parser;
    private static var _interp:hscript.Interp;

    public function new() {
    }

    public function evaluate(condition:String):Bool {
        if (_parser == null) {
            _parser = new hscript.Parser();
        }
        if (_interp == null) {
            _interp = new hscript.Interp();
        }

        _interp.variables.set("Backend", Backend);
        _interp.variables.set("backend", Backend.id);

        var program = _parser.parseString(condition);
        var r = _interp.execute(program);

        return r;
    }

}