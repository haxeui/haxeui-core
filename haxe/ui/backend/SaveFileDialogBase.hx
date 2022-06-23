package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.Dialogs.FileDialogExtensionInfo;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;

typedef SaveFileDialogOptions = {
    @:optional var writeAsBinary:Null<Bool>;
    @:optional var extensions:Array<FileDialogExtensionInfo>;
    @:optional var title:String;
}

class SaveFileDialogBase {
    public var saveResult:Bool = false;
    public var callback:DialogButton->Bool->Void = null;
    public var onDialogClosed:DialogEvent->Void = null;
    
    public var fileInfo:FileInfo = null;
    
    
    public function new(options:SaveFileDialogOptions = null, callback:DialogButton->Bool->Void = null) {
        this.options = options;
        this.callback = callback;
    }
    
    private var _options:SaveFileDialogOptions = null;
    public var options(get, set):SaveFileDialogOptions;
    private function get_options():SaveFileDialogOptions {
        return _options;
    }
    private function set_options(value:SaveFileDialogOptions):SaveFileDialogOptions {
        _options = value;
        validateOptions();
        return value;
    }
    
    private function validateOptions() {
        if (_options == null) {
            options = { };
        }
    }
    
    public function show() {
        Dialogs.messageBox("SaveFileDialog has no implementation on this backend", "Save File", MessageBoxType.TYPE_ERROR);
    }
    
    private function dialogConfirmed() {
        saveResult = true;
        if (callback != null) {
            callback(DialogButton.OK, saveResult);
        }
        if (onDialogClosed != null) {
            var event = new DialogEvent(DialogEvent.DIALOG_CLOSED, false, saveResult);
            event.button = DialogButton.OK;
            onDialogClosed(event);
        }
    }
    
    private function dialogCancelled() {
        saveResult = false;
        if (callback != null) {
            callback(DialogButton.CANCEL, saveResult);
        }
        if (onDialogClosed != null) {
            var event = new DialogEvent(DialogEvent.DIALOG_CLOSED, false, saveResult);
            event.button = DialogButton.CANCEL;
            onDialogClosed(event);
        }
    }
}