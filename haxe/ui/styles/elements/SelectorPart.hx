package haxe.ui.styles.elements;

class SelectorPart {
    public var parent:SelectorPart = null;

    public var pseudoClass(default, set):String = null;
    private function set_pseudoClass(value:String):String {
        _pseudoClassName = null;
        return pseudoClass = value;
    }

    /** The class a component has for `pseudoClass` (":hover"), made once: matching a rule made it each time. **/
    public var pseudoClassName(get, never):String;
    private var _pseudoClassName:String = null;
    private function get_pseudoClassName():String {
        if (_pseudoClassName == null && pseudoClass != null) {
            _pseudoClassName = ":" + pseudoClass;
        }
        return _pseudoClassName;
    }

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
