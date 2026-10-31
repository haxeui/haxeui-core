package haxe.ui.styles;

import haxe.crypto.Sha1;
import haxe.ui.core.Component;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.ImportElement;
import haxe.ui.styles.elements.MediaQuery;
import haxe.ui.styles.elements.RuleElement;

using StringTools;

@:access(haxe.ui.core.Component)
class StyleSheet {
    public var name:String;

    private var _imports:Array<ImportElement> = [];
    private var _rules:Array<RuleElement> = [];

    // Indexes into _rules, built lazily by buildRuleIndex(): a rule is filed under the key its last selector part
    // requires of a component, so buildStyleFor() only tests the rules that can match. _unindexedRules == null means
    // the index is stale.
    private var _nodeNameIndex:Map<String, Array<Int>>;
    private var _idIndex:Map<String, Array<Int>>;
    private var _classNameIndex:Map<String, Array<Int>>;
    private var _unindexedRules:Array<Int>;

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
            _rules.remove(r);
            _unindexedRules = null;
        }
    }

    public function removeAllRules() {
        _rules = [];
        _unindexedRules = null;
        _parsedCss = [];
    }

    public function clear() {
        removeAllRules();
        _imports = [];
        _mediaQueries = [];
        _animations = new Map<String, AnimationKeyFrames>();
    }

    public function addRule(el:RuleElement) {
        if (el.directiveCount == 0) {
            return;
        }
        _rules.push(el);
        _unindexedRules = null;
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
        _imports = _imports.concat(styleSheet._imports);
        _rules = _rules.concat(styleSheet._rules);
        _unindexedRules = null;
        _mediaQueries = _mediaQueries.concat(styleSheet._mediaQueries);
        for (k in styleSheet._animations.keys()) {
            _animations.set(k, styleSheet._animations.get(k));
        }
    }

    private function buildRuleIndex() {
        _nodeNameIndex = new Map<String, Array<Int>>();
        _idIndex = new Map<String, Array<Int>>();
        _classNameIndex = new Map<String, Array<Int>>();
        _unindexedRules = [];

        for (i in 0..._rules.length) {
            var part = _rules[i].selector.parts[_rules[i].selector.parts.length - 1];
            if (part == null || part.nodeName == "*") {
                _unindexedRules.push(i);
            } else if (part.nodeName != null) {
                addToIndex(_nodeNameIndex, part.nodeName, i);
            } else if (part.id != null) {
                addToIndex(_idIndex, part.id, i);
            } else if (part.className != null) {
                addToIndex(_classNameIndex, part.classNameParts[0], i);
            } else {
                _unindexedRules.push(i);
            }
        }
    }

    private static function addToIndex(index:Map<String, Array<Int>>, key:String, ruleIndex:Int) {
        var indices = index.get(key);
        if (indices == null) {
            indices = [];
            index.set(key, indices);
        }
        indices.push(ruleIndex);
    }

    public function buildStyleFor(c:Component, style:Style = null):Style {
        if (style == null) {
            style = {};
        }
        if (_unindexedRules == null) {
            buildRuleIndex();
        }

        var candidates = _unindexedRules.copy();
        if (c.nodeName != null && _nodeNameIndex.exists(c.nodeName)) {
            candidates = candidates.concat(_nodeNameIndex.get(c.nodeName));
        }
        if (c.id != null && _idIndex.exists(c.id)) {
            candidates = candidates.concat(_idIndex.get(c.id));
        }
        for (i in 0...c.classes.length) {
            var className = c.classes[i];
            // a class listed twice must not add its rules twice
            if (c.classes.indexOf(className) == i && _classNameIndex.exists(className)) {
                candidates = candidates.concat(_classNameIndex.get(className));
            }
        }
        candidates.sort((a, b) -> a - b); // the cascade follows source order

        for (i in candidates) {
            var r = _rules[i];
            if (!r.match(c)) {
                continue;
            }

            style.mergeDirectives(r.directives);
        }

        for (mq in _mediaQueries) {
            if (mq.relevant) {
                style = mq.styleSheet.buildStyleFor(c, style);
            }
        }

        return style;
    }
}