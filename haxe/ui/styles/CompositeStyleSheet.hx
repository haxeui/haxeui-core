package haxe.ui.styles;

import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.styles.StyleSheet;
import haxe.ui.styles.elements.AnimationKeyFrames;

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
    
    public function buildStyleFor(c:Component):Style {
        var style = new Style();
        
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