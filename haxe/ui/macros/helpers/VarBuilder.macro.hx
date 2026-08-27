package haxe.ui.macros.helpers;

import haxe.macro.Expr.Field;

class VarBuilder {
    public var field:Field;
    public var classBuilder:ClassBuilder;

    public function new(field:Field, classBuilder:ClassBuilder) {
        this.field = field;
        this.classBuilder = classBuilder;
    }

    public var name(get, null):String;
    private function get_name():String {
        return field.name;
    }

    public function remove() {
        classBuilder.fields.remove(field);
    }
}