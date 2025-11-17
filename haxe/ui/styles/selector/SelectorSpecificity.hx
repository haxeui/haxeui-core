package haxe.ui.styles.selector;

import haxe.ui.styles.selector.SelectorData;

/**
 * Returns the specificity of a selector which is
 * 'weight', used during cascading. 
 * If multiple selectors matches the same elements, the most
 * specific one is used
 */
class SelectorSpecificity
{
    /**
     * Return the specifity of a selector, which is
     * its priority next to other selector
     */
    public static function get(selector:SelectorVO):Int
    {
        //holds the specicities values
        var selectorSpecificityVO = new SelectorSpecificityVO();
        
        //a pseudo element increment the specificity
        switch (selector.pseudoElement)
        {
            case PseudoElementSelectorValue.FIRST_LETTER,
            PseudoElementSelectorValue.FIRST_LINE,
            PseudoElementSelectorValue.AFTER,
            PseudoElementSelectorValue.BEFORE:
                selectorSpecificityVO.typeAndPseudoElementsNumber++;
            
            case PseudoElementSelectorValue.NONE:    
        }
        
        var components:Array<SelectorComponentValue> = selector.components;
        var length:Int = components.length;
        for (i in 0...length)
        {
            var component:SelectorComponentValue = components[i];
            
            switch(component)
            {
                case SelectorComponentValue.COMBINATOR(value):
                    
                case SelectorComponentValue.SIMPLE_SELECTOR_SEQUENCE(value):
                    getSimpleSelectorSequenceSpecificity(value, selectorSpecificityVO);
            }
        }
        
        //specificity has 3 categories, whose int values are concatenated
        //for instance, if idSelectorsNumber is equal to 1, classAttributesAndPseudoClassesNumber to 0
        //and typeAndPseudoElementsNumber to 2,
        //the specificity is 102
        return selectorSpecificityVO.idSelectorsNumber * 100 + selectorSpecificityVO.classAttributesAndPseudoClassesNumber * 10 + selectorSpecificityVO.typeAndPseudoElementsNumber;
    }
    
    /**
     * Increment the specificity of simple selector sequence
     */
    private static function getSimpleSelectorSequenceSpecificity(simpleSelectorSequence:SimpleSelectorSequenceVO, selectorSpecificity:SelectorSpecificityVO):Void
    {
        getSimpleSelectorSequenceStartSpecificity(simpleSelectorSequence.startValue, selectorSpecificity);
        
        var simpleSelectors:Array<SimpleSelectorSequenceItemValue> = simpleSelectorSequence.simpleSelectors;
        var length:Int = simpleSelectors.length;
        for (i in 0...length)
        {
            var simpleSelectorSequenceItem:SimpleSelectorSequenceItemValue = simpleSelectors[i];
            getSimpleSelectorSequenceItemSpecificity(simpleSelectorSequenceItem, selectorSpecificity);
        }
    }
    
    /**
     * Increment specificity according to a simple selector start item
     */
    private static function getSimpleSelectorSequenceStartSpecificity(simpleSelectorSequenceStart:SimpleSelectorSequenceStartValue, selectorSpecificity:SelectorSpecificityVO):Void
    {
        switch(simpleSelectorSequenceStart)
        {
            case SimpleSelectorSequenceStartValue.TYPE(value):
                selectorSpecificity.typeAndPseudoElementsNumber++;
                
            case SimpleSelectorSequenceStartValue.UNIVERSAL:
        }
    }
    
    /**
     * Increment specificity according to a simple selector item
     */
    private static function getSimpleSelectorSequenceItemSpecificity(simpleSelectorSequenceItem:SimpleSelectorSequenceItemValue, selectorSpecificity:SelectorSpecificityVO):Void
    {
        switch (simpleSelectorSequenceItem)
        {
            case ATTRIBUTE(value):
                selectorSpecificity.classAttributesAndPseudoClassesNumber++;
                
            case PSEUDO_CLASS(value):
                selectorSpecificity.classAttributesAndPseudoClassesNumber++;
                
            case CSS_CLASS(value):
                selectorSpecificity.classAttributesAndPseudoClassesNumber++;
                
            case ID(value):
                selectorSpecificity.idSelectorsNumber++;
        }
    }
}

