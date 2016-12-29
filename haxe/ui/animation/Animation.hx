package haxe.ui.animation;

import haxe.ui.core.Component;

#if actuate
import motion.easing.IEasing;
import motion.easing.Back;
import motion.easing.Bounce;
import motion.easing.Cubic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;
#end

class Animation {
    public var keyFrames:Array<AnimationKeyFrame> = [];
    public var componentMap:Map<String, Component> = new Map<String, Component>();

    #if actuate
    public var easing:IEasing = Linear.easeNone;
    #else
    public var easing:Dynamic = null;
    #end

    public var id:String;

    private var _currentKeyFrame:AnimationKeyFrame;
    
    public function new() {
    }

    public var easingString(null, set):String;
    private function set_easingString(value:String):String {
        easing = easingFromString(value);
        return value;
    }

    public function addKeyFrame(time:Int):AnimationKeyFrame {
        var keyFrame:AnimationKeyFrame = new AnimationKeyFrame(time);
        keyFrame.animation = this;
        keyFrames.push(keyFrame);
        return keyFrame;
    }

    public function setComponent(id:String, component:Component) {
        componentMap.set(id, component);
    }

    public function getComponent(id:String):Component {
        return componentMap.get(id);
    }

    private var _currentTime:Int = 0;
    private var _currentFrameIndex:Int = 0;
    private var _complete:Void->Void;
    public function start(complete:Void->Void = null) {
        _complete = complete;
        _stopped = false;
        _currentTime = 0;
        _currentFrameIndex = 0;
        _currentKeyFrame = null;
        runFrame(_currentFrameIndex);
    }

    private function runFrame(index:Int) {
        var f:AnimationKeyFrame = keyFrames[index];
        _currentKeyFrame = f;
        var duration:Float = f.time - _currentTime;
        f.run(duration, function() {
            _currentTime = f.time;
            nextFrame();
        });
    }

    private function nextFrame() {
        _currentFrameIndex++;
        if (_stopped == true) {
            complete();
            return;
        }
        if (_currentFrameIndex >= keyFrames.length) {
            complete();
        } else {
            runFrame(_currentFrameIndex);
        }
    }

    public var looping:Bool = false;

    private var _loop:Bool = false;
    private function complete() {
        if (_loop == true) {
            start();
        } else {
            if (_complete != null) {
                _complete();
            }
        }
    }

    public function loop(complete:Void->Void = null) {
        _loop = true;
        looping = true;
        start(complete);
    }

    private var _stopped:Bool = false;
    public function stop() {
        if (_currentKeyFrame != null) {
            _currentKeyFrame.stop();
        }
        _stopped = true;
        _loop = false;
    }

    public function fromXML(xml:Xml) {
        id = xml.get("id");
        easing = easingFromString(xml.get("ease"));
        for (keyFrameNode in xml.elementsNamed("keyframe")) {
            var kf = addKeyFrame(Std.parseInt(keyFrameNode.get("time")));
            for (refNode in keyFrameNode.elements()) {
                var r = kf.addComponentRef(refNode.nodeName);
                for (attrName in refNode.attributes()) {
                    var attrValue = refNode.get(attrName);
                    if (StringTools.startsWith(attrValue, "{") && StringTools.endsWith(attrValue, "}")) {
                        attrValue = attrValue.substring(1, attrValue.length - 1);
                        r.addVar(attrName, attrValue);
                    } else {
                        r.addProperty(attrName, Std.parseFloat(attrValue));
                    }
                }
            }
        }
    }

    public var vars:Map<String, Float> = new Map<String, Float>();
    public function setVar(name:String, value:Float) {
        vars.set(name, value);
    }

    public function clone():Animation {
        var c:Animation = new Animation();
        c.id = this.id;
        c.easingString = this.easingString;
        c.easing = this.easing;
        for (f in keyFrames) {
            var cf = f.clone();
            cf.animation = c;
            c.keyFrames.push(cf);
        }
        return c;
    }

    #if actuate
    public static function easingFromString(s:String):IEasing {
        switch (s) {
            case "Linear.easeNone": return Linear.easeNone;
            case "Back.easeIn":     return Back.easeIn;
            case "Back.easeOut":    return Back.easeOut;
            case "Bounce.easeIn":   return Bounce.easeIn;
            case "Bounce.easeOut":  return Bounce.easeOut;
            case "Cubic.easeIn":    return Cubic.easeIn;
            case "Cubic.easeOut":   return Cubic.easeOut;
            case "Expo.easeIn":     return Expo.easeIn;
            case "Expo.easeOut":    return Expo.easeOut;
            case "Quad.easeIn":     return Quad.easeIn;
            case "Quad.easeOut":    return Quad.easeOut;
            case "Quart.easeIn":    return Quart.easeIn;
            case "Quart.easeOut":   return Quart.easeOut;
            case "Quint.easeIn":    return Quint.easeIn;
            case "Quint.easeOut":   return Quint.easeOut;
            case "Sine.easeIn":     return Sine.easeIn;
            case "Sine.easeOut":    return Sine.easeOut;
            default:                return Linear.easeNone;
        }
    }
    #else
    public static function easingFromString(s:String):Dynamic {
        return null;
    }
    #end
}