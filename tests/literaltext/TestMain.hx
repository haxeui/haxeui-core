import haxe.ui.HaxeUIApp;
import haxe.ui.backend.cs.TestDriver;
import haxe.ui.backend.cs.native.Native;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.core.Screen;
import haxe.ui.locale.LocaleManager;
import utest.Assert;
import utest.Runner;
import utest.ui.text.PlainTextReport;

/** Typed braces stay literal in TextArea and TextField (haxeui-core-joe, setLiteralText). */
class TestMain {
    static function main() {
        var app = new HaxeUIApp();
        app.ready(function() {
            var runner = new Runner();
            runner.addCase(new LiteralText());
            var report = new PlainTextReport(runner);
            @:privateAccess report.newline = "\n";
            @:privateAccess report.indent = "  ";
            report.setHandler(function(r) {
                Sys.println(r.getResults());
                Host.Exit(@:privateAccess r.result.stats.isOk ? 0 : 1);
            });
            runner.run();
        });
    }
}

class LiteralText extends utest.Test {
    function teardown() {
        for (c in Screen.instance.rootComponents.copy()) Screen.instance.removeComponent(c);
        TestDriver.pump();
    }

    function testTypedBracesInTextArea() {
        var area = new TextArea();
        area.left = 20;
        area.top = 20;
        area.width = 200;
        area.height = 100;
        Screen.instance.addComponent(area);
        TestDriver.pump(2);
        TestDriver.clickComponent(area);
        TestDriver.type("a {{company}} b");
        TestDriver.pump(2);
        Assert.equals("a {{company}} b", area.text);
    }

    function testTypedBracesInTextField() {
        var field = new TextField();
        field.left = 20;
        field.top = 20;
        field.width = 200;
        Screen.instance.addComponent(field);
        TestDriver.pump(2);
        TestDriver.clickComponent(field);
        TestDriver.type("{{x}}");
        TestDriver.pump(2);
        Assert.equals("{{x}}", field.text);
    }

    function testSetLiteralText() {
        var area = new TextArea();
        Screen.instance.addComponent(area);
        area.setLiteralText("{{company}}");
        TestDriver.pump(2);
        Assert.equals("{{company}}", area.text);
        Assert.equals("{{company}}", area.getTextInput().text);
        var field = new TextField();
        Screen.instance.addComponent(field);
        field.setLiteralText("{{y}}");
        TestDriver.pump(2);
        Assert.equals("{{y}}", field.text);
    }

    function testLiteralDropsTranslation() {
        var field = new TextField();
        Screen.instance.addComponent(field);
        field.text = "{{no.such.key}}"; // a translation: registered, not stored
        Assert.notNull(LocaleManager.instance.findBindingExpr(field, "text"));
        field.setLiteralText("plain");
        Assert.isNull(LocaleManager.instance.findBindingExpr(field, "text"));
        LocaleManager.instance.refreshFor(field);
        Assert.equals("plain", field.text);
    }
}
