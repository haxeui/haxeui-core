package haxe.ui.containers;

import haxe.ui.core.Component;
import haxe.ui.layouts.HorizontalLayout;
import haxe.ui.core.IClonable;

/**
 A `Box` component that lays its children out horizontally
**/
@:dox(icon="/icons/ui-split-panel.png") 
class HBox extends Box implements IClonable<HBox> {
	public function new() {
		super();
		layout = new HorizontalLayout();
	}
}