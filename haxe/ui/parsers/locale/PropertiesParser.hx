package haxe.ui.parsers.locale;

using StringTools;

class PropertiesParser extends LocaleParser {
    public function new() {
        super();
    }

    public override function parse(data:String):Map<String, String> {
        var result:Map<String, String> = new Map<String, String>();
        var lines = data.split("\n");
        for (line in lines) {
            line = line.trim();
            if (line.length == 0 || line.startsWith("#")) {
                continue;
            }

            var separator:Int = line.indexOf("=");
            if (separator == -1) {
                throw 'Locale parser: Invalid line ${line}';
            }

            var key = line.substr(0, separator).trim();
            var content = line.substr(separator + 1).trim();
            result.set(key, content);
        }

        return result;
    }
}
