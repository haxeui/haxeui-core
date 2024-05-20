package haxe.ui.core;

interface IScroller {
    public function ensureVisible(component:Component):Void;
    public var isScrollableHorizontally(get, null):Bool;
    public var isScrollableVertically(get, null):Bool;
    public var isScrollable(get, null):Bool;
    public var vscrollPos(get, set):Float;
    public var hscrollPos(get, set):Float;
}