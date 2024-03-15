package haxe.ui.core;

interface IScroller {
    public function ensureVisible(component:Component):Void;
    public var isScrollableHorizontally(get, null):Bool;
    public var isScrollableVertically(get, null):Bool;
    public var isScrollable(get, null):Bool;
}