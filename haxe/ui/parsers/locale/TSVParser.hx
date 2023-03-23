package haxe.ui.parsers.locale;

/**
 * Register the parser before intialising the toolkik
 * LocaleParser.register("csv", TSVParser);
 */
class TSVParser extends KeyValueParser {
	public function new() {
		super();
		this.PARSER_SEPARATOR = "\t";
		this.PARSER_COMMENT_STRING = "#";
		this.PARSER_STRICT = false;
		this.PARSER_LINE_FEED = "\n";
	}
	
}
