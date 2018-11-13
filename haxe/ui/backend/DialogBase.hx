package haxe.ui.backend;

import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;

@:xml('
<vbox styleNames="dialog-container">
    <hbox id="dialog-title" styleNames="dialog-title">
        <label id="dialog-title-label" styleNames="dialog-title-label" text="HaxeUI" />
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
    
    public function new() {
        super();
        dialogFooterContainer.hide();
    }
    
    public override function show() {
        Screen.instance.addComponent(this);
    }

    public override function addComponent(child:Component):Component {
        if (child.hasClass("dialog-container")) {
            return super.addComponent(child);
        }
        return dialogContent.addComponent(child);
    }
    
    public function addFooterComponent(c:Component) {
        dialogFooterContainer.show();
        dialogFooter.addComponent(c);
    }
}