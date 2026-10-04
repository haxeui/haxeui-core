package haxe.ui.layouts;

import haxe.ds.IntMap;
import haxe.ds.ObjectMap;

/**
 * The measured heights (or widths) of a virtual list's rows when items differ in size
 * (VerticalVirtualLayout with `variableItemSize`).
 *
 * A height belongs to its row's item, not to a position: rows above it can be folded away,
 * inserted or moved (a data source kept in sync keeps its item objects), and the height has to go
 * with the row - a cache by position hands each row the height of whichever row was there before,
 * and the rows overlap or leave gaps. Items that are not objects (strings, numbers) cannot be told
 * apart, so they are remembered by position. A new width wraps text differently, so it forgets
 * every height. A height of 0 is "not measured yet" and is not remembered.
 */
class VirtualSizeCache {
    var byItem = new ObjectMap<Dynamic, Float>();
    var byIndex = new IntMap<Float>();
    var width:Float = -1;

    public function new() {}

    /** The size remembered for `item` (the row at `index`), or null if it was never measured. */
    public function get(item:Dynamic, index:Int):Null<Float> {
        return isObject(item) ? byItem.get(item) : byIndex.get(index);
    }

    /** Remembers `size` for `item` (the row at `index`), replacing what was there. */
    public function set(item:Dynamic, index:Int, size:Float):Void {
        if (size <= 0) return;
        if (isObject(item)) byItem.set(item, size) else byIndex.set(index, size);
    }

    /** The width the rows are laid out at; a different one from last time forgets every size. */
    public function widthIs(w:Float):Void {
        if (w == width) return;
        width = w;
        clear();
    }

    public function clear():Void {
        byItem = new ObjectMap<Dynamic, Float>();
        byIndex = new IntMap<Float>();
    }

    static inline function isObject(item:Dynamic):Bool {
        return item != null && Reflect.isObject(item) && !Std.isOfType(item, String);
    }
}
