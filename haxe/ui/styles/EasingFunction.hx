package haxe.ui.styles;

enum abstract EasingFunction(String) from String {
    /**
     Specifies an animation with the same speed from start to end.
    **/
    var LINEAR = "linear";

    /**
     Specifies an animation with a slow start, then fast, then end slowly.
    **/
    var EASE = "ease";

    /**
     Specifies an animation with a slow start.
    **/
    var EASE_IN = "easeIn";

    /**
     Specifies an animation with a slow end.
    **/
    var EASE_OUT = "easeOut";

    /**
     Specifies an animation with a slow start and end.
    **/
    var EASE_IN_OUT = "easeInOut";
}
