package haxe.ui.styles.elements;

import haxe.ui.core.Component;
import haxe.ui.styles.Value;

@:access(haxe.ui.core.Component)
class RuleElement {
    public var selector:Selector;
    public var directives:Map<String, Directive> = new Map<String, Directive>();

    public function new(selector:String, directives:Array<Directive>) {
        this.selector = new Selector(selector);
        //this.directives = directives;

        for (d in directives) {
            processDirective(d);
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

        if (c.pseudoClass != null) {
            var pc = ":" + c.pseudoClass;
            if (d.hasClass(pc) == false) {
                return false;
            }
        }

        if (c.className != null) {
            for (p in c.classNameParts) {
                if (d.hasClass(p) == false) {
                    return false;
                }
            }
        }

        if (c.nodeName != null) {
            var classNodeName:String = @:privateAccess d.nodeName;
            if (c.nodeName != classNodeName) {
                return false;
            }
        }

        if (c.id != null && c.id != d.id) {
            return false;
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
                var vl = ValueTools.composite(d.value);
                if (vl.length == 4 || vl.length == 1) {
                    processComposite(d, ["padding-top", "padding-left", "padding-right", "padding-bottom"]);
                } else if (vl.length == 2) {
                    processComposite(new Directive("", vl[0]), ["padding-top", "padding-bottom"]);
                    processComposite(new Directive("", vl[1]), ["padding-left", "padding-right"]);
                } else if (vl.length == 0) {
                    processComposite(d, ["padding-top", "padding-left", "padding-right", "padding-bottom"]);
                }
            case "margin":
                var vl = ValueTools.composite(d.value);
                if (vl.length == 4 || vl.length == 1) {
                    processComposite(d, ["margin-top", "margin-left", "margin-right", "margin-bottom"]);
                } else if (vl.length == 2) {
                    processComposite(new Directive("", vl[0]), ["margin-top", "margin-bottom"]);
                    processComposite(new Directive("", vl[1]), ["margin-left", "margin-right"]);
                }
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
                processComposite(d, ["border-top-size", "border-left-size", "border-right-size", "border-bottom-size"]);
            case "border-color":
                processComposite(d, ["border-top-color", "border-left-color", "border-right-color", "border-bottom-color"], true);
            case "background-image-clip":
                processComposite(d, ["background-image-clip-top", "background-image-clip-left", "background-image-clip-bottom", "background-image-clip-right"]);
            case "background-image-slice":
                processComposite(d, ["background-image-slice-top", "background-image-slice-left", "background-image-slice-bottom", "background-image-slice-right"]);
            case "animation":
                processComposite(d, ["animation-name", "animation-duration", "animation-timing-function", "animation-delay", "animation-iteration-count", "animation-direction", "animation-fill-mode"]);
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
            case _:
        }
    }
}
