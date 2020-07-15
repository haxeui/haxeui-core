package haxe.ui.core;

import haxe.ui.components.Button;
import haxe.ui.containers.Box;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.TypeConverter;

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
            switch (Type.typeof(_data)) {
                case TObject | TClass(_):
                    var fieldList:Array<String> = Reflect.fields(_data);
                    if (Type.getClass(_data) != null) {
                        var instanceFields = Type.getInstanceFields(Type.getClass(_data));
                        for (i in instanceFields) {
                            if (Reflect.isFunction(Reflect.getProperty(_data, i)) == false && fieldList.indexOf(i) == -1) {
                                fieldList.push(i);
                            }
                        }
                        _fieldList = fieldList;
                    }
                case _:    
                    _fieldList = ["text"];
            }
        }
        
        trace(Type.typeof(_data));
        updateValues(_data, _fieldList);
        
        var components = findComponents(InteractiveComponent);
        for (c in components) {
            if (Std.is(c, Button)) {
                if (c.hasEvent(MouseEvent.CLICK, onItemClick) == false) {
                    c.registerEvent(MouseEvent.CLICK, onItemClick);
                }
            } else {
                if (c.hasEvent(UIEvent.CHANGE, onItemChange) == false) {
                    c.registerEvent(UIEvent.CHANGE, onItemChange);
                }
            }
        }
    }
    
    private function onItemChange(event:UIEvent) {
        var v = event.target.value;
        if (_data != null) {
            Reflect.setProperty(_data, event.target.id, v);
        }
        var e = new ItemEvent(ItemEvent.COMPONENT_EVENT);
        e.bubble = true;
        e.source = event.target;
        e.sourceEvent = event;
        e.data = _data;
        dispatch(e);
    }
    
    private function onItemClick(event:UIEvent) {
        var e = new ItemEvent(ItemEvent.COMPONENT_EVENT);
        e.bubble = true;
        e.source = event.target;
        e.sourceEvent = event;
        e.data = _data;
        dispatch(e);
    }
    
    private function updateValues(value:Dynamic, fieldList:Array<String> = null) {
        if (fieldList == null) {
            fieldList = Reflect.fields(value);
        }
        
        var valueObject = null;
        switch (Type.typeof(value)) {
            case TObject | TClass(_):
                valueObject = value;
            case _:
                valueObject = {text: value};
        }

        for (f in fieldList) {
            var v = Reflect.getProperty(valueObject, f);
            if (Type.typeof(v) == TObject) {
                updateValues(v);
            } else {
                var c:Component = findComponent(f, null, true);
                if (c != null && v != null) {
                    var propValue:Dynamic = TypeConverter.convert(v);
                    c.value = propValue;
                    
                    if (c.hasEvent(UIEvent.CHANGE, onItemChange) == false) {
                        c.registerEvent(UIEvent.CHANGE, onItemChange);
                    }
                    if (c.hasEvent(MouseEvent.CLICK, onItemClick) == false) {
                        c.registerEvent(MouseEvent.CLICK, onItemClick);
                    }
                    
                    c.show();
                } else if (c != null) {
                    c.hide();
                }
            }
        }
    }
}