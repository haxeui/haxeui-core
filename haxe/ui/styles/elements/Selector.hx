package haxe.ui.styles.elements;

class Selector {
    public var parts:Array<SelectorPart> = [];
    
    public function new(s:String) {
        var p = s.split(" ");
        var parent = null;
        for (i in p) {
            i = StringTools.trim(i);
            if (i.length == 0) {
                continue;
            }
            
            var current = new SelectorPart();
            current.parent = parent;
            
            var p1 = i.split(":");
            current.pseudoClass = p1[1];
            
            var main = p1[0];
            
            if (main.charAt(0) == ".") {
                current.className = main.substring(1);
            } else {
                var p2 = main.split(".");
                if (p2[0].charAt(0) == "#") {
                    current.id = p2[0].substring(1);
                } else {
                    current.nodeName = p2[0].toLowerCase();
                }
                current.className = p2[1];
            }
            
            parts.push(current);
            parent = current;
        }
    }
    
    public function toString():String {
        return parts.join(" ");
    }
}
