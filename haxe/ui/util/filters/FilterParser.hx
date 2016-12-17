package haxe.ui.util.filters;

class FilterParser {
    private static var filterParamDefaults:Map<String, Array<Dynamic>>;

    public static function parseFilter(filterDetails:Array<Dynamic>):Filter {
        var filter:Filter = null;
        if (filterDetails[0] == "drop-shadow") {
            filter = parseDropShadow(filterDetails);
        } else if (filterDetails[0] == "blur") {
            filter = parseBlur(filterDetails);
        }
        return filter;
    }

    public static function parseDropShadow(filterDetails:Array<Dynamic>):DropShadow {
        if (filterDetails == null || filterDetails.length == 0) {
            return null;
        }

        var copy:Array<Dynamic> = filterDetails.copy();
        buildDefaults();

        var filterName = copy[0];
        copy.remove(filterName);

        copy = copyFilterDefaults(filterName, copy);

        var dropShadow:DropShadow = new DropShadow();
        dropShadow.distance = copy[0];
        dropShadow.angle = copy[1];
        dropShadow.color = copy[2];
        dropShadow.alpha = copy[3];
        dropShadow.blurX = copy[4];
        dropShadow.blurY = copy[5];
        dropShadow.strength = copy[6];
        dropShadow.quality = copy[7];
        dropShadow.inner = copy[8];
        return dropShadow;
    }

    public static function parseBlur(filterDetails:Array<Dynamic>):Blur {
        if (filterDetails == null || filterDetails.length == 0) {
            return null;
        }

        var copy:Array<Dynamic> = filterDetails.copy();
        buildDefaults();

        var filterName = copy[0];
        copy.remove(filterName);

        copy = copyFilterDefaults(filterName, copy);

        var blur:Blur = new Blur();
        blur.amount = copy[0];
        return blur;
    }

    private static function copyFilterDefaults(filterName:String, params:Array<Dynamic>):Array<Dynamic> {
        var copy:Array<Dynamic> = [];

        var defaultParams:Array<Dynamic> = filterParamDefaults[filterName];
        if (defaultParams != null) {
            for (p in defaultParams) {
                copy.push(p);
            }
        }
        if (params != null) {
            var n:Int = 0;
            for (p in params) {
                copy[n] = p;
                n++;
            }
        }

        return copy;
    }

    private static function buildDefaults() {
        if (filterParamDefaults != null) {
            return;
        }

        filterParamDefaults = new Map<String, Array<Dynamic>>();
        filterParamDefaults["drop-shadow"] = [];
        filterParamDefaults["drop-shadow"] = filterParamDefaults["drop-shadow"].concat([4, 45, 0, 1, 4, 4, 1, 1, false, false, false]);

        filterParamDefaults["blur"] = [];
        filterParamDefaults["blur"] = filterParamDefaults["blur"].concat([1]);
    }
}