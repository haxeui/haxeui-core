package;


class Alias {
	public static function main () {
		var args = [ "run", "haxeui-core" ].concat (Sys.args ());
		Sys.exit (Sys.command ("haxelib", args));
	}
}