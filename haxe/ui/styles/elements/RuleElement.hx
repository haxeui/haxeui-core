package haxe.ui.styles.elements;

import haxe.ui.core.Component;
import haxe.ui.styles.Value;
#if new_selectors
import haxe.ui.styles.selector.SelectorMatcher;
import haxe.ui.styles.selector.SelectorParser;
import haxe.ui.styles.selector.SelectorData;
#end

@:access(haxe.ui.core.Component)
class RuleElement {
#if new_selectors
    public var selector:SelectorVO;
    static var matchedPseudoClasses = new MatchedPseudoClassesVO(false, false, false, false, false, false, false, false, false, false, null, null, null);
#else
    public var selector:Selector;
#end
    public var directives:Map<String, Directive> = new Map<String, Directive>();
    public var directiveCount:Int = 0;

    public function new(selector:String, directives:Array<Directive>) {
#if new_selectors
        this.selector = SelectorParser.parse(selector);
#else
        this.selector = new Selector(selector);
#end
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

#if new_selectors
        matchedPseudoClasses.hover = false;
        matchedPseudoClasses.focus = false;
        matchedPseudoClasses.active = false;
        matchedPseudoClasses.link = false;
        matchedPseudoClasses.enabled = false;
        matchedPseudoClasses.disabled = false;
        matchedPseudoClasses.checked = false;
        matchedPseudoClasses.fullscreen = false;

        matchedPseudoClasses.hasClasses = d.classes.length > 0;
        matchedPseudoClasses.nodeClassList = d.classes;

        if (matchedPseudoClasses.hasClasses) {
            for (c in (d.classes:Array<String>)) {
                if (c == ':hover') matchedPseudoClasses.hover = true;
                else if (c == ':focus') matchedPseudoClasses.focus = true;
                else if (c == ':active') matchedPseudoClasses.active = true;
                else if (c == ':link') matchedPseudoClasses.link = true;
                else if (c == ':enabled') matchedPseudoClasses.enabled = true;
                else if (c == ':disabled') matchedPseudoClasses.disabled = true;
                else if (c == ':checked') matchedPseudoClasses.checked = true;
                else if (c == ':fullscreen') matchedPseudoClasses.fullscreen = true;
            }
        }
        
        matchedPseudoClasses.hasId = true;
        matchedPseudoClasses.nodeId = d.id;
        matchedPseudoClasses.nodeType = d.className;

        // naive version, full match every rule:
        // final res = SelectorMatcher.match(d, selector, matchedPseudoClasses);
        // trace('$res: ${selector.toString()} == <${@:privateAccess d.className} id=${d.id} class=${d.classes}>');
        // return res;
        
        var match:Bool = false;
                            
        //to optimise speed the matchSelector method must be called
        //the least time possible
        
        //if the selector begins with a class, 
        //then only match if the node has at least one class,
        //and contains the first class of the selector
        if (selector.beginsWithClass) {
            if (matchedPseudoClasses.hasClasses) {
                var classListLength:Int = matchedPseudoClasses.nodeClassList.length;
                for (cls in matchedPseudoClasses.nodeClassList) {
                    if (cls == selector.firstClass) {
                        // in this case, the selector only has a single
                        // class selector, so it is a match
                        if (selector.isSimpleClassSelector == true) {
                            match = true;
                            break;
                        } 
                        //else need to perform a full match
                        else {
                            match = SelectorMatcher.match(d, selector, matchedPseudoClasses) == true;
                            break;
                        }
                    }
                }
            }
        }
        //if the selector begins with an id selector, only match node if
        //it has an id
        else if (selector.beginsWithId == true) {
            if (matchedPseudoClasses.hasId == true) {
                if (matchedPseudoClasses.nodeId == selector.firstId) {
                    //if the selector consists of only an Id, it is a match
                    if (selector.isSimpleIdSelector == true)
                        match = true;
                    //else need to perform a full match
                    else
                        match = SelectorMatcher.match(d, selector, matchedPseudoClasses) == true;
                }
            }
        }
        //if the selector begins with a type, only match node wih the
        //same type
        else if (selector.beginsWithType == true) {
            if (matchedPseudoClasses.nodeType == selector.firstType) {
                //if the selector is only a type selector, then it matches
                if (selector.isSimpleTypeSelector == true)
                    match = true;
                //else a full match is needed
                else
                    match = SelectorMatcher.match(d, selector, matchedPseudoClasses) == true;
            }
        }
        //in other cases, full match
        else
            match = SelectorMatcher.match(d, selector, matchedPseudoClasses) == true;
        
        // if (match == true)
        // {
        //     //if the selector is matched, store the coresponding style declaration
        //     //along with the matching selector
        //     var matchingStyleDeclaration:StyleDeclarationVO = new StyleDeclarationVO();
        //     matchingStyleDeclaration.style = styleRule.style;
        //     matchingStyleDeclaration.selector = selectors[k];
        //     _matchingStyleDeclaration.push(matchingStyleDeclaration);
            
        //     //break to prevent from adding a style declaration
        //     //multiplt time if more than one selector
        //     //matches
        //     break;
        // }

        // if (matchedPseudoClasses.hover)
            // trace('$match: ${selector.toString()} == <${@:privateAccess d.tagName} id=${d.id} class=${d.classList}> {$directives}');

        return match;
#else
        return ruleMatch(selector.parts[selector.parts.length - 1], d);
#end
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