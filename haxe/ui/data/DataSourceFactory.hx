package haxe.ui.data;

class DataSourceFactory<T> {
    public function new() {
    }

    public function create<T>(type:Class<DataSource<T>>):DataSource<T> {
        var ds:DataSource<T> = Type.createInstance(type, []);
        return ds;
    }

    public function fromString<T>(data:String, type:Class<DataSource<T>>):DataSource<T> {
        var ds = create(type);

        if (StringTools.startsWith(data, "<")) { // xml
            var xml:Xml = Xml.parse(data).firstElement();
            for (el in xml.elements()) {
                var o:Dynamic = { };
                Reflect.setField(o, "id", el.nodeName);
                for (attr in el.attributes()) {
                    Reflect.setField(o, attr, el.get(attr));
                }
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
}