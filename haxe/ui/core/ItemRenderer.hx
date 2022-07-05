package haxe.ui.core;

import haxe.ui.components.Button;
import haxe.ui.containers.Box;
import haxe.ui.core.TypeMap;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.TypeConverter;

class ItemRenderer extends Box {
    public function new() {
        super();
        registerEvent(MouseEvent.MOUSE_OVER, _onItemMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, _onItemMouseOut);
        registerEvent(MouseEvent.MOUSE_DOWN, _onItemMouseDown);
        registerEvent(MouseEvent.MOUSE_UP, _onItemMouseUp);
    }

    private function _onItemMouseOver(event:MouseEvent) {
        addClass(":hover");
    }

    private function _onItemMouseOut(event:MouseEvent) {
        removeClass(":hover");
    }

    private function _onItemMouseDown(event:MouseEvent) {
        addClass(":down");
    }

    private function _onItemMouseUp(event:MouseEvent) {
        removeClass(":down");
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
        _data = value;
        invalidateComponentData();
        return value;
    }

    public var itemIndex:Int = -1;

    private var _fieldList:Array<String> = null; // is caching a good idea?
    private override function validateComponentData() {
        if (_data != null && (_fieldList == null || _fieldList.length == 0)) {
            switch (Type.typeof(_data)) {
                case TObject | TClass(_):
                    if ((_data is String) == false) {
                        var fieldList:Array<String> = Reflect.fields(_data);
                        if (Type.getClass(_data) != null) {
                            var instanceFields = Type.getInstanceFields(Type.getClass(_data));
                            for (i in instanceFields) {
                                if (fieldList.indexOf(i) == -1 && Reflect.isFunction(Reflect.getProperty(_data, i)) == false) {
                                    fieldList.push(i);
                                } else if (StringTools.startsWith(i, "get_") && fieldList.indexOf(i.substr(4)) == -1 && Reflect.isFunction(Reflect.getProperty(_data, i)) == true) {
                                    fieldList.push(i.substr(4));
                                }
                            }
                            _fieldList = fieldList;
                        }
                    } else {
                        _fieldList = ["text"];
                    }
                case _:
                    _fieldList = ["text"];
            }
        }

        updateValues(_data, _fieldList);

        var components = findComponents(InteractiveComponent);
        for (c in components) {
            if ((c is Button)) {
                if (c.hasEvent(MouseEvent.CLICK, onItemClick) == false) {
                    c.registerEvent(MouseEvent.CLICK, onItemClick);
                }
            } else {
                if (c.hasEvent(UIEvent.CHANGE, onItemChange) == false) {
                    c.registerEvent(UIEvent.CHANGE, onItemChange);
                }
            }
        }
        
        onDataChanged(_data);
    }

    private function onDataChanged(data:Dynamic) {
        _data = data;
    }
    
    private function onItemChange(event:UIEvent) {
        if (itemIndex < 0) {
            return; 
        }
        var v = event.target.value;
        if (_data != null) {
            Reflect.setProperty(_data, event.target.id, v);
        }
        var e = new ItemEvent(ItemEvent.COMPONENT_EVENT);
        e.bubble = true;
        e.source = event.target;
        e.sourceEvent = event;
        e.itemIndex = itemIndex;
        e.data = _data;
        dispatch(e);
    }

    private function onItemClick(event:UIEvent) {
        if (itemIndex < 0) {
            return; 
        }
        var e = new ItemEvent(ItemEvent.COMPONENT_EVENT);
        e.bubble = true;
        e.source = event.target;
        e.sourceEvent = event;
        e.itemIndex = itemIndex;
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
                if ((value is String) == false) {
                    valueObject = value;
                } else {
                    valueObject = {text: value};
                }
            case _:
                valueObject = {text: value};
        }

        for (f in fieldList) {
            var v = Reflect.getProperty(valueObject, f);
            var c:Component = findComponent(f, null, true);
            if (c != null && v != null) {
                var propValue = TypeConverter.convertTo(v, TypeMap.getTypeInfo(c.className, "value"));
                c.value = propValue;

                if ((c is InteractiveComponent) || (c is ItemRenderer)) {
                    if (c.hasEvent(UIEvent.CHANGE, onItemChange) == false) {
                        c.registerEvent(UIEvent.CHANGE, onItemChange);
                    }
                    if (c.hasEvent(MouseEvent.CLICK, onItemClick) == false) {
                        c.registerEvent(MouseEvent.CLICK, onItemClick);
                    }
                }

                c.show();
            } else if (c != null) {
                c.hide();
            } else if (f != "id" && f != "layout") {
                try {
                    Reflect.setProperty(this, f, v);
                } catch (e:Dynamic) {}
            } else if (Type.typeof(v) == TObject) {
                updateValues(v);
            }
        }
    }
}