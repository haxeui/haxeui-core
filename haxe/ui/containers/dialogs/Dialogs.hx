package haxe.ui.containers.dialogs;

import haxe.io.Bytes;
import haxe.ui.backend.OpenFileDialogBase.OpenFileDialogOptions;
import haxe.ui.backend.SaveFileDialogBase.SaveFileDialogOptions;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.containers.dialogs.OpenFileDialog;
import haxe.ui.containers.dialogs.SaveFileDialog;
import haxe.ui.core.Component;

typedef FileDialogExtensionInfo = {
    @:optional var extension:String;
    @:optional var label:String;
}

typedef FileInfo = {
    @:optional var name:String;
    @:optional var text:String;
    @:optional var bytes:Bytes;
    @:optional var isBinary:Bool;
}

typedef SelectedFileInfo = { > FileInfo,
    @:optional var fullPath:String;
}

class FileDialogTypes {
    public static inline var ANY:Array<FileDialogExtensionInfo> = null;
    
    public static var IMAGES(get, null):Array<FileDialogExtensionInfo>;
    private static function get_IMAGES():Array<FileDialogExtensionInfo> {
        return [{label: "Image Files", extension: "png, gif, jpeg, jpg, bmp"}];
    }
    
    public static var TEXTS(get, null):Array<FileDialogExtensionInfo>;
    private static function get_TEXTS():Array<FileDialogExtensionInfo> {
        return [{label: "Text Files", extension: "txt"}];
    }
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
    
    public static function openBinaryFile(title:String = null, fileTypes:Array<FileDialogExtensionInfo> = null, callback:SelectedFileInfo->Void) {
        var options:OpenFileDialogOptions = {
            readContents: true,
            readAsBinary: true,
            multiple: false,
            extensions: fileTypes,
            title: title
        }
        openFile(function(button, selectedFiles) {
            if (button == DialogButton.OK && selectedFiles.length > 0) {
                callback(selectedFiles[0]);
            }
        }, options);
    }
    
    public static function openTextFile(title:String = null, fileTypes:Array<FileDialogExtensionInfo> = null, callback:SelectedFileInfo->Void) {
        var options:OpenFileDialogOptions = {
            readContents: true,
            readAsBinary: false,
            multiple: false,
            extensions: fileTypes,
            title: title
        }

        openFile(function(button, selectedFiles) {
            if (button == DialogButton.OK && selectedFiles.length > 0) {
                callback(selectedFiles[0]);
            }
        }, options);
    }
    
    public static function saveFile(callback:DialogButton->Bool->Void, fileInfo:FileInfo, options:SaveFileDialogOptions = null) {
        var dialog = new SaveFileDialog();
        dialog.callback = callback;
        dialog.options = options;
        dialog.fileInfo = fileInfo;
        dialog.show();
    }
    
    public static function saveBinaryFile(title:String = null, fileTypes:Array<FileDialogExtensionInfo> = null, fileInfo:FileInfo, callback:Bool->Void) {
        var options:SaveFileDialogOptions = {
            writeAsBinary: true,
            extensions: fileTypes,
            title: title
        }

        saveFile(function(button, result) {
            callback(result);
        }, fileInfo, options);
    }
    
    public static function saveTextFile(title:String = null, fileTypes:Array<FileDialogExtensionInfo> = null, fileInfo:FileInfo, callback:Bool->Void) {
        var options:SaveFileDialogOptions = {
            writeAsBinary: false,
            extensions: fileTypes,
            title: title
        }

        saveFile(function(button, result) {
            callback(result);
        }, fileInfo, options);
    }
}