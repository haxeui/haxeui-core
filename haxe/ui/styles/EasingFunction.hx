package haxe.ui.styles;

enum EasingFunction {
    /**
     Specifies an animation with the same speed from start to end.
    **/
    LINEAR;

    /**
     Specifies an animation with a slow start, then fast, then end slowly.
    **/
    EASE;

    /**
     Specifies an animation with a slow start.
    **/
    EASE_IN;

    /**
     Specifies an animation with a slow end.
    **/
    EASE_OUT;

    /**
     Specifies an animation with a slow start and end.
    **/
    EASE_IN_OUT;
}
