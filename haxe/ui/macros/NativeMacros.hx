package haxe.ui.macros;

import haxe.ui.parsers.config.ConfigParser;
import haxe.ui.parsers.modules.Module;
import haxe.ui.parsers.modules.ModuleParser;
import haxe.ui.util.GenericConfig;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.rtti.Meta;
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Compiler;
#end

class NativeMacros {
    private static var _nativeProcessed:Bool = false;
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
                var config:GenericConfig = parser.parse(File.getContent(filePath));
                _nativeConfigs.push(config);
                return true;
            }

            return false;
        }, "native.");

        _nativeConfigLoaded = true;
        return _nativeConfigs;
    }
    #end
}