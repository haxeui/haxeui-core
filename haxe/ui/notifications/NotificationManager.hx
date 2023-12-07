package haxe.ui.notifications;

import haxe.ui.Toolkit;
import haxe.ui.animation.AnimationBuilder;
import haxe.ui.animation.AnimationSequence;
import haxe.ui.core.Screen;
import haxe.ui.events.NotificationEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.EventDispatcher;
import haxe.ui.util.Timer;

using haxe.ui.animation.AnimationTools;

class NotificationManager extends EventDispatcher<NotificationEvent> {
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
    private static var DEFAULT_EXPIRY:Int = 3000;

    public var maxNotifications:Int = -1;
    public var animationFn:Array<Notification>->Array<AnimationBuilder> = AnimateFromBottom;

    private var _timer:Timer = null;
    private function startTimer() {
        if (_timer != null) {
            return;
        }
        _timer = new Timer(100, onTimer);
    }

    private function stopTimer() {
        if (_timer == null) {
            return;
        }

        _timer.stop();
        _timer = null;
    }

    private function onTimer() {
        if (_isAnimating) {
            return;
        }

        if (_addQueue.length > 0) {
            pushNotification(_addQueue.shift());
        } else if (_removeQueue.length > 0) {
            popNotification(_removeQueue.shift());
        }

        if (_addQueue.length == 0 && _removeQueue.length == 0) {
            stopTimer();
        }
    }

    private var _addQueue:Array<Notification> = [];
    public function addNotification(notificationData:NotificationData):Notification {
        if (notificationData.title == null) {
            notificationData.title = "Notification";
        }
        if (notificationData.actions == null || notificationData.actions.length == 0) {
            if (notificationData.expiryMs == null) {
                notificationData.expiryMs = DEFAULT_EXPIRY;
            }
        } else if (notificationData.expiryMs == null) {
            notificationData.expiryMs = -1; // we'll assume if there are actions we dont want it to expire by default
        }

        var notification = new Notification();
        notification.notificationData = notificationData;
        if (!_isAnimating) {
            pushNotification(notification);
        } else {
            _addQueue.push(notification);
            startTimer();
        }

        return notification;
    }

    private var _removeQueue:Array<Notification> = [];
    public function removeNotification(notification:Notification) {
        if (_currentNotifications.indexOf(notification) == -1) {
            return;
        }
        if (_isAnimating) {
            _removeQueue.push(notification);
            startTimer();
            return;
        }

        popNotification(notification);
    }

    public function clearNotifications():Void {
        for (notification in _currentNotifications) {
            removeNotification(notification);
        }
    }

    private function popNotification(notification:Notification) {
        if (_currentNotifications.indexOf(notification) == -1) {
            return;
        }

        _isAnimating = true;
        notification.fadeOut(function () {
            var event = new NotificationEvent(NotificationEvent.HIDDEN);
            event.notification = notification;
            notification.dispatch(event);
            dispatch(event, notification);

            _isAnimating = false;
            _currentNotifications.remove(notification);
            Screen.instance.removeComponent(notification);
            positionNotifications();
        });
    }

    private function pushNotification(notification:Notification) {
        if (maxNotifications > 0) {
            while (_currentNotifications.length > maxNotifications - 1) {
                var n = _currentNotifications.pop();
                n.fadeOut(function () {
                    Screen.instance.removeComponent(n);
                });
            }
        }

        notification.opacity = 0;
        Screen.instance.addComponent(notification);
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

            var event = new NotificationEvent(NotificationEvent.SHOWN);
            event.notification = notification;
            notification.dispatch(event);
            dispatch(event, notification);

            _currentNotifications.insert(0, notification);
            positionNotifications();
        });

        if (notification.notificationData.expiryMs > 0) {
            Timer.delay(function () {
                removeNotification(notification);
            }, notification.notificationData.expiryMs);
        }
    }

    private static var GUTTER_SIZE = 20;
    private static var SPACING = 10;
    private var _isAnimating:Bool = false;
    private function positionNotifications() {
        if (_isAnimating == true) {
            return;
        }

        _isAnimating = true;

        var sequence = new AnimationSequence();
        var builders = animationFn(_currentNotifications);
        for (builder in builders) {
            sequence.add(builder);
        }

        sequence.onComplete = function() {
            _isAnimating = false;
            if (_removeQueue.length > 0) {
                popNotification(_removeQueue.shift());
            } else if (_addQueue.length > 0) {
                pushNotification(_addQueue.shift());
            }
        }
        sequence.play();
    }

    public static function AnimateFromBottom(notifications:Array<Notification>):Array<AnimationBuilder> {
        var builders = [];

        var scy = Screen.instance.height;
        var baselineY = scy - GUTTER_SIZE;

        for (notification in notifications) {
            var builder = new AnimationBuilder(notification);
            builder.setPosition(0, "top", Std.int(notification.top), true);
            builder.setPosition(100, "top", Std.int(baselineY - notification.height), true);
            if (notification.opacity == 0) {
                builder.setPosition(0, "opacity", 0, true);
                builder.setPosition(100, "opacity", 1, true);
            }
            builders.push(builder);
            baselineY -= (notification.height + SPACING);
        }

        return builders;
    }
}