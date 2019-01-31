package haxe.ui.styles.elements;

class SelectorPart {
    public var parent:SelectorPart = null;
    
    public var pseudoClass:String = null;
    public var className:String = null;
    public var id:String = null;
    public var nodeName:String = null;
    
    public function new() {
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
