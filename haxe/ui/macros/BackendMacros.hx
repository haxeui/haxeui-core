package haxe.ui.macros;
import haxe.ui.util.Defines;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ui.macros.helpers.CodeBuilder;
import haxe.ui.util.Properties;
#end

class BackendMacros {

    #if macro
    public static var properties:Properties = new Properties();
    public static var additionalExprs:Array<Expr> = [];
    #end

    macro public static function processBackend():Expr {
        loadBackendProperties();

        var builder = new CodeBuilder();
        for (name in properties.names()) {
            builder.add(macro
                Toolkit._backendProperties.setProp($v{name}, $v{properties.getProp(name)})
            );
        }

        if (Context.getDefines().get("theme") != null) {
            builder.add(macro
                Toolkit.theme = $v{Context.getDefines().get("theme")}
            );
        }

        for (k in Defines.getAll().keys()) {
            var v = Defines.getAll().get(k);
            builder.add(macro haxe.ui.util.Defines.set($v{k}, $v{v}));
        }
        
        for (additionalExpr in additionalExprs) {
            builder.add(additionalExpr);
        }

        return builder.expr;
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
            #if haxeui_macro_times
            var stopTimer = Context.timer("BackendMacros.loadBackendProperties");
            #end

            var map:Map<String, String> = new Map<String, String>();
            MacroHelpers.scanClassPath(function(filePath:String, base:String) {
                var props:Properties = new Properties();
                props.fromFile(filePath);
                properties.addAll(props);
                for (propName in props.names()) {
                    var propValue = props.getProp(propName);
                    map.set(propName, propValue);
                }
                return false;
            }, searchCriteria);

            var serializer = new haxe.Serializer();
            serializer.serialize(map);
            var s = serializer.toString();
            Context.addResource("app.properties", haxe.io.Bytes.ofString(s));

            #if haxeui_macro_times
            stopTimer();
            #end
        } 
        return macro null;
    }

    #end
}