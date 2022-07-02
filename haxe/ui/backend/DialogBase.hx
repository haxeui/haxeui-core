package haxe.ui.backend;

import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.containers.Box;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

@:dox(hide) @:noCompletion
class DialogBase extends Box {
    public var modal:Bool = true;
    public var autoCenterDialog:Bool = true;
    public var buttons:DialogButton = null;
    public var centerDialog:Bool = true;
    public var button:DialogButton = null;

    private var _overlay:Component;

    public var dialogContainer:haxe.ui.containers.VBox;
    public var dialogTitle:haxe.ui.containers.HBox;
    public var dialogTitleLabel:haxe.ui.components.Label;
    public var dialogCloseButton:haxe.ui.components.Image;
    public var dialogContent:haxe.ui.containers.VBox;
    public var dialogFooterContainer:haxe.ui.containers.Box;
    public var dialogFooter:haxe.ui.containers.HBox;

    public var destroyOnClose:Bool = true;
    
    public function new() {
        super();

        dialogContainer = new haxe.ui.containers.VBox();
        dialogContainer.id = "dialog-container";
        dialogContainer.styleNames = "dialog-container";
        addComponent(dialogContainer);

        dialogTitle = new haxe.ui.containers.HBox();
        dialogTitle.id = "dialog-title";
        dialogTitle.styleNames = "dialog-title";
        dragInitiator = dialogTitle;
        dialogContainer.addComponent(dialogTitle);

        dialogTitleLabel = new haxe.ui.components.Label();
        dialogTitleLabel.id = "dialog-title-label";
        dialogTitleLabel.styleNames = "dialog-title-label";
        dialogTitleLabel.text = "HaxeUI";
        dialogTitle.addComponent(dialogTitleLabel);

        dialogCloseButton = new haxe.ui.components.Image();
        dialogCloseButton.id = "dialog-close-button";
        dialogCloseButton.styleNames = "dialog-close-button";
        dialogTitle.addComponent(dialogCloseButton);

        dialogContent = new haxe.ui.containers.VBox();
        dialogContent.id = "dialog-content";
        dialogContent.styleNames = "dialog-content";
        dialogContent.registerEvent(UIEvent.RESIZE, onContentResize);
        dialogContainer.addComponent(dialogContent);

        dialogFooterContainer = new haxe.ui.containers.Box();
        dialogFooterContainer.id = "dialog-footer-container";
        dialogFooterContainer.styleNames = "dialog-footer-container";
        dialogContainer.addComponent(dialogFooterContainer);

        dialogFooter = new haxe.ui.containers.HBox();
        dialogFooter.id = "dialog-footer";
        dialogFooter.styleNames = "dialog-footer";
        dialogFooter.registerEvent(UIEvent.RESIZE, onFooterResize);
        dialogFooterContainer.addComponent(dialogFooter);

        dialogFooterContainer.hide();
        dialogCloseButton.onClick = function(e) {
            hideDialog(DialogButton.CANCEL);
        }
    }

    private var _autoSizeDialog:Bool = false;
    private override function onReady() {
        super.onReady();
        _autoSizeDialog = this.autoWidth;
    }
    
    private var _dialogParent:Component = null;
    public var dialogParent(get, set):Component;
    private function get_dialogParent():Component {
        return _dialogParent;
    }
    private function set_dialogParent(value:Component):Component {
        _dialogParent = value;
        return value;
    }

    public function showDialog(modal:Bool = true) {
        this.modal = modal;
        show();
    }

    private var _forcedLeft:Null<Float> = null;
    private override function set_left(value:Null<Float>):Null<Float> {
        super.set_left(value);
        autoCenterDialog = false;
        _forcedLeft = value;
        return value;
    }
    
    private var _forcedTop:Null<Float> = null;
    private override function set_top(value:Null<Float>):Null<Float> {
        super.set_top(value);
        autoCenterDialog = false;
        _forcedTop = value;
        return value;
    }
    
    public override function show() {
        #if !haxeui_flixel
        handleVisibility(false);
        #end
        var dp = dialogParent;
        if (modal) {
            if (_overlay != null) {
                return;
            }
            _overlay = new Component();
            _overlay.id = "modal-background";
            _overlay.addClass("modal-background");
            _overlay.percentWidth = _overlay.percentHeight = 100;
            _overlay.onClick = function(_) {
                if (closable) {
                    hideDialog(DialogButton.CANCEL);
                }
            }
            if (dp != null) {
                dp.addComponent(_overlay);
            } else {
                Screen.instance.addComponent(_overlay);
            }
        }
        createButtons();

        if (dp != null) {
            dp.addComponent(this);
        } else {
            Screen.instance.addComponent(this);
        }
        this.syncComponentValidation();
        if (autoHeight == false) {
            dialogContainer.percentHeight = 100;
            dialogContent.percentHeight = 100;
        }
        if (centerDialog) {
            centerDialogComponent(cast(this, Dialog));
        }
        
        Toolkit.callLater(function() {
            if (centerDialog) {
                centerDialogComponent(cast(this, Dialog));
            }
            Toolkit.callLater(function() {
                handleVisibility(true);
                centerDialogComponent(cast(this, Dialog));
                _forcedLeft = null;
                _forcedTop = null;
                if (autoCenterDialog) {
                    Screen.instance.registerEvent(UIEvent.RESIZE, _onScreenResized);
                }
            });
        });
    }

    private function _onScreenResized(_) {
        _forcedLeft = null;
        _forcedTop = null;
        centerDialogComponent(cast this);
    }
    
    private var _buttonsCreated:Bool = false;
    private function createButtons() {
        if (_buttonsCreated == true) {
            return;
        }
        if (buttons != null) {
            for (button in buttons.toArray()) {
                var buttonComponent = new Button();
                buttonComponent.id = button.toString().toLowerCase();
                var text = button.toString();
                buttonComponent.text = text;
                buttonComponent.userData = button;
                buttonComponent.registerEvent(MouseEvent.CLICK, onFooterButtonClick);
                addFooterComponent(buttonComponent);
            }
            _buttonsCreated = true;
        }
    }

    public var closable(get, set):Bool;
    private function get_closable():Bool {
        return !dialogCloseButton.hidden;
    }
    private function set_closable(value:Bool):Bool {
        if (value == true) {
            dialogCloseButton.show();
        } else {
            dialogCloseButton.hide();
        }
        return value;
    }

    private function validateDialog(button:DialogButton, fn:Bool->Void) {
        fn(true);
    }

    public override function hide() {
        validateDialog(this.button, function(result) {
            if (result == true) {
                var dp = dialogParent;
                
                var event = new DialogEvent(DialogEvent.DIALOG_CLOSED);
                event.button = this.button;
                dispatch(event);
                if (event.canceled == true) {
                    return;
                }
                
                if (modal && _overlay != null) {
                    if (dp != null) {
                        dp.removeComponent(_overlay);
                    } else {
                        Screen.instance.removeComponent(_overlay);
                    }
                }
                if (dp != null) {
                    dp.removeComponent(this, destroyOnClose);
                } else {
                    Screen.instance.removeComponent(this, destroyOnClose);
                }
            }
        });
    }

    public function hideDialog(button:DialogButton) {
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

    public override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        dialogTitle.width = this.layout.innerWidth;
        if (_autoSizeDialog == false) {
            var offset = this.layout.paddingLeft + this.layout.paddingRight;
            if (dialogContent.width != this.width - offset) {
                dialogContent.width = this.width - offset;
            }
            if (dialogFooterContainer.width != this.width - offset) {
                dialogFooterContainer.width = this.width - offset;
            }
        }
        
        return b;
    }

    private override function onDestroy() {
        super.onDestroy();
        if (_overlay != null) {
            Screen.instance.removeComponent(_overlay);
            _overlay = null;
        }
        Screen.instance.unregisterEvent(UIEvent.RESIZE, _onScreenResized);
    }
    
    private function onContentResize(e) {
        if (dialogFooter.width <= 0 || dialogFooterContainer.width <= 0 || _autoSizeDialog == false) {
            return;
        }

        var cx = Math.max(dialogFooter.width, dialogContent.width);
        var offset = this.layout.paddingLeft + this.layout.paddingRight;
        var recenter:Bool = false;
        
        if (cx > 0 && cx != this.width + offset) {
            this.width = cx + offset;
            recenter = true;
        }
        
        if (dialogFooterContainer.width != this.width - offset) {
            dialogFooterContainer.width = this.width - offset;
        }
        
        if (recenter == true && autoCenterDialog == true) {
            centerDialogComponent(cast(this, Dialog), false);
        }
    }
    
    private function onFooterResize(e) {
        if (dialogFooter.width <= 0 || dialogFooterContainer.width <= 0 || _autoSizeDialog == false) {
            return;
        }
        var cx = Math.max(dialogFooter.width, dialogContent.width);
        var offset = this.layout.paddingLeft + this.layout.paddingRight;
        var recenter:Bool = false;
        
        if (cx > 0 && cx != this.width + offset) {
            this.width = cx + offset;
            recenter = true;
        }
        
        if (dialogFooterContainer.width != this.width - offset) {
            dialogFooterContainer.width = this.width - offset;
        }
        
        if (recenter == true && autoCenterDialog == true) {
            centerDialogComponent(cast(this, Dialog), false);
        }
    }
    
    public function addFooterComponent(c:Component) {
        dialogFooterContainer.show();
        dialogFooter.addComponent(c);
    }

    public function centerDialogComponent(dialog:Dialog, validate:Bool = true) {
        if (validate == true) {
            dialog.syncComponentValidation();
        }
        var dp = dialogParent;
        if (dp != null) {
            if (validate == true) {
                dp.syncComponentValidation();
            }
            var x = (dp.actualComponentWidth / 2) - (dialog.actualComponentWidth / 2);
            if (_forcedLeft != null && _forcedLeft > 0) {
                x = _forcedLeft;
            }
            var y = (dp.actualComponentHeight / 2) - (dialog.actualComponentHeight / 2);
            if (_forcedTop != null && _forcedTop > 0) {
                y = _forcedTop;
            }
            dialog.moveComponent(x, y);
        } else {
            var x = (Screen.instance.actualWidth / 2) - (dialog.actualComponentWidth / 2);
            if (_forcedLeft != null && _forcedLeft > 0) {
                x = _forcedLeft;
            }
            var y = (Screen.instance.actualHeight / 2) - (dialog.actualComponentHeight / 2);
            if (_forcedTop != null && _forcedTop > 0) {
                y = _forcedTop;
            }
            dialog.moveComponent(x, y);
        }
    }

    private function onFooterButtonClick(event:MouseEvent) {
        hideDialog(event.target.userData);
    }
}
