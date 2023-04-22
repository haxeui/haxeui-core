package haxe.ui.components;

import haxe.ui.util.Variant;
import haxe.ui.containers.Box;

// TODO: move to behaviours (not really priority as it will probably never have a native counterpart)
class Decorator extends Box {
    public override function set_icon(value:Variant):Variant {
        var image = findComponent(Image);
        if (image == null) {
            image = new Image();
            addComponent(image);
        }
        image.resource = value;
        return value;
    }
}