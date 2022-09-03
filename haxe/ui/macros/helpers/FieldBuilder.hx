package haxe.ui.macros.helpers;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Metadata;
import haxe.macro.ExprTools;
import haxe.ui.macros.helpers.ClassBuilder;

class FieldBuilder {
    public var field:Field;
    public var classBuilder:ClassBuilder;

    public function new(field:Field, classBuilder:ClassBuilder) {
        this.field = field;
        this.classBuilder = classBuilder;
    }

    public var name(get, set):String;
    private function get_name():String {
        return field.name;
    }
    private function set_name(value:String):String {
        field.name = value;
        return value;
    }

    public var isStatic(get, null):Bool;
    private function get_isStatic():Bool {
        return field.access.indexOf(AStatic) != -1;
    }
    
    public var access(get, set):Array<Access>;
    private function get_access():Array<Access> {
        return field.access;
    }
    private function set_access(value:Array<Access>):Array<Access> {
        field.access = value;
        return value;
    }

    public function remove() {
        classBuilder.fields.remove(field);
    }

    public var typePath(get, null):TypePath;
    private function get_typePath():TypePath {
        switch (field.kind) {
            case FVar(t, _) | FProp(_, _, t, _):
                switch (t) {
                    case TPath(p):
                        return p;
                    case _:
                }
            case _:
        }
        return null;
    }

    public var type(get, null):ComplexType;
    private function get_type():ComplexType {
        switch (field.kind) {
            case FVar(t, _):
                return t;
            case FProp(_, _, t, _):
                return t;
            case _:
        }
        return null;
    }

    public var isNullable(get, null):Bool;
    private function get_isNullable():Bool {
        switch (this.type) {
            case TPath(p):
                if (p.name == "Bool" || p.name == "Int" || p.name == "Float") {
                    return false;
                }
            case _:
        }
        return true;
    }

    public var isBool(get, null):Bool;
    private function get_isBool():Bool {
        switch (this.type) {
            case TPath(p):
                if (p.name == "Bool") {
                    return true;
                }
            case _:
        }
        return false;
    }

    public var isString(get, null):Bool;
    private function get_isString():Bool {
        switch (this.type) {
            case TPath(p):
                if (p.name == "String") {
                    return true;
                }
            case _:
        }
        return false;
    }

    public var isNumeric(get, null):Bool;
    private function get_isNumeric():Bool {
        switch (this.type) {
            case TPath(p):
                if (p.name == "Int" || p.name == "Float") {
                    return true;
                }
            case _:
        }
        return false;
    }

    public var meta(get, null):Metadata;
    private function get_meta():Metadata {
        return field.meta;
    }

    public var expr(get, null):Expr;
    private function get_expr():Expr {
        switch (field.kind) {
            case FVar(_, e):
                return e;
            case _:
        }
        return null;
    }

    public function addMeta(name:String, params:Array<Expr> = null) {
        if (params == null) {
            params = [];
        }
        if (field.meta == null) {
            field.meta = [];
        }
        field.meta.push({
            name: name,
            params: params,
            pos: classBuilder.pos
        });
    }

    public function getMetaCount(name:String):Int {
        var n = 0;
        for (m in field.meta) {
            if (m.name == name || m.name == ':${name}') {
                n++;
            }
        }
        return n;
    }

    public function getMetaByIndex(name:String, index:Int = 0):MetadataEntry {
        var n = 0;
        for (m in field.meta) {
            if (m.name == name || m.name == ':${name}') {
                if (n == index) {
                    return m;
                }
                n++;
            }
        }
        return null;
    }

    public function getMetaValueString(name:String, paramIndex:Int = 0, metaIndex:Int = 0):String {
        var n = 0;
        for (m in field.meta) {
            if (m.name == name || m.name == ':${name}') {
                if (n == metaIndex) {
                    if (m.params[paramIndex] == null) {
                        return null;
                    }
                    return ExprTools.toString(m.params[paramIndex]);
                }

                n++;
            }
        }
        return null;
    }

    public function getMetaValueExpr(name:String, paramIndex:Int = 0):Expr {
        for (m in field.meta) {
            if (m.name == name || m.name == ':${name}') {
                if (m.params[paramIndex] == null) {
                    return null;
                }
                return m.params[paramIndex];
            }
        }
        return null;
    }

    public function hasMetaParam(name:String, param:String):Bool {
        for (m in field.meta) {
            if (m.name == name || m.name == ':${name}') {
                for (p in m.params) {
                    if (ExprTools.toString(p) == param) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    public function mergeMeta(source:Metadata, exceptions:Array<String>) {
        for (m in source) {
            var use = true;
            for (e in exceptions) {
                if (m.name == e || m.name == ':${e}') {
                    use = false;
                    break;
                }
            }
            if (use == true) {
                if (field.meta == null) {
                    field.meta = [];
                }
                meta.push(m);
            }
        }
    }

    public var doc(get, set):String;
    private function get_doc():String {
        return field.doc;
    }
    private function set_doc(value:String):String {
        field.doc = value;
        return value;
    }

    public var isDynamic(get, null):Bool;
    private function get_isDynamic():Bool {
        switch (type) {
            case TPath(p):
                return (p.name == "Dynamic");
            case _:
        }
        return false;
    }

    public var isVariant(get, null):Bool;
    private function get_isVariant():Bool {
        switch (type) {
            case TPath(p):
                return (p.name == "Variant");
            case _:
        }
        return false;
    }

    public var isComponent(get, null):Bool;
    private function get_isComponent():Bool {
        if (type == null) {
            return false;
        }
        
        #if (haxe_ver < 4)
            switch (type) {
                case TPath(p):
                    if (p.name == "Component" || p.name == "String" || p.name == "Bool" || p.name == "Int" || p.name == "Variant") {
                        return false;
                    }
                case _:    
            }
        #end
        
        var builder = new ClassBuilder(ComplexTypeTools.toType(type));
        return builder.hasSuperClass("haxe.ui.core.Component");
    }
    
    public function hasMeta(name:String):Bool {
        for (m in field.meta) {
            if (m.name == name || m.name == ':${name}') {
                return true;
            }
        }
        return false;
    }
}