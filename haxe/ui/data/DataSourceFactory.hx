package haxe.ui.data;

class DataSourceFactory<T> {
    public function new() {
    }

    public function create<T>(type:Class<DataSource<T>>):DataSource<T> {
        #if haxeui_winforms
        var ds = new ArrayDataSource<T>();
        #else
        var ds:DataSource<T> = Type.createInstance(type, []);
        #end
        return ds;
    }

    public function fromString<T>(data:String, type:Class<DataSource<T>>):DataSource<T> {
        var ds = create(type);

        if (StringTools.startsWith(data, "<")) { // xml
            var xml:Xml = Xml.parse(data).firstElement();
            for (el in xml.elements()) {
                var o:Dynamic = xml2Object(el);
                ds.add(o);
            }
        } else if (StringTools.startsWith(data, "[")) { // json array
            var json:Array<Dynamic> = Json.parse(StringTools.replace(data, "'", "\""));
            for (o in json) {
                ds.add(o);
            }
        }

        return ds;
    }
	
	private function xml2Object(el:Xml, addId:Bool = true):Dynamic {
		var o = {};
		
		if (addId == true) {
			Reflect.setField(o, "id", el.nodeName);
		}
		
		for (attr in el.attributes()) {
			Reflect.setField(o, attr, el.get(attr));
		}
		
		for (childEl in el.elements()) {
			var childObject = xml2Object(childEl, false);
			Reflect.setField(o, childEl.nodeName, childObject);
		}
		
		return o;
	}
}