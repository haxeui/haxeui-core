package haxe.ui.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodePos;
import haxe.ui.util.StringUtil;
#end

class LayoutMacros {
    macro static function build():Array<Field> {
        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());

        if (builder.fullPath != "haxe.ui.layouts.Layout") {
            //ModuleMacros.loadModules();
        }

        if (!Context.getLocalClass().get().isPrivate) {
            for (alias in buildLayoutAliases(builder.fullPath)) {
                haxe.ui.layouts.LayoutFactory.register(alias, builder.fullPath);
            }
        }

        buildClonable(builder);

        return builder.fields;
    }

    public static function buildLayoutAliases(fullPath:String):Array<String> {
        var aliases = [];
        var name:String = fullPath.split(".").pop();
        name = StringTools.replace(name, "Layout", "");
        name = StringTools.trim(name);
        if (name.length > 0) {
            aliases.push(name);

            var parts = StringUtil.splitOnCapitals(name);
            name = name.toLowerCase();
            if (parts.length > 1) {
                var alias1 = parts.join(" ");
                var alias2 = parts.join("-");
                parts.reverse();
                var alias3 = parts.join(" ");
                var alias4 = parts.join("-");
                aliases.push(alias1);
                aliases.push(alias2);
                aliases.push(alias3);
                aliases.push(alias4);

                // this is a bit of a hack, we'd like to use "vertical grid" as just "grid"
                // so we'll add an appropriate alias, this can also be achived in another way
                // using IDirectionalLayout (like IDirectionalComponent), but im not sure it 
                // warrants it yet
                if (parts[parts.length - 1] == "vertical" && parts.length > 1) {
                    parts.pop();
                    var directionalAlias1 = parts.join(" ");
                    var directionalAlias2 = parts.join("-");
                    aliases.push(directionalAlias1);
                    aliases.push(directionalAlias2);
                }
            }

        }

        return aliases;
    }

    static function buildClonable(builder:ClassBuilder) {
        var useSelf:Bool = (builder.fullPath == "haxe.ui.layouts.Layout");

        var cloneFn = builder.findFunction("cloneLayout");
        if (cloneFn == null) { // add new clone fn
            var access:Array<Access> = [APublic];
            if (useSelf == false) {
                access.push(AOverride);
            }
            cloneFn = builder.addFunction("cloneLayout", builder.complexType, access);
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
            }, builder.complexType, access);
        }
    }
}