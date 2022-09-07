package haxe.ui.components;
import haxe.ui.components.Rule.RuleBuilder;

/**
 * A horizontal rule component, similar to the HTML `<hr>` tag.
 */
@:composite(Builder)
class HorizontalRule extends Rule {

    /**
     * Creates a new horizontal rule.
     */
    public function new() {
        super();
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends RuleBuilder {
    private override function showWarning() { // do nothing
    }
}