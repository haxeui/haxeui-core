package haxe.ui.parsers.locale;

using StringTools;

class PoParser extends LocaleParser {
    public function new() {
        super();
    }

    public override function parse(data:String):Map<String, String> {
        var msgidEReg = ~/msgid *= *"(.*)"/;
        var msgstrEReg = ~/msgstr *= *"(.*)"/;
        var result:Map<String, String> = new Map<String, String>();
        var lines = data.split("\n");
        var currentID:String = null;
        for (line in lines) {
            line = line.trim();
            if (line.length == 0 || line.startsWith("#")) {
                continue;
            }

            if (currentID == null) {
                if (msgidEReg.match(line)) {
                    currentID = msgidEReg.matched(1);
                } else {
                    throw 'Locale parser: Invalid line ${line}';
                }
            } else {
                if (msgstrEReg.match(line)) {
                    result.set(currentID, msgstrEReg.matched(1));

                    currentID = null;
                } else {
                    throw 'Locale parser: Invalid line ${line}';
                }
            }
        }

        return result;
    }
}
