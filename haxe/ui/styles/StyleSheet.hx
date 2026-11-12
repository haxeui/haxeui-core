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
            _rulesByComponent = null;
        }
    }

    public function removeAllRules() {
        _rules = [];
        _rulesByComponent = null;
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
        _rulesByComponent = null;
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
        _rulesByComponent = null;
        _mediaQueries = _mediaQueries.concat(styleSheet._mediaQueries);
        for (k in styleSheet._animations.keys()) {
            _animations.set(k, styleSheet._animations.get(k));
        }
    }

    public function buildStyleFor(c:Component, style:Style = null):Style {
        if (style == null) {
            style = Style.empty();
        }
        mergeRulesFor(c, style);
        return style;
    }

    private function mergeRulesFor(c:Component, style:Style) {
        for (r in rulesThatCouldMatch(c)) {
            if (r.match(c)) {
                style.mergeDirectives(r.directives);
            }
        }
        for (mq in _mediaQueries) {
            if (mq.relevant) {
                mq.styleSheet.mergeRulesFor(c, style);
            }
        }
    }

    // A theme has hundreds of rules and a component matches a handful of them, nearly all the rest
    // ruled out by its own name, id and classes. So the rules each such component could match are
    // kept, in order, to spare testing the others every time a style is built. Rules that ask about
    // ancestors are still tested, as those can change without the component changing.
    private var _rulesByComponent:Map<String, Array<RuleElement>> = null;
    private var _idsNeeded:Map<String, Bool> = null;

    private function rulesThatCouldMatch(c:Component):Array<RuleElement> {
        if (_rulesByComponent == null) {
            _rulesByComponent = new Map<String, Array<RuleElement>>();
            _idsNeeded = new Map<String, Bool>();
            for (r in _rules) {
                if (r.idNeeded != null) {
                    _idsNeeded.set(r.idNeeded, true);
                }
            }
        }
        // An id no rule asks for can't make a difference: left out, ids made up at runtime don't
        // each add an entry.
        var id = c.id;
        var key = c.nodeName + " " + (id != null && _idsNeeded.exists(id) ? id : "") + " " + c.classes.join(" ");
        var found = _rulesByComponent.get(key);
        if (found == null) {
            found = [for (r in _rules) if (r.couldMatch(c)) r];
            _rulesByComponent.set(key, found);
        }
        return found;
    }
}