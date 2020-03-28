package haxe.ui.containers.dialogs;

import haxe.ui.backend.MessageBoxBase;
import haxe.ui.containers.dialogs.Dialog;

abstract MessageBoxType(String) from String {
    public static inline var TYPE_INFO:MessageBoxType = "haxeui-core/styles/default/dialogs/information.png";
    public static inline var TYPE_QUESTION:MessageBoxType = "haxeui-core/styles/default/dialogs/question.png";
    public static inline var TYPE_WARNING:MessageBoxType = "haxeui-core/styles/default/dialogs/exclamation.png";
    public static inline var TYPE_ERROR:MessageBoxType = "haxeui-core/styles/default/dialogs/cross-circle.png";
    
	public function toString():String {
        return Std.string(this);
    }
}

class MessageBox extends MessageBoxBase {
    public function new() {
        super();
        title = "Message";
    }
    
    private override function onInitialize() {
        super.onInitialize();
        if (buttons.toArray().length == 0) {
            switch (type) {
                case MessageBoxType.TYPE_INFO:
                    buttons = DialogButton.OK;
                case MessageBoxType.TYPE_QUESTION:
                    buttons = DialogButton.YES | DialogButton.NO | DialogButton.CANCEL;
                case MessageBoxType.TYPE_WARNING:
                    buttons = DialogButton.CLOSE;
                case MessageBoxType.TYPE_ERROR:
                    buttons = DialogButton.CLOSE;
            }
            createButtons();
        }
        if (title == "Message") {
            switch (type) {
                case MessageBoxType.TYPE_INFO:
                    title = "Info";
                case MessageBoxType.TYPE_QUESTION:
                    title = "Question";
                case MessageBoxType.TYPE_WARNING:
                    title = "Warning";
                case MessageBoxType.TYPE_ERROR:
                    title = "Error";
            }
        }
    }
}
