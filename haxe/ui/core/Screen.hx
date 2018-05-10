package haxe.ui.core;

import haxe.ui.animation.AnimationManager;
import haxe.ui.backend.ScreenBase;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.DialogButton;
import haxe.ui.containers.dialogs.DialogOptions;
import haxe.ui.focus.FocusManager;
import haxe.ui.util.EventMap;

@:dox(hide)
class DialogEntry {
    public function new() {

    }

    public var overlay:Component;
    public var dialog:Dialog;
    public var callback:Int->Void;
}

class Screen extends ScreenBase {

    private static var _instance:Screen;
    public static var instance(get, never):Screen;
    private static function get_instance():Screen {
        if (_instance == null) {
            _instance = new Screen();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance
    //***********************************************************************************************************
    public var rootComponents:Array<Component>;

    private var _dialogs:Map<Dialog, DialogEntry>;
    private var _eventMap:EventMap;

    public function new() {
        super();
        rootComponents = [];
        _dialogs = new Map<Dialog, DialogEntry>();
        _eventMap = new EventMap();
    }

    public override function addComponent(component:Component) {
        super.addComponent(component);
        component.ready();
        rootComponents.push(component);
        FocusManager.instance.pushView(component);
        component.registerEvent(UIEvent.RESIZE, _onRootComponentResize);    //refresh vh & vw
    }

    public override function removeComponent(component:Component) {
        super.removeComponent(component);
        component.depth = -1;
        rootComponents.remove(component);
        component.unregisterEvent(UIEvent.RESIZE, _onRootComponentResize);
    }

    public function setComponentIndex(child:Component, index:Int) {
        if (index >= 0 && index <= rootComponents.length) {
            handleSetComponentIndex(child, index);
            rootComponents.remove(child);
            rootComponents.insert(index, child);
        }
    }

    public function refreshStyleRootComponents() {
        for (component in rootComponents) {
            _refreshStyleComponent(component);
        }
    }

    @:access(haxe.ui.core.Component)
    private function _refreshStyleComponent(component:Component) {
        for (child in component.childComponents) {
//            child.applyStyle(child.style);
            child.invalidateComponentStyle();
            child.invalidateComponentDisplay();
            _refreshStyleComponent(child);
        }
    }

    private function _onRootComponentResize(e:UIEvent) {
        _refreshStyleComponent(e.target);
    }

    //***********************************************************************************************************
    // Dialogs
    //***********************************************************************************************************
    public override function messageDialog(message:String, title:String = null, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        var dialog = super.messageDialog(message, title, options, callback);
        if (dialog != null) {
            return dialog;
        }

        var dialogOptions:DialogOptions = new DialogOptions();

        var dialogOptions:DialogOptions = createDialogOptions(options);
        if (dialogOptions.buttons.length == 0) {
            dialogOptions.addStandardButton(DialogButton.OK);
        }
        if (title != null) {
            dialogOptions.title = title;
        }

        var content:HBox = new HBox();
        content.percentWidth = 100;

        if (dialogOptions.icon > 0) {
            var image:haxe.ui.components.Image = new haxe.ui.components.Image();
            image.id = "message-dialog-icon";
            image.styleNames = "message-dialog-icon";
            switch (dialogOptions.icon) { // TODO: needs to be style
                case DialogOptions.ICON_ERROR:
                    image.resource = "haxeui-core/styles/default/dialogs/cross-circle.png";
                case DialogOptions.ICON_INFO:
                    image.resource = "haxeui-core/styles/default/dialogs/information.png";
                case DialogOptions.ICON_WARNING:
                    image.resource = "haxeui-core/styles/default/dialogs/exclamation.png";
                case DialogOptions.ICON_QUESTION:
                    image.resource = "haxeui-core/styles/default/dialogs/question.png";

            }
            content.addComponent(image);
        }

        var label:Label = new Label();
        label.percentWidth = 100;
        label.text = message;
        label.id = "message-dialog-message";
        label.addClass("message-dialog-message");

        content.addComponent(label);

        return showDialog(content, dialogOptions, callback);
    }

    public override function showDialog(content:Component, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        var dialog = super.showDialog(content, options, callback);
        if (dialog != null) {
            return dialog;
        }

        var overlay:Component = new Component();
        overlay.id = "modal-background";
        overlay.addClass("modal-background");
        overlay.percentWidth = overlay.percentHeight = 100;
        addComponent(overlay);

        var dialog:Dialog = new Dialog();
        dialog.callback = callback;
        dialog.dialogOptions = createDialogOptions(options);
        content.addClass("dialog-content");
        dialog.addComponent(content);
        addComponent(dialog);
        centerDialog(dialog);

        //var animation:Animation = AnimationManager.instance.get("haxe.ui.components.animation.dialog.show");
        var x = (width / 2) - (dialog.componentWidth / 2);
        var y = (height / 2) - (dialog.componentHeight / 2);
        var vars:Map<String, Float> = [
            "startLeft" => x,
            "startTop" => y + 20,
            "endLeft" => x,
            "endTop" => y
        ];
        AnimationManager.instance.run("haxe.ui.components.animation.dialog.show", ["target" => dialog], vars);
        //animation.r

        var entry:DialogEntry = new DialogEntry();
        entry.overlay = overlay;
        entry.dialog = dialog;
        _dialogs.set(dialog, entry);

        if (Lambda.count(_dialogs) == 1) {
            for (r in rootComponents) {
                r.addClass("modal-component");
            }
        }

        return dialog;
    }

    private static function createDialogOptions(options:Dynamic):DialogOptions {
        if (Std.is(options, DialogOptions)) {
            return cast(options, DialogOptions);
        }

        var dialogOptions:DialogOptions = new DialogOptions();

        var o:Dynamic = { };
        if (options == null) {
            o = { };
        } else if (Std.is(options, Int)) {
            var n:Int = cast(options, Int);
            o.buttons = [n];
            o.icon = n;
        } else {
            o = options;
        }

        if (o.buttons == null) {
            o.buttons = [DialogButton.OK];
        } else if (Std.is(o.buttons, Int)) {
            o.buttons = [options.buttons];
        }

        if (o.title == null) {
            o.title = "HaxeUI";
        }

        var buttons:Array<Dynamic> = o.buttons;
        for (b in buttons) {
            if (Std.is(b, Int)) {
                if (b & DialogButton.OK == DialogButton.OK) {
                    dialogOptions.addStandardButton(DialogButton.OK);
                }
                if (b & DialogButton.CANCEL == DialogButton.CANCEL) {
                    dialogOptions.addStandardButton(DialogButton.CANCEL);
                }
                if (b & DialogButton.CLOSE == DialogButton.CLOSE) {
                    dialogOptions.addStandardButton(DialogButton.CLOSE);
                }
                if (b & DialogButton.CONFIRM == DialogButton.CONFIRM) {
                    dialogOptions.addStandardButton(DialogButton.CONFIRM);
                }
                if (b & DialogButton.YES == DialogButton.YES) {
                    dialogOptions.addStandardButton(DialogButton.YES);
                }
                if (b & DialogButton.NO == DialogButton.NO) {
                    dialogOptions.addStandardButton(DialogButton.NO);
                }
            } else {
                var dialogButton:DialogButton = new DialogButton();
                dialogButton.id = b.id;
                dialogButton.text = b.text;
                dialogButton.icon = b.icon;
                if (b.closesDialog != null) {
                    dialogButton.closesDialog = b.closesDialog;
                }
                dialogOptions.addButton(dialogButton);
            }
        }

        if (o.icon != null) {
            if (o.icon & DialogOptions.ICON_ERROR == DialogOptions.ICON_ERROR) {
                dialogOptions.icon = DialogOptions.ICON_ERROR;
            } else if (o.icon & DialogOptions.ICON_INFO == DialogOptions.ICON_INFO) {
                dialogOptions.icon = DialogOptions.ICON_INFO;
            } else if (o.icon & DialogOptions.ICON_WARNING == DialogOptions.ICON_WARNING) {
                dialogOptions.icon = DialogOptions.ICON_WARNING;
            } else if (o.icon & DialogOptions.ICON_QUESTION == DialogOptions.ICON_QUESTION) {
                dialogOptions.icon = DialogOptions.ICON_QUESTION;
            }
        }

        dialogOptions.title = o.title;
        dialogOptions.styleNames = o.styleNames;

        return dialogOptions;
    }

    public override function hideDialog(dialog:Dialog):Bool {
        if (super.hideDialog(dialog) == true) {
            return true;
        }

        var entry:DialogEntry = _dialogs.get(dialog);
        if (entry == null) {
            return false;
        }

        var x = dialog.left;
        var vars:Map<String, Float> = [
            "startLeft" => dialog.left,
            "startTop" => dialog.top,
            "endLeft" => x,
            "endTop" => dialog.top - 20
        ];
        AnimationManager.instance.run("haxe.ui.components.animation.dialog.hide", ["target" => dialog], vars, function() {
            Screen.instance.removeComponent(entry.dialog);
            Screen.instance.removeComponent(entry.overlay);
            _dialogs.remove(dialog);

            if (Lambda.count(_dialogs) == 0) {
                for (r in rootComponents) {
                    r.removeClass("modal-component");
                }
            }
        });

        return true;
    }

    public function centerDialog(dialog:Dialog) {
        dialog.syncValidation();
        var x = (width / 2) - (dialog.componentWidth / 2);
        var y = (height / 2) - (dialog.componentHeight / 2);
        dialog.moveComponent(x, y);
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    public function registerEvent(type:String, listener:Dynamic->Void) {
        if (supportsEvent(type) == true) {
            if (_eventMap.add(type, listener) == true) {
                mapEvent(type, _onMappedEvent);
            }
        } else {
            //#if debug
            trace('WARNING: Screen event "${type}" not supported');
            //#end
        }
    }

    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (_eventMap.remove(type, listener) == true) {
            unmapEvent(type, _onMappedEvent);
        }
    }

    private function _onMappedEvent(event:UIEvent) {
        _eventMap.invoke(event.type, event);
    }
}
