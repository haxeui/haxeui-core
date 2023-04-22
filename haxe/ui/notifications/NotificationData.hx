package haxe.ui.notifications;

typedef NotificationData = {
    var body:String;
    @:optional var title:String;
    @:optional var icon:String;
    @:optional var actions:Array<String>;
    @:optional var expiryMs:Int;
    @:optional var type:NotificationType;
    @:optional var styleNames:String;
}