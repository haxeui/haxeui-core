package haxe.ui.macros;

#if macro
import haxe.macro.Type;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.Ref;
import haxe.macro.TypeTools;
import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.macro.Context;
#end

/*

use: --macro addGlobalMetadata('', '@:build(haxe.ui.macros.ProfileMacros.build())')
add: @:profile to a method

*/
class ProfileMacros {
    static var count:Int = 0;
    
    
    macro public static function build():Array<Field> {
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
        
        var found = false;
        for (f in MacroHelpers.getFieldsWithMeta("profile", fields)) {
            fields.push({
                name: f.name + "_stats",
                doc: null,
                meta: [],
                access: [APrivate, AStatic],
                kind: FVar(macro:Dynamic, macro $v{ null }),
                pos: haxe.macro.Context.currentPos()
            });
            
            var fn = null;
            switch (f.kind) {
                case FFun(f):
                        fn = f;
                default:
            }

            var className = Context.getLocalClass().toString().split(".").pop();
            var varName = f.name + "_stats";
            MacroHelpers.insertLine(fn, macro {
                if ($i{className}.$varName == null) {
                    $i{className}.$varName = { name: $v{f.name}, count: 0, total_time: 0, average: 0, min: 0xFFFFFF, max: 0, times: []};
                }
                $i{className}.$varName.startTime = Sys.time();
            }, 0);
            
            MacroHelpers.appendLine(fn, macro {
                var delta = Sys.time() - $i{className}.$varName.startTime;
                $i{className}.$varName.total_time += delta;
                /*
                var arr = cast $i{className}.$varName.times;
                arr.push(delta);
                */
                if (delta < $i{className}.$varName.min) {
                    $i{className}.$varName.min = delta;
                }
                if (delta > $i{className}.$varName.max) {
                    $i{className}.$varName.max = delta;
                }
                $i{className}.$varName.count++;
                $i{className}.$varName.average = $i{className}.$varName.total_time / $i{className}.$varName.count;
                trace($i{className}.$varName.name + " > count: " + $i{className}.$varName.count + ", total_time: " + $i{className}.$varName.total_time);
            });
            
//            trace(ExprTools.toString(fn.expr));
            
            found = true;
            
        }

        if (found == false) {
            return null;
        }
        
        return fields;
    }
}
