package haxe.ui.styles.selector.matchers;

import haxe.ui.styles.selector.SelectorData;

/**
 * Functions to match attribute selectors
 */
class Attributes
{
    /**
     * Return wether an attribute selector
     * matches the element
     */
    public static function match(getAttribute:String->String, attributeSelector:AttributeSelectorValue):Bool
    {
        return switch(attributeSelector)
        {
            case AttributeSelectorValue.ATTRIBUTE(value):
                getAttribute(value) != null;
                
            case AttributeSelectorValue.ATTRIBUTE_VALUE(name, value):
                getAttribute(name) == value;
                
            case AttributeSelectorValue.ATTRIBUTE_LIST(name, value):
                matchAttributeList(getAttribute, name, value);
                
            case AttributeSelectorValue.ATTRIBUTE_VALUE_BEGINS(name, value):
                matchAttributeBeginValue(getAttribute, name, value);
                
            case AttributeSelectorValue.ATTRIBUTE_VALUE_CONTAINS(name, value):
                matchAttributeContainsValue(getAttribute, name, value);
                
            case AttributeSelectorValue.ATTRIBUTE_VALUE_ENDS(name, value):
                matchAttributeEndValue(getAttribute, name, value);
                
            case AttributeSelectorValue.ATTRIBUTE_VALUE_BEGINS_HYPHEN_LIST(name, value):
                matchAttributeBeginsHyphenList(getAttribute, name, value);
        }
    }
    
    /**
     * return wether the value of the "name" attribute is a hyphen
     * separated list whose first item is "value"
     */
    private static function matchAttributeBeginsHyphenList(getAttribute:String->String, name:String, value:String):Bool
    {
        var attributeValue:String = getAttribute(name);
        //early exit if the attribute doesn't exist on the element
        if (attributeValue == null)
        {
            return false;
        }
        
        //valid if value exactly matches the attribute
        if (attributeValue == value)
        {
            return true;
        }
        
        //else valid if begins with value + hyphen
        var hyphenValue:String = value + "-";
        return attributeValue.substr(0, hyphenValue.length) == hyphenValue;
    }
    
    /**
     * Return wether the value of the "name" attribute ends with "value"
     */
    private static function matchAttributeEndValue(getAttribute:String->String, name:String, value:String):Bool
    {
        var attributeValue:String = getAttribute(name);
        //early exit if the attribute doesn't exist on the element
        if (attributeValue == null)
        {
            return false;
        }
        
        return attributeValue.lastIndexOf(value) == attributeValue.length - value.length;
    }
    
    /**
     * Return wether the value of the "name" attribute contains "value"
     */
    private static function matchAttributeContainsValue(getAttribute:String->String, name:String, value:String):Bool
    {
        var attributeValue:String = getAttribute(name);
        //early exit if the attribute doesn't exist on the element
        if (attributeValue == null)
        {
            return false;
        }
        
        return attributeValue.indexOf(value) != -1;
    }
    
    /**
     * Return wether the value of the "name" attribute
     * on the element begins with "value"
     */
    private static function matchAttributeBeginValue(getAttribute:String->String, name:String, value:String):Bool
    {
        var attributeValue:String = getAttribute(name);
        //early exit if the attribute doesn't exist on the element
        if (attributeValue == null)
        {
            return false;
        }
        
        return attributeValue.indexOf(value) == 0;
    }
    
    /**
     * Return wether "value" is a part of the "name" attribute
     * which is a white-space separated list of values
     */
    private static function matchAttributeList(getAttribute:String->String, name:String, value:String):Bool
    {
        var attributeValue:String = getAttribute(name);
        //early exit if the attribute doesn't exist on the element
        if (attributeValue == null)
        {
            return false;
        }
        
        trace(attributeValue);
        var attributeValueAsList:Array<String> = attributeValue.split(" ");
        for (i in 0...attributeValueAsList.length)
        {
            if (attributeValueAsList[i] == value)
            {
                return true;
            }
        }
        
        return false;
    }
}

