package haxe.ui.containers.dialogs;

import haxe.ui.backend.MessageBoxBase;
import haxe.ui.containers.dialogs.Dialog.DialogButton;

abstract MessageBoxType(String) from String {
    public static inline var TYPE_INFO:MessageBoxType = "info";
    public static inline var TYPE_QUESTION:MessageBoxType = "question";
    public static inline var TYPE_WARNING:MessageBoxType = "warning";
    public static inline var TYPE_ERROR:MessageBoxType = "error";
    public static inline var TYPE_YESNO:MessageBoxType = "yesno";

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
                case MessageBoxType.TYPE_YESNO:
                    buttons = DialogButton.YES | DialogButton.NO;
            }
            createButtons();
        }
        if (title == "Message") {
            switch (type) {
                case MessageBoxType.TYPE_INFO:
                    title = "{{messagebox.title.info}}";
                case MessageBoxType.TYPE_QUESTION:
                    title = "{{messagebox.title.question}}";
                case MessageBoxType.TYPE_WARNING:
                    title = "{{messagebox.title.warning}}";
                case MessageBoxType.TYPE_ERROR:
                    title = "{{messagebox.title.error}}";
                case MessageBoxType.TYPE_YESNO:
                    title = "{{messagebox.title.question}}";
            }
        }
    }
}
