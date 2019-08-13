package haxe.ui.core;

import haxe.ui.containers.Box;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;

class ItemRenderer extends Box {
    public function new() {
        super();
        registerEvent(MouseEvent.MOUSE_OVER, _onItemMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, _onItemMouseOut);
    }

    private function _onItemMouseOver(event:MouseEvent) {
        addClass(":hover");
    }

    private function _onItemMouseOut(event:MouseEvent) {
        removeClass(":hover");
    }

    private var _allowHover:Bool = true;
    @clonable public var allowHover(get, set):Bool;
    private function get_allowHover():Bool {
        return _allowHover;
    }
    private function set_allowHover(value:Bool):Bool {
        if (_allowHover == value) {
            return value;
        }
        _allowHover = value;
        if (_allowHover == true) {
            registerEvent(MouseEvent.MOUSE_OVER, _onItemMouseOver);
            registerEvent(MouseEvent.MOUSE_OUT, _onItemMouseOut);
        } else {
            unregisterEvent(MouseEvent.MOUSE_OVER, _onItemMouseOver);
            unregisterEvent(MouseEvent.MOUSE_OUT, _onItemMouseOut);
        }
        return value;
    }

    private var _data:Dynamic;
    public var data(get, set):Dynamic;
    private function get_data():Dynamic {
        return _data;
    }
    private function set_data(value:Dynamic):Dynamic {
        if (value == _data) {
            return value;
        }

        _data = value;
        invalidateComponentData();
        return value;
    }

    public var itemIndex:Int = -1;

    private var _fieldList:Array<String> = null; // is caching a good idea?
    private override function validateComponentData() {
        if (_fieldList == null || _fieldList.length == 0) {
            var fieldList:Array<String> = Reflect.fields(_data);
            if (Type.getClass(_data) != null) {
                var instanceFields = Type.getInstanceFields(Type.getClass(_data));
                for (i in instanceFields) {
                    if (Reflect.isFunction(Reflect.getProperty(_data, i)) == false && fieldList.indexOf(i) == -1) {
                        fieldList.push(i);
                    }
                }
            }
            _fieldList = fieldList;
        }
        
        updateValues(_data, _fieldList);
    }
    
    private function onItemChange(event:UIEvent) {
        var v = event.target.value;
        Reflect.setProperty(_data, event.target.id, v);
    }
    
    private function updateValues(value:Dynamic, fieldList:Array<String> = null) {
        if (fieldList == null) {
            fieldList = Reflect.fields(value);
        }
        
        for (f in fieldList) {
            var v = Reflect.getProperty(value, f);
            if (Type.typeof(v) == TObject) {
                updateValues(v);
            } else {
                var c:Component = findComponent(f, null, true);
                if (c != null && v != null) {
                    var propValue:Dynamic = v;
                    
                    if (propValue == "true" || propValue == "yes" || propValue == "false" || propValue == "no") {
                        propValue = (propValue == "true" || propValue == "yes");
                    } else if (~/^[0-9]*$/i.match(propValue)) {
                        propValue = Std.parseInt(propValue);
                    }
                    
                    c.value = propValue;
                    
                    if (c.hasEvent(UIEvent.CHANGE, onItemChange) == false) {
                        c.registerEvent(UIEvent.CHANGE, onItemChange);
                    }
                    
                    c.show();
                } else if (c != null) {
                    c.hide();
                }
            }
        }
    }
}