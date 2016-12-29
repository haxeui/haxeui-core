package haxe.ui.animation;

#if actuate
import motion.Actuate;
#end

class AnimationKeyFrame {
    public var animation:Animation;
    public var time(default, default):Int;

    public var componentRefs:Array<AnimationComponentRef> = [];

    public function new(time:Int) {
        this.time = time;
    }

    public function addComponentRef(id:String):AnimationComponentRef {
        var componentRef:AnimationComponentRef = new AnimationComponentRef(id);
        componentRef.keyFrame = this;
        componentRefs.push(componentRef);
        return componentRef;
    }

    private var _completeCallback:Void->Void;
    private var _count:Int = 0;

    public function run(duration:Float, complete:Void->Void) {
        _completeCallback = complete;
        _count = componentRefs.length;
        for (ref in componentRefs) {
            if (animation.getComponent(ref.id) == null) {
                _count--;
            }
        }

        for (ref in componentRefs) {
            var actualComponent = animation.getComponent(ref.id);
            if (actualComponent != null) {
                var props:Dynamic = { };

                for (k in ref.properties.keys()) {
                    Reflect.setField(props, k,  ref.properties.get(k));
                }

                for (k in ref.vars.keys()) {
                    var v = ref.vars.get(k);
                    if (animation.vars.exists(v)) {
                        Reflect.setField(props, k, animation.vars.get(v));
                    }
                }

                #if actuate
                Actuate.tween(actualComponent, duration / 1000, props, true).ease(animation.easing).onComplete(onComplete);
                #else
                onComplete();
                #end
            }
        }
    }

    public function stop() {
        #if actuate
        for (ref in componentRefs) {
            var actualComponent = animation.getComponent(ref.id);
            if (actualComponent != null) {
                Actuate.stop(actualComponent);
            }
        }
        #end
    }
    
    private function onComplete() {
        _count--;
        if (_count == 0) {
            _completeCallback();
        }
    }

    public function clone():AnimationKeyFrame {
        var c:AnimationKeyFrame = new AnimationKeyFrame(this.time);
        c.animation = this.animation;
        for (r in this.componentRefs) {
            var cr = r.clone();
            cr.keyFrame = c;
            c.componentRefs.push(cr);
        }
        return c;
    }
}