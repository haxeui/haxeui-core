package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;

typedef SelectFileDialogOptions = {
    @:optional var readContents:Null<Bool>;
    @:optional var readAsBinary:Null<Bool>;
    @:optional var multiple:Null<Bool>;
}

typedef SelectedFileInfo = {
    var name:String;
    @:optional var fullPath:String;
    @:optional var text:String;
    @:optional var bytes:Bytes;
    var isBinary:Bool;
}

class SelectFileDialogBase {
    public var callback:DialogButton->Array<SelectedFileInfo>->Void = null;
    public var options:SelectFileDialogOptions = null;
    
    public function new() {
    }
    
    private function validateOptions() {
        if (options == null) {
            options = { };
        }
        
        if (options.readContents == null) {
            options.readContents = false;
        }
        if (options.readAsBinary == null) {
            options.readAsBinary = false;
        }
        if (options.multiple == null) {
            options.multiple = false;
        }
    }
    
    public function show() {
        Dialogs.messageBox("SelectFileDialog has no implementation on this backend", "Select File", MessageBoxType.TYPE_ERROR);
    }
}