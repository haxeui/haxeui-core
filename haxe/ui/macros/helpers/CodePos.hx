package haxe.ui.macros.helpers;

enum CodePos {
    Start;
    End;
    AfterSuper;
    Pos(pos:Int);
}