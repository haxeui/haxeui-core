package haxe.ui.graphics;

import haxe.io.Bytes;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;

enum DrawCommand {
    Clear;
    SetPixel(x:Float, y:Float, color:Color);
    SetPixels(pixels:Bytes);
    MoveTo(x:Float, y:Float);
    LineTo(x:Float, y:Float);
    StrokeStyle(color:Null<Color>, thickness:Null<Float>, alpha:Null<Float>);
    Circle(x:Float, y:Float, radius:Float);
    FillStyle(color:Null<Color>, alpha:Null<Float>);
    CurveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float);
    CubicCurveTo(controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float);
    Rectangle(x:Float, y:Float, width:Float, height:Float);
    Image(resource:Variant, x:Float, y:Float, width:Float, height:Float);
}
