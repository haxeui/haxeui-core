package;

import haxe.ui.parsers.locale.KeyValueParser;

/**
 * Register the parser before intialising the toolkik
 * LocaleParser.register("csv", TSVParser);
 */
class TSVParser extends KeyValueParser {
	public function new() {
		super();
		this.SEPARATOR = "\t";
		this.COMMENT_STRING = "#";
		this.STRICT = false;
		this.LINE_FEED = "\n";
	}
	
}
