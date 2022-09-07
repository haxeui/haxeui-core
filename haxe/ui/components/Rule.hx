package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDirectionalComponent;

/**
 * A simple rule component, that crosses the parent container.
 */
@:composite(RuleBuilder)
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

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class RuleBuilder extends CompositeBuilder {
    public function new(component:Component) {
        super(component);
        showWarning();
    }
    
    private function showWarning() {
        trace("WARNING: trying to create an instance of 'Rule' directly, use either 'HorizontalRule' or 'VerticalRule'");
    }
}