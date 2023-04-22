package haxe.ui.notifications;

import haxe.ui.components.Button;
import haxe.ui.containers.VBox;

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
            NotificationManager.instance.removeNotification(this);
        }
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
            for (actionText in _notificationData.actions) {
                var button = new Button();
                button.text = actionText;
                actionsContainer.addComponent(button);
            }
            actionsFooter.show();
        }
        return value;
    }
}