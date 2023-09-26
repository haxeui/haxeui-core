package haxe.ui.filters;

class Tint extends Filter {
    public static var DEFAULTS:Array<Any> = [0, 1];

    public var color:Int;
    public var amount:Float; // from 0 -> 1

    public override function parse(filterDetails:Array<Any>) {
        var copy = Filter.applyDefaults(filterDetails, DEFAULTS);
        this.color = copy[0];
        this.amount = copy[1];

        if (this.amount < 0) {
            this.amount = 0;
        } else if (this.amount > 1) {
            this.amount = 1;
        }
        
    }
}