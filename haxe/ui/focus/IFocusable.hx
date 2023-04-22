package haxe.ui.focus;

interface IFocusable {
    public var focus(get, set):Bool;
    public var allowFocus(get, set):Bool;
    public var autoFocus(get, set):Bool;
    public var disabled(get, set):Bool;
}
