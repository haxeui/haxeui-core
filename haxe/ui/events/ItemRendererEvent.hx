package haxe.ui.events;

import haxe.ui.actions.ActionType;
import haxe.ui.core.ItemRenderer;

class ItemRendererEvent extends UIEvent {
    public static final DATA_CHANGED:EventType<ItemRendererEvent> = EventType.name("datachanged");
    
    public var itemRenderer:ItemRenderer;

    public function new(type:EventType<ItemRendererEvent>, itemRenderer:ItemRenderer) {
        super(type, true);
        this.itemRenderer = itemRenderer;
        if (this.itemRenderer != null) {
            this.data = this.itemRenderer.data;
        }
    }

    public override function clone():ItemRendererEvent {
        var c:ItemRendererEvent = new ItemRendererEvent(this.type, this.itemRenderer);
        postClone(c);
        return c;
    }
    
    public override function copyFrom(e:UIEvent) {
        var ire = cast(e, ItemRendererEvent);
        this.itemRenderer = ire.itemRenderer;
        if (this.itemRenderer != null) {
            this.data = this.itemRenderer.data;
        }
    }
}