package haxe.ui.backend;

import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;

typedef OpenFileDialogOptions = {
    @:optional var readContents:Null<Bool>;
    @:optional var readAsBinary:Null<Bool>;
    @:optional var multiple:Null<Bool>;
    @:optional var extensions:Array<FileDialogExtensionInfo>;
    @:optional var title:String;
}

class OpenFileDialogBase {
    public var selectedFiles:Array<SelectedFileInfo> = null;
    public var callback:DialogButton->Array<SelectedFileInfo>->Void = null;
    public var onDialogClosed:DialogEvent->Void = null;
    
    public function new(options:OpenFileDialogOptions = null, callback:DialogButton->Array<SelectedFileInfo>->Void = null) {
        this.options = options;
        this.callback = callback;
    }
    
    private var _options:OpenFileDialogOptions = null;
    public var options(get, set):OpenFileDialogOptions;
    private function get_options():OpenFileDialogOptions {
        return _options;
    }
    private function set_options(value:OpenFileDialogOptions):OpenFileDialogOptions {
        _options = value;
        validateOptions();
        return value;
    }
    
    private function validateOptions() {
        if (_options == null) {
            options = { };
        }
        
        if (_options.readContents == null) {
            _options.readContents = false;
        }
        if (_options.readAsBinary == null) {
            _options.readAsBinary = false;
        }
        if (_options.multiple == null) {
            _options.multiple = false;
        }
    }
    
    public function show() {
        Dialogs.messageBox("OpenFileDialog has no implementation on this backend", "Open File", MessageBoxType.TYPE_ERROR);
    }
    
    private function dialogConfirmed(files:Array<SelectedFileInfo>) {
        selectedFiles = files;
        if (callback != null) {
            callback(DialogButton.OK, selectedFiles);
        }
        if (onDialogClosed != null) {
            var event = new DialogEvent(DialogEvent.DIALOG_CLOSED, false, selectedFiles);
            event.button = DialogButton.OK;
            onDialogClosed(event);
        }
    }
    
    private function dialogCancelled() {
        selectedFiles = null;
        if (callback != null) {
            callback(DialogButton.CANCEL, selectedFiles);
        }
        if (onDialogClosed != null) {
            var event = new DialogEvent(DialogEvent.DIALOG_CLOSED, false, selectedFiles);
            event.button = DialogButton.CANCEL;
            onDialogClosed(event);
        }
    }
}