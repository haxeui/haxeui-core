package ::package::;

import haxe.ui.HaxeUIApp;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;

class ::main:: {
    public static function main() {
        var app = new HaxeUIApp();
        app.ready(function() {
            var main:Component = ComponentMacros.buildComponent("assets/main.xml");
            app.addComponent(main);

            app.start();
        });
    }
}
