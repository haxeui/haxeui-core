package haxe.ui;

import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;

typedef PreloadItem = {
    type:String,
    resourceId:String
}

class Preloader extends Component {
    public function new() {
        super();
        id = "preloader";
        styleString = "width:auto;height:auto;";
    }
    
    private override function createChildren() {
        var label = new Label();
        label.text = "Loading";
        addComponent(label);
    }
    
    private override function validateLayout():Bool {
        var b = super.validateLayout();
        if (width > 0 && height > 0) {
            left = (Screen.instance.width / 2) - (width / 2);
            top = (Screen.instance.height / 2) - (height / 2);
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
            var text = label.text + ".";
            if (StringTools.endsWith(text, "....")) {
                text = "Loading";
            }
            label.text = text;
        }
    }
    
    public function increment() {
        progress(_current + 1, _max);
    }
    
    public function complete() {
        Screen.instance.removeComponent(this);
    }
}
