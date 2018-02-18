package descriptors;
import sys.FileSystem;

class NMEProjectNmml extends OpenFlApplicationXml {
    public function new() {
        super();
    }
    
    public override function find(path:String):Bool {
        var contents = FileSystem.readDirectory(path);
        for (c in contents) {
            if (FileSystem.isDirectory(path + "/" + c) == false && (c == "application.nmml" || c == "project.nmml")) {
                load(path + "/" + c);
                return true;
            }
        }
        return false;
    }
}