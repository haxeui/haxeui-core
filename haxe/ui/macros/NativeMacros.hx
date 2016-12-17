package haxe.ui.macros;

import haxe.ui.parsers.config.ConfigParser;
import haxe.ui.util.GenericConfig;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import sys.io.File;
#end

class NativeMacros {
    private static var _nativeProcessed:Bool;
    macro public static function processNative():Expr {
        if (_nativeProcessed == true) {
            return macro null;
        }

        var code:String = "function() {\n";

        var nativeConfigs:Array<GenericConfig> = loadNativeConfig();
        for (config in nativeConfigs) {
            code += MacroHelpers.buildGenericConfigCode(config, "nativeConfig");
        }

        code += "}()\n";

        _nativeProcessed = true;
        return Context.parseInlineString(code, Context.currentPos());
    }

    #if macro
    private static var _nativeConfigLoaded:Bool = false;
    private static var _nativeConfigs:Array<GenericConfig> = new Array<GenericConfig>();
    public static function loadNativeConfig():Array<GenericConfig> {
        if (_nativeConfigLoaded == true) {
            return _nativeConfigs;
        }

        MacroHelpers.scanClassPath(function(filePath:String) {
            var parser:ConfigParser = ConfigParser.get(MacroHelpers.extension(filePath));
            if (parser != null) {
                try {
                    var config:GenericConfig = parser.parse(File.getContent(filePath));
                    _nativeConfigs.push(config);
                    return true;
                } catch (e:Dynamic) {
                    trace('WARNING: Problem parsing native ${MacroHelpers.extension(filePath)} (${filePath}) - ${e} (skipping file)');
                    return false;
                }
            }

            return false;
        }, ["native."]);

        _nativeConfigLoaded = true;
        return _nativeConfigs;
    }
    #end
}