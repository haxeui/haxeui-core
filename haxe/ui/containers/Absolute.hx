package haxe.ui.containers;

import haxe.ui.core.Component;
import haxe.ui.layouts.AbsoluteLayout;
import haxe.ui.core.IClonable;

/**
 `Layout` that does not modify a components `top` or `left` positions
**/
@:dox(icon="/icons/ui-layered-pane.png") 
class Absolute extends Box implements IClonable<Absolute> {
	public function new() {
		super();
		layout = new AbsoluteLayout();
	}
}