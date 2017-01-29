package haxe.ui.animation.transition;

import haxe.ui.core.Component;
class Transition {
    public var inAnimations:Array<Animation> = [];
    public var outAnimations:Array<Animation> = [];

    public var id:String;

    public var componentMap:Map<String, Component> = new Map<String, Component>();

    public function new() {

    }

    public function addInAnimation(animation:Animation):Void {
        inAnimations.push(animation);
    }

    public function addOutAnimation(animation:Animation):Void {
        outAnimations.push(animation);
    }

    public function setInComponent(id:String, component:Component) {
        componentMap.set(id, component);
    }

    public function getComponent(id:String):Component {
        return componentMap.get(id);
    }

    public function start(onComplete:Void->Void = null):Void {
        var animationCallback:Void->Void = null;

        if (onComplete != null) {
            var total = inAnimations.length + outAnimations.length;
            var current = 0;
            animationCallback = onComplete == null ? null : function() {
                if (++current >= total) {
                    onComplete();
                }
            };
        }

        for (a in inAnimations) {
            a.start(animationCallback);
        }

        for (a in outAnimations) {
            a.start(animationCallback);
        }
    }

    public function stop():Void {
        for (a in inAnimations) {
            a.stop();
        }

        for (a in outAnimations) {
            a.stop();
        }
    }

    public function clone():Transition {
        var c:Transition = new Transition();
        c.id = this.id;

        for (a in inAnimations) {
            var ca = a.clone();
            c.inAnimations.push(ca);
        }

        for (a in outAnimations) {
            var ca = a.clone();
            c.outAnimations.push(ca);
        }

        return c;
    }
}
