package haxe.ui.styles;

import haxe.ui.constants.UnitTime;

enum Value {
    VString(v:String);
    VNumber(v:Float);
    VBool(v:Bool);
    VDimension(v:Dimension);
    VColor(v:Int);
    VCall(f:String, vl:Array<Value>);
    VConstant(v:String);
    VComposite(vl:Array<Value>);
    VTime(v:Float, unit:UnitTime);
    VNone();
}
