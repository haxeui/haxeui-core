package haxe.ui.components;

import haxe.Json;
import haxe.Timer;
import haxe.ui.Toolkit;
import haxe.ui.ToolkitAssets;
import haxe.ui.containers.Box;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Variant;

class AtlasPlayer extends Box {
    public var animationDirection:String = "forward";
    public var autoPlay:Bool = true;

    private var _playing:Bool = false;
    private var _frames:Array<AtlasFrame> = [];

    private var _resource:Variant = null;
    public var resource(get, set):Variant;
    private function get_resource():Variant {
        return _resource;
    }
    private function set_resource(value:Variant):Variant {
        _resource = value;
        checkAtlas();
        return value;
    }

    public var _atlas:String;
    public var atlas(get, set):String;
    private function get_atlas():String {
        return _atlas;
    }
    private function set_atlas(value:String):String {
        _atlas = value;
        checkAtlas();
        return value;
    }

    @:bind(this, UIEvent.HIDDEN)
    private function onHidden(_) {
        if (_resource == null) {
            return;
        }
        if (_atlas == null) {
            return;
        }

        stop();
    }

    @:bind(this, UIEvent.SHOWN)
    private function onShown(_) {
        if (_resource == null) {
            return;
        }
        if (_atlas == null) {
            return;
        }

        if (autoPlay) {
            play();
        }
    }

    private function checkAtlas() {
        if (_resource == null) {
            return;
        }
        if (_atlas == null) {
            return;
        }

        var atlasData = ToolkitAssets.instance.getText(_atlas);
        if (atlasData == null) {
            return;
        }

        _frames = [];
        var atlasJson = Json.parse(atlasData);
        var framesJson:Array<Dynamic> = atlasJson.frames;
        for (frameJson in framesJson) {
            if (frameJson.frame != null) {
                _frames.push({
                    x: frameJson.frame.x,
                    y: frameJson.frame.y,
                    w: frameJson.frame.w,
                    h: frameJson.frame.h
                });
            }
        }

        showFrame(0);
        this.customStyle.backgroundImage = _resource.toString();
        this.customStyle.backgroundImageRepeat = "stretch";
        if (autoPlay && !hidden) {
            play();
        }
    }

    private var _targetFrameRate:Int = 60;
    public var targetFrameRate(get, set):Int;
    private function get_targetFrameRate():Int {
        return _targetFrameRate;
    }
    private function set_targetFrameRate(value:Int):Int {
        _targetFrameRate = value;
        _frameInterval = 1000 / value;
        return value;
    }


    private var _frameInterval:Float = 0;
    private var _timer:Timer;
    private var _nextFrameMS:Float = 0;
    public function play() {
        if (_playing) {
            return;
        }
        if (_frames == null || _frames.length <= 1) {
            return;
        }
        if (_frameInterval == 0) {
            _frameInterval = 1000 / _targetFrameRate;
        }

        _playing = true;
        showFrame(0);
        #if haxeui_spinner_use_timer
        stop();
        _timer = new Timer(Math.round(_frameInterval));
        _timer.run = onTimer;
        #else
        _nextFrameMS = timestamp() + _frameInterval;
        Toolkit.callLater(onCallLater);
        #end
    }

    public function stop() {
        _playing = false;
        #if haxeui_spinner_use_timer
        _timer.stop();
        _timer = null;
        #end
    }

    private function onCallLater() {
        if (!_playing) {
            return;
        }
        var current = timestamp();
        if (current >= _nextFrameMS) {
            _nextFrameMS = current + _frameInterval;
            onTimer();
        }
        Toolkit.callLater(onCallLater);
    }

    private inline function timestamp():Float {
        #if sys
        return Sys.time() * 1000;
        #elseif js
        return js.Syntax.code("Date.now()");
        #else
        return Date.now().getTime();
        #end
    }

    private function onTimer() {
        if (animationDirection == "forward") {
            nextFrame();
        } else if (animationDirection == "reverse") {
            prevFrame();
        } else if (animationDirection == "bounce") {
            boundFrame();
        } else {
            nextFrame();
        }
    }

    private var _currentFrameIndex:Int = -1;
    public function showFrame(frameIndex:Int) {
        if (_currentFrameIndex == frameIndex) {
            return;
        }
        _currentFrameIndex = frameIndex;
        var frame = _frames[frameIndex];
        if (frame == null) {
            return;
        }

        this.customStyle.backgroundImageClipLeft = frame.x;
        this.customStyle.backgroundImageClipTop = frame.y;
        this.customStyle.backgroundImageClipBottom = frame.y + frame.h;
        this.customStyle.backgroundImageClipRight = frame.x + frame.w;
        this.invalidateComponentStyle();
    }

    public function nextFrame() {
        var nextIndex = _currentFrameIndex + 1;
        if (nextIndex >= _frames.length) {
            nextIndex = 0;
        }
        showFrame(nextIndex);
    }

    private function prevFrame() {
        var nextIndex = _currentFrameIndex - 1;
        if (nextIndex < 0) {
            nextIndex = _frames.length - 1;
        }
        showFrame(nextIndex);
    }

    private var _currentBounceDirection = "forward";
    public function boundFrame() {
        if (_currentBounceDirection == "forward") {
            var nextIndex = _currentFrameIndex + 1;
            if (nextIndex >= _frames.length) {
                nextIndex = _frames.length - 1;
                _currentBounceDirection = "reverse";
            }
            showFrame(nextIndex);
        } else {
            var nextIndex = _currentFrameIndex - 1;
            if (nextIndex < 0) {
                nextIndex = 0;
                _currentBounceDirection = "forward";
            }
            showFrame(nextIndex);
        }
    }

    public override function validateComponentLayout():Bool {
        if (_currentFrameIndex != -1) {
            var frame = _frames[_currentFrameIndex];
            if (this.autoWidth) {
                this.width = frame.w;
            }
            if (this.autoHeight) {
                this.height = frame.h;
            }
        }
        return false;
    }
}


private typedef AtlasFrame = {
    var x:Float;
    var y:Float;
    var w:Float;
    var h:Float;
}