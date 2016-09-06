package haxe.ui.core;

import haxe.ui.components.Label;
import haxe.ui.containers.HBox;

class BasicItemRenderer extends ItemRenderer {
    public function new() {
        super();

        addClass("itemrenderer"); // TODO: shouldnt have to do this
        this.percentWidth = 100;

        var hbox:HBox = new HBox();
        hbox.percentWidth = 100;

        var label:Label = new Label();
        label.id = "value";
        label.percentWidth = 100;
        hbox.addComponent(label);

        addComponent(hbox);
    }
}
