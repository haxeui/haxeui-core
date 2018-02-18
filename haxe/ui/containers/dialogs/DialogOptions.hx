package haxe.ui.containers.dialogs;

/**
 Holds options associated with instances of `Dialog`
**/
class DialogOptions {
    public static inline var ICON_ERROR:Int = 0x000100;
    public static inline var ICON_INFO:Int = 0x000200;
    public static inline var ICON_WARNING:Int = 0x000400;
    public static inline var ICON_QUESTION:Int = 0x000800;

    /**
     Array of button definitions in this `Dialog`

     *Note*: a button definition is different from a button instance
    **/
    public var buttons:Array<DialogButton> = [];
    /**
     The string to display in the dialogs title bar
    **/
    public var title:String;
    /**
     The predefined icon of this dialog, values can be:

        - `ICON_ERROR` - Error icon

        - `ICON_INFO` - Info icon

        - `ICON WARNING` - Warning icon

        - `ICON_QUESTION` - Question icon
    **/
    public var icon:Int;
    /**
     Any additional styles names to apply to this dialog
    **/
    public var styleNames:String;

    public function new() {

    }

    /**
     Adds a predefined button definition, values can be:

        - `DialogButton.OK`

        - `DialogButton.CANCEL`

        - `DialogButton.CLOSE`

        - `DialogButton.CONFIRM`

        - `DialogButton.YES`

        - `DialogButton.NO`
    **/
    public function addStandardButton(button:Int) {
        switch (button) {
            case DialogButton.OK:
                var b = new DialogButton();
                b.text = "OK";
                b.id = '${DialogButton.OK}';
                b.styleNames = "dialog-button dialog-button-ok";
                addButton(b);
            case DialogButton.CANCEL:
                var b = new DialogButton();
                b.text = "Cancel";
                b.id = '${DialogButton.CANCEL}';
                b.styleNames = "dialog-button dialog-button-cancel";
                addButton(b);
            case DialogButton.CLOSE:
                var b = new DialogButton();
                b.text = "Close";
                b.id = '${DialogButton.CLOSE}';
                b.styleNames = "dialog-button dialog-button-close";
                addButton(b);
            case DialogButton.CONFIRM:
                var b = new DialogButton();
                b.text = "Confirm";
                b.id = '${DialogButton.CONFIRM}';
                b.styleNames = "dialog-button dialog-button-confirm";
                addButton(b);
            case DialogButton.YES:
                var b = new DialogButton();
                b.text = "Yes";
                b.id = '${DialogButton.YES}';
                b.styleNames = "dialog-button dialog-button-yes";
                addButton(b);
            case DialogButton.NO:
                var b = new DialogButton();
                b.text = "No";
                b.id = '${DialogButton.NO}';
                b.styleNames = "dialog-button dialog-button-no";
                addButton(b);
            default:
        }
    }

    /**
     Adds a button definition
    **/
    public function addButton(button:DialogButton) {
        buttons.push(button);
    }
}
