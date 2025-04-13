package haxe.ui.backend;

import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;

typedef OpenFolderDialogOptions = {
    @:optional var defaultPath:String;
    @:optional var title:String;
    @:optional var multiple:Null<Bool>;
    @:optional var hiddenFolders:Null<Bool>;
    @:optional var canCreateFolder:Null<Bool>;
}

class OpenFolderDialogBase {
    public var selectedFolders:Array<String> = null;
    public var callback:DialogButton->Array<String>->Void = null;
    public var onDialogClosed:DialogEvent->Void = null;
    
    public function new(options:OpenFolderDialogOptions = null, callback:DialogButton->Array<String>->Void = null) {
        this.options = options;
        this.callback = callback;
    }
    
    private var _options:OpenFolderDialogOptions = null;
    public var options(get, set):OpenFolderDialogOptions;
    private function get_options():OpenFolderDialogOptions {
        return _options;
    }
    private function set_options(value:OpenFolderDialogOptions):OpenFolderDialogOptions {
        _options = value;
        validateOptions();
        return value;
    }
    
    private function validateOptions() {
        if (_options == null) {
            options = { };
        }

        if (_options.multiple == null) {
            _options.multiple = false;
        }

        if (_options.canCreateFolder == null) {
            _options.canCreateFolder = false;
        }

        if (_options.hiddenFolders == null) {
            _options.hiddenFolders = false;
        }
    }
    
    public function show() {
        Dialogs.messageBox("OpenFolderDialog has no implementation on this backend", "Open Folder", MessageBoxType.TYPE_ERROR);
    }
    
    private function dialogConfirmed(folders:Array<String>) {
        selectedFolders = folders;
        if (callback != null) {
            callback(DialogButton.OK, selectedFolders);
        }
        if (onDialogClosed != null) {
            var event = new DialogEvent(DialogEvent.DIALOG_CLOSED, false, selectedFolders);
            event.button = DialogButton.OK;
            onDialogClosed(event);
        }
    }
    
    private function dialogCancelled() {
        selectedFolders = null;
        if (callback != null) {
            callback(DialogButton.CANCEL, selectedFolders);
        }
        if (onDialogClosed != null) {
            var event = new DialogEvent(DialogEvent.DIALOG_CLOSED, false, selectedFolders);
            event.button = DialogButton.CANCEL;
            onDialogClosed(event);
        }
    }
}