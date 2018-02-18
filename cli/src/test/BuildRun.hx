package test;
import builds.BuildFactory;
import runs.RunFactory;

class BuildRun extends Test {
    private var _id:String;
    
    public function new(id:String) {
        super();
        _id = id;
    }

    public override function execute(params:Params) {
        var build = BuildFactory.get(_id);
        build.execute(params);
        
        var run = RunFactory.get(_id, params);
        run.execute(params);
    }
}
