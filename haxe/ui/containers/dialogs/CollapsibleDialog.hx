package haxe.ui.containers.dialogs;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Image;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.events.MouseEvent;

/**
 * A dialog with a minimize/maximize button in the title bar, which collapses the dialog body.
 */
@:composite(Builder)
class CollapsibleDialog extends Dialog {
    /**
     * Set this property to collapse/expand the dialog body.
     */
     @:clonable @:behaviour(Minimized, false)    public var minimized:Bool;
}

private class Minimized extends DataBehaviour {
    public override function validateData() {
        var dialogContent = _component.findComponent("dialog-content", Box);
        if (dialogContent == null) {
            return;
        }
        var dialogFooterContainer = _component.findComponent("dialog-footer-container", Box);
        if (dialogFooterContainer == null) {
            return;
        }
        var hasFooterComponents = false;
        var dialogFooter = _component.findComponent("dialog-footer", Box);
        if (dialogFooter != null) {
            hasFooterComponents = dialogFooter.numComponents > 0;
        }
        var dialogMinMaxButton = _component.findComponent("dialog-minmax-button", Image);
        if (dialogMinMaxButton == null) {
            return;
        }
        var offset = dialogContent.height;
        if (hasFooterComponents) {
            offset += dialogFooterContainer.height;
        }
        if (_value) {
            // Collapse the dialog.
            dialogMinMaxButton.swapClass("dialog-maximize-button", "dialog-minimize-button");
            dialogContent.hidden = true;
            dialogFooterContainer.hidden = true;
            _component.height -= offset;
        } else {
            dialogMinMaxButton.swapClass("dialog-minimize-button", "dialog-maximize-button");
            dialogContent.hidden = false;
            dialogFooterContainer.hidden = !hasFooterComponents;
            _component.height += offset;
        }
    }
}

@:dox(hide) @:noCompletion
private class Builder extends CompositeBuilder {
    private var _dialog:CollapsibleDialog;
    private var _dialogMinMaxButton:Image;
    
    public function new(dialog:CollapsibleDialog) {
        super(dialog);
        _dialog = dialog;
    }

    public override function onReady() {
        super.onReady();

        var dialogTitle = _component.findComponent("dialog-title", HBox, true);
        // Create the minimize/maximize button.
        _dialogMinMaxButton = new Image();
        _dialogMinMaxButton.id = "dialog-minmax-button";
        _dialogMinMaxButton.styleNames = "dialog-minimize-button";
        _dialogMinMaxButton.scriptAccess = false;
        _dialogMinMaxButton.registerEvent(MouseEvent.CLICK, onMinMaxButton);
        dialogTitle.addComponent(_dialogMinMaxButton);

        // Move the button before the close button
        dialogTitle.setComponentIndex(_dialogMinMaxButton, 1);
    }

    private function onMinMaxButton(_) {
        _dialog.minimized = !_dialog.minimized;
    }
}
