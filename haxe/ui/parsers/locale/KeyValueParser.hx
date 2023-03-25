package haxe.ui.parsers.locale;

using StringTools;

class KeyValueParser extends LocaleParser {
	var PARSER_SEPARATOR:String = "";
	var PARSER_COMMENT_STRING:String = "";
	var PARSER_LINE_FEED:String = "\n";
	var PARSER_STRICT:Bool = false; // do not allow parser to continue if a line is incorrect
	
	public override function parse(data:String):Map<String, String> {
		if (PARSER_SEPARATOR == "") {
			throw "PARSER_SEPARATOR needs implementation in " + Type.getClassName(Type.getClass(this));
		}
		
		var result:Map<String, String> = new Map<String, String>();
		var lines = data.split(PARSER_LINE_FEED);
		for (line in lines) {
			line = line.trim();
			if (line.length == 0 || (line.startsWith(PARSER_COMMENT_STRING) && PARSER_COMMENT_STRING != "")) {
				continue;
			}

			var separator:Int = line.indexOf(PARSER_SEPARATOR);
			if (separator == -1) {
				// skip the line if separator is not found else throw if strict
				if (PARSER_STRICT)
					throw 'Locale parser: Invalid line ${line}. Missing separator $PARSER_SEPARATOR';
				else continue;
			}

			var key = line.substr(0, separator).trim();
			var content = line.substr(separator + 1);
			result.set(key, content);
		}

		return result;
	}
}
