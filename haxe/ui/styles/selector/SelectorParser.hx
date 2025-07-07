/*
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
*/
package haxe.ui.styles.selector;

using StringTools;
import haxe.ui.styles.selector.SelectorData;
import haxe.ui.styles.selector.SelectorMetadata;
import haxe.ui.styles.selector.parsers.*;

/**
 * This class is a parser whose role
 * is to parse a single CSS selector string,
 * and parse it into typed selector data.
 *
 * Trying to parse multiple selectors (example: "div, p")
 * will fail
 * 
 * @author Yannick DOMINGUEZ
 */
class SelectorParser 
{
    /**
     * Parse the selector string into a typed selector object
     *
     * @param selector the CSS selector string to parse
     * @return the typed selector or null if the selector is invalid
     */
    public static function parse(selector:String):SelectorVO
    {
        var state:SelectorParserState = IGNORE_SPACES;
        var next:SelectorParserState = BEGIN_SIMPLE_SELECTOR;
        var start:Int = 0;
        var position:Int = 0;
        var c:Int = selector.fastCodeAt(position);
        
        var simpleSelectorSequenceStartValue:SimpleSelectorSequenceStartValue = null;
        var simpleSelectorSequenceItemValues:Array<SimpleSelectorSequenceItemValue> = [];
        var components:Array<SelectorComponentValue> = [];
        
        var selectorData:SelectorVO = new SelectorVO(components, PseudoElementSelectorValue.NONE,
        false, null, false, null, false, null, false, false, false);
        
        while (!StringTools.isEof(c))
        {
            switch (state)
            {
                case IGNORE_SPACES:
                    switch(c)
                    {
                        case
                            '\n'.code,
                            '\r'.code,
                            '\t'.code,
                            ' '.code:
                        default:
                            state = next;
                            continue;
                    }
                    
                case BEGIN_SIMPLE_SELECTOR:
                    if (isSelectorChar(c))
                    {
                        state = SIMPLE_SELECTOR;
                        next = END_TYPE_SELECTOR;
                        start = position;
                    }
                    else
                    {
                        switch(c)
                        {
                            
                            case '.'.code:
                                state = SIMPLE_SELECTOR;
                                next = END_CLASS_SELECTOR;
                                start = position + 1;
                                
                            case '#'.code:
                                state = SIMPLE_SELECTOR;
                                next = END_ID_SELECTOR;
                                start = position + 1;
                                
                            case '*'.code:
                                state = SIMPLE_SELECTOR;
                                next = END_UNIVERSAL_SELECTOR;
                                start = position;
                                
                            case ':'.code:
                                state = BEGIN_PSEUDO_SELECTOR;
                                start = position;
                                
                            case '['.code:
                                state = BEGIN_ATTRIBUTE_SELECTOR;
                                start = position;
                                continue;
                                
                            default:
                                state = INVALID_SELECTOR;
                                continue;
                        }
                    }
                    
                    
                case BEGIN_ATTRIBUTE_SELECTOR:
                    position = Attribute.parse(selector, position, simpleSelectorSequenceItemValues);
                    state = END_SIMPLE_SELECTOR;
                    next = IGNORE_SPACES;
                    
                case BEGIN_PSEUDO_SELECTOR:
                    if (isSelectorChar(c))
                    {
                        position = PseudoClass.parse(selector, position, simpleSelectorSequenceItemValues);
                        state = END_SIMPLE_SELECTOR;
                        next = IGNORE_SPACES;
                    }
                    else
                    {
                        switch(c)
                        {
                            case ':'.code:
                                state = PSEUDO_ELEMENT_SELECTOR;
                                
                            default:
                                state = INVALID_SELECTOR;
                                continue;
                        }
                    }
                    
                case PSEUDO_ELEMENT_SELECTOR:    
                    position = PseudoElement.parse(selector, position, selectorData);
                    state = IGNORE_SPACES;
                    next = INVALID_SELECTOR;
                    
                case END_SIMPLE_SELECTOR:
                    switch(c)
                    {
                        case ' '.code, '\n'.code, '\r'.code, '>'.code:
                            state = BEGIN_COMBINATOR;
                            continue;
                                
                        case ':'.code, '#'.code, '.'.code, '['.code:
                            state = BEGIN_SIMPLE_SELECTOR;
                            continue;
                            
                        default:
                            state = INVALID_SELECTOR;
                            continue;
                    }
                    
                case SIMPLE_SELECTOR:    
                    if (!isSelectorChar(c))
                    {
                        switch(c)
                        {
                            case ' '.code, '\n'.code, '\r'.code, '>'.code, ':'.code, '#'.code, '.'.code, '['.code:
                                state = next;
                                continue;
                                
                            default:
                                state = INVALID_SELECTOR;
                                continue;
                        }
                    }
                    
                case END_TYPE_SELECTOR:
                    var type:String = selector.substr(start, position - start);
                    simpleSelectorSequenceStartValue = SimpleSelectorSequenceStartValue.TYPE(type.toUpperCase());
                    state = END_SIMPLE_SELECTOR;
                    continue;
                    
                case END_CLASS_SELECTOR:
                    var className:String = selector.substr(start, position - start);
                    simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.CSS_CLASS(className));
                    state = END_SIMPLE_SELECTOR;
                    continue;
                    
                case END_ID_SELECTOR:
                    var id:String = selector.substr(start, position - start);
                    simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ID(id));
                    state = END_SIMPLE_SELECTOR;    
                    continue;
                    
                case END_UNIVERSAL_SELECTOR:
                    simpleSelectorSequenceStartValue = SimpleSelectorSequenceStartValue.UNIVERSAL;
                    state = END_SIMPLE_SELECTOR;
                    continue;
                    
                case BEGIN_COMBINATOR:
                    
                    flushSelectors(simpleSelectorSequenceStartValue, simpleSelectorSequenceItemValues, components);
                    
                    simpleSelectorSequenceStartValue = null;
                    simpleSelectorSequenceItemValues = [];
                    
                    state = IGNORE_SPACES;
                    next = COMBINATOR;
                    continue;
                    
                case COMBINATOR:
                    
                    if (isSelectorChar(c))
                    {
                        state = BEGIN_SIMPLE_SELECTOR;
                        components.push(SelectorComponentValue.COMBINATOR(CombinatorValue.DESCENDANT));
                        continue;
                    }
                    else
                    {
                        switch(c)
                        {
                            case '>'.code:
                                state = IGNORE_SPACES;
                                next = BEGIN_SIMPLE_SELECTOR;
                                components.push(SelectorComponentValue.COMBINATOR(CombinatorValue.CHILD));
                                
                            case '+'.code:
                                state = IGNORE_SPACES;
                                next = BEGIN_SIMPLE_SELECTOR;
                                components.push(SelectorComponentValue.COMBINATOR(CombinatorValue.ADJACENT_SIBLING));
                                
                            case '~'.code:
                                state = IGNORE_SPACES;
                                next = BEGIN_SIMPLE_SELECTOR;
                                components.push(SelectorComponentValue.COMBINATOR(CombinatorValue.GENERAL_SIBLING));
                                
                            case ':'.code, '#'.code, '.'.code, '['.code, '*'.code:
                            state = BEGIN_SIMPLE_SELECTOR;
                            components.push(SelectorComponentValue.COMBINATOR(CombinatorValue.DESCENDANT));
                            continue;
                        }
                    }
                    
                case INVALID_SELECTOR:
                    return null;
            }
            c = selector.fastCodeAt(++position);
        }
        
        //TODO 2 : dusplaicate code, when reading ident, should
        //read until end of file
        switch(next)
        {
            case END_TYPE_SELECTOR:
                var type = selector.substr(start, position - start);
                //type stored internally as uppercase to match html tag name
                simpleSelectorSequenceStartValue = SimpleSelectorSequenceStartValue.TYPE(type.toUpperCase());
                
            case END_UNIVERSAL_SELECTOR:    
                simpleSelectorSequenceStartValue = SimpleSelectorSequenceStartValue.UNIVERSAL;
                
            case END_CLASS_SELECTOR:
                var className:String = selector.substr(start, position - start);
                simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.CSS_CLASS(className));
                state = END_SIMPLE_SELECTOR;
                
            case END_ID_SELECTOR:
                var id = selector.substr(start, position - start);
                simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ID(id));
                
            default:    
        }
        
        flushSelectors(simpleSelectorSequenceStartValue, simpleSelectorSequenceItemValues, components);
        
        //if at this point, there are no components in
        //this selector, it is invalid
        if (selectorData.components.length == 0)
        {
            return null;
        }
        
        //simple selectors and combinators are parsed from left to 
        //right but are matched from right to left to match
        //combinators logic, so the array is reversed
        selectorData.components.reverse();
        
        //if the selector begins with a class return it, else return null
        var firstClass:String = SelectorMetadata.getFirstClass(selectorData.components);
        
        //check wether the selector only contains a single class
        var isSimpleClassSelector:Bool = false;
        if (firstClass != null)
        {
            isSimpleClassSelector = SelectorMetadata.getIsSimpleClassSelector(selectorData.components);
        }
        
        //same as above for Id
        var firstId:String = SelectorMetadata.getFirstId(selectorData.components);
        
        var isSimpleIdSelector:Bool = false;
        if (firstId != null)
        {
            isSimpleIdSelector = SelectorMetadata.getIsSimpleIdSelector(selectorData.components);
        }
        
        //same as above for type
        var firstType:String = SelectorMetadata.getFirstType(selectorData.components);
        
        var isSimpleTypeSelector:Bool = false;
        if (firstType != null)
        {
            isSimpleTypeSelector = SelectorMetadata.getIsSimpleTypeSelector(selectorData.components);
        }
        
        var typedSelector:SelectorVO = new SelectorVO(selectorData.components, selectorData.pseudoElement,
        firstClass != null, firstClass,
        firstId != null, firstId,
        firstType != null, firstType
        , isSimpleClassSelector, isSimpleIdSelector, isSimpleTypeSelector);
        
        return typedSelector;
    }

    private static function flushSelectors(simpleSelectorSequenceStartValue:SimpleSelectorSequenceStartValue, simpleSelectorSequenceItemValues:Array<SimpleSelectorSequenceItemValue>, components:Array<SelectorComponentValue>):Void
    {
        if (simpleSelectorSequenceStartValue == null && simpleSelectorSequenceItemValues.length == 0)
        {
            return;
        }
        
        if (simpleSelectorSequenceStartValue == null)
        {
            simpleSelectorSequenceStartValue = SimpleSelectorSequenceStartValue.UNIVERSAL;
        }

        var simpleSelectorSequence:SimpleSelectorSequenceVO = new SimpleSelectorSequenceVO(simpleSelectorSequenceStartValue, simpleSelectorSequenceItemValues);
        components.push(SelectorComponentValue.SIMPLE_SELECTOR_SEQUENCE(simpleSelectorSequence));
        
    }
    
    static inline function isAsciiChar(c) {
        return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code);
    }
    
    static inline function isSelectorChar(c) {
        return isAsciiChar(c) || c == '-'.code || c == '_'.code;
    }
}

