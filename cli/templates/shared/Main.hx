package ::package::;

import haxe.ui.HaxeUIApp;

class ::main:: {
    public static function main() {
        var app = new HaxeUIApp();
        app.ready(function() {
            app.addComponent(new MainView());

            app.start();
        });
    }
}
