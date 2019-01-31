package haxe.ui.containers;

import haxe.ui.containers.ListView.ItemRendererFunction2;
import haxe.ui.core.ItemRenderer;

interface IVirtualContainer {
    public var itemWidth(get, set):Float;
    public var itemHeight(get, set):Float;
    public var itemCount(get, set):Int;
    public var variableItemSize(get, set):Bool;
    public var virtual(get, set):Bool;

    public var hscrollPos(get, set):Float;
    public var hscrollMax(get, set):Float;
    public var hscrollPageSize(get, set):Float;
    public var vscrollPos(get, set):Float;
    public var vscrollMax(get, set):Float;
    public var vscrollPageSize(get, set):Float;

    public var itemRenderer(get, set):ItemRenderer;
    public var itemRendererFunction(get, set):ItemRendererFunction2;
    public var itemRendererClass(get, set):Class<ItemRenderer>;
}
