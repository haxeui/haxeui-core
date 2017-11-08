package updates;

class HaxeLibUpdate extends Update {
    private var _haxelibs:Array<String>;
    
    public function new(haxelibs:Array<String>) {
        super();
        _haxelibs = haxelibs;
    }
    
    public override function execute(params:Params) {
        for (h in _haxelibs) {
            Util.log('TODO: update haxelibs when ready: ${h}');
        }
    }
}