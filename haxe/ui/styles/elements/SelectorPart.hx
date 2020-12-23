package haxe.ui.styles.elements;

class SelectorPart {
    public var parent:SelectorPart = null;

    public var pseudoClass:String = null;
    public var className:String = null;
    public var id:String = null;
    public var nodeName:String = null;
    public var direct:Bool = false;

    public function new() {
    }

    private var _parts:Array<String> = null;
    public var classNameParts(get, null):Array<String>;
    private function get_classNameParts():Array<String> {
        if (className == null) {
            return null;
        }
        if (_parts == null) {
            _parts = className.split(".");
        }
        return _parts;
    }

    public function toString():String {
        var sb:StringBuf = new StringBuf();

        if (id != null) {
            sb.add("#" + id);
        }
        if (nodeName != null) {
            sb.add(nodeName);
        }
        if (className != null) {
            sb.add("." + className);
        }
        if (pseudoClass != null) {
            sb.add(":" + pseudoClass);
        }

        return sb.toString();
    }
}
