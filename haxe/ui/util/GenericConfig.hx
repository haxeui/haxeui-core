package haxe.ui.util;

class GenericConfig {
    public var values:Map<String, String>;
    public var sections:Map<String, Array<GenericConfig>>;

    public function new() {
        values = new Map<String, String>();
        sections = new Map<String, Array<GenericConfig>>();
    }

    public function addSection(name:String):GenericConfig {
        var config:GenericConfig = new GenericConfig();
        var array:Array<GenericConfig> = sections.get(name);
        if (array == null) {
            array = [];
            sections.set(name, array);
        }
        array.push(config);
        return config;
    }

    public function findBy(section:String, field:String = null, value:String = null):GenericConfig {
        var array:Array<GenericConfig> = sections.get(section);
        if (array == null) {
            return null;
        }

        if (field == null && value == null) {
            return array[0];
        }

        var r = null;
        for (item in array) {
            for (key in item.values.keys()) {
                if (key == field && item.values.get(key) == value) {
                    r = item;
                    break;
                }
            }
            if (r != null) {
                break;
            }
        }
        return r;
    }

    public function queryBool(q:String, defaultValue:Bool = false):Bool {
        var r = query(q, null);
        if (r == null) {
            return defaultValue;
        }
        return (r == "true");
    }

    public function query(q:String, defaultValue:String = null):String {
        var regexp:EReg = new EReg("\\.(?![^\\[]*\\])", "g");
        var final:Array<String> = regexp.split(q);
        var ref:GenericConfig = this;

        var value:String = null;
        for (f in final) {
            if (f.indexOf("[") == -1 && f.indexOf("@") == -1) {
                ref = ref.findBy(f);
            } else if (f.indexOf("[") != -1) {
                var p:Array<String> = f.split("[");
                var p1:String = p[0];
                var p2:String = p[1].split("=")[0];
                var p3:String = p[1].split("=")[1];
                p3 = p3.substr(0, p3.length - 1);

                ref = ref.findBy(p1, p2, p3);
             } else if (f.indexOf("@") != -1) {
                var v = f.substr(1, f.length);
                value = ref.values.get(v);
                break;
             }

            if (ref == null) {
                return defaultValue;
            }
        }

        if (value == null) {
            value = defaultValue;
        }

        return value;
    }

    // TODO: duplication
    public function queryValues(q:String):Map<String, String> {
        var regexp:EReg = new EReg("\\.(?![^\\[]*\\])", "g");
        var final:Array<String> = regexp.split(q);
        var ref:GenericConfig = this;

        for (f in final) {
            if (f.indexOf("[") == -1 && f.indexOf("@") == -1) {
                ref = ref.findBy(f);
            } else if (f.indexOf("[") != -1) {
                var p:Array<String> = f.split("[");
                var p1:String = p[0];
                var p2:String = p[1].split("=")[0];
                var p3:String = p[1].split("=")[1];
                p3 = p3.substr(0, p3.length - 1);

                ref = ref.findBy(p1, p2, p3);
             }

            if (ref == null) {
                return null;
            }
        }

        return ref.values;
    }
}