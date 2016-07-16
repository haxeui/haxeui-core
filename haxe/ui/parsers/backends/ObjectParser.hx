package haxe.ui.parsers.backends;

class ObjectParser extends BackendParser {
    private function fromObject(obj:Dynamic):Backend {
        var backend:Backend = new Backend();
        backend.id = obj.id;

        if (obj.classes != null) {
            var classes:Array<Dynamic> = obj.classes;
            for (c in classes) {
                var classEntry:Backend.BackendClassEntry = new Backend.BackendClassEntry();
                classEntry.source = c.source;
                classEntry.target = c.target;
                backend.classEntries.push(classEntry);
            }
        }

        return backend;
    }
}