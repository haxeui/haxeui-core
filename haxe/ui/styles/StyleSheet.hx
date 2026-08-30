package haxe.ui.styles;

import haxe.crypto.Sha1;
import haxe.ui.core.Component;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.Directive;
import haxe.ui.styles.elements.ImportElement;
import haxe.ui.styles.elements.MediaQuery;
import haxe.ui.styles.elements.RuleElement;
import haxe.ui.styles.elements.Selector;

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
        }
    }

    public function removeAllRules() {
        _rules = [];
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
        _mediaQueries = _mediaQueries.concat(styleSheet._mediaQueries);
        for (k in styleSheet._animations.keys()) {
            _animations.set(k, styleSheet._animations.get(k));
        }
    }

    var directives = new Map<String, Directive>();
    var selectedSelectors = new Map<String, Selector>();

    public function buildStyleFor(c:Component, style:Style = null):Style {
        if (style == null) {
            style = {};
        }

        if (rules.length <= 0) {
            return style;
        }

        directives.clear();

        for (r in rules) {
            if (!r.match(c)) {
                continue;
            }

            for (k in r.directives.keys()) {
                var v = r.directives.get(k);
                if (!directives.exists(k)) {
                    directives[k] = v;
                    selectedSelectors[k] = r.selector;
                } else {
                    if (r.selector.hasPrecedenceOrEqualTo(selectedSelectors[k])) {
                        directives[k] = v;
                        selectedSelectors[k] = r.selector;
                        if (k == "background-color") {
                            directives["background-color-end"] = v;
                            selectedSelectors["background-color-end"] = r.selector;
                        }
                    }
                }
            }
        }

        style.mergeDirectives(directives);

        return style;
    }
}