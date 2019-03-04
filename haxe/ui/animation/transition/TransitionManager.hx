package haxe.ui.animation.transition;

import haxe.ui.core.Component;

class TransitionManager {
    private static var _instance:TransitionManager;
    public static var instance(get, never):TransitionManager;
    private static function get_instance():TransitionManager {
        if (_instance == null) {
            _instance = new TransitionManager();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance
    //***********************************************************************************************************
    private var _transitions:Map<String, Transition> = new Map<String, Transition>();
    public function new() {

    }

    public function registerTransition(id:String, transition:Transition) {
        _transitions.set(id, transition);
    }

    public function run(id:String, inComponents:Map<String, Component> = null, inVars:Map<String, Float> = null,
                        outComponents:Map<String, Component> = null, outVars:Map<String, Float> = null, complete:Void->Void = null):Transition {
        var t:Transition = initTransition(id, inComponents, inVars, outComponents, outVars);
        if (t != null) {
            t.start(function() {
                if (complete != null) {
                    complete();
                }
            });
        }
        return t;
    }

    private function initTransition(id:String, inComponents:Map<String, Component> = null, inVars:Map<String, Float> = null,
                                    outComponents:Map<String, Component> = null, outVars:Map<String, Float> = null):Transition {
        var t:Transition = get(id);
        if (t != null) {
            if (inComponents != null) {
                for (k in inComponents.keys() ) {
                    for (a in t.inAnimations) {
                        a.setComponent(k, inComponents.get(k));
                    }
                }
            }

            if (outComponents != null) {
                for (k in outComponents.keys() ) {
                    for (a in t.outAnimations) {
                        a.setComponent(k, outComponents.get(k));
                    }
                }
            }

            if (inVars != null) {
                for (k in inVars.keys()) {
                    for (a in t.inAnimations) {
                        a.setVar(k, inVars.get(k));
                    }
                }
            }

            if (outVars != null) {
                for (k in outVars.keys()) {
                    for (a in t.outAnimations) {
                        a.setVar(k, outVars.get(k));
                    }
                }
            }
        }
        return t;
    }

    public function get(id:String):Transition {
        var t:Transition = _transitions.get(id);
        if (t == null) {
            return null;
        }
        return t.clone();
    }

}