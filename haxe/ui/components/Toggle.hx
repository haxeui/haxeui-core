package haxe.ui.components;

/**
 * Just a regular button, but defaults to toggle mode.
 * 
 * shortens this:
 * ```haxe
 * var button = new Button();
 * button.toggle = true;
 * ```
 * to this:
 * ```haxe
 * var toggle = new Toggle();
 * ```
 */
class Toggle extends Button {

    /**
     * Creates a new toggling button.
     */
    public function new() {
        super();
        this.toggle = true;
    }
}