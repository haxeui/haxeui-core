package haxe.ui.parsers.backends;
import haxe.ui.util.GenericConfig;

class Backend {
    public var id(default, default):String;
    public var classEntries(default, default):Array<BackendClassEntry> = new Array<BackendClassEntry>();
    public var config:GenericConfig = new GenericConfig();

    public function new() {
    }

    public function validate() {
        if (classEntries.length == 0) {
            trace("WARNING: no class entries found in backend config");
        }
    }

    public function toString():String {
        var s:String = "";
        s += 'id: ${id}\n';

        s += 'classes:\n';
        for (classEntry in classEntries) {
            s += '  source: ${classEntry.source}, target: ${classEntry.target}\n';
        }
        return s;
    }

}

class BackendClassEntry {
    public function new() {

    }

    public var target(default, default):String;
    public var source(default, default):String;
}