package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.IDirectionalComponent;

class Rule extends Component implements IDirectionalComponent {
    public function new() {
        super();
        #if (haxeui_openfl && !haxeui_flixel)
        mouseChildren = false;
        #end
    }
}