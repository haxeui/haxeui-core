package haxe.ui.styles.elements;

class Selector {
    public var parts:Array<SelectorPart> = [];
    public var weight:Weight = new Weight();

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

        //  https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity
        //  Combinators, such as +, >, ~, " ", and ||, may make a selector more specific in what is selected 
        //  but they don't add any value to the specificity weight.
        for ( p in parts) {
            if (p.id != null) {
                weight.a++;
            }
            if (p.className != null) {
                weight.b++;
            }
            if (p.pseudoClass != null) {
                weight.c++;
            }
        }
    }

    public function hasPrecedenceOrEqualTo(s:Selector) {
        if (weight.a > s.weight.a) return true;
        if (weight.a < s.weight.a) return false;
        if (weight.b > s.weight.b) return true;
        if (weight.b < s.weight.b) return false;
        if (weight.c > s.weight.c) return true;
        if (weight.c < s.weight.c) return false;
        return true;
    }

    public function toString():String {
        return parts.join(" ");
    }
}

class Weight {
    public var a:Int;
    public var b:Int;
    public var c:Int;

    public function new() {}
}
