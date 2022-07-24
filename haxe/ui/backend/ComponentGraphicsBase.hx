package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.core.Component;
import haxe.ui.graphics.DrawCommand;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;

// base graphics class, does nothing except cache draw commands - some backends dont need (or want) caching, which which case the impl will simply not call super
class ComponentGraphicsBase {
    private var _component:Component;
    private var _drawCommands:Array<DrawCommand> = [];
    
    public function new(component:Component) {
        _component = component;
    }
    
    public function clear() {
        _drawCommands = [];
        _drawCommands.push(Clear);
    }
    
    public function setPixel(x:Float, y:Float, color:Color) {
        _drawCommands.push(SetPixel(x, y, color));
    }
    
    public function setPixels(pixels:Bytes) {
        _drawCommands.push(SetPixels(pixels));
    }
    
    public function moveTo(x:Float, y:Float) {
        _drawCommands.push(MoveTo(x, y));
    }
    
    public function lineTo(x:Float, y:Float) {
        _drawCommands.push(LineTo(x, y));
    }
    
    public function strokeStyle( color:Null<Color>, thickness:Null<Float> = 1, alpha:Null<Float> = 1) {
        _drawCommands.push(StrokeStyle(color, thickness, alpha));
    }
    
    public function circle(x:Float, y:Float, radius:Float) {
        _drawCommands.push(Circle(x, y, radius));
    }
    
    public function fillStyle(color:Null<Color>, alpha:Null<Float> = 1) {
        _drawCommands.push(FillStyle(color, alpha));
    }
    
    public function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float) {
        _drawCommands.push(CurveTo(controlX, controlY, anchorX, anchorY));
    }
    
    public function cubicCurveTo(controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float) {
        _drawCommands.push(CubicCurveTo(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY));
    }
    
    public function rectangle(x:Float, y:Float, width:Float, height:Float) {
        _drawCommands.push(Rectangle(x, y, width, height));
    }
    
    public function image(resource:Variant, x:Null<Float> = null, y:Null<Float> = null, width:Null<Float> = null, height:Null<Float> = null) {
        _drawCommands.push(Image(resource, x, y, width, height));
    }
    
    public function resize(width:Null<Float>, height:Null<Float>) {
    }
    
    public function setProperty(name:String, value:String) {
    }

    private function detach() {
    }
    
    private function replayDrawCommands() {
        var commands = _drawCommands.copy();
        _drawCommands = [];
        for (c in commands) {
            switch (c) {
                case Clear:
                    clear();
                case SetPixel(x, y, color):    
                    setPixel(x, y, color);
                case SetPixels(pixels):    
                    setPixels(pixels);
                case MoveTo(x, y): 
                    moveTo(x, y);
                case LineTo(x, y):
                    lineTo(x, y);
                case StrokeStyle(color, thickness, alpha):
                    strokeStyle(color, thickness, alpha);
                case Circle(x, y, radius):
                    circle(x, y, radius);
                case FillStyle(color, alpha):
                    fillStyle(color, alpha);
                case CurveTo(controlX, controlY, anchorX, anchorY):
                    curveTo(controlX, controlY, anchorX, anchorY);
                case CubicCurveTo(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY):
                    cubicCurveTo(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
                case Rectangle(x, y, width, height):
                    rectangle(x, y, width, height);
                case Image(resource, x, y, width, height):
                    image(resource, x, y, width, height);
                    
            }
        }
    }
}