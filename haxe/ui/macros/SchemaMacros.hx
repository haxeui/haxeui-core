package haxe.ui.macros;

import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.util.StringUtil;

/*
 current usage: --macro haxe.ui.macros.SchemaMacros.buildComponentsSchema('assets/haxeui.xsd')
 
 if you want to generated schemas for everything, use:
 
--macro include('haxe.ui.components')
--macro include('haxe.ui.containers')
--macro include('haxe.ui.containers.dialogs')
--macro include('haxe.ui.containers.menus')
--macro include('haxe.ui.containers.properties')

note, this will mean you will create ref to every component (TODO)
 
*/

class SchemaMacros {
    #if macro
    private static var filename:String;
    
    public static function buildComponentsSchema(filename:String = null) {
        if (filename == null) {
            filename = "haxeui.xsd";
        }
        SchemaMacros.filename = filename;
        haxe.macro.Context.onGenerate(onTypesGenerated);
    }
    
    private static function onTypesGenerated(types:Array<Type>) {
        var schema = new Schema();
        for (t in types) {
            var classInfo = new ClassBuilder(t);
            if (classInfo.hasSuperClass("haxe.ui.core.ComponentCommon")) {
                switch (t) {
                    case TInst(classType, params):
                        buildSchemaType(classType.get(), schema);
                    case _:
                }
            }
        }
        
        for (t in types) {
            var classInfo = new ClassBuilder(t);
            if (classInfo.hasSuperClass("haxe.ui.core.Component")) {
                switch (t) {
                    case TInst(classType, params):
                        buildSchemaElement(classType.get(), schema);
                    case _:
                }
            }
        }
        
        schema.write(SchemaMacros.filename);
    }
    
    private static function buildSchemaElement(classType:ClassType, schema:Schema) {
        var dox = classType.meta.extract(":dox")[0];
        if (dox != null && ExprTools.toString(dox.params[0]) == "hide") {
            return;
        }
        
        var element = new SchemaElement();
        element.name = buildElementName(classType);
        element.type = classType.name + "Type";
        #if haxeui_schema_debug
        Sys.println("Generating XSD element: " + element.name + " (" + classType.name + ")");
        #end
        schema.elements.push(element);
    }
    
    private static function buildElementName(classType:ClassType) {
        var s = StringUtil.toDashes(classType.name);
        // bit hacky, we dont want VBox to become v-box, we want it to become vbox
        for (p in s.split("-")) {
            if (StringTools.trim(p).length == 1) {
                s = classType.name.toLowerCase();
                break;
            }
        }
        return s;
    }
    
    private static function buildSchemaType(classType:ClassType, schema:Schema) {
        var dox = classType.meta.extract(":dox")[0];
        if (dox != null && ExprTools.toString(dox.params[0]) == "hide") {
            //return;
        }
        
        #if haxeui_schema_debug
        Sys.println("Generating XSD type: " + classType.name + "Type (" + classType.name + ")");
        #end
        var complexType = new SchemaComplexType();
        complexType.name = classType.name + "Type";
        schema.complexTypes.push(complexType);
        if (classType.superClass != null) {
            complexType.extension = classType.superClass.t.get().name + "Type";
            if (complexType.extension == "ComponentSurfaceType") {
                complexType.extension = null;
            }
        }
        var fields = classType.fields.get();
        for (f in fields) {
            if (f.isPublic == false) {
                continue;
            }
            switch (f.kind) {
                case FVar(read, write):
                    if (write != AccNever && write != AccNo) {
                        var attr = new SchemaAttribute();
                        attr.name = f.name;
                        attr.type = typeToSchemaType(f.type, f.name);
                        if (StringTools.startsWith(attr.name, "on")) {
                            attr.name = attr.name.toLowerCase();
                        }
                        if (attr.type != null) {
                            complexType.attributes.push(attr);
                            
                            if (f.doc != null) {
                                var fixedDoc = StringTools.trim(f.doc);
                                if (StringTools.startsWith(fixedDoc, "*")) {
                                    fixedDoc = StringTools.trim(fixedDoc.substr(1));
                                }
                                fixedDoc = StringTools.replace(fixedDoc, "&", "&amp;");
                                attr.documentation = fixedDoc;
                            }
                            
                            // some special cases
                            if (attr.name == "styleString") {
                                attr.name = "style";
                            } else if (attr.name == "styleNames") {
                                var copy = new SchemaAttribute();
                                copy.name = "styleName";
                                copy.type = attr.type;
                                copy.documentation = attr.documentation;
                                complexType.attributes.push(copy);
                            }
                        }
                    }
                case _:    
            }
        }
    }
    
    private static function typeToSchemaType(t:Type, fieldName:String):String {
        var s = null;
        switch (t) {
            case TInst(classType, _):
                if (classType.get().name == "String") {
                    s = "xs:string";
                }
            case TAbstract(t, params):
                var name = t.get().name;
                if (name == "Bool") {
                    s = "xs:boolean";
                } else if (name == "Int") {
                    s = "xs:int";
                } else if (name == "Float") {
                    s = "xs:float";
                } else if (name == "Color") {
                    s = "xs:string";
                } else if (params != null && params.length == 1) {
                    switch (params[0]) {
                        case TInst(classType, _):
                            if (classType.get().name == "String") {
                                s = "xs:string";
                            }
                        case TAbstract(t2, params):    
                            var name = t2.get().name;
                            if (name == "Bool") {
                                s = "xs:boolean";
                            } else if (name == "Int") {
                                s = "xs:int";
                            } else if (name == "Float") {
                                s = "xs:float";
                            } else if (name == "Color") {
                                s = "xs:string";
                            } else {
                                //trace("UNKNOWN: ", fieldName, t2.get().name);
                            }
                        case _:
                            //trace("UNKNOWN: ", fieldName, t.get().type);
                    }
                } else {
                    switch (t.get().type) {
                        case TInst(classType, _):
                            if (classType.get().name == "String") {
                                s = "xs:string";
                            }
                        case TEnum(t, params):
                            if (t.get().name == "VariantType") {
                                s = "xs:string";
                            }
                        case _:    
                            //trace("UNKNOWN: ", fieldName, t.get().type);
                    }
                }
            case TDynamic(t):
                s = "xs:string";
            case TFun(args, ret):
                s = "xs:string";
            case _:    
                //trace("UNKNOWN2: ", fieldName, t);
        }
        return s;
    }
    #end
}

private class Schema {
    public var elements:Array<SchemaElement> = [];
    public var complexTypes:Array<SchemaComplexType> = [];
    
    public function new() {
    }
    
    public function write(path:String) {
        var sb = new StringBuf();
        sb.add('<?xml version="1.0" encoding="UTF-8"?>\n');
        sb.add('<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">\n');

        for (element in elements) {
            element.writeTo(sb);
        }
        
        for (complexType in complexTypes) {
            complexType.writeTo(sb);
        }
        
        sb.add('</xs:schema>\n');
        var s = sb.toString();
        sys.io.File.saveContent(path, s);
    }
}

private class SchemaElement {
    public var name:String = null;
    public var type:String = null;
    public var documentation:String = null;
    
    public function new() {
    }
    
    public function writeTo(sb:StringBuf) {
        sb.add('    <xs:element name="${name}" type="${type}">\n');
        sb.add('    </xs:element>\n\n');
    }
}

private class SchemaComplexType {
    public var name:String = null;
    public var extension:String = null;
    public var attributes:Array<SchemaAttribute> = [];
    
    public function new() {
    }
    
    public function writeTo(sb:StringBuf) {
        sb.add('    <xs:complexType name="${name}">\n');
        if (extension == null) {
            sb.add('        <xs:sequence>\n');
            sb.add('            <xs:any maxOccurs="unbounded" minOccurs="0" processContents="lax" />\n');
            sb.add('        </xs:sequence>\n');
            for (attribute in attributes) {
                attribute.writeTo(sb);
            }
        } else {
            sb.add('        <xs:complexContent>\n');
            sb.add('            <xs:extension base="${extension}">\n');
            sb.add('                <xs:sequence>\n');
            sb.add('                    <xs:any maxOccurs="unbounded" minOccurs="0" processContents="lax" />\n');
            sb.add('                </xs:sequence>\n');
            for (attribute in attributes) {
                attribute.writeTo(sb, 4);
            }
            sb.add('            </xs:extension>\n');
            sb.add('        </xs:complexContent>\n');
        }
        sb.add('    </xs:complexType>\n\n');
    }
}

private class SchemaAttribute {
    public var name:String = null;
    public var type:String = "xs:string";
    public var documentation:String = null;
    
    public function new() {
    }
    
    public function writeTo(sb:StringBuf, indent:Int = 2) {
        var space = StringTools.lpad("", " ", 4 * indent);
        
        sb.add(space);
        sb.add('<xs:attribute name="${name}" type="${type}">\n');
        if (documentation != null && documentation.length > 0) {
            sb.add(space);
            sb.add('    <xs:annotation>\n');
            sb.add(space);
            sb.add('        <xs:documentation>${documentation}</xs:documentation>\n');
            sb.add(space);
            sb.add('    </xs:annotation>\n');
        }
        sb.add(space);
        sb.add('</xs:attribute>\n');
    }
}

