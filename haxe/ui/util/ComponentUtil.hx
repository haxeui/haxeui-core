package haxe.ui.util;

import haxe.ui.core.Component;

class ComponentUtil {
    public static function getDepth(target:Component):Int {
        var count:Int = 0;
        while (target.parentComponent != null) {
            target = target.parentComponent;
            ++count;
        }

        return count;
    }
    
    public static function dumpComponentTree(from:Component, verbose:Bool = false) {
        #if js
        recurseTreeGrouped(from, verbose);
        #else
        recurseTreeTrace(from, 0, verbose);
        #end
    }
    
    public static function walkComponentTree(from:Component, cb:Int->Component->Void) {
        recurseTree(0, from, cb);
    }
    
    private static function recurseTree(depth:Int, c:Component, cb:Int->Component->Void) {
        cb(depth, c);
        for (child in c.childComponents) {
            recurseTree(depth + 1, child, cb);
        }
    }
    
    private static function recurseTreeTrace(c:Component, level:Int, verbose:Bool) {
        var display = c.className;
        if (c.id != null) {
            display += "#" + c.id;
        }
        var space = StringTools.lpad("", " ", level * 4);
        display = space + display;
        trace(display);
        
        for (child in c.childComponents) {
            recurseTreeTrace(child, level + 1, verbose);
        }
    }
    
    private static function recurseTreeGrouped(c:Component, verbose:Bool) {
        #if js
        var display = c.className;
        if (c.id != null) {
            display += "#" + c.id;
        }
        
        js.Browser.console.groupCollapsed(display);
        
        if (verbose == true) {
            js.Browser.console.groupCollapsed("Component Details");
            #if haxeui_html5
            js.Browser.console.log(c.element);
            #end
            js.Browser.console.groupEnd();
        }
        
        for (child in c.childComponents) {
            recurseTreeGrouped(child, verbose);
        }
        js.Browser.console.groupEnd();
        #end
    }
}
