package haxe.ui.containers;

import haxe.ui.containers.ButtonBar.ButtonBarBuilder;
import haxe.ui.layouts.HorizontalLayout;

@:composite(Layout, Builder)
class HorizontalButtonBar extends ButtonBar {
    public function new() {
        super();
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
private class Layout extends HorizontalLayout {
    private override function resizeChildren() {
        super.resizeChildren();

        var max:Float = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            if (child.layout.calcAutoHeight() > max) { // changed to calcAutoHeight so it uses the right height (@devezas)
                max = child.layout.calcAutoHeight();
            }
        }
        
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }
            
            if (child.text == null || child.text.length == 0 || child.height != max) { // changed so it adjust when the columns decrease the calculated height (@devezas)
                child.height = max;
            }
        }
    }
}


//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends ButtonBarBuilder {
    private override function showWarning() { // do nothing
    }
}
