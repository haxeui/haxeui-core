package haxe.ui.components;

import haxe.ui.core.Component;

/**
 A general purpose spacer component
**/
class Spacer extends Component {
    public function new() {
        super();
        #if (haxeui_openfl && !haxeui_flixel)
        mouseChildren = false;
        #end
    }
}