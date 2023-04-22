package haxe.ui.parsers.locale;

using StringTools;

class PropertiesParser extends LocaleParser {
    public override function parse(data:String):Map<String, String> {
        var result:Map<String, String> = new Map<String, String>();
        var lines = data.split("\n");
        var newLines = [];
        // bit cheeky, but lets strip comments and empty lines
        // before we start parsing
        for (line in lines) {
            if (line.trim().length == 0 || line.trim().startsWith("#")) {
                continue;
            }

            newLines.push(line);
        }

        data = newLines.join("\n");

        var inValue = false;
        var propName = "";
        var propValue = "";
        for (i in 0...data.length) {
            var ch = data.charAt(i);
            switch(ch) {
                case "=":
                    if (inValue == true) {
                        propValue += ch;
                    }
                    inValue = true;
                case "\n": 
                    var hasSpace = false;
                    var hasEquals = false;
                    for (j in i + 1...data.length) { // lets peek ahead
                        var ch2 = data.charAt(j);
                        if (ch2 == "=") {
                            hasEquals = true;
                            break;
                        } else if (ch2 == " ") {
                            hasSpace = true;
                        } else if (ch2 == "\n") {
                            break;
                        }
                    }

                    if (hasEquals == true && hasSpace == false) {
                        inValue = false;
                        result.set(propName, propValue);

                        propName = "";
                        propValue = "";
                    } else {
                        propValue += ch;
                    }
                case _:    
                    if (inValue) {
                        propValue += ch;
                    } else {
                        propName += ch;
                    }
            }
        }

        if (propName.length > 0 && propValue.length > 0) {
            result.set(propName, propValue);
        }

        return result;
    }
}
