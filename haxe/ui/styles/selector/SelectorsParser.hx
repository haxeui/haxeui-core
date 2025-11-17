package haxe.ui.styles.selector;

using StringTools;
using Lambda;
import haxe.ui.styles.selector.SelectorData;

/**
 * Parses one or many CSS selector(s)
 *
 * @author Yannick DOMINGUEZ
 */
class SelectorsParser
{
    /**
     * Takes a string containing or multiple comma-separated CSS selectors
     * and return an array of typed selectors, or null if at least one of the
     * selector is invalid
     *
     * @param selectors the CSS selectors to parse
     * @return an array of typed selectors or null if one or more selectors are
     * invalid
     */
    public static function parse(selectors:String):Array<SelectorVO>
    {
        var typedSelectors = new Array<SelectorVO>();
        
        var state:SelectorsParserState = IGNORE_SPACES;
        var next:SelectorsParserState = BEGIN_SELECTOR;
        var start:Int = 0;
        var position:Int = 0;
        var c:Int = selectors.fastCodeAt(position);
        
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
                    
                case BEGIN_SELECTOR:
                    state = SELECTOR;
                    next = END_SELECTOR;
                    start = position;
                    continue;
                    
                case SELECTOR:
                    if (!isSelectorChar(c))
                    {
                        switch(c)
                        {
                            case ','.code:
                                state = END_SELECTOR;
                                next = BEGIN_SELECTOR;
                                continue;
                        }
                    }
                    
                case END_SELECTOR:
                    var selector:String = selectors.substr(start, position - start);
                    typedSelectors.push(SelectorParser.parse(selector));
                    state = next;
            }
            c = selectors.fastCodeAt(++position);
        }

        //parse last selector if any
        var selector:String = selectors.substr(start, position - start);
        typedSelectors.push(SelectorParser.parse(selector));

        //if one selector is invalid, the whole rule and selectors are
        //invalid and won't be used during cascade
        if (typedSelectors.has(null))
        {
            return null;
        }

        return typedSelectors;
    }

    /**
     * Parse one selector. Returns a typed selector or null if invalid
     */
    private static function parseSelector(selector:String):SelectorVO
    {
        var typedSelector:SelectorVO = SelectorParser.parse(selector);
        
        //if one selector is invalid, the whole rule and selectors are
        //invalid and won't be used during cascade
        if (typedSelector == null)
        {
            return null;
        }

        return typedSelector;
    }

    static inline function isSelectorChar(c:Int):Bool {
        return isAsciiChar(c) || c == ':'.code || c == '.'.code || c == '*'.code;
    }
    
    static inline function isAsciiChar(c) {
        return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code);
    }
}

