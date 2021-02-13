package haxe.ui.containers;

import haxe.ui.layouts.HorizontalLayout;

@:composite(Layout)
class Header extends HBox {
    public function new() {
        super();
        layout = new Layout();
    }
}

private class Layout extends HorizontalLayout {
    private override function resizeChildren() {
        super.resizeChildren();

        var max:Float = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            if (child.height > max) {
                max = child.height;
            }
        }
        
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            if (child.text == null || child.text.length == 0) {
                child.height = max;
            }
        }
    }
}