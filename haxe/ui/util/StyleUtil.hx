package haxe.ui.util;

class StyleUtil {
    static private var style2ComponentEReg:EReg = ~/-(\w)/g;
    static private var component2StyleEReg:EReg = ~/([A-Z])/g;

    /**
    *   Example: "background-color" to "backgroundColor"
    **/
    static public function styleProperty2ComponentProperty(property:String):String {
        return style2ComponentEReg.map(property, function(re:EReg):String{
            return re.matched(1).toUpperCase();
        });
    }

    /**
    *   Example: "backgroundColor" to "background-color"
    **/
    static public function componentProperty2StyleProperty(property:String):String {
        return component2StyleEReg.map(property, function(re:EReg):String{
            return '-${re.matched(1).toLowerCase()}' ;
        });
    }
}
