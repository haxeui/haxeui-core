package haxe.ui.styles;

import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.AnimationKeyFrame;
import haxe.ui.styles.elements.Directive;
import haxe.ui.styles.elements.ImportElement;
import haxe.ui.styles.elements.MediaQuery;
import haxe.ui.styles.elements.RuleElement;

// based on: https://github.com/jotform/css.js/blob/master/css.js

class Parser {
    var cssRegex = new EReg('([\\s\\S]*?)\\{([\\s\\S]*?)\\}', 'gi');
    var cssMediaQueryRegex = '((@media [\\s\\S]*?)\\{([\\s\\S]*?\\}\\s*?)\\})';
    var cssKeyframeRegex = new EReg('((@.*?keyframes [\\s\\S]*?)\\{([\\s\\S]*?\\}\\s*?)\\})', 'gi');
    var combinedCSSRegex = '((\\s*?(?:\\/\\*[\\s\\S]*?\\*\\/)?\\s*?@media[\\s\\S]*?)\\{([\\s\\S]*?)\\}\\s*?\\})|(([\\s\\S]*?)\\{([\\s\\S]*?)\\})'; //to match css & media queries together
    var cssCommentsRegex = new EReg('(\\/\\*[\\s\\S]*?\\*\\/)', 'gi');
    var cssImportStatementRegex = new EReg('@import .*?;', 'gi');
    
    public function new() {
    }
    
    public function parse(source:String):StyleSheet {
        source = cssCommentsRegex.replace(source, "");
        
        var styleSheet = new StyleSheet();
        
        source = cssImportStatementRegex.map(source, function(e) {
            var i = e.matched(0);
            i = i.substr(7);
            i = StringTools.replace(i, "\"", "");
            i = StringTools.replace(i, "'", "");
            i = StringTools.replace(i, ";", "");
            i = StringTools.trim(i);
            styleSheet.addImport(new ImportElement(i));
            return "";
        });
        
        source = cssKeyframeRegex.map(source, function(e) {
            var k = e.matched(0);
            
            var selector = StringTools.trim(StringTools.replace(extractSelector(k), "@keyframes", ""));
            var data = extractDirectives(k);
            
            var keyframes = new Array<AnimationKeyFrame>();
            var arr = data.split("\n");
            for (a in arr) {
                a = StringTools.trim(a);
                var keyframe = new AnimationKeyFrame();
                keyframe.time = ValueTools.parse(extractSelector(a));
                keyframe.directives = parseDirectives(extractDirectives(a));
                keyframes.push(keyframe);
                trace(keyframe);
            }
            
            var animation = new AnimationKeyFrames(selector, keyframes);
            styleSheet.addAnimation(animation);
            
            return "";
        });
        
        var unified = new EReg(combinedCSSRegex, 'gi');
        unified.map(source, function(e) {
            var selector = "";
            if (e.matched(2) == null) {
                selector = StringTools.trim(e.matched(5).split("\r\n").join("\n"));
            } else {
                selector = StringTools.trim(e.matched(2).split("\r\n").join("\n"));
            }
            
            // Never have more than a single line break in a row
            selector = new EReg("\n+", "g").replace(selector, "\n");
            
            
            //determine the type
            if (selector.indexOf('@media') != -1) {
                var n1 = selector.indexOf("(");
                var n2 = selector.lastIndexOf(")");
                var mediaQuery = selector.substring(n1 + 1, n2);
                
                var mediaStyleSheet = new Parser().parse(e.matched(3) + '\n}');
                var mq = new MediaQuery(parseDirectives(mediaQuery), mediaStyleSheet);
                styleSheet.addMediaQuery(mq);
            } else {
                //we have standard css
                var directives = parseDirectives(e.matched(6));
                var selectors = selector.split(",");
                for (s in selectors) {
                    s = StringTools.trim(s);
                    if (s.length > 0) {
                        styleSheet.addRule(new RuleElement(s, directives));
                    }
                }
            }
            
            return null;
        });
        
        return styleSheet;
    }
    
    private function parseDirectives(rulesString:String):Array<Directive> {
        rulesString = rulesString.split('\r\n').join('\n');
        var ret:Array<Directive> = [];
        
        var rules = rulesString.split(';');
        for (line in rules) {
            var d = parseDirective(line);
            if (d != null) {
                ret.push(d);
            }
        }
        
        return ret;
    }
    
    private function parseDirective(line:String):Directive {
        var d = null;
        line = StringTools.trim(line);
        if (line.length == 0) {
            return null;
        }
        
        if (line.indexOf(':') != -1) {
            var parts = line.split(':');
            var cssDirective = StringTools.trim(parts[0]);
            var cssValue = StringTools.trim(parts.slice(1).join(':'));
            
            //more checks
            if (cssDirective.length < 1 || cssValue.length < 1) {
                return null;
            }
            d = new Directive(cssDirective, ValueTools.parse(cssValue));
        } else {
            d = new Directive("", ValueTools.parse(line), true);
        }
        
        return d;
    }
    
    private function extractSelector(s:String):String {
        var selector = null;
 
        var n1 = s.indexOf("{");
        selector = StringTools.trim(s.substr(0, n1));
        
        return selector;
    }
    
    private function extractDirectives(s:String):String {
        var directives = null;
        
        var n1 = s.indexOf("{");
        var n2 = s.lastIndexOf("}");
        directives = StringTools.trim(s.substr(n1 + 1, n2 - n1 - 1));
        
        return directives;
    }
}