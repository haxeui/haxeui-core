package haxe.ui.constants;

enum abstract SelectionMode(String) from String to String {
    var DISABLED = "disabled";
    var ONE_ITEM = "one-item";
    var ONE_ITEM_REPEATED = "one-item-repeated";
    var MULTIPLE = "multiple"; // same as 'multiple-click-modifier-key', just shorter
    var MULTIPLE_CLICK_MODIFIER_KEY = "multiple-click-modifier-key";
    var MULTIPLE_MODIFIER_KEY = "multiple-modifier-key";
    var MULTIPLE_LONG_PRESS = "multiple-long-press";
}
