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
    
    public function match(d:Component):Bool {
        return ruleMatch(selector.parts[selector.parts.length - 1], d);
    }
    
    private static function ruleMatch( c : SelectorPart, d : Component ) {
        if (c.nodeName == "*") {
            return true;
        }
        
        if (c.pseudoClass != null) {
            var pc = ":" + c.pseudoClass;
            if (d.classes.indexOf(pc) == -1) {
                return false;
            }
        }
        
        if (c.className != null) {
            if (d.classes.indexOf(c.className) == -1) {
                return false;
            }
        }
        
        if (c.nodeName != null) {
            var className:String = Type.getClassName(Type.getClass(d)).split(".").pop();
            if (c.nodeName.toLowerCase() != className.toLowerCase()) {
                return false;
            }
        }
        
        if (c.id != null && c.id != d.id) {
            return false;
        }
        
        if (c.parent != null) {
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
                }
            case "margin":
                var vl = ValueTools.composite(d.value);
                if (vl.length == 4 || vl.length == 1) {
                    processComposite(d, ["margin-top", "margin-left", "margin-right", "margin-bottom"]);
                } else if (vl.length == 2) {
                    processComposite(new Directive("", vl[0]), ["margin-top", "margin-bottom"]);
                    processComposite(new Directive("", vl[1]), ["margin-left", "margin-right"]);
                }
            case "spacing":
                processComposite(d, ["horizontal-spacing", "vertical-spacing"]);
            case "background":
                processComposite(d, ["background-color", "background-color-end", "background-gradient-style"]);
            case "border":
                processComposite(d, ["border-size", "border-style", "border-color"]);
            case "border-size":    
                processComposite(d, ["border-top-size", "border-left-size", "border-right-size", "border-bottom-size"]);
            case "border-color": 
                processComposite(d, ["border-top-color", "border-left-color", "border-right-color", "border-bottom-color"], true);
            case "background-image-clip": 
                processComposite(d, ["background-image-clip-top", "background-image-clip-left", "background-image-clip-bottom", "background-image-clip-right"]);
            case "background-image-slice":    
                processComposite(d, ["background-image-slice-top", "background-image-slice-left", "background-image-slice-bottom", "background-image-slice-right"]);
            case _:
                directives.set(d.directive, d);
        }
    }
    
    private function processComposite(d:Directive, parts:Array<String>, duplicate:Bool = false) {
        for (p in parts) {
            directives.remove(p);
        }
        
        switch (d.value) {
            case Value.VConstant(v):
                /*
                var vp = v.split(" ");
                var n = 0;
                for (p in parts) {
                    var vv = vp[n];
                    if (vv == null) {
                        vv = vp[vp.length - 1];
                    }
                    directives.set(p, new Directive(p, ValueTools.parse(vv)));
                    n++;
                }
                trace(v);
                */
//                trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>--------------------------- " + v);
            case Value.VColor(v):    
 //               trace(">>>>>>>>>>>>>>>>>>>>>>>>>>> " + v);
                if (duplicate == false) {
                    directives.set(parts[0], new Directive(parts[0], d.value));
                } else {
                    for (p in parts) {
                        directives.set(p, new Directive(p, d.value));
                    }
                }
            case Value.VDimension(v):
                /*
                var vp = ValueTools.string(d.value).split(" ");
                var n = 0;
                for (p in parts) {
                    var vv = vp[n];
                    if (vv == null) {
                        vv = vp[vp.length - 1];
                    }
                    directives.set(p, new Directive(p, ValueTools.parse(vv)));
                    n++;
                }
                trace(v);
                */
                for (p in parts) {
                    directives.set(p, new Directive(p, Value.VDimension(v)));
                }
            case Value.VNumber(v):
                /*
                var vp = ValueTools.string(d.value).split(" ");
                var n = 0;
                for (p in parts) {
                    var vv = vp[n];
                    if (vv == null) {
                        vv = vp[vp.length - 1];
                    }
                    directives.set(p, new Directive(p, ValueTools.parse(vv)));
                    n++;
                }
                trace(v);
                */
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
