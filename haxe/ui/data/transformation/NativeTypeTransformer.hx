package haxe.ui.data.transformation;

class NativeTypeTransformer implements IItemTransformer<Dynamic> {
    public function new() {
    }

    public function transformFrom(i:Dynamic):Dynamic {
        var o:Dynamic = null;
        if ((i is String)) {
            o = { text: i, value: i };
        } else if ((i is Int) || (i is Float) || (i is Bool)) {
            o = { value: i };
        } else {
            o = i;
        }
        return o;
    }

}