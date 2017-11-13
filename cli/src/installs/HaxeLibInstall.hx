package installs;

class HaxeLibInstall extends Install {
    private var _haxelibs:Array<String>;
    
    public function new(haxelibs:Array<String>) {
        super();
        _haxelibs = haxelibs;
    }
    
    public override function execute(params:Params) {
        for (h in _haxelibs) {
            Util.log('TODO: install haxelibs when ready: ${h}');
        }
    }
}