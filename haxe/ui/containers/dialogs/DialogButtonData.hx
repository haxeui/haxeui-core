package haxe.ui.containers.dialogs;

/**
 Holds information about a `Button` to create in a `Dialog` button bar
**/
typedef DialogButtonData = {
    /**
     The string to use as the buttons text
    **/
    text:String,
    /**
     The image resource to use as the buttons icon
    **/
    ?icon:String,
    /**
     The identifier of this button
    **/
    ?id:String,
    /**
     Any additional styles names to apply to this button
    **/
    ?styleNames:String,
    /**
     Any inline styling to apply to this button
    **/
    ?style:String,
    /**
     Whether or not clicking this button will close the parent `Dialog` (_defaults to true_)
    **/
    ?closesDialog:Bool
}
