package haxe.ui.macros;

class Backend2 {
    public var id(default, default):String;
    public var classEntries(default, default):Array<BackendClassEntry>;

    public function new() {
        classEntries = [];
    }

    public function fromXML(xml:Xml) {
        id = xml.get("id");

        for (el in xml.elements()) {
            var nodeName:String = el.nodeName;

            if (nodeName == "classes") {
                for (classNode in el.elementsNamed("class")) {
                    var classEntry:BackendClassEntry = new BackendClassEntry();
                    classEntry.source = classNode.get("source");
                    classEntry.target = classNode.get("target");
                    classEntries.push(classEntry);
                }
            }
        }
    }
}

class BackendClassEntry {
    public function new() {

    }

    public var target(default, default):String;
    public var source(default, default):String;
}