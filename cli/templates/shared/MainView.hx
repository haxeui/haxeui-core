package ::package::;

import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.macros.ComponentMacros.build("assets/main-view.xml"))
class MainView extends VBox {
    public function new() {
        super();
        button1.onClick = function(e) {
            button1.text = "Thanks!";
        }
    }
    
    @:bind(button2, MouseEvent.CLICK)
    private function onMyButton(e:MouseEvent) {
        button2.text = "Thanks!";
    }
}