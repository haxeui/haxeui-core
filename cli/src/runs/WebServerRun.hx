package runs;

class WebServerRun extends Run {
    private var _directory:String;
    private var _address:String;
    public function new(directory:String, address:String = "http://localhost:2000") {
        super();
        _directory = directory;
        _address = address;
    }
    
    public override function execute(params:Params) {
        var browser = new ProcessRun(["start", "chrome", _address]);
        browser.execute(params);
        
        var server = new ProcessRun(["nekotools", "server", "-d", _directory]);
        server.execute(params);
    }
}