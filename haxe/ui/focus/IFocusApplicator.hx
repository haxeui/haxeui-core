package haxe.ui.focus;

import haxe.ui.core.Component;

interface IFocusApplicator {
    function apply(target:Component):Void;
    function unapply(target:Component):Void;
    var enabled(get, set):Bool;
}