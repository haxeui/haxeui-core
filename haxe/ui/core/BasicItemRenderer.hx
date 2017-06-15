package haxe.ui.core;

import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;

class BasicItemRenderer extends ItemRenderer {
    public function new() {
        super();

        this.percentWidth = 100;

        var hbox:HBox = new HBox();
        hbox.percentWidth = 100;

        var icon:Image = new Image();
        icon.id = "icon";
        hbox.addComponent(icon);

        var label:Label = new Label();
        label.id = "value";
        label.percentWidth = 100;
        hbox.addComponent(label);

        addComponent(hbox);
    }
}
