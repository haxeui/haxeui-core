package haxe.ui.notifications;

import haxe.ui.components.Button;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.NotificationEvent;
import haxe.ui.notifications.NotificationData.NotificationActionData;

@:xml('
<vbox>
    <hbox width="100%">
        <label id="title" text="Title" width="100%" />
        <image id="closeButton" styleName="notification-close-button" />
    </hbox>
    <rule />
    <hbox id="contentContainer" width="100%">
        <image id="notificationIcon" resource="haxeui-core/styles/shared/info-large.png" />
        <scrollview id="bodyContainer" width="100%" contentWidth="100%" autoFocus="false" allowFocus="false">
            <vbox width="100%">
                <label id="body" text="This is the body" width="100%" />
            </vbox>
        </scrollview>    
    </hbox>        
    <hbox id="actionsFooter" width="100%">
        <spacer width="100%" />
        <hbox id="actionsContainer">
        </hbox>
    </hbox>
</vbox>
')
class Notification extends VBox {
    public function new() {
        super();

        closeButton.onClick = function(_) {
            hide();
        }
    }

    public override function hide() {
        NotificationManager.instance.removeNotification(this);
    }

    private var _notificationData:NotificationData = null;
    public var notificationData(get, set):NotificationData;
    private function get_notificationData():NotificationData {
        return _notificationData;
    }
    private function set_notificationData(value:NotificationData):NotificationData {
        _notificationData = value;
        title.text = _notificationData.title;
        body.text = _notificationData.body;
        if (_notificationData.icon != null) {
            notificationIcon.resource = _notificationData.icon;
        } else if (_notificationData.type != null) {
            switch (_notificationData.type) {
                case Info:
                    addClass("info");
                    addClass("blue-notification");
                case Error:
                    addClass("error");
                    addClass("red-notification");
                case Warning:    
                    addClass("warning");
                    addClass("yellow-notification");
                case Success:    
                    addClass("success");
                    addClass("green-notification");
                case Default:    
            }
        }
        if (_notificationData.styleNames != null) {
            this.styleNames = _notificationData.styleNames;
            this.invalidateComponentStyle();
        }
        if (_notificationData.actions == null || _notificationData.actions.length == 0) {
            actionsFooter.hide();
        } else {
            actionsContainer.removeAllComponents();
            for (actionData in _notificationData.actions) {
                var button = new Button();
                button.text = actionData.text;
                button.icon = actionData.icon;
                button.userData = actionData;
                button.registerEvent(MouseEvent.CLICK, onActionButton);
                actionsContainer.addComponent(button);
            }
            actionsFooter.show();
        }
        return value;
    }

    private function onActionButton(event:MouseEvent) {
        var closeNotification = true;

        var notificationEvent = new NotificationEvent(NotificationEvent.ACTION);
        notificationEvent.notification = this;
        dispatch(notificationEvent);
        if (notificationEvent.canceled) {
            closeNotification = false;
        }
        NotificationManager.instance.dispatch(notificationEvent, this);
        if (notificationEvent.canceled) {
            closeNotification = false;
        }

        var actionData:NotificationActionData = event.target.userData;
        if (actionData.callback != null) {
            closeNotification = actionData.callback(actionData);
        }

        if (closeNotification) {
            hide();
        }
    }
}