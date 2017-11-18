package haxe.ui.styles.animation;

#if actuate
    typedef KeyFrame = haxe.ui.styles.animation.actuate.KeyFrame;
#else
    typedef KeyFrame = haxe.ui.styles.animation.none.KeyFrame;
#end