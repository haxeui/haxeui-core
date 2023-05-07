package haxe.ui.actions;

// action types here are "logical" actions, so "press" doesnt mean mouse / screen / key press,
// it means "press on a button" (could be hardware button), so for example
// you "press" a key on the keyboard, but only pressing the space key might dispatch the
// "press" action type
enum abstract ActionType(String) from String to String {
    var PRESS = "actionPress";
    var LEFT = "actionLeft";
    var RIGHT = "actionRight";
    var UP = "actionUp";
    var DOWN = "actionDown";
    var NEXT = "actionNext";
    var PREVIOUS = "actionPrevious";
    var BACK = "actionBack";
    var OK = "actionOK";
    var CONFIRM = "actionConfirm";
    var CANCEL = "actionCancel";
}