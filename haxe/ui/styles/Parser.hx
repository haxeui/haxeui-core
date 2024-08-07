package haxe.ui.styles;

import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.AnimationKeyFrame;
import haxe.ui.styles.elements.Directive;
import haxe.ui.styles.elements.DirectiveExtension;
import haxe.ui.styles.elements.ImportElement;
import haxe.ui.styles.elements.MediaQuery;
import haxe.ui.styles.elements.RuleElement;
import haxe.ui.themes.ThemeManager;

// based on: https://github.com/jotform/css.js/blob/master/css.js

using StringTools;

@:access(haxe.ui.themes.ThemeManager)
class Parser {
    static var cssKeyframesRegex:EReg = ~/@keyframes\s*(\w+?)\s*\{([\s\S]*?\}\s*?)\}/gi;
    static var cssKeyframeSelectorRegex:EReg = ~/([\w%]+)\s*\{\s*([\s\S]*?)\s*\}/gi;
    static var combinedCSSMediaRegex:EReg = ~/((\s*?(?:\/\*[\s\S]*?\*\/)?\s*?@media[\s\S]*?)\{([\s\S]*?)\}\s*?\})|(([\s\S]*?)\{([\s\S]*?)\})/gi; //to match css & media queries together
    static var cssCommentsRegex:EReg = ~/(\/\*[\s\S]*?\*\/)/gi;
    static var cssImportStatementRegex:EReg = ~/@import .*?;/gi;

    static var newlineRegex:EReg = new EReg("\n+", "g");

    public function new() {
    }

    public function parse(source:String):StyleSheet {
        source = cssCommentsRegex.replace(source, "");
        
        if (source.indexOf("$") != -1) {
            var n1 = source.indexOf("$");
            while (n1 != -1) {
                var n2 = n1;
                while (n2 <= source.length - 1) {
                    var c = source.charAt(n2);
                    if (c == " " || c == ";" || c == "\n" || c == ",") {
                        break;
                    }
                    n2++;
                }

                if (n2 != source.length - 1) {
                    var key = source.substring(n1 + 1, n2);
                    var value = ThemeManager.instance.currentThemeVars.get(key);
                    if (value != null) {
                        var before = source.substring(0, n1);
                        var after = source.substring(n2);
                        source = before + value + after;
                        n2 = n1 + value.length;
                    } else {
                        trace("WARNING: css variable '" + key + "' not defined");
                    }
                }
                
                n1 = source.indexOf("$", n2);
            }
        }
        
        #if debug
        if (source.indexOf("$") != -1) {
            trace("WARNING: some css variables not resolved");
        }
        #end
        

        var styleSheet = new StyleSheet();

        source = cssImportStatementRegex.map(source, function(e) {
            var i = e.matched(0);
            i = i.substr(7);
            i = ~/"|'|;/g.replace(i, "");
            i = StringTools.trim(i);
            styleSheet.addImport(new ImportElement(i));
            return "";
        });

        source = cssKeyframesRegex.map(source, function(e) {
            var id:String = e.matched(1);
            var data = e.matched(2);

            var keyframes = [];
            cssKeyframeSelectorRegex.map(data, function(e) {
                var selector:String = e.matched(1);
                var directives:String = e.matched(2);
                if (selector == "from") {
                    selector = "0%";
                } else if (selector == "to") {
                    selector = "100%";
                }

                var keyframe = new AnimationKeyFrame();
                keyframe.time = ValueTools.parse(selector);
                keyframe.directives = parseDirectives(directives);
                keyframes.push(keyframe);

                return null;
            });

            var animation = new AnimationKeyFrames(id, keyframes);
            styleSheet.addAnimation(animation);

            return "";
        });

        combinedCSSMediaRegex.map(source, function(e) {
            var selector = "";
            if (e.matched(2) == null) {
                selector = StringTools.trim(e.matched(5).split("\r\n").join("\n"));
            } else {
                selector = StringTools.trim(e.matched(2).split("\r\n").join("\n"));
            }

            // Never have more than a single line break in a row
            selector = newlineRegex.replace(selector, "\n");


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
        } else if (line.startsWith(".")) {
            d = new DirectiveExtension(line);
        } else {
            d = new Directive("", ValueTools.parse(line), true);
        }

        return d;
    }
}
