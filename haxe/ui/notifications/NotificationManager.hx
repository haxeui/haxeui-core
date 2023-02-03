package haxe.ui.notifications;

import haxe.ui.util.Timer;
import haxe.ui.Toolkit;
import haxe.ui.animation.AnimationBuilder;
import haxe.ui.core.Screen;

using haxe.ui.animation.AnimationTools;

class NotificationManager {
    private static var _instance:NotificationManager;
    public static var instance(get, null):NotificationManager;
    private static function get_instance():NotificationManager {
        if (_instance == null) {
            _instance = new NotificationManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    private var _currentNotifications:Array<Notification> = [];
    public static var DEFAULT_EXPIRY:Int = 3000;

    private function new() {

    }

    private var _addQueue:Array<Notification> = [];
    public function addNotification(notificationData:NotificationData) {
        if (notificationData.title == null) {
            notificationData.title = "Notification";
        }
        if (notificationData.actions == null || notificationData.actions.length == 0) {
            if (notificationData.expiryMs == null) {
                notificationData.expiryMs = DEFAULT_EXPIRY;
            }
        } else {
            notificationData.expiryMs = -1; // we'll assume if there are actions we dont want it to expire
        }

        var notification = new Notification();
        notification.notificationData = notificationData;
        if (!_isAnimating) {
            pushNotification(notification);
        } else {
            _addQueue.push(notification);
        }
    }

    private var _removeQueue:Array<Notification> = [];
    public function removeNotification(notification:Notification) {
        if (_isAnimating) {
            _removeQueue.push(notification);
            return;
        }

        popNotification(notification);
    }

    private function popNotification(notification:Notification) {
        notification.fadeOut(function () {
            _currentNotifications.remove(notification);
            Screen.instance.removeComponent(notification);
            positionNotifications();
        });
    }

    private function pushNotification(notification:Notification) {
        _currentNotifications.insert(0, notification);
        notification.opacity = 0;
        Screen.instance.addComponent(notification);
        notification.validateNow();
        Toolkit.callLater(function () {
            notification.validateNow();
            var scx = Screen.instance.width;
            var scy = Screen.instance.height;
            if (notification.height > 300) {
                notification.height = 300;                
                notification.contentContainer.percentHeight = 100;
                notification.bodyContainer.percentHeight = 100;
            }
            var baseline = scy - GUTTER_SIZE;
            notification.left = scx - notification.width - GUTTER_SIZE;
            notification.top = baseline - notification.height;

            positionNotifications();
        });

        if (notification.notificationData.expiryMs > 0) {
            Timer.delay(function () {
                removeNotification(notification);
            }, notification.notificationData.expiryMs);
        }
    }

    public static var GUTTER_SIZE = 20;
    public static var SPACING = 10;
    private var _isAnimating:Bool = false;
    private function positionNotifications() {
        _isAnimating = true;
        var scy = Screen.instance.height;
        var baseline = scy - GUTTER_SIZE;

        var builder:AnimationBuilder = null;
        var builders:Array<AnimationBuilder> = [];
        for (notification in _currentNotifications) {
            builder = new AnimationBuilder(notification);
            builder.setPosition(0, "top", Std.int(notification.top), true);
            builder.setPosition(100, "top", Std.int(baseline - notification.height), true);
            if (notification.opacity == 0) {
                builder.setPosition(0, "opacity", 0, true);
                builder.setPosition(100, "opacity", 1, true);
            }
            builders.push(builder);
            baseline -= (notification.height + SPACING);
        }

        if (builders.length > 0) {
            builder.onComplete = function () {
                if (_addQueue.length > 0) {
                    pushNotification(_addQueue.shift());
                } else if (_removeQueue.length > 0) {
                    popNotification(_removeQueue.shift());
                } else {
                    _isAnimating = false;
                }
            }

            for (builder in builders) {
                builder.play();
            }
        } else {
            _isAnimating = false;
        }
    }
}