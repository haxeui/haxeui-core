package haxe.ui.filters;

import haxe.ui.styles.CssFilters;

class FilterParser {
    public static function parseFilter(filterDetails:Array<Any>):Filter {
        var filterName = filterDetails.shift();
        if (!CssFilters.hasCssFilter(filterName)) {
            return null;
        }

        var ctor = CssFilters.getCssFilter(filterName);
        var filter:Filter = ctor();
        filter.parse(filterDetails);
        return filter;
    }
}