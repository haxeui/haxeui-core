package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.IDirectionalComponent;

/**
 * A simple rule component, that crosses the parent container.
 */
class Rule extends Component implements IDirectionalComponent {

    /**
     * Creates a new rule component.
     */
    private function new() {
        super();
        #if (haxeui_openfl && !haxeui_flixel)
        mouseChildren = false;
        #end
    }
}