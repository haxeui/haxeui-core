package haxe.ui.styles;

enum Dimension {
    PERCENT(value:Float);
    PX(value:Float);
    VW(value:Float);
    VH(value:Float);
    VMIN(value:Float);
    REM(value:Float);
    CALC(s:String);
}
