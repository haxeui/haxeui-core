package haxe.ui.parsers.locale;

/**
 * Register it for the file extension before intialising the toolkik
 * LocaleParser.register("csv", CSVParser);
 */
class CSVParser extends KeyValueParser {
	public function new() {
		super();
		this.PARSER_SEPARATOR = ";";
		this.PARSER_COMMENT_STRING = "#";
		this.PARSER_STRICT = false;
		this.PARSER_LINE_FEED = "\n";
	}
	
}
