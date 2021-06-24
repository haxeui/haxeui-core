package haxe.ui.binding;

import haxe.ui.Toolkit;
import haxe.ui.core.Component;
import haxe.ui.core.TypeMap;
import haxe.ui.locale.LocaleManager;
import haxe.ui.scripting.ScriptInterp;
import haxe.ui.themes.ThemeManager;
import haxe.ui.util.Variant;
import hscript.Expr;
import hscript.Parser;

class PropertyInfo {
    public var name:String;
    public var script:String;
    public var languageBinding:Bool = false;

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
    
    public function reset() {
        objects = new Map<String, Array<String>>();
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
            array = [];
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
        addStaticClass("theme", ThemeManager.instance);
        addStaticClass("lookupLocaleString", LocaleManager.instance.lookupString);
    }

    public function refreshAll() {
        for (c in bindingInfo.keys()) {
            refreshFor(c);
        }
    }
    
    public function refreshFor(c:Component) {
        if (bindingInfo.exists(c) == false) {
            return;
        }
        
        var info:BindingInfo = bindingInfo.get(c);
        for (propName in info.props.keys()) {
            var propInfo:PropertyInfo = info.props.get(propName);
            handleProp(c, propInfo);
        }
    }

    public function addStaticClass(name:String, c:Dynamic) {
        interp.variables.set(name, c);
    }

    public function add(c:Component, prop:String, script:String) {
        if (c.isReady == false) {
            Toolkit.callLater(function() {
                add(c, prop, script);
            });
            return;
        }

        if (hasBindingInfo(c, prop, script) == true) {
            return;
        }
        
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

    public function findLanguageBinding(c:Component, prop:String):PropertyInfo {
        var info = bindingInfo.get(c);
        if (info == null) {
            return null;
        }
        
        var propInfo:PropertyInfo = info.props.get(prop);
        return propInfo;
    }
    
    public function addLanguageBinding(c:Component, prop:String, script:String, overwrite:Bool = true) {
        if (hasBindingInfo(c, prop, script) == true && overwrite == false) {
            return;
        }
        
        var n1:Int = script.indexOf("{{");
        while (n1 != -1) {
            var n2:Int = script.indexOf("}}", n1);
            var scriptPart:String = script.substr(n1 + 2, n2 - n1 - 2);
            scriptPart = buildLocaleScript(scriptPart);
            var parser:Parser = new Parser();
            var expr:Expr = parser.parseString(scriptPart);

            var info = bindingInfo.get(c);
            if (info == null) {
                info = new BindingInfo();
                bindingInfo.set(c, info);
            }
            var propInfo:PropertyInfo = info.props.get(prop);
            if (propInfo == null) {
                propInfo = info.addProp(prop, script);
            } else {
                propInfo.reset();
                propInfo.script = script;
            }

            propInfo.languageBinding = true;
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

            n1 = script.indexOf("{{", n2);
        }
    }

    public function remove(c:Component) {
        bindingInfo.remove(c);
    }
    
    public function cloneBinding(from:Component, to:Component) {
        var info = bindingInfo.get(from);
        if (info == null) {
            return;
        }
        
        for (prop in info.props.keys()) {
            var propInfo = info.props.get(prop);
            if (propInfo.languageBinding == false) {
                add(to, prop, propInfo.script);
            } else {
                addLanguageBinding(to, prop, propInfo.script);
            }
        }
    }
    
    private function hasBindingInfo(c:Component, prop:String, script:String):Bool {
        var info = bindingInfo.get(c);
        if (info == null) {
            return false;
        }
        
        if (info.props.exists(prop) == false) {
            return false;
        }
        
        var bindingScript = info.props.get(prop);
        return bindingScript.script == script;
    }
    
    private function isLocaleString(script:String):Bool {
        return LocaleManager.instance.hasString(StringTools.trim(script.split(",")[0]));
    }
    
    private function buildLocaleScript(script:String):String {
        if (script == null) {
            return null;
        }
        if (script.length == 0) {
            return script;
        }
        if (StringTools.startsWith(script, "lookupLocaleString(")) {
            return script;
        }
        var params = script.split(",");
        script = "lookupLocaleString('" + params[0] + "'";
        params.shift();
        if (params.length > 0) {
            script += ",";
            script += params.join(",");
        }
        script += ")";
        return script;
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
        } else if (TypeMap.getTypeInfo(t.className, prop.name) == "Variant") {
            result = Variant.fromDynamic(result);
        }

        Reflect.setProperty(t, prop.name, result);
    }

    private function interpolate(s:String, prop:PropertyInfo, t:Component):String {
        var copy:String = s;
        copy = StringTools.replace(copy, "{{", "${");
        copy = StringTools.replace(copy, "}}", "}");
        var n1:Int = copy.indexOf("${");
        while (n1 != -1) {
            var n2:Int = copy.indexOf("}", n1);
            var before:String = copy.substr(0, n1);
            var after:String = copy.substr(n2 + 1, copy.length);
            var script:String = copy.substr(n1 + 2, n2 - n1 - 2);

            var result:Any = exec(script, prop, t);

            copy = before + result + after;
            n1 = copy.indexOf("${");
        }
        return copy;
    }

    private var interp:ScriptInterp = new ScriptInterp();
    private function exec(script:String, prop:PropertyInfo, t:Component):Dynamic {
        if (isLocaleString(script)) {
            script = buildLocaleScript(script);
        }
        var parser = new Parser();
        var expr = parser.parseString(script);

        var root = findRoot(t);
        for (objectId in prop.objects.keys()) {
            var object = root.findComponent(objectId, Component);
            if (object != null) {
                interp.variables.set(objectId, object);
            }
        }
        interp.variables.set("this", t);

        var result:Dynamic = null;
        try {
            result = interp.expr(expr);
        } catch (e:Dynamic) {
            #if debug
            trace(e);
            #end
        }
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
        #if hscriptPos
        var ex = expr.e;
        #else
        var ex = expr;
        #end
        switch (ex) {
            case ECall(_, params):
                for (p in params) {
                    extractFields(p, propInfo);
                }
            case EField(o, fieldId):
                #if hscriptPos
                var oe = o.e;
                #else
                var oe = o;
                #end
                switch (oe) {
                    case EIdent(objectId):
                        propInfo.addObject(objectId, fieldId);
                    case EField(o, fieldId):    
                        #if hscriptPos
                        var oe = o.e;
                        #else
                        var oe = o;
                        #end
                        switch (oe) {
                            case EIdent(objectId):
                                propInfo.addObject(objectId, fieldId);
                            case _:    
                        }
                    case _:    
                }
                /*
            case EField(EIdent(objectId), fieldId):
                propInfo.addObject(objectId, fieldId);
                */
                /*
            case EField(EField(EIdent(objectId), fieldId), _):
                propInfo.addObject(objectId, fieldId);
               */
            case EIdent(objectId):
                propInfo.addObject(objectId, "value");
            case EBinop(_, e1, e2):
                extractFields(e1, propInfo);
                extractFields(e2, propInfo);
            case EUnop(_, _, e):
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