package haxe.ui.data.transformation;

interface IItemTransformer<T> {
    public function transformFrom(i:Dynamic):T;
}