package haxe.ui.notifications;

import haxe.ui.util.Variant;

typedef NotificationData = {
    var body:String;
    @:optional var title:String;
    @:optional var icon:String;
    @:optional var actions:Array<NotificationActionData>;
    @:optional var expiryMs:Int;
    @:optional var type:NotificationType;
    @:optional var styleNames:String;
}

typedef NotificationActionData = {
    @:optional var text:String;
    @:optional var icon:Variant;
    @:optional var callback:NotificationActionData->Bool;
}