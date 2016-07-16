package haxe.ui.parsers.backends;
import haxe.ui.util.GenericConfig;

class XMLParser extends BackendParser {
	public function new() {
		super();
	}
	
	public override function parse(data:String):Backend {
		var backend:Backend = new Backend();
		
		var xml:Xml = Xml.parse(data).firstElement();
		backend.id = xml.get("id");
		
		for (el in xml.elements()) {
			var nodeName:String = el.nodeName;
			
			if (nodeName == "classes") {
				for (classNode in el.elementsNamed("class")) {
					var classEntry:Backend.BackendClassEntry = new Backend.BackendClassEntry();
					classEntry.source = classNode.get("source");
					classEntry.target = classNode.get("target");
					backend.classEntries.push(classEntry);
				}
			} else {
				parseAddionalConfig(el, backend.config);
			}
		}
		
		return backend;
	}
	
	private function parseAddionalConfig(node:Xml, parent:GenericConfig):Void {
		var group = parent.addSection(node.nodeName);
		for (attr in node.attributes()) {
			group.values.set(attr, node.get(attr));
		}
		for (el in node.elements()) {
			parseAddionalConfig(el, group);
		}
	}
}