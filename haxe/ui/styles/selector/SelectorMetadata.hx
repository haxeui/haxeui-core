package haxe.ui.styles.selector;

import haxe.ui.styles.selector.SelectorData;

/**
 * This class allows to attach metadata to a selector
 * to optimize matching
 */
class SelectorMetadata
{
    /**
     * if the selector begins with a class selector, return it,
     * else return null
     */
    public static function getFirstClass(components:Array<SelectorComponentValue>):String
    {
        switch(components[0])
        {
            case SIMPLE_SELECTOR_SEQUENCE(value):
                //check that don't start with type selector
                if (value.startValue == UNIVERSAL)
                {
                    //check that has at least 1 simple selector
                    if (value.simpleSelectors.length != 0)
                    {
                        //check that the first simple selector is a class selector
                        switch(value.simpleSelectors[0])
                        {
                            case CSS_CLASS(value):
                                return value;
                                
                            default:    
                        }
                    }
                }
                
            //won't happen, selector always begins with selector sequence    
            case COMBINATOR(value):
        }
        return null;
    }
    
    /**
     * Returns wether this selector contains only one clss selector
     */
    public static function getIsSimpleClassSelector(components:Array<SelectorComponentValue>):Bool
    {
        // > 1 means that it has combinators
        if (components.length > 1)
        {
            return false;
        }
        
        switch(components[0])
        {
            case SIMPLE_SELECTOR_SEQUENCE(value):
                //must start with universal selector
                if (value.startValue == UNIVERSAL)
                {
                    //check that has only 1 simple selector
                    if (value.simpleSelectors.length == 1)
                    {
                        //check that that this simple selector is a class selector
                        switch(value.simpleSelectors[0])
                        {
                            case CSS_CLASS(value):
                                return true;
                                
                            default:    
                        }
                    }
                }
                
            case COMBINATOR(value):
        }
        return false;
    }
    
    /**
     * Same as above for id selector
     */
    public static function getIsSimpleIdSelector(components:Array<SelectorComponentValue>):Bool
    {
        if (components.length > 1)
        {
            return false;
        }
        
        switch(components[0])
        {
            case SIMPLE_SELECTOR_SEQUENCE(value):
                
                if (value.startValue == UNIVERSAL)
                {
                    if (value.simpleSelectors.length == 1)
                    {
                        switch(value.simpleSelectors[0])
                        {
                            case ID(value):
                                return true;
                                
                            default:    
                        }
                    }
                }
                
            case COMBINATOR(value):
        }
        return false;
    }
    
    /**
     * Same as above for type selector
     */
    public static function getIsSimpleTypeSelector(components:Array<SelectorComponentValue>):Bool
    {
        if (components.length > 1)
        {
            return false;
        }
        
        switch(components[0])
        {
            case SIMPLE_SELECTOR_SEQUENCE(value):
                switch(value.startValue)
                {
                    case TYPE(typeValue):
                        if (value.simpleSelectors.length == 0)
                        {
                            return true;
                        }
                        
                    default:    
                        
                }
                
            case COMBINATOR(value):
        }
        return false;
    }
    
    /**
     * if the selector begins with an Id selector, return it,
     * else return null
     */
    public static function getFirstId(components:Array<SelectorComponentValue>):String
    {
        switch(components[0])
        {
            case SIMPLE_SELECTOR_SEQUENCE(value):
                //check that don't start with type selector
                if (value.startValue == UNIVERSAL)
                {
                    //check that has at least 1 simple selector
                    if (value.simpleSelectors.length != 0)
                    {
                        //check that the first simple selector is an Id selector
                        switch(value.simpleSelectors[0])
                        {
                            case ID(value):
                                return value;
                                
                            default:    
                        }
                    }
                }
                
            //won't happen, selector always begins with selector sequence    
            case COMBINATOR(value):
        }
        return null;
    }
    
    /**
     * if the selector begins with a type selector, return it,
     * else return null
     */
    public static function getFirstType(components:Array<SelectorComponentValue>):String
    {
        switch(components[0])
        {
            case SIMPLE_SELECTOR_SEQUENCE(value):
                switch(value.startValue)
                {
                    case TYPE(value):
                        return value;
                        
                    default:    
                }
                
            //won't happen, selector always begins with selector sequence    
            case COMBINATOR(value):
        }
        return null;
    }
}

