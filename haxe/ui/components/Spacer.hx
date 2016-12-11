package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.IClonable;

/**
 A general purpose spacer component
**/
class Spacer extends Component implements IClonable<Spacer> {
    public function new() {
        super();
        #if (openfl && !flixel)
        mouseChildren = false;
        #end
    }
}