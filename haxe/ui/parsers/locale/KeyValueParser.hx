package haxe.ui.parsers.locale;

using StringTools;

class KeyValueParser extends LocaleParser {
	var SEPARATOR:String = "";
	var COMMENT_STRING:String = "";
	var LINE_FEED:String = "\n";
	var STRICT:Bool = false; // do not allow parser to continue if a line is incorrect
	
	public override function parse(data:String):Map<String, String> {
		if (SEPARATOR == "") {
			throw "separator, comment needs implementation";
		}
		
		var result:Map<String, String> = new Map<String, String>();
		var lines = data.split(LINE_FEED);
		for (line in lines) {
			line = line.trim();
			if (line.length == 0 || (line.startsWith(COMMENT_STRING) && COMMENT_STRING != "")) {
				continue;
			}

			var separator:Int = line.indexOf(SEPARATOR);
			if (separator == -1) {
				// skip the line if separator is not found else throw if strict
				if (STRICT)
					throw 'Locale parser: Invalid line ${line}. Missing separator $SEPARATOR';
				else continue;
			}

			var key = line.substr(0, separator).trim();
			var content = line.substr(separator + 1);
			result.set(key, content);
		}

		return result;
	}
}
