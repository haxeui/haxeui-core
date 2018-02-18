package haxe.ui.util;

import haxe.ui.core.Component;

class ComponentUtil
{
    public static function getDepth(target:Component):Int {
        var count:Int = 0;
        while(target.parentComponent != null) {
            target = target.parentComponent;
            ++count;
        }

        return count;
    }
}
