package haxe.ui.events;

class LoadingEvent extends UIEvent {
    public static final LOADING_STARTED:EventType<LoadingEvent> = EventType.name("loadingstarted");
    public static final LOADING_PROGRESS:EventType<LoadingEvent> = EventType.name("loadingprogress");
    public static final LOADING_COMPLETE:EventType<LoadingEvent> = EventType.name("loadingcomplete");
    public static final LOADING_ERRORED:EventType<LoadingEvent> = EventType.name("loadingerrored");

    public var progress:Float;
    public var maxProgress:Float;

    public override function clone():UIEvent {
        var c:LoadingEvent = new LoadingEvent(this.type);
        c.progress = this.progress;
        c.maxProgress = this.maxProgress;
        c.canceled = this.canceled;
        postClone(c);
        return c;
    }
}