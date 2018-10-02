package haxe.ui.macros;

import haxe.ui.util.Properties;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class BackendMacros {
    public static var properties:Properties = new Properties();
    macro public static function processBackend():Expr {
        loadBackendProperties();

        var code:String = "(function() {\n";
        for (name in properties.names()) {
            code += 'Toolkit.backendProperties.setProp("${name}", "${properties.getProp(name)}");\n';
        }
        if (Context.getDefines().exists("theme")) {
            code += 'Toolkit.theme = "${Context.getDefines().get("theme")}";\n';
        }
        code += "})()\n";
        return Context.parseInlineString(code, Context.currentPos());
    }

    #if macro

    private static function loadBackendProperties():Expr {
        var searchCriteria:Array<String> = [];
        for (k in Context.getDefines().keys()) {
            if (StringTools.startsWith(k, "haxeui-")) {
                searchCriteria.push('${k}.properties');
            }
        }
        if (searchCriteria.length > 0) {
            MacroHelpers.scanClassPath(function(filePath:String) {
                var props:Properties = new Properties();
                props.fromFile(filePath);
                properties.addAll(props);
                return false;
            }, searchCriteria);
        }
        return macro null;
    }

    #end
}