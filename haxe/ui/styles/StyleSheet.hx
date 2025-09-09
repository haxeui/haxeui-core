package haxe.ui.styles;

import haxe.crypto.Sha1;
import haxe.ui.core.Component;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.ImportElement;
import haxe.ui.styles.elements.MediaQuery;
import haxe.ui.styles.elements.RuleElement;
import haxe.ui.styles.elements.Directive;
#if new_selectors
import haxe.ui.styles.selector.SelectorData;
import haxe.ui.styles.selector.SelectorSpecificity;
#end

using StringTools;

class StyleSheet {
    public var name:String;

    private var _styleCacheTree = new haxe.utils.trie.Trie<String, Array<Map<String, Directive>>>();

#if new_selectors
    // private var _directives = new Map<String, Directive>();
    // private var _selectedSelectors = new Map<String, SelectorVO>();
#end

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

    public function buildStyleFor(c:Component, style:Style = null):Style {
        if (style == null) {
            style = {};
        }

        final key = @:privateAccess c._styleCacheKey;
        var cachedDirectives = _styleCacheTree.get(key);
        if (cachedDirectives != null) {
            for (d in cachedDirectives)
                style.mergeDirectives(d);
        } else 
        {

            cachedDirectives = [];

    #if new_selectors
            // _directives.clear();
            // _selectedSelectors.clear();
    #end

            for (r in rules) {
                if (!r.match(c)) {
                    continue;
                }
    #if new_selectors
                // this was some code for specifity but this is broken with the caching now. ignore it
                // for (k=>v in r.directives) {
                //     if (!_directives.exists(k)) {
                //         _directives.set(k, v);
                //         _selectedSelectors.set(k, r.selector);
                //     } else {
                //         if (SelectorSpecificity.get(r.selector) >= SelectorSpecificity.get(_selectedSelectors.get(k))) {
                //             _directives.set(k, v);
                //             _selectedSelectors.set(k, r.selector);
                //         }
                //     }
                // }
                // cachedDirectives.push(_directives);
                cachedDirectives.push(r.directives);
    #else
                cachedDirectives.push(r.directives);
    #end
            }

            for (d in cachedDirectives)
                style.mergeDirectives(d);
            _styleCacheTree.set(key, cachedDirectives);
        }

        return style;
    }
}