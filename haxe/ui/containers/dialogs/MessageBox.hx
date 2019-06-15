package haxe.ui.containers.dialogs;

import haxe.ui.containers.dialogs.Dialog;

abstract MessageBoxType(String) from String {
    public static inline var INFO:MessageBoxType = "haxeui-core/styles/default/dialogs/information.png";
    public static inline var QUESTION:MessageBoxType = "haxeui-core/styles/default/dialogs/question.png";
    public static inline var WARNING:MessageBoxType = "haxeui-core/styles/default/dialogs/exclamation.png";
    public static inline var ERROR:MessageBoxType = "haxeui-core/styles/default/dialogs/cross-circle.png";
    
	public function toString():String {
        return Std.string(this);
    }
}

@:xml('
<hbox width="100%" style="spacing:10px;">
    <image id="iconImage" />
    <label width="100%" id="messageLabel" />
</hbox>
')
class MessageBox extends Dialog {
    public function new() {
        super();
        title = "Message";
    }
    
    private override function onInitialize() {
        super.onInitialize();
        if (buttons.toArray().length == 0) {
            switch (type) {
                case MessageBoxType.INFO:
                    buttons = DialogButton.OK;
                case MessageBoxType.QUESTION:
                    buttons = DialogButton.YES | DialogButton.NO | DialogButton.CANCEL;
                case MessageBoxType.WARNING:
                    buttons = DialogButton.CLOSE;
                case MessageBoxType.ERROR:
                    buttons = DialogButton.CLOSE;
            }
            createButtons();
        }
        if (title == "Message") {
            switch (type) {
                case MessageBoxType.INFO:
                    title = "Info";
                case MessageBoxType.QUESTION:
                    title = "Question";
                case MessageBoxType.WARNING:
                    title = "Warning";
                case MessageBoxType.ERROR:
                    title = "Error";
            }
        }
    }
    
    public var message(get, set):String;
    private function get_message():String {
        return messageLabel.text;
    }
    private function set_message(value:String):String {
        messageLabel.text = value;
        return value;
    }
    
    public var type(get, set):MessageBoxType;
    private function get_type():MessageBoxType {
        return iconImage.resource;
    }
    private function set_type(value:MessageBoxType):MessageBoxType {
        iconImage.resource = value.toString();
        return value;
    }
}
