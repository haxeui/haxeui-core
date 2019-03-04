package haxe.ui.constants;

@:enum
abstract TransitionMode(String) from String to String {

    /**
        Without transition.
    **/
    var NONE = "none";

    /**
        From left or from right. It depends of new selectedIndex is greater or lower than the old selectedIndex.
    **/
    var HORIZONTAL_SLIDE = "horizontal-slide";

    /**
        Always from the left.
    **/
    var HORIZONTAL_SLIDE_FROM_LEFT = "horizontal-slide-from-left";

    /**
        Always from the right.
    **/
    var HORIZONTAL_SLIDE_FROM_RIGHT = "horizontal-slide-from-right";

    /**
        From top or from bottom. It depends of new selectedIndex is greater or lower than the old selectedIndex.
    **/
    var VERTICAL_SLIDE = "vertical-slide";

    /**
        Always from the top.
    **/
    var VERTICAL_SLIDE_FROM_TOP = "vertical-slide-from-top";

    /**
        Always from the bottom.
    **/
    var VERTICAL_SLIDE_FROM_BOTTOM = "vertical-slide-from-bottom";

    /**
        Opacity transition.
    **/
    var FADE = "fade";
}
