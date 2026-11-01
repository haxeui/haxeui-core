package haxe.ui.styles;

import haxe.crypto.Sha1;
import haxe.ui.core.Component;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.ImportElement;
import haxe.ui.styles.elements.MediaQuery;
import haxe.ui.styles.elements.RuleElement;

using StringTools;

class StyleSheet {
    public var name:String;

    private var _imports:Array<ImportElement> = [];
    private var _rules:Array<RuleElement> = [];

    private var _mediaQueries:Array<MediaQuery> = [];

    private var _animations:Map<String, AnimationKeyFrames> = new Map<String, AnimationKeyFrames>();
    public var animations(get, never):Map<String, AnimationKeyFrames>;
    private function get_animations():Map<String, AnimationKeyFrames> {
        return _animations;
    }

    public function new() {
    }

    public function addImport(el:ImportElement) {
        _imports.push(el);
    }

    public var imports(get, null):Array<ImportElement>;
    private function get_imports():Array<ImportElement> {
        return _imports;
    }

    public var rules(get, null):Array<RuleElement>;
    private function get_rules():Array<RuleElement> {
        var r = _rules.copy();

        for (mq in _mediaQueries) {
            if (mq.relevant) {
                r = r.concat(mq.styleSheet.rules);
            }
        }

        return r;
    }

    public var hasMediaQueries(get, null):Bool;
    private function get_hasMediaQueries():Bool {
        return _mediaQueries.length > 0;
    }

    /**
        The rules whose effect can change with the screen's size: those using vw or vh, and every rule in an
        @media block, whether or not its condition holds now.
    **/
    public function sizeDependentRules(out:Array<RuleElement> = null):Array<RuleElement> {
        if (out == null) {
            out = [];
        }
        for (r in _rules) {
            if (r.usesViewportUnits) {
                out.push(r);
            }
        }
        for (mq in _mediaQueries) {
            mq.styleSheet.allRules(out);
        }
        return out;
    }

    private function allRules(out:Array<RuleElement>) {
        for (r in _rules) {
            out.push(r);
        }
        for (mq in _mediaQueries) {
            mq.styleSheet.allRules(out);
        }
    }

    public function findRule(selector:String, useCache = false):RuleElement {
        for (r in rules) {
            if (r.selector.toString() == selector) {
                return r;
            }
        }
        return null;
    }

    public function findMatchingRules(selector:String, useCache = false):Array<RuleElement> {
        var m = [];
        for (r in rules) {
            if (r.selector.toString() == selector) {
                m.push(r);
            }
        }
        return m;
    }
    
    public function removeRule(selector:String) {
        var r = findRule(selector);
        if (r != null) {
            _ruleIndex = null;
            _rules.remove(r);
        }
    }

    public function removeAllRules() {
        _ruleIndex = null;
        _rules = [];
        _parsedCss = [];
    }

    public function clear() {
        _ruleIndex = null;
        removeAllRules();
        _imports = [];
        _mediaQueries = [];
        _animations = new Map<String, AnimationKeyFrames>();
    }

    public function addRule(el:RuleElement) {
        _ruleIndex = null;
        if (el.directiveCount == 0) {
            return;
        }
        _rules.push(el);
    }

    public function addMediaQuery(el:MediaQuery) {
        _mediaQueries.push(el);
    }

    public function addAnimation(el:AnimationKeyFrames) {
        _animations.set(el.id, el);
    }

    var _parsedCss:Array<String> = [];
    public function parse(css:String) {
        if (css == null) {
            return;
        }
        if (css.trim().length == 0) {
            return;
        }
        var hash = Sha1.encode(css);
        if (_parsedCss.indexOf(hash) != -1) {
            return;
        }

        var parser = new Parser();
        var ss = parser.parse(css);
        var f = new StyleSheet();
        for (i in ss.imports) {
            var importCss = ToolkitAssets.instance.getText(i.url);
            var importStyleSheet = new Parser().parse(importCss);
            f.merge(importStyleSheet);
        }

        f.merge(ss);
        merge(f);
        _parsedCss.push(hash);
    }

    public function merge(styleSheet:StyleSheet) {
        _ruleIndex = null;
        _imports = _imports.concat(styleSheet._imports);
        _rules = _rules.concat(styleSheet._rules);
        _mediaQueries = _mediaQueries.concat(styleSheet._mediaQueries);
        for (k in styleSheet._animations.keys()) {
            _animations.set(k, styleSheet._animations.get(k));
        }
    }

    public function buildStyleFor(c:Component, style:Style = null):Style {
        if (style == null) {
            style = {};
        }
        // Only the rules that could apply to it, by the last part of their selectors, in their order (see RuleIndex);
        // then the media queries' rules that hold now, after them, as `rules` lists them.
        var candidates = ruleIndex().candidates(c);
        for (i in candidates) {
            var r = _rules[i];
            if (!r.match(c)) {
                continue;
            }

            style.mergeDirectiveList(r.directiveList, r.directives);
        }
        for (mq in _mediaQueries) {
            if (mq.relevant) {
                mq.styleSheet.buildStyleFor(c, style);
            }
        }

        return style;
    }

    private var _ruleIndex:RuleIndex = null;
    private function ruleIndex():RuleIndex {
        if (_ruleIndex == null) {
            _ruleIndex = new RuleIndex(_rules);
        }
        return _ruleIndex;
    }
}

/**
    A stylesheet's rules by the last part of their selectors: its id, else its first class, else its node name, else
    any component. A component is matched only against the rules under its own id, classes and node name and those for
    any component, rather than against every rule, which building a style did for each component. Positions keep the
    rules' order, so the cascade comes out the same.
**/
private class RuleIndex {
    private var byId:Map<String, Array<Int>> = new Map();
    private var byClass:Map<String, Array<Int>> = new Map();
    private var byNode:Map<String, Array<Int>> = new Map();
    private var any:Array<Int> = [];
    private var found:Array<Int> = [];

    public function new(rules:Array<RuleElement>) {
        for (i in 0...rules.length) {
            var parts = rules[i].selector.parts;
            var last = parts[parts.length - 1];
            if (last.id != null) {
                add(byId, last.id, i);
            } else if (last.className != null) {
                add(byClass, last.classNameParts[0], i);
            } else if (last.nodeName != null && last.nodeName != "*") {
                add(byNode, last.nodeName, i);
            } else {
                any.push(i);
            }
        }
    }

    private static function add(map:Map<String, Array<Int>>, key:String, i:Int) {
        var list = map.get(key);
        if (list == null) {
            list = [];
            map.set(key, list);
        }
        list.push(i);
    }

    /** The positions of the rules that could apply to `c`, in order. The array is reused by the next call. **/
    @:access(haxe.ui.core.Component)
    public function candidates(c:Component):Array<Int> {
        found.resize(0);
        for (i in any) {
            found.push(i);
        }
        if (c.id != null) {
            collect(byId.get(c.id));
        }
        var node:String = c.nodeName;
        if (node != null) {
            collect(byNode.get(node));
        }
        for (name in c.classes) {
            collect(byClass.get(name));
        }
        found.sort(compare);
        // A rule sits under one key, but a component could list a class twice.
        var n = 0;
        for (k in 0...found.length) {
            if (k == 0 || found[k] != found[k - 1]) {
                found[n++] = found[k];
            }
        }
        found.resize(n);
        return found;
    }

    private inline function collect(list:Null<Array<Int>>) {
        if (list != null) {
            for (i in list) {
                found.push(i);
            }
        }
    }

    private static function compare(a:Int, b:Int):Int {
        return a - b;
    }
}
