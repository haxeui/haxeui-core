package haxe.ui.macros;

import haxe.macro.ExprTools;
#if macro
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr;

using StringTools;
#end

class NavigationMacros {
    #if macro
    public static macro function buildNavigatableView():Array<Field> {
        var localClass = Context.getLocalClass();
        var localType = Context.getLocalType();
        var localComplexType = TypeTools.toComplexType(localType);
        var localMeta = localClass.get().meta;

        var routeDetailsMeta = null;
        if (localMeta.has(":route")) {
            routeDetailsMeta = localMeta.extract(":route")[0];
        }
        if (localMeta.has("route")) {
            routeDetailsMeta = localMeta.extract("route")[0];
        }

        var navigationSubDomain = Context.getDefines().get("haxeui_navigation_sub_domain");
        if (navigationSubDomain != null && navigationSubDomain.trim().length > 0) {
            BackendMacros.additionalExprs.push(macro haxe.ui.navigation.NavigationManager.instance.subDomain = $v{navigationSubDomain});
        }

        var routeExpr:Expr = null;
        if (routeDetailsMeta != null) {
            var routePathExpr = routeDetailsMeta.params[0];
            var initialRoute = localMeta.has(":initialRoute") || localMeta.has("initialRoute");
            var errorRoute = localMeta.has(":errorRoute") || localMeta.has("errorRoute");
            var preserveView = localMeta.has(":preserveView") || localMeta.has("preserveView");
            
            if (routePathExpr != null) {
                var parts = localClass.toString().split(".");
                parts.push("new");
                routeExpr = macro haxe.ui.navigation.NavigationManager.instance.registerRoute($routePathExpr, {
                    viewCtor: $p{parts},
                    initial: $v{initialRoute},
                    error: $v{errorRoute},
                    preserveView: $v{preserveView}
                });
            }
        }

        var applyParamsField = null;
        var initField = null;
        var fields = Context.getBuildFields();
        for (f in fields) {
            if (f.name == "applyParams") {
                applyParamsField = f;
            } else if (f.name == "__init__") {
                initField = f;
            }
        }

        if (applyParamsField == null) {
            fields.push({
                name: "applyParams",
                access: [APublic],
                kind: FFun({
                    args: [{name: "params", type: macro: Map<String, Any>}],
                    expr: macro {
                    }
                }),
                pos: Context.currentPos()
            });
        }


        if (initField == null && routeExpr != null) {
            fields.push({
                name: "__init__",
                access: [AStatic],
                kind: FFun({
                    args: [],
                    expr: macro {
                        ${routeExpr}
                    }
                }),
                pos: Context.currentPos()
            });
        }

        return fields;
    }

    #end
}