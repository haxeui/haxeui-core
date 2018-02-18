package haxe.ui.containers.dialogs;

/**
 Holds information about a `Button` to create in a `Dialog` button bar
**/
@:dox(icon = "/icons/application-dialog.png")
class DialogButton {
    public static inline var OK:Int = 0x000001;
    public static inline var CANCEL:Int = 0x000002;
    public static inline var CLOSE:Int = 0x000004;
    public static inline var CONFIRM:Int = 0x000008;
    public static inline var YES:Int = 0x000010;
    public static inline var NO:Int = 0x000020;

    public static inline var YES_NO:Int = 0x000010 | 0x000020;
    public static inline var YES_NO_CANCEL:Int = 0x000010 | 0x000020 | 0x000002;

    /**
     The string to use as the buttons text
    **/
    public var text:String;
    /**
     The image resource to use as the buttons icon
    **/
    public var icon:String;
    /**
     The identifier of this button
    **/
    public var id:String;
    /**
     Any additional styles names to apply to this button
    **/
    public var styleNames:String;
    /**
     Any inline styling to apply to this button
    **/
    public var style:String;
    /**
     Whether or not clicking this button will close the parent `Dialog` (_defaults to true_)
    **/
    public var closesDialog:Bool = true;

    public function new(id:String = null, text:String = null, closesDialog:Bool = true) {
        this.id = id;
        this.text = text;
        this.closesDialog = closesDialog;
    }
}
