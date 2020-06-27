package ::package::;

import haxe.ui.HaxeUIApp;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;

class ::main:: {
    public static function main() {
        var app = new HaxeUIApp();
        app.ready(function() {
            var mainView:Component = ComponentMacros.buildComponent("assets/main-view.xml");
            app.addComponent(mainView);

            app.start();
        });
    }
}
