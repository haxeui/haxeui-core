package haxe.ui.styles.elements;

class Selector {
    public var parts:Array<SelectorPart> = [];

    private var weightA = 0;
    private var weightB = 0;
    private var weightC = 0;

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
                weightA++;
            }
            if (p.className != null) {
                weightB++;
            }
            if (p.pseudoClass != null) {
                weightC++;
            }
        }
    }

    public function hasPrecedenceOrEqualTo(s:Selector) {
        if (weightA > s.weightA) return true;
        if (weightA < s.weightA) return false;
        if (weightB > s.weightB) return true;
        if (weightB < s.weightB) return false;
        if (weightC > s.weightC) return true;
        if (weightC < s.weightC) return false;
        return true;
    }

    public function toString():String {
        return parts.join(" ");
    }
}
