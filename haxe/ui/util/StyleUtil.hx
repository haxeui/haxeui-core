package haxe.ui.util;

class StyleUtil
{
    /**
    *   Example: "background-color" to "backgroundColor"
    **/
    static public function styleProperty2ComponentProperty(property:String):String {
        return ~/-(\w)/g.map(property, function(re:EReg):String{
            return re.matched(1).toUpperCase();
        });
    }

    /**
    *   Example: "backgroundColor" to "background-color"
    **/
    static public function componentProperty2StyleProperty(property:String):String {
        return ~/([A-Z])/g.map(property, function(re:EReg):String{
            return '-${re.matched(1).toLowerCase()}' ;
        });
    }
}
