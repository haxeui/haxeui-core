package haxe.ui.styles.selector.parsers;

import haxe.ui.styles.selector.SelectorData;
using StringTools;

/**
 * CSS Selector attribute parser 
 */
class Attribute
{
    public static function parse(selector:String, position:Int, simpleSelectorSequenceItemValues:Array<SimpleSelectorSequenceItemValue>):Int
    {
        //consumes '[' token
        position++;

        var c:Int = selector.fastCodeAt(position);
        var start:Int = position;
        
        var attribute:String = null;
        var op:String = null; // operator
        var value:String = null;
        
        var state:AttributeSelectorParserState = IGNORE_SPACES;
        var next:AttributeSelectorParserState = ATTRIBUTE;
        
        while (true)
        {
            switch(state)
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
                
                case ATTRIBUTE:
                    if (!isSelectorChar(c))
                    {
                        attribute = selector.substr(start, position - start);
                        
                        if (c == ']'.code)
                        {
                            state = END_SELECTOR;
                            continue;
                        }
                        else
                        {
                            state = IGNORE_SPACES;
                            next = BEGIN_OPERATOR;
                            continue;
                        }
                    }
                
                case BEGIN_OPERATOR:
                    start = position;
                    state = OPERATOR;
                    
                case OPERATOR:
                    if (!isOperatorChar(c))
                    {
                        op = selector.substr(start, position - start);
                        state = IGNORE_SPACES;
                        next = END_OPERATOR;
                        continue;
                    }
                    
                case END_OPERATOR:
                    switch(c)
                        {
                            case '"'.code, "'".code:
                                position++;
                                start = position;
                                state = STRING_VALUE;
                                
                            case ']'.code:
                                state = END_SELECTOR;
                                continue;
                                
                            default:
                                
                                if (isSelectorChar(c) == true)
                                {
                                    start = position;
                                    state = IDENTIFIER_VALUE;
                                }
                                else
                                {
                                    state = INVALID_SELECTOR;
                                }
                        }
                    
                case STRING_VALUE:
                    if (!isSelectorChar(c))
                    {
                        switch (c)
                        {
                            case '"'.code, "'".code:
                                value = selector.substr(start, position - start);
                                state = END_SELECTOR;
                                
                            case ']'.code:
                                state = INVALID_SELECTOR;
                                
                            default:
                                state = INVALID_SELECTOR;
                        }
                    }
                    
                case IDENTIFIER_VALUE:
                    if (!isSelectorChar(c))
                    {
                        switch (c)
                        {
                            case ']'.code:
                                value = selector.substr(start, position - start);
                                state = END_SELECTOR;
                                continue;
                                
                            default:
                                state = INVALID_SELECTOR;
                        }
                    }
                    
                case INVALID_SELECTOR:
                    attribute = null;
                    break;
                    
                case END_SELECTOR:    
                    break;
                
            }
            c = selector.fastCodeAt(++position);
        }

        //invalid selector
        if (attribute == null)
        {
            return -1;
        }
        
        if (op != null)
        {
            switch(op)
            {
                case '=':
                    simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE(attribute, value)));
                    
                case '^=':
                    simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE_BEGINS(attribute, value)));
            
                case '~=':
                    simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_LIST(attribute, value)));
                    
                case '$=':
                    simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE_ENDS(attribute, value)));
                    
                case '*=':
                    simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE_CONTAINS(attribute, value)));
                
                case '|=':
                    simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE_BEGINS_HYPHEN_LIST(attribute, value)));
            }
        }
        else
        {
            simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE(attribute)));
        }
        
        return position;
    }

    static inline function isSelectorChar(c) 
    {
        return isAsciiChar(c) || c == '-'.code || c == '_'.code;
    }

    static inline function isAsciiChar(c) 
    {
        return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code);
    }

    static inline function isOperatorChar(c:Int):Bool
    {
        return c == '='.code || c == '~'.code || c == '^'.code || c == '$'.code || c == '*'.code || c == '|'.code;
    }
}
