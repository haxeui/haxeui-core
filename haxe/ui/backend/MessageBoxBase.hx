package haxe.ui.backend;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;

/*
#if (haxe_ver >= 4)
@:xml('
<hbox width="100%" style="spacing:10px;">
    <image id="iconImage" />
    <label width="100%" id="messageLabel" />
</hbox>
')
#end
*/
class MessageBoxBase extends Dialog {
    //#if (haxe_ver < 4) // TODO: seems using two @xml build macros in haxe 3.4.7 breaks things - order related probably - work around for now is to manually create
    public var iconImage:haxe.ui.components.Image;
    public var messageLabel:haxe.ui.components.Label;
    //#end

    public function new() {
        super();
        //#if (haxe_ver < 4) // TODO: seems using two @xml build macros in haxe 3.4.7 breaks things - order related probably - work around for now is to manually create

        var hbox = new haxe.ui.containers.HBox();
        hbox.percentWidth = 100;
        hbox.styleString = "spacing:10px;";
        addComponent(hbox);

        iconImage = new haxe.ui.components.Image();
        iconImage.id = "iconImage";
        hbox.addComponent(iconImage);

        messageLabel = new haxe.ui.components.Label();
        messageLabel.id = "messageLabel";
        messageLabel.percentWidth = 100;
        hbox.addComponent(messageLabel);

        //#end
    }

    public var message(get, set):String;
    private function get_message():String {
        return messageLabel.text;
    }
    private function set_message(value:String):String {
        messageLabel.text = value;
        return value;
    }

    public override function get_text():String {
        return message;
    }
    public override function set_text(value:String):String {
        message = value;
        return value;
    }

    public override function get_icon():String {
        return iconImage.resource;
    }
    public override function set_icon(value:String):String {
        iconImage.resource = value;
        return value;
    }
    
    private var _type:String = null;
    public var type(get, set):MessageBoxType;
    private function get_type():MessageBoxType {
        return _type;
    }
    private function set_type(value:MessageBoxType):MessageBoxType {
        _type = value.toString();
        iconImage.addClass(_type);
        addClass(_type);
        return value;
    }
}