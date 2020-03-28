package haxe.ui.binding;

import haxe.ui.core.Component;
import haxe.ui.scripting.ScriptInterp;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

class PropertyInfo {
    public var name:String;
    public var script:String;
    
    public var objects:Map<String, Array<String>> = new Map<String, Array<String>>();
    
    public function new() {
    }
    
    public function addObject(objectId:String, objectProp:String) {
        var array:Array<String> = objects.get(objectId);
        if (array == null) {
            array = [];
            objects.set(objectId, array);
        }
        if (array.indexOf(objectProp) == -1) {
            array.push(objectProp);
        }
    }
}

class TargetInfo {
    public var props:Map<String, Map<Component, Array<PropertyInfo>>> = new Map<String, Map<Component, Array<PropertyInfo>>>();
    
    public function new() {
    }
    
    public function addBinding(sourceProp:String, target:Component, targetProp:PropertyInfo) {
        var map:Map<Component, Array<PropertyInfo>> = props.get(sourceProp);
        if (map == null) {
            map = new Map<Component, Array<PropertyInfo>>();
            props.set(sourceProp, map);
        }
        
        var array = map.get(target);
        if (array == null) {
            array = new Array<PropertyInfo>();
            map.set(target, array);
        }

        array.push(targetProp);
    }
}

class BindingInfo {
    public var props:Map<String, PropertyInfo> = new Map<String, PropertyInfo>();
    
    public function new() {
    }
    
    public function addProp(name:String, script:String):PropertyInfo {
        var p = props.get(name);
        if (p == null) {
            p = new PropertyInfo();
            p.name = name;
            p.script = script;
            props.set(name, p);
        }
        return p;
    }
}

class BindingManager {
    private static var _instance:BindingManager = null;
    public static var instance(get, null):BindingManager;
    private static function get_instance():BindingManager {
        if (_instance == null) {
            _instance = new BindingManager();
        }
        return _instance;
    }
    
    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    private static var bindingInfo:Map<Component, BindingInfo> = new Map<Component, BindingInfo>();
    private static var targets:Map<String, TargetInfo> = new Map<String, TargetInfo>();
    
    private function new() {
    }
    
    public function add(c:Component, prop:String, script:String) {
        var n1:Int = script.indexOf("${");
        while (n1 != -1) {
            var n2:Int = script.indexOf("}", n1);
            var scriptPart:String = script.substr(n1 + 2, n2 - n1 - 2);
        
            var parser:Parser = new Parser();
            var expr:Expr = parser.parseString(scriptPart);
            
            var info = bindingInfo.get(c);
            if (info == null) {
                info = new BindingInfo();
                bindingInfo.set(c, info);
            }

            var propInfo:PropertyInfo = info.addProp(prop, script);
            extractFields(expr, propInfo);
            for (objectId in propInfo.objects.keys()) {
                for (fieldId in propInfo.objects.get(objectId)) {
                    var targetInfo = targets.get(objectId);
                    if (targetInfo == null) {
                        targetInfo = new TargetInfo();
                        targets.set(objectId, targetInfo);
                    }
                    targetInfo.addBinding(fieldId, c, propInfo);
                }
            }
            handleProp(c, propInfo);
            
            n1 = script.indexOf("${", n2);
        }
    }
    
    public function componentPropChanged(c:Component, prop:String) {
        if (c == null || c.id == null) {
            return;
        }
        
        var targetInfo = targets.get(c.id);
        if (targetInfo == null) {
            return;
        }
        
        var map:Map<Component, Array<PropertyInfo>> = targetInfo.props.get(prop);
        if (map == null) {
            return;
        }

        for (t in map.keys()) {
            var array:Array<PropertyInfo> = map.get(t);
            for (prop in array) {
                handleProp(t, prop);
            }
        }
    }
    
    private function handleProp(t:Component, prop:PropertyInfo) {
        var result:Dynamic = interpolate(prop.script, prop, t);
        var currentType = Type.typeof(Reflect.getProperty(t, prop.name));
        if (currentType == TFloat) {
            result = Std.parseFloat(Std.string(result));
        } else if (currentType == TInt) {
            result = Std.parseInt(Std.string(result));
        } else if (currentType == TBool) {
            result = (Std.string(result) == "true");
        }
        
        Reflect.setProperty(t, prop.name, result);
    }
    
    private function interpolate(s:String, prop:PropertyInfo, t:Component):String {
        var copy:String = s;
        var n1:Int = copy.indexOf("${");
        while (n1 != -1) {
            var n2:Int = copy.indexOf("}", n1);
            var before:String = copy.substr(0, n1);
            var after:String = copy.substr(n2 + 1, copy.length);
            var script:String = copy.substr(n1 + 2, n2 - n1 - 2);
            
            var result = exec(script, prop, t);
            copy = before + result + after;
            n1 = copy.indexOf("${");
        }
        return copy;
    }

    private var interp = new ScriptInterp();
    private function exec(script:String, prop:PropertyInfo, t:Component) {
        var parser = new Parser();
        var expr = parser.parseString(script);
        
        var root = findRoot(t);
        for (objectId in prop.objects.keys()) {
            interp.variables.set(objectId, root.findComponent(objectId));
        }
        interp.variables.set("this", t);
        
        var result:Dynamic = null;
        try {
            result = interp.expr(expr);
        } catch (e:Dynamic) { }
        return result;
    }
    
    private function findRoot(c:Component):Component {
        var root = c;
        
        var ref = c;
        while (ref != null) {
            root = ref;
            if (root.bindingRoot) {
                break;
            }
            ref = ref.parentComponent;
        }
        
        return root;
    }
    
    private function extractFields(expr:Expr, propInfo:PropertyInfo) {
        switch (expr) {
            case ECall(e, params):
                for (p in params) {
                    extractFields(p, propInfo);
                }
            case EField(EIdent(objectId), fieldId):
                propInfo.addObject(objectId, fieldId);
            case EField(EField(EIdent(objectId), fieldId), _):
                propInfo.addObject(objectId, fieldId);
            case EIdent(objectId):
                propInfo.addObject(objectId, "value");
            case EBinop(op, e1, e2):    
                extractFields(e1, propInfo);
                extractFields(e2, propInfo);
            case EUnop(op, prefix, e):     
                extractFields(e, propInfo);
            case EArrayDecl(values):
                for (v in values) {
                    extractFields(v, propInfo);
                }
            case EConst(_):
            case _:
                trace(expr);
        }
    }
}