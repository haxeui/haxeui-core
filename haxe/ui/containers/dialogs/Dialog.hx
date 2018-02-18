package haxe.ui.containers.dialogs;

import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.layouts.VerticalLayout;

/**
 Class returned from `Screen.instance.showDialog` or `Screen.instance.messageDialog`
**/
@:dox(icon = "/icons/application-sub.png")
class Dialog extends Component {
    private var _titleBar:Box;
    private var _buttons:HBox;

    private var _title:Label;
    private var _closeButton:Button;

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() {
        layout = new VerticalLayout();
    }

    private function createTitleBar() {
        if (native == true) {
            return;
        }
        if (_titleBar == null) {
            _titleBar = new Box();
            _titleBar.id = "dialog-title-bar";
            _titleBar.addClass("dialog-title-bar");

            _title = new Label();
            _title.text = _options.title;
            _title.id = "dialog-title";
            _title.addClass("dialog-title");
            _titleBar.addComponent(_title);

            _closeButton = new Button();
            _closeButton.id = "dialog-close-button";
            _closeButton.addClass("dialog-close-button");
            _closeButton.registerEvent(MouseEvent.CLICK, _onButtonClick);
            var dialogButton:DialogButton = new DialogButton();
            dialogButton.closesDialog = true;
            dialogButton.id = '${DialogButton.CLOSE}';
            _closeButton.userData = dialogButton;
            _titleBar.addComponent(_closeButton);

            addComponent(_titleBar);
        }
    }

    private function createButtonBar() {
        if (_buttons == null && _options != null && _options.buttons.length > 0) {
            _buttons = new HBox();
            _buttons.id = "dialog-buttons";
            _buttons.addClass("dialog-buttons");

            for (b in _options.buttons) {
                addButton(b);
            }

            addComponent(_buttons);
        }
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    public override function addComponent(child:Component):Component {
        var r = null;
        if (child == _titleBar || child == _buttons) {
            r = super.addComponent(child);
        } else {
            child.addClass("dialog-content");
            r = super.addComponent(child);
            createButtonBar();
        }

        return r;
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    /**
     Closes this dialog and removes it from the `Screen`
    **/
    public function close(buttonId:String = null) {
        screen.hideDialog(this);
        
        var dialogButton = null;
        
        if (_buttons != null) {
            var button = _buttons.findComponent(buttonId);
            if (button != null) {
                dialogButton = cast(button, DialogButton);
            }
        }
        
        if (dialogButton == null) {
            dialogButton = new DialogButton(buttonId);
        }
        
        if (callback != null) {
            callback(dialogButton);
        }
    }

    /**
     Adds a button to the button bar of this dialog
    **/
    public function addButton(dialogButton:DialogButton):Button {
        if (_buttons == null) {
            createButtonBar();
        }

        var button = new Button();
        button.id = dialogButton.id;
        button.text = dialogButton.text;
        button.styleNames = dialogButton.styleNames;
        button.styleString = dialogButton.style;
        button.icon = dialogButton.icon;
        button.userData = dialogButton;
        button.registerEvent(MouseEvent.CLICK, _onButtonClick);

        _buttons.addComponent(button);

        return button;
    }

    private var _options:DialogOptions;
    /**
     Sets (or gets) the dialog options associated with this dialog instance
    **/
    public var dialogOptions(get, set):DialogOptions;
    private function get_dialogOptions():DialogOptions {
        return _options;
    }
    private function set_dialogOptions(value:DialogOptions):DialogOptions {
        _options = value;
        if (_options.styleNames != null) {
            styleNames = _options.styleNames;
        }
        createTitleBar();
        return value;
    }

    /**
     The callback function to invoke when one of the dialog buttons has been clicked
    **/
    public var callback:DialogButton->Void;

    //***********************************************************************************************************
    // Event Handlers
    //***********************************************************************************************************
    private function _onButtonClick(event:MouseEvent) {
        var dialogButton = null;
        if (event.target.userData != null) {
            dialogButton = cast(event.target.userData, DialogButton);
        }
        if (dialogButton == null || dialogButton.closesDialog == true) {
            close();
        }
        if (callback != null) {
            callback(dialogButton);
        }
    }
}