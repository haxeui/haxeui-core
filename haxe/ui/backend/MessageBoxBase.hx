package haxe.ui.backend;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;

@:xml('
<hbox width="100%" style="spacing:10px;">
    <image id="iconImage" />
    <label width="100%" id="messageLabel" />
</hbox>
')
class MessageBoxBase extends Dialog {
    public function new() {
        super();
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