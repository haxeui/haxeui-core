package haxe.ui.constants;

enum abstract AnimationDirection(String) from String to String {
    /**
     The animation is played as normal (forwards).
    **/
    var NORMAL = "normal";

    /**
     The animation is played in reverse direction (backwards).
    **/
    var REVERSE = "reverse";

    /**
     The animation is played forwards first, then backwards.
    **/
    var ALTERNATE = "alternate";

    /**
     The animation is played backwards first, then forwards.
    **/
    var ALTERNATE_REVERSE = "alternate-reverse";
}
