package haxe.ui.core;

class ClassFactory<T> {

    public var generator:Class<T>;

    public var properties:Map<String, Dynamic>;

    public function new(generator:Class<T>, properties:Map<String, Dynamic> = null) {
        this.generator = generator;
        this.properties = properties;
    }

    public function newInstance():T {
        var instance:T = Type.createInstance(generator, []);

        if (properties != null) {
            for (property in properties.keys()) {
                Reflect.setProperty(instance, property, properties[property]);
            }
        }

        return instance;
    }
}
