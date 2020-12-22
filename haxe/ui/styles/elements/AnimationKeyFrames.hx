package haxe.ui.styles.elements;

class AnimationKeyFrames {
    public var id:String;

    private var _keyframes:Array<AnimationKeyFrame> = [];

    public function new(id:String, keyframes:Array<AnimationKeyFrame>) {
        this.id = id;
        _keyframes = keyframes;
    }

    public var keyFrames(get, null):Array<AnimationKeyFrame>;
    private function get_keyFrames():Array<AnimationKeyFrame> {
        return _keyframes;
    }
}