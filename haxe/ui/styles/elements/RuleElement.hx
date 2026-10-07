package haxe.ui.styles.elements;

import haxe.ui.core.Component;
import haxe.ui.styles.Value;

@:access(haxe.ui.core.Component)
class RuleElement {
    public var selector:Selector;
    public var directives:Map<String, Directive> = new Map<String, Directive>();
    public var directiveCount:Int = 0;

    public function new(selector:String, directives:Array<Directive>) {
        this.selector = new Selector(selector);
        //this.directives = directives;

        for (d in directives) {
            processDirective(d);
            directiveCount++;
        }
    }

    public function addDirective(directive:String, value:Value) {
        var d = new Directive(directive, value);
        processDirective(d);
    }

    public function match(d:Component):Bool {
        return ruleMatch(selector.parts[selector.parts.length - 1], d);
    }

    private static function ruleMatch( c : SelectorPart, d : Component ):Bool {
        if (c.nodeName == "*") {
            return true;
        }

        if (c.id != null && c.id != d.id) {
            return false;
        }

        if (c.className != null) {
            for (p in c.classNameParts) {
                if (d.hasClass(p) == false) {
                    return false;
                }
            }
        }

        if (c.pseudoClass != null) {
            var pc = ":" + c.pseudoClass;
            if (d.hasClass(pc) == false) {
                return false;
            }
        }

        if (c.nodeName != null) {
            var classNodeName:String = @:privateAccess d.nodeName;
            if (c.nodeName != classNodeName) {
                return false;
            }
        }

        if (c.parent != null) {
            if (c.direct == true) {
                var p = d.parentComponent;
                if (p == null) {
                    return false;
                }
                if (!ruleMatch(c.parent, p)) {
                    return false;
                }
            } else {
                var p = d.parentComponent;
                while (p != null) {
                    if (ruleMatch(c.parent, p)) {
                        break;
                    }
                    p = p.parentComponent;
                }
                if (p == null) {
                    return false;
                }
            }
        }

        return true;
    }

    private function processDirective(d:Directive) {
        switch (d.directive) {
            case "padding":
                processSidesComposite(d, ["padding-top", "padding-right", "padding-bottom", "padding-left"]);
            case "margin":
                processSidesComposite(d, ["margin-top", "margin-right", "margin-bottom", "margin-left"]);
            case "background-position":
                processComposite(d, ["background-position-x", "background-position-y"]);
            case "spacing":
                processComposite(d, ["horizontal-spacing", "vertical-spacing"]);
            case "background":
                processComposite(d, ["background-color", "background-color-end", "background-gradient-style"]);
            case "border":
                processComposite(d, ["border-size", "border-style", "border-color"]);
            case "border-top":
                processComposite(d, ["border-top-size", "border-style", "border-top-color"]);
            case "border-left":
                processComposite(d, ["border-left-size", "border-style", "border-left-color"]);
            case "border-bottom":
                processComposite(d, ["border-bottom-size", "border-style", "border-bottom-color"]);
            case "border-right":
                processComposite(d, ["border-right-size", "border-style", "border-right-color"]);
            case "border-size":
                processSidesComposite(d, ["border-top-size", "border-right-size", "border-bottom-size", "border-left-size"]);
            case "border-color":
                processSidesComposite(d, ["border-top-color", "border-right-color", "border-bottom-color", "border-left-color"], true);
            case "background-image-clip":
                processComposite(d, ["background-image-clip-top", "background-image-clip-left", "background-image-clip-bottom", "background-image-clip-right"]);
            case "background-image-slice":
                processComposite(d, ["background-image-slice-top", "background-image-slice-left", "background-image-slice-bottom", "background-image-slice-right"]);
            case "animation":
                processComposite(d, ["animation-name", "animation-duration", "animation-timing-function", "animation-delay", "animation-iteration-count", "animation-direction", "animation-fill-mode"]);
            case "cursor":
                var vl = ValueTools.composite(d.value);
                if (vl.length == 1) {
                    processComposite(new Directive("", Value.VComposite([vl[0], Value.VNumber(0), Value.VNumber(0)])), ["cursor-name", "cursor-offset-x", "cursor-offset-y"]);
                } else if (vl.length == 3) {
                    processComposite(d, ["cursor-name", "cursor-offset-x", "cursor-offset-y"]);
                }
            case "background-size":
                var vl = ValueTools.composite(d.value);
                if (vl.length == 1) {
                    processComposite(new Directive("", vl[0]), ["background-width", "background-height"]);
                } else if (vl.length == 2) {
                    processComposite(d, ["background-width", "background-height"]);
                }
            case "font-style":
                var v1 = ValueTools.composite(d.value);
                if (v1 == null) {
                    v1 = [d.value];
                }
                for (v in v1) {
                    var s = ValueTools.string(v).toLowerCase();
                    if (s == "bold") {
                        directives.set("font-bold", new Directive("font-bold", Value.VBool(true)));
                    } else if (s == "italic") {
                        directives.set("font-italic", new Directive("font-italic", Value.VBool(true)));
                    } else if (s == "underline") {
                        directives.set("font-underline", new Directive("font-underline", Value.VBool(true)));
                    }
                }
            case _:
                directives.set(d.directive, d);
        }
    }

    // css box shorthand: parts are top, right, bottom, left; 1 to 3 values are expanded to all four sides
    private function processSidesComposite(d:Directive, parts:Array<String>, duplicate:Bool = false) {
        switch (d.value) {
            case Value.VComposite(vl) if (vl.length > 0 && vl.length < 4):
                var top = vl[0];
                var right = (vl.length > 1) ? vl[1] : top;
                var bottom = (vl.length > 2) ? vl[2] : top;
                processComposite(new Directive(d.directive, Value.VComposite([top, right, bottom, right])), parts, duplicate);
            case _:
                processComposite(d, parts, duplicate);
        }
    }

    private function processComposite(d:Directive, parts:Array<String>, duplicate:Bool = false) {
        for (p in parts) {
            directives.remove(p);
        }

        switch (d.value) {
            case Value.VConstant(_):
            case Value.VColor(_):
                if (duplicate == false) {
                    directives.set(parts[0], new Directive(parts[0], d.value));
                } else {
                    for (p in parts) {
                        directives.set(p, new Directive(p, d.value));
                    }
                }
            case Value.VDimension(v):
                for (p in parts) {
                    directives.set(p, new Directive(p, Value.VDimension(v)));
                }
            case Value.VNumber(_):
                for (p in parts) {
                    directives.set(p, new Directive(p, d.value));
                }
            case Value.VComposite(vl):
                var n = 0;
                for (p in parts) {
                    if (vl[n] != null) {
                        var nd = new Directive(p, vl[n]);
                        processDirective(nd);
                        directives.set(p, nd);
                    }
                    n++;
                }
            case Value.VNone:
                for (p in parts) {
                    var nd = new Directive(p, d.value);
                    processDirective(nd);
                    directives.set(p, nd);
                }
            case Value.VCall(f, vl):
                for (p in parts) {
                    directives.set(p, new Directive(p, d.value));
                }
            case _:
                trace("unknown value type", d.value);
        }
    }
}
