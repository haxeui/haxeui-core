package haxe.ui.styles;

import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.styles.Style;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.RuleElement;

class CompositeStyleSheet {
    private var _styleSheets:Array<StyleSheet> = [];

    public function new() {
    }

    private var _animations:Map<String, AnimationKeyFrames> = null;
    public var animations(get, never):Map<String, AnimationKeyFrames>;
    private function get_animations():Map<String, AnimationKeyFrames> {
        if (_animations != null) {
            return _animations;
        }

        _animations = new Map<String, AnimationKeyFrames>();

        for (s in _styleSheets) {
            for (key in s.animations.keys()) {
                var a = s.animations.get(key);
                _animations.set(key, a);
            }
        }

        return _animations;
    }

    public function findAnimation(id:String) {
        for (a in animations) {
            if (a.id == id) {
                return a;
            }
        }
        
        return null;
    }
    
    public var hasMediaQueries(get, null):Bool;
    private function get_hasMediaQueries():Bool {
        for (styleSheet in _styleSheets) {
            if (styleSheet.hasMediaQueries == true) {
                return true;
            }
        }
        return false;
    }
    
    public function getAnimation(id:String, create:Bool = true):AnimationKeyFrames {
        var a = findAnimation(id);
        if (a == null) {
            a = new AnimationKeyFrames(id, []);
            addAnimation(a);
        }
        return a;
    }
    
    public function addAnimation(animation:AnimationKeyFrames) {
        _styleSheets[0].addAnimation(animation);
    }
    
    public function addStyleSheet(styleSheet:StyleSheet) {
        _styleSheets.push(styleSheet);
    }

    public function removeStyleSheet(styleSheet:StyleSheet) {
        _styleSheets.remove(styleSheet);
    }

    public function parse(css:String, styleSheetName:String = "default", invalidateAll:Bool = false) {
        var s = findStyleSheet(styleSheetName);
        if (s == null) {
            s = new StyleSheet();
            s.name = styleSheetName;
            _styleSheets.push(s);
        }

        s.parse(css);
        _animations = null;

        if (invalidateAll == true) {
            Screen.instance.invalidateAll();
        }
    }

    public function findStyleSheet(styleSheetName:String):StyleSheet {
        for (s in _styleSheets) {
            if (s.name == styleSheetName) {
                return s;
            }
        }

        return null;
    }

    public function findRule(selector:String, useCache:Bool = false):RuleElement {
        for (s in _styleSheets) {
            var el = s.findRule(selector, useCache);
            if (el != null) {
                return el;
            }
        }
        return null;
    }

    private var _matchingRuleCache:Map<String, Array<RuleElement>> = new Map<String, Array<RuleElement>>();
    public function findMatchingRules(selector:String, useCache = false):Array<RuleElement> {
        if (useCache && _matchingRuleCache.exists(selector)) {
            return _matchingRuleCache.get(selector);
        }
        var m = [];
        for (s in _styleSheets) {
            m = m.concat(s.findMatchingRules(selector, useCache));
        }
        if (useCache && m.length > 0) {
            _matchingRuleCache.set(selector, m);
        }
        return m;
    }
    
    public function getAllRules():Array<RuleElement> {
        var r = [];
        for (s in _styleSheets) {
            r = r.concat(s.rules);
        }
        return r;
    }
    
    public function buildStyleFor(c:Component):Style {
        var style:Style = {};

        for (s in _styleSheets) {
            style = s.buildStyleFor(c, style);
        }

        return style;
    }

    public function clear(styleSheetName:String) {
        var s = findStyleSheet(styleSheetName);
        if (s != null) {
            s.clear();
            _animations = null;
        }
    }
}