package haxe.ui.events;

enum abstract EventType<T:UIEvent>(String) to String from String {
	public static function name<T:UIEvent>(name:String):EventType<T> {
		return cast name;
	}
}