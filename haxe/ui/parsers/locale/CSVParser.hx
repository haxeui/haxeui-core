package haxe.ui.parsers.locale;

/**
 * Register it for the file extension before intialising the toolkik
 * LocaleParser.register("csv", CSVParser);
 */
class CSVParser extends KeyValueParser {
	public function new() {
		super();
		this.SEPARATOR = ";";
		this.COMMENT_STRING = "#";
		this.STRICT = false;
		this.LINE_FEED = "\n";
	}
	
}
