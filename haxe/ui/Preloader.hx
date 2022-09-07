package haxe.ui;

import haxe.ui.components.Label;
import haxe.ui.containers.Box;
import haxe.ui.core.Screen;

typedef PreloadItem = {
    type:String,
    resourceId:String
}

class Preloader extends Box {
    public function new() {
        super();
        id = "preloader";
        styleString = "width:100%;height:100%;";
        styleNames = "default-background";
    }

    private override function createChildren() {
        var label = new Label();
        label.text = "Loading";
        label.verticalAlign = "center";
        label.horizontalAlign = "center";
        addComponent(label);
    }

    private override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        if (actualComponentWidth > 0 && actualComponentHeight > 0) {
            //left = (Screen.instance.actualWidth / 2) - (actualComponentWidth / 2);
            //top = (Screen.instance.actualHeight / 2) - (actualComponentHeight / 2);
        }
        return b;
    }

    private var _current:Int;
    private var _max:Int;
    public function progress(current:Int, max:Int) {
        _current = current;
        _max = max;

        if (current > 0) {
            var label = findComponent(Label);
            if (label != null) {
                var text = label.text; // + ".";
                if (StringTools.endsWith(text, "....")) {
                    text = "Loading";
                }
                label.text = text;
            }
        }
    }

    public function increment() {
        progress(_current + 1, _max);
    }

    public function complete() {
        Screen.instance.removeComponent(this);
    }
}
