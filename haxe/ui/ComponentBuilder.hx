package haxe.ui;

import haxe.macro.Expr;

@:access(haxe.ui.macros.ComponentMacros)
class ComponentBuilder {
    macro public static function build(resourcePath:String, params:Expr = null):Array<Field> {
        return haxe.ui.macros.ComponentMacros.buildCommon(resourcePath, params);
    }
    
    macro public static function fromFile(filePath:String, params:Expr = null):Expr {
        return haxe.ui.macros.ComponentMacros.buildComponentCommon(filePath, params);
    }
    
    macro public static function fromString(source:String, params:Expr = null):Expr {
        return haxe.ui.macros.ComponentMacros.buildFromStringCommon(source, params);
    }
    
}