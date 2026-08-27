package haxe.ui.styles.selector.parsers;

import haxe.ui.styles.selector.SelectorData;
using StringTools;

/**
 * CSS Selector pseudo-element parser
 */
class PseudoElement
{
    public static function parse(selector:String, position:Int, selectorData:SelectorVO):Int
    {
        var c:Int = selector.fastCodeAt(position);
        var start:Int = position;
        
        while (true)
        {
            if (!isPseudoClassChar(c))
            {
                break;
            }
            c = selector.fastCodeAt(++position);
        }
        
        var pseudoElement:String = selector.substr(start, position - start);
        var typedPseudoElement:PseudoElementSelectorValue = null;
        
        switch (pseudoElement)
        {
            case 'first-line':
                typedPseudoElement = PseudoElementSelectorValue.FIRST_LINE;
                
            case 'first-letter':
                typedPseudoElement = PseudoElementSelectorValue.FIRST_LETTER;
                
            case 'before':
                typedPseudoElement = PseudoElementSelectorValue.BEFORE;
                
            case 'after':
                typedPseudoElement = PseudoElementSelectorValue.AFTER;

            default:
                typedPseudoElement = PseudoElementSelectorValue.NONE;
                
        }
        
        selectorData.pseudoElement = typedPseudoElement;
        
        return --position;
    }

    static inline function isPseudoClassChar(c) {
        return isAsciiChar(c) || c == '-'.code;
    }

    static inline function isAsciiChar(c) {
        return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code);
    }
}
