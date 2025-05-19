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

    /**
     Specifies an animation with a quadratic slow start.
    **/
    var QUAD_IN = "quadIn";
    
    /**
     Specifies an animation with a quadratic slow end.
    **/
    var QUAD_OUT = "quadOut";
    
    /**
     Specifies an animation with a quadratic slow start and end.
    **/
    var QUAD_IN_OUT = "quadInOut";
    
    /**
     Specifies an animation with a cubic slow start.
    **/
    var CUBIC_IN = "cubicIn";

    /**
     Specifies an animation with a cubic slow end.
    **/    
    var CUBIC_OUT = "cubicOut";
    
    /**
     Specifies an animation with a cubic slow start and end.
    **/
    var CUBIC_IN_OUT = "cubicInOut";
    
    /**
     Specifies an animation with a quartic slow start.
    **/
    var QUART_IN = "quartIn";
    
    /**
     Specifies an animation with a quartic slow end.
    **/
    var QUART_OUT = "quartOut";
 
    /**
     Specifies an animation with a quartic slow start and end.
    **/   
    var QUART_IN_OUT = "quartInOut";
}
