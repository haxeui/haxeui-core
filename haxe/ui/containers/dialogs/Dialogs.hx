package haxe.ui.containers.dialogs;

import haxe.io.Bytes;
import haxe.ui.backend.OpenFileDialogBase.OpenFileDialogOptions;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.containers.dialogs.OpenFileDialog;
import haxe.ui.core.Component;

typedef FileDialogExtensionInfo = {
    @:optional var extension:String;
    @:optional var label:String;
}

typedef SelectedFileInfo = {
    var name:String;
    @:optional var fullPath:String;
    @:optional var text:String;
    @:optional var bytes:Bytes;
    var isBinary:Bool;
}

class Dialogs {
    public static function messageBox(message:String, title:String = null, type:MessageBoxType = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        if (type == null) {
            type = MessageBoxType.TYPE_INFO;
        } else if (type == "info") {
            type = MessageBoxType.TYPE_INFO;
        } else if (type == "question") {
            type = MessageBoxType.TYPE_QUESTION;
        } else if (type == "warning") {
            type = MessageBoxType.TYPE_WARNING;
        } else if (type == "error") {
            type = MessageBoxType.TYPE_ERROR;
        } else if (type == "yesno") {
            type = MessageBoxType.TYPE_YESNO;
        }

        var messageBox = new MessageBox();
        messageBox.type = type;
        messageBox.message = message;
        messageBox.modal = modal;
        if (title != null) {
            messageBox.title = title;
        }
        messageBox.show();
        if (callback != null) {
            messageBox.registerEvent(DialogEvent.DIALOG_CLOSED, function(e:DialogEvent) {
                callback(e.button);
            });
        }
        return messageBox;
    }

    public static function dialog(contents:Component, title:String = null, buttons:DialogButton = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        var dialog = new Dialog();
        dialog.modal = modal;
        if (title != null) {
            dialog.title = title;
        }
        if (buttons != null) {
            dialog.buttons = buttons;
        }
        dialog.addComponent(contents);
        dialog.show();
        if (callback != null) {
            dialog.registerEvent(DialogEvent.DIALOG_CLOSED, function(e:DialogEvent) {
                callback(e.button);
            });
        }
        return dialog;
    }
    
    public static function openFile(callback:DialogButton->Array<SelectedFileInfo>->Void, options:OpenFileDialogOptions = null) {
        var dialog = new OpenFileDialog();
        dialog.callback = callback;
        dialog.options = options;
        dialog.show();
    }
}