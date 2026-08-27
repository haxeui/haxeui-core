package haxe.ui.styles.selector.parsers;

import haxe.ui.styles.selector.SelectorData;
using StringTools;

/**
 * CSS Selector pseudo-class parser 
 */
class PseudoClass
{
    //TODO : parse pseudo class with arguments
    public static function parse(selector:String, position:Int, simpleSelectorSequenceItemValues:Array<SimpleSelectorSequenceItemValue>):Int
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
        
        var pseudoClass:String = selector.substr(start, position - start);
        
        var typedPseudoClass:PseudoClassSelectorValue = switch(pseudoClass)
        {
            case 'first-child':
                PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.FIRST_CHILD);
                
            case 'last-child':
                PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.LAST_CHILD);
        
            case 'empty':
                PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.EMPTY);
                
            case 'root':
                PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.ROOT);
                
            case 'first-of-type':
                PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.FIRST_OF_TYPE);    
                
            case 'last-of-type':
                PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.LAST_OF_TYPE);    
                
            case 'only-of-type':
                PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.ONLY_OF_TYPE);    
                
            case 'only-child':
                PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.ONLY_CHILD);
                
            case 'link':
                PseudoClassSelectorValue.LINK(LinkPseudoClassValue.LINK);    
                
            case 'visited':
                PseudoClassSelectorValue.LINK(LinkPseudoClassValue.VISITED);
                
            case 'active':
                PseudoClassSelectorValue.USER_ACTION(UserActionPseudoClassValue.ACTIVE);
                
            case 'hover':
                PseudoClassSelectorValue.USER_ACTION(UserActionPseudoClassValue.HOVER);
                
            case 'focus':
                PseudoClassSelectorValue.USER_ACTION(UserActionPseudoClassValue.FOCUS);
                
            case 'target':
                PseudoClassSelectorValue.TARGET;

            case 'fullscreen':
                PseudoClassSelectorValue.FULLSCREEN;

            // case 'nth-child':
            //     //TODO
                
            // case 'nth-last-child':
            //     //TODO
                
            // case 'nth-of-type':
            //     //TODO
                
            // case 'nth-last-of-type':
            //     //TODO
                
            // case 'not':
            //     //TODO
                
            // case 'lang':
            //     //TODO
                
            case 'enabled':
                PseudoClassSelectorValue.UI_ELEMENT_STATES(UIElementStatesValue.ENABLED);
                
            case 'disabled':
                PseudoClassSelectorValue.UI_ELEMENT_STATES(UIElementStatesValue.DISABLED);
                
            case 'checked':
                PseudoClassSelectorValue.UI_ELEMENT_STATES(UIElementStatesValue.CHECKED);
                
            default: 
                PseudoClassSelectorValue.CUSTOM(pseudoClass);
        }

        //selector is invalid
        if (typedPseudoClass == null)
        {
            return -1;
        }
        
        simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.PSEUDO_CLASS(typedPseudoClass));
        
        return --position;
    }

    static inline function isPseudoClassChar(c) {
        return isAsciiChar(c) || c == '-'.code;
    }

    static inline function isAsciiChar(c) {
        return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code);
    }
}
