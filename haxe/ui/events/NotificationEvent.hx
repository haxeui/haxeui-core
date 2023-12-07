package haxe.ui.events;

import haxe.ui.notifications.Notification;

class NotificationEvent extends UIEvent {
    public static final SHOWN:EventType<ScrollEvent> = EventType.name("notificationshown");
    public static final HIDDEN:EventType<ScrollEvent> = EventType.name("notificationhidden");
    public static final ACTION:EventType<ScrollEvent> = EventType.name("notificationaction");

    public var notification:Notification = null;

    public override function clone():NotificationEvent {
        var c:NotificationEvent = new NotificationEvent(this.type);
        c.notification = this.notification;
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        postClone(c);
        return c;
    }
}