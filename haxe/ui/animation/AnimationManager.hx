package haxe.ui.animation;

import haxe.ui.core.Component;

class AnimationManager {
    private static var _instance:AnimationManager;
    public static var instance(get, never):AnimationManager;
    private static function get_instance():AnimationManager {
        if (_instance == null) {
            _instance = new AnimationManager();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance
    //***********************************************************************************************************
    private var _animations:Map<String, Animation> = new Map<String, Animation>();
    public function new() {

    }

    public function registerAnimation(id:String, animation:Animation) {
        _animations.set(id, animation);
    }

    public function run(id:String, components:Map<String, Component> = null, vars:Map<String, Float> = null, complete:Void->Void = null):Animation {
        var a:Animation = initAnimation(id, components, vars);
        if (a != null) {
            a.start(function() {
                if (complete != null) {
                    complete();
                }
            });
        }
        return a;
    }

    public function loop(id:String, components:Map<String, Component> = null, vars:Map<String, Float> = null, complete:Void->Void = null):Animation {
        var a:Animation = initAnimation(id, components, vars);
        if (a != null) {
            a.loop(function() {
                if (complete != null) {
                    complete();
                }
            });
        }
        return a;
    }

    private function initAnimation(id:String, components:Map<String, Component> = null, vars:Map<String, Float> = null):Animation {
        var a:Animation = get(id);
        if (a != null) {
            if (components != null) {
                for (k in components.keys() ) {
                    a.setComponent(k, components.get(k));
                }
            }

            if (vars != null) {
                for (k in vars.keys()) {
                    a.setVar(k, vars.get(k));
                }
            }
        }
        return a;
    }

    public function get(id:String):Animation {
        var a:Animation = _animations.get(id);
        if (a == null) {
            return null;
        }
        return a.clone();
    }

}