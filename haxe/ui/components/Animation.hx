package haxe.ui.components;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.ui.core.Component;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;

@:composite(Layout)
class Animation extends Canvas {
    private var _player:AnimationPlayer = null;
    
    public function new() {
        super();
        componentGraphics.setProperty("html5.graphics.method", "canvas");
    }

    private var _frameRate:Null<Float> = null;
    public var frameRate(get, set):Null<Float>;
    private function get_frameRate():Null<Float> {
        return _frameRate;
    }
    private function set_frameRate(value:Null<Float>):Null<Float> {
        _frameRate = value;
        if (_player != null) {
            _player.frameRate(_frameRate);
        }
        return value;
    }
    
    private var _resource:String;
    public var resource(get, set):String;
    private function get_resource():String {
        return _resource;
    }
    private function set_resource(value:String):String {
        if (_player != null) {
            _player.dispose();
        }
        _player = null;
        
        // TODO: could be smarter about this
        if (StringTools.endsWith(value, ".gif")) {
            _player = new GifAnimationPlayer(this);
        } else {
            trace("animation type not supported");
        }
        
        _resource = value;
        if (_player != null) {
            _player.loadResource(_resource);
            if (_frameRate != null) {
                _player.frameRate(_frameRate);
            }
        }
        
        return value;
    }
}

//***********************************************************************************************************
// Layout
//***********************************************************************************************************
@:access(haxe.ui.components.Animation)
private class Layout extends DefaultLayout {
    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var animation = cast(_component, Animation);
        if (animation._player == null) {
            return new Size(0, 0);
        }
        return animation._player.size();
    }
}

//***********************************************************************************************************
// Animation Player Base
//***********************************************************************************************************
private class AnimationPlayer {
    private var _canvas:Canvas;
    
    public function new(canvas:Canvas) {
        _canvas = canvas;
    }
    
    public function dispose() {
        _canvas = null;
    }
    
    public function loadResource(resource:String) {
    }
    
    private var _frameRate:Null<Float> = null;
    public function frameRate(value:Null<Float>) {
        _frameRate = value;
    }
    
    public function size():Size {
        return new Size(0, 0);
    }
}

//***********************************************************************************************************
// GIF Animation Player
//***********************************************************************************************************
private class GifAnimationPlayer extends AnimationPlayer {
    public function new(canvas:Canvas) {
        super(canvas);
        #if !format
        trace("format haxelib is required for animated gif decoding");
        #end
    }
    
    #if format
    private var _gifData:format.gif.Data = null;
    private var _blocks:Array<format.gif.Data.Block> = null;
    private var _gifSize:Size = null;
    private var _frameCount:Int = 0;
    private var _currentFrame:Int = 0;
    private var _blockIndex:Int = 0;
    
    private var _loop:Null<Bool> = null;
    public var loop(get, set):Bool;
    private function get_loop():Bool {
        return _loop;
    }
    private function set_loop(value:Bool):Bool {
        _loop = value;
        return value;
    }
    
    public override function loadResource(resource:String) {
        _gifData = null;
        _loop = null;
        _gifSize = null;
        _frameCount = 0;
        _currentFrame = 0;
        _blockIndex = 0;
        _blocks = [];
        _cachedFrames = new Map<Int, Bytes>();
        
        
        var gifBytes = ToolkitAssets.instance.getBytes(resource);
        if (gifBytes == null) {
            trace("resource not found: " + resource);
            return;
        }

        var gifReader = new format.gif.Reader(new BytesInput(gifBytes));
        _gifData = gifReader.read();
        preprocess();
        _canvas.invalidateComponentLayout();
        play();
    }
    
    private function play() {
        _blockIndex = 0;
        processBlock();
    }
    
    private var _cachedFrames:Map<Int, Bytes> = null;
    private var _useCache:Bool = true;
    private var _precache:Bool = false;
    private function processBlock() {
        var block = _blocks[_blockIndex];
        switch (block) {
            case BFrame(_):
                var pixels = null;
                if (_useCache == true && _cachedFrames != null) {
                    pixels = _cachedFrames.get(_currentFrame);
                }
                if (pixels == null) {
                    pixels = format.gif.Tools.extractFullRGBA(_gifData, _currentFrame);
                    if (_useCache == true && _cachedFrames != null) {
                        _cachedFrames.set(_currentFrame, pixels);
                    }
                }
                _canvas.componentGraphics.clear();
                _canvas.componentGraphics.setPixels(pixels);
                _currentFrame++;
                _blockIndex++;
                processBlock();
            case BExtension(EGraphicControl(gce)):    
                var delayMs = gce.delay * 10;
                if (_frameRate != null) {
                    delayMs = Std.int(1000 / _frameRate);
                }
                if (_currentFrame > 0) {
                    Timer.delay(function() {
                        _blockIndex++;
                        processBlock();
                    }, delayMs);
                } else {
                    _blockIndex++;
                    processBlock();
                }
            case BEOF:
                if (_loop == true) {
                    _currentFrame = 0;
                    _blockIndex = 0;
                    processBlock();
                }
            case _:
                _blockIndex++;
                processBlock();
        }
    }
    
    private function preprocess() {
        if (_gifData == null) {
            return;
        }
        for (block in _gifData.blocks) {
            _blocks.push(block);
            switch (block) {
                case BFrame(frame):
                    if (_gifSize == null) {
                        _gifSize = new Size(frame.width, frame.height);
                    }
                    if (_precache == true) {
                        _cachedFrames.set(_frameCount, format.gif.Tools.extractFullRGBA(_gifData, _frameCount));
                    }
                    _frameCount++;
                    
                case BExtension(EApplicationExtension(AENetscapeLooping(loops))):
                    if (_loop == null) {
                        _loop = (loops == 0);
                    }
                case _:    
            }
        }
    }
    
    public override function size():Size {
         if (_gifData == null || _gifSize == null) {
             return super.size();
         }
         return _gifSize;
    }
    
    public override function dispose() {
        super.dispose();
        _gifData = null;
        _gifSize = null;
        _blocks = null;
        _cachedFrames = null;
    }
    #end
}