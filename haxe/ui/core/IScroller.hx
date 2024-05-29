package haxe.ui.core;

import haxe.ui.constants.ScrollMode;

interface IScroller {
    public function ensureVisible(component:Component):Void;
    public function findHorizontalScrollbar():Component;
    public function findVerticalScrollbar():Component;
    public var isScrollableHorizontally(get, null):Bool;
    public var isScrollableVertically(get, null):Bool;
    public var isScrollable(get, null):Bool;
    public var vscrollPos(get, set):Float;
    public var hscrollPos(get, set):Float;
    public var virtual(get, set):Bool;
    public var scrollMode(get, set):ScrollMode;
}