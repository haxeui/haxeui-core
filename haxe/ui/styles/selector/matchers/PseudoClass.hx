package haxe.ui.styles.selector.matchers;

import haxe.ui.core.Component;
import haxe.ui.styles.selector.SelectorData;
typedef Element = Component;

// import haxe.ui.styles.dom.Element;
// import haxe.ui.styles.dom.DOMConstants;

/**
 * Functions to match pseudo class selectors
 */
class PseudoClass
{
    /**
     * Return wether a pseudo class matches
     * the element
     */
    public static function match(element:Element, pseudoClassSelector:PseudoClassSelectorValue, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        switch (pseudoClassSelector)
        {
            case PseudoClassSelectorValue.STRUCTURAL(value):
                return matchStructuralPseudoClassSelector(element, value);
                
            case PseudoClassSelectorValue.LINK(value):
                return matchLinkPseudoClassSelector(element, value, matchedPseudoClasses);
                
            case PseudoClassSelectorValue.USER_ACTION(value):
                return matchUserActionPseudoClassSelector(element, value, matchedPseudoClasses);    
                
            case PseudoClassSelectorValue.TARGET:
                return matchTargetPseudoClassSelector(element);
                
            case PseudoClassSelectorValue.NOT(value):
                return matchNegationPseudoClassSelector(element, value);
                
            case PseudoClassSelectorValue.LANG(value):
                return matchLangPseudoClassSelector(element, value);
                
            case PseudoClassSelectorValue.UI_ELEMENT_STATES(value):
                return matchUIElementStatesSelector(element, value, matchedPseudoClasses);

            case PseudoClassSelectorValue.FULLSCREEN:
                return matchedPseudoClasses.fullscreen;

            case PseudoClassSelectorValue.CUSTOM(value):
                return matchedPseudoClasses.nodeClassList.contains(value);
            
            default:
                return false;
        }
    }

    /**
     * Return wether a UI state selector
     * matches the element
     */
    private static function matchUIElementStatesSelector(element:Element, uiElementState:UIElementStatesValue, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        switch(uiElementState)
        {
            case UIElementStatesValue.CHECKED:
                return matchedPseudoClasses.checked;
                
            case UIElementStatesValue.DISABLED:
                return matchedPseudoClasses.disabled;
                
            case UIElementStatesValue.ENABLED:
                return matchedPseudoClasses.enabled;
        }
    }
    
    /**
     * Return wether a negation pseudo-class selector
     * matches the element
     */
    private static function matchNegationPseudoClassSelector(element:Element, negationSimpleSelectorSequence:SimpleSelectorSequenceVO):Bool
    {
        return false;
    }

    /**
     * Return wether a lang pseudo-class selector
     * matches the element
     */
    private static function matchLangPseudoClassSelector(element:Element, lang:Array<String>):Bool
    {
        return false;
    }
    
    /**
     * Return wether a structural pseudo-class selector
     * matches the element
     */
    private static function matchStructuralPseudoClassSelector(element:Element, structuralPseudoClassSelector:StructuralPseudoClassSelectorValue):Bool
    {
        switch(structuralPseudoClassSelector)
        {
            case StructuralPseudoClassSelectorValue.EMPTY:
                return element.childComponents.length == 0;
                
            case StructuralPseudoClassSelectorValue.FIRST_CHILD:
                
                //HTML root element is not considered a first child
                //
                //TODO : parent of root element should actually be a document
                // if (element.parentComponent == null)
                //     return false;
                
                // return element.previousSibling == null;
                return false;
                
            case StructuralPseudoClassSelectorValue.LAST_CHILD:
                
                //HTML root element not considered last child
                // if (element.parentComponent == null)
                //     return false;
                
                // return element.nextSibling == null;
                return false;
                
            case StructuralPseudoClassSelectorValue.ONLY_CHILD:
                
                //HTML root element is not considered only child
                if (element.parentComponent == null)
                {
                    return false;
                }
                
                return element.parentComponent.childComponents.length == 1;
                
            case StructuralPseudoClassSelectorValue.ROOT:
            //     return element.tagName == DOMConstants.HTML_HTML_TAG_NAME && element.parentComponent == null;
                return false;
                
            case StructuralPseudoClassSelectorValue.ONLY_OF_TYPE:
                return matchOnlyOfType(element);
                
            case StructuralPseudoClassSelectorValue.FIRST_OF_TYPE:
                return matchFirstOfType(element);
                
            case StructuralPseudoClassSelectorValue.LAST_OF_TYPE:
                return matchLastOfType(element);    
                
            case StructuralPseudoClassSelectorValue.NTH_CHILD(value):
                return matchNthChild(element, value);
                
            case StructuralPseudoClassSelectorValue.NTH_LAST_CHILD(value):
                return matchNthLastChild(element, value);
                
            case StructuralPseudoClassSelectorValue.NTH_LAST_OF_TYPE(value):
                return matchNthLastOfType(element, value);
                
            case StructuralPseudoClassSelectorValue.NTH_OF_TYPE(value):
                return matchNthOfType(element, value);
        }
    }
    
    private static function matchNthChild(element:Element, value:StructuralPseudoClassArgumentValue):Bool
    {
        // if (element.parentComponent == null) return false;
        // final idx = element.parentComponent.childComponents.indexOf(element)+1;
        // switch(value) {
        //     case INDEX(_idx): return _idx == idx;
        //     case ODD: return (idx & 1) != 0;
        //     case EVEN: return (idx & 1) != 0;
        // }
        return false;
    }
    
    private static function matchNthLastChild(element:Element, value:StructuralPseudoClassArgumentValue):Bool
    {
        // if (element.parentComponent == null) return false;
        // final idx:Int = element.parentComponent.childComponents.length - (element.parentComponent.childComponents.indexOf(element) + 1);
        // switch(value) {
        //     case INDEX(_idx): return _idx == idx;
        //     case ODD: return (idx & 1) != 0;
        //     case EVEN: return (idx & 1) != 0;
        // }
        return false;
    }
    
    private static function matchNthLastOfType(element:Element, value:StructuralPseudoClassArgumentValue):Bool
    {
        return false;
    }
    
    private static function matchNthOfType(element:Element, value:StructuralPseudoClassArgumentValue):Bool
    {
        return false;
    }
    
    /**
     * Return wether the element is the first 
     * element among its element siblings of
     * its type (tag name)
     */
    private static function matchFirstOfType(element:Element):Bool
    {
        // var type = element.tagName;        
        // var previousSibling:Element = element.previousSibling;        
        // while (previousSibling != null) {
        //     if (previousSibling.tagName == type)
        //         return false;            
        //     previousSibling = previousSibling.previousSibling;
        // }        
        // return true;
        return false;
    }
    
    /**
     * Same as above but for last element
     */
    private static function matchLastOfType(element:Element):Bool
    {
        // var type = element.tagName;        
        // var nextSibling:Element = element.nextSibling;        
        // while (nextSibling != null) {
        //     if (nextSibling.tagName == type)
        //         return false;            
        //     nextSibling = nextSibling.nextSibling;
        // }        
        // return true;
        return false;
    }
    
    /**
     * Return wether this element is the only among
     * its element sibling of its type (tag name)
     */
    private static function matchOnlyOfType(element:Element):Bool
    {
        //to be the only of its type is the same as
        //being the first and last of its type
        return matchLastOfType(element) == true && matchFirstOfType(element) == true;
    }
    
    /**
     * Return wether a link pseudo-class selector
     * matches the element
     */
    private static function matchLinkPseudoClassSelector(element:Element, linkPseudoClassSelector:LinkPseudoClassValue, matchedPseudoClass:MatchedPseudoClassesVO):Bool
    {
        switch(linkPseudoClassSelector)
        {
            case LinkPseudoClassValue.LINK:
                return matchedPseudoClass.link;
                
            case LinkPseudoClassValue.VISITED:
                return false;
        }
    }
    
    /**
     * Return wether a user pseudo-class selector
     * matches the element
     */
    private static function matchUserActionPseudoClassSelector(element:Element, userActionPseudoClassSelector:UserActionPseudoClassValue, matchedPseudoClass:MatchedPseudoClassesVO):Bool
    {
        switch(userActionPseudoClassSelector)
        {
            case UserActionPseudoClassValue.ACTIVE:
                return matchedPseudoClass.active;
                
            case UserActionPseudoClassValue.HOVER:
                return matchedPseudoClass.hover;
                
            case UserActionPseudoClassValue.FOCUS:
                return matchedPseudoClass.focus;
        }
    }
    
    /**
     * Return wether the target pseudo-class 
     * matches the element.
     */
    private static function matchTargetPseudoClassSelector(element:Element):Bool
    {
        return false;
    }
}

