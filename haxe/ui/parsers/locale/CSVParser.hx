package haxe.ui.parsers.locale;

/**
 * ...
 * @author bb
 */
class CSVParser extends KeyValueParser 
{
	public function new() 
	{
		super();
		this.SEPARATOR = ";";
		this.COMMENT_STRING = "#";
		this.STRICT = false;
		this.LINE_FEED = "\n";
	}
	
}