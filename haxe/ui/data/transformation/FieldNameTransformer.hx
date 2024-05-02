package haxe.ui.data.transformation;

class FieldNameTransformer implements IItemTransformer<Dynamic> {
    public var mapping:Map<String, String> = null;

    public function new(mapping:Map<String, String> = null) {
        this.mapping = mapping;
    }

    public function transformFrom(i:Dynamic):Dynamic {
        if (mapping == null) {
            return i;
        }

        var o:Dynamic = haxe.Json.parse(haxe.Json.stringify(i)); // poor mans deep clone
        for (fromField in mapping.keys()) {
            var toField = mapping.get(fromField);
            if (Reflect.hasField(i, fromField)) {
                var value = Reflect.field(i, fromField);
                Reflect.deleteField(o, fromField);
                Reflect.setField(o, toField, value);
            }
        }

        return o;
    }

}