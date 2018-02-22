package haxe.ui.styles;

import haxe.ui.core.Component;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.ImportElement;
import haxe.ui.styles.elements.MediaQuery;
import haxe.ui.styles.elements.RuleElement;

class StyleSheet {
    private var _imports:Array<ImportElement> = [];
    private var _rules:Array<RuleElement> = [];
    
    private var _mediaQueries:Array<MediaQuery> = [];
    public var _animations:Map<String, AnimationKeyFrames> = new Map<String, AnimationKeyFrames>();
    
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
    
    public function addRule(el:RuleElement) {
        _rules.push(el);
    }
    
    public function addMediaQuery(el:MediaQuery) {
        _mediaQueries.push(el);
    }
    
    public function addAnimation(el:AnimationKeyFrames) {
        _animations.set(el.id, el);
    }
    
    public function parse(css:String) {
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
    }
    
    public function merge(styleSheet:StyleSheet) {
        _imports = _imports.concat(styleSheet._imports);
        _rules = _rules.concat(styleSheet._rules);
        _mediaQueries = _mediaQueries.concat(styleSheet._mediaQueries);
        for (k in styleSheet._animations.keys()) {
            _animations.set(k, styleSheet._animations.get(k));
        }
    }
    
    public function buildStyleFor(c:Component):Style {
        var relevantRules:Array<RuleElement> = [];
        for (r in rules) {
            if (!r.match(c)) {
                continue;
            }
            relevantRules.push(r);
        }
        
        var style:Style = new Style();
        for (r in relevantRules) {
            style.mergeDirectives(r.directives);
        }

        if (style.animationName != null) {
            style.animationKeyFrames = _animations.get(style.animationName);
        }
        
        return style;
    }
}