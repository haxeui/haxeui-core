package haxe.ui.styles.elements;

class Selector {
    public var parts:Array<SelectorPart> = [];

    public function new(s:String) {
        s = StringTools.replace(s, ">", " > ");
        var p = s.split(" ");
        var parent = null;
        var nextDirect:Bool = false;
        for (i in p) {
            i = StringTools.trim(i);
            if (i.length == 0) {
                continue;
            }
            if (i == ">") {
                nextDirect = true;
                continue;
            }

            var current = new SelectorPart();
            if (nextDirect == true) {
                current.direct = true;
                nextDirect = false;
            }
            current.parent = parent;

            var p1 = i.split(":");
            current.pseudoClass = p1[1];

            var main = p1[0];

            // compound selector, eg: "button#id.a.b", "#id.a.b", ".a.b#id"
            var classNames:Array<String> = [];
            var p2 = main.split(".");
            for (n in 0...p2.length) {
                var p3 = p2[n].split("#");
                if (n > 0) {
                    classNames.push(p3[0]);
                } else if (main.charAt(0) != "." && main.charAt(0) != "#") {
                    current.nodeName = p3[0].toLowerCase();
                }
                if (p3.length > 1) {
                    current.id = p3[1];
                }
            }
            if (classNames.length > 0) {
                current.className = classNames.join(".");
            }

            parts.push(current);
            parent = current;
        }
    }

    public function toString():String {
        return parts.join(" ");
    }
}
