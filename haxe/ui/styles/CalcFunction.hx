package haxe.ui.styles;

enum CalcFunction {
    FMin(values:Array<Value>);
    FMax(values:Array<Value>);
    FClamp(value:Value, min:Value, max:Value);
}
