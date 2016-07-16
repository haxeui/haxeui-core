package haxe.ui.animation;

class AnimationComponentRef {
    public var keyFrame:AnimationKeyFrame;

    public var id:String;
    public var properties:Map<String, Float> = new Map<String, Float>();
    public var vars:Map<String, String> = new Map<String, String>();

    public function new(id:String) {
        this.id = id;
    }

    public function addProperty(name:String, value:Float) {
        properties.set(name, value);
    }

    public function addVar(name:String, value:String) {
        vars.set(name, value);
    }

    public function clone():AnimationComponentRef {
        var c:AnimationComponentRef = new AnimationComponentRef(this.id);
        for (k in this.properties.keys()) {
            c.properties.set(k, this.properties.get(k));
        }
        for (k in this.vars.keys()) {
            c.vars.set(k, this.vars.get(k));
        }
        return c;
    }
}