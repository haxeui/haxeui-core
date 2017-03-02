package haxe.ui;

import haxe.ui.backend.AppBase;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;

@:keep
class HaxeUIApp extends AppBase {
    public function new() {
        super();
        Toolkit.build();
        build();
    }

    public function ready(onReady:Void->Void, onEnd:Void->Void = null) {
        init(onReady, onEnd);
    }

    private override function init(onReady:Void->Void, onEnd:Void->Void = null) {
        if (Toolkit.backendProperties.getProp("haxe.ui.theme") != null && Toolkit.theme == "default") {
            Toolkit.theme = Toolkit.backendProperties.getProp("haxe.ui.theme");
        }

        Toolkit.init(getToolkitInit());
        super.init(onReady, onEnd);
    }

    public function addComponent(component:Component) {
        Screen.instance.addComponent(component);
    }
}