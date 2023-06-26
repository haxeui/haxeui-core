package haxe.ui.filters;

class Filter {
    public function new() {
    }

    public function parse(filterDetails:Array<Any>) {
        trace("WARNING: css filter '" + Type.getClassName(Type.getClass(this)) + "' has not implemented parse function");
    }

    private static function applyDefaults(params:Array<Any>, defaults:Array<Any>):Array<Any> {
        var copy:Array<Any> = [];

        if (defaults != null) {
            for (p in defaults) {
                copy.push(p);
            }
        }
        if (params != null) {
            var n:Int = 0;
            for (p in params) {
                copy[n] = p;
                n++;
            }
        }

        return copy;
    }
}