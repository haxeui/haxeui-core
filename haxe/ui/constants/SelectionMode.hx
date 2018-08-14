package haxe.ui.constants;

@:enum
abstract SelectionMode(String) from String to String {
    var DISABLED = "disabled";
    var ONE_ITEM = "one-item";
    var ONE_ITEM_REPEATED = "one-item-repeated";
    var MULTIPLE_CTRL = "multiple-ctrl";
    var MULTIPLE_SHIFT = "multiple-shift";
    var MULTIPLE_LONG_PRESS = "multiple-long-press";
}
