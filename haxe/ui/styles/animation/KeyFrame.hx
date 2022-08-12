package haxe.ui.styles.animation;

import haxe.ui.core.Component;
import haxe.ui.events.AnimationEvent;
import haxe.ui.styles.animation.util.Actuator;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.Directive;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float = 0;
    public var delay:Float = 0;
    public var easingFunction:EasingFunction;

    private var _actuator:Actuator<Dynamic>;

    public function new() {
    }

    public function stop() {
        if (_actuator != null) {
            _actuator.stop();
            _actuator = null;
        }
    }

    public function run(target:Component, cb:Void->Void) {
        if (_actuator != null) {
            return;
        }

        var properties:Dynamic = {};
        for (d in directives) {
            Reflect.setField(properties, d.directive, d.value);
        }

        var hasFrameEvent = target.hasEvent(AnimationEvent.FRAME);
        _actuator = new Actuator(target, properties, time, {
            delay: delay,
            easingFunction: easingFunction,
            onComplete: function() {
                _actuator = null;
                cb();
            },
            onUpdate: function(time:Float, delta:Float, position:Float) {
                if (hasFrameEvent) {
                    var event = new AnimationEvent(AnimationEvent.FRAME);
                    event.currentTime = time;
                    event.delta = delta;
                    event.position = position;
                    target.dispatch(event);
                }
            }
        });
        _actuator.run();
    }
}
