package haxe.ui.animation;

#if haxeui_expose_all
@:expose
#end
class AnimationSequence {
    public var onComplete:Void->Void = null;
    public var builders:Array<AnimationBuilder> = [];

    private var _activeBuilders:Array<AnimationBuilder>;

    public function new() {

    }

    public function add(builder:AnimationBuilder) {
        if (builder == null) {
            return;
        }
        builders.push(builder);
    }

    private function onAnimationComplete() {
        _activeBuilders.pop();
        if (_activeBuilders.length == 0) {
            if (onComplete != null) {
                onComplete();
            }
        }
    }

    public function play() {
        if (builders.length == 0) {
            if (onComplete != null) {
                onComplete();
            }
            return;
        }
        _activeBuilders = builders.copy();
        for (builder in builders) {
            builder.onComplete = onAnimationComplete;
        }
        for (builder in builders) {
            builder.play();
        }
    }
}