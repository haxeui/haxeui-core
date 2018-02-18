package test;

class TestFactory {
    public static function get(id:String, params:Params):Test {
        var t:Test = null;
        
        t = new BuildRun(id);
        
        return t;
    }
}