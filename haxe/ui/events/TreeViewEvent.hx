package haxe.ui.events;

import haxe.ui.containers.TreeViewNode;

class TreeViewEvent extends UIEvent {
    public static final NODE_EXPANDED:EventType<TreeViewEvent> = EventType.name("nodeexpanded");
    public static final NODE_COLLAPSED:EventType<TreeViewEvent> = EventType.name("nodecollapsed");

    public var node:TreeViewNode = null;

    public override function clone():TreeViewEvent {
        var c:TreeViewEvent = new TreeViewEvent(this.type);
        c.node = this.node;
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        postClone(c);
        return c;
    }
}