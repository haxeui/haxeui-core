package haxe.ui.backend;

import haxe.ui.components.Button;
import haxe.ui.containers.Box;
import haxe.ui.containers.dialogs.Dialog2;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;

@:xml('
<vbox id="dialog-container" styleNames="dialog-container">
    <hbox id="dialog-title" styleNames="dialog-title">
        <label id="dialog-title-label" styleNames="dialog-title-label" text="HaxeUI" />
        <image id="dialog-close-button" styleNames="dialog-close-button" />
    </hbox>
    <vbox id="dialog-content" styleNames="dialog-content">
    </vbox>
    <box width="100%" id="dialog-footer-container" styleNames="dialog-footer-container">
        <hbox id="dialog-footer" styleNames="dialog-footer">
        </hbox>
    </box>
</vbox>
')
class DialogBase extends Box {
    public var modal:Bool = true;
    public var buttons:DialogButton2 = null;
    public var draggable:Bool = false;
    public var centerDialog:Bool = true;
    public var button:DialogButton2 = null;
    
    private var _overlay:Component;
    
    public function new() {
        super();
        dialogFooterContainer.hide();
        dialogCloseButton.onClick = function(e) {
            hideDialog(DialogButton2.CANCEL);
        }
    }
    
    public function showDialog(modal:Bool = true) {
        this.modal = modal;
        show();
    }
    
    public override function show() {
        if (modal) {
            _overlay = new Component();
            _overlay.id = "modal-background";
            _overlay.addClass("modal-background");
            _overlay.percentWidth = _overlay.percentHeight = 100;
            Screen.instance.addComponent(_overlay);
        }
        if (buttons != null) {
            for (button in buttons.toArray()) {
                var buttonComponent = new Button();
                buttonComponent.text = button.toString();
                buttonComponent.userData = button;
                buttonComponent.registerEvent(MouseEvent.CLICK, onFooterButtonClick);
                addFooterComponent(buttonComponent);
            }
        }
        Screen.instance.addComponent(this);
        if (centerDialog) {
            centerDialogComponent(cast(this, Dialog2));
        }
    }

    public override function hide() {
        if (modal && _overlay != null) {
            Screen.instance.removeComponent(_overlay);
        }
        Screen.instance.removeComponent(this);
        
        var event = new DialogEvent(DialogEvent.DIALOG_CLOSED);
        event.button = this.button;
        dispatch(event);
    }

    public function hideDialog(button:DialogButton2) {
        this.button = button;
        hide();
    }
    
    public var title(get, set):String;
    private function get_title():String {
        return dialogTitleLabel.text;
    }
    private function set_title(value:String):String {
        dialogTitleLabel.text = value;
        return value;
    }
    
    public override function addComponent(child:Component):Component {
        if (child.hasClass("dialog-container")) {
            return super.addComponent(child);
        }
        return dialogContent.addComponent(child);
    }
    
    public override function validateComponentLayout() {
        var b = super.validateComponentLayout();
        dialogTitle.width = this.layout.innerWidth;
        if (autoWidth == false) {
            dialogContent.width = this.layout.innerWidth;
        }
        return b;
    }
    
    public function addFooterComponent(c:Component) {
        dialogFooterContainer.show();
        dialogFooter.addComponent(c);
    }
    
    public function centerDialogComponent(dialog:Dialog2) {
        dialog.syncComponentValidation();
        var x = (Screen.instance.width / 2) - (dialog.componentWidth / 2);
        var y = (Screen.instance.height / 2) - (dialog.componentHeight / 2);
        dialog.moveComponent(x, y);
    }
    
    private function onFooterButtonClick(event:MouseEvent) {
        hideDialog(event.target.userData);
    }
}