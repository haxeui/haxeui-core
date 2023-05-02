package haxe.ui.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodePos;
#end

class LayoutMacros {
    macro static function build():Array<Field> {
        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());

        buildClonable(builder);

        return builder.fields;
    }

    static function buildClonable(builder:ClassBuilder) {
        var useSelf:Bool = (builder.fullPath == "haxe.ui.layouts.Layout");

        var cloneFn = builder.findFunction("cloneLayout");
        if (cloneFn == null) { // add new clone fn
            var access:Array<Access> = [APublic];
            if (useSelf == false) {
                access.push(AOverride);
            }
            cloneFn = builder.addFunction("cloneLayout", builder.path, access);
        }

        var cloneLineExpr = null;
        var typePath = TypeTools.toComplexType(builder.type);
        if (useSelf == false) {
            cloneLineExpr = macro var c:$typePath = cast super.cloneLayout();
        } else {
            cloneLineExpr = macro var c:$typePath = self();
        }
        cloneFn.add(cloneLineExpr, CodePos.Start);

        var n = 1;
        for (f in builder.getFieldsWithMeta("clonable")) {
            if (f.isNullable == true) {
                cloneFn.add(macro if ($p{["this", f.name]} != null) $p{["c", f.name]} = $p{["this", f.name]}, Pos(n));
            } else {
                cloneFn.add(macro $p{["c", f.name]} = $p{["this", f.name]}, Pos(n));
            }
            n++;
        }

        cloneFn.add(macro return c);

        var hasOverriddenSelf = (builder.findFunction("self") != null);

        if (hasOverriddenSelf == false) {
            // add "self" function
            var access:Array<Access> = [APrivate];
            if (useSelf == false) {
                access.push(AOverride);
            }
            var typePath = builder.typePath;
            builder.addFunction("self", macro {
                return new $typePath();
            }, builder.path, access);
        }
    }
}