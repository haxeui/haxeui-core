package haxe.ui.constants;

enum abstract AnimationFillMode(String) from String to String {
    /**
     Animation will not apply any styles to the target before or after it is executing.
    **/
    var NONE = "none";

    /**
     The target will retain the style values that is set by the last keyframe (depends on animation direction and
     animation iteration count).
    **/
    var FORWARDS = "forwards";

    /**
     The target will get the style values that is set by the first keyframe (depends on animation direction),
     and retain this during the animation delay period).
    **/
    var BACKWARDS = "backwards";

    /**
     The animation will follow the rules for both forwards and backwards, extending the animation properties
     in both directions.
    **/
    var BOTH = "both";
}
