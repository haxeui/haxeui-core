package haxe.ui.core;

import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.containers.Box;
import haxe.ui.core.TypeMap;
import haxe.ui.events.ItemEvent;
import haxe.ui.events.ItemRendererEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Color;
import haxe.ui.util.TypeConverter;
import haxe.ui.util.Variant;

class ItemRenderer extends Box {
    @:clonable public var autoRegisterInteractiveEvents:Bool = true;
    @:clonable public var recursiveStyling:Bool = false;
    
    public function new() {
        super();
        registerEvent(MouseEvent.MOUSE_OVER, _onItemMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, _onItemMouseOut);
        registerEvent(MouseEvent.MOUSE_DOWN, _onItemMouseDown);
        registerEvent(MouseEvent.MOUSE_UP, _onItemMouseUp);
    }

    private function _onItemMouseOver(event:MouseEvent) {
        addClass(":hover", true, recursiveStyling);
        if (!recursiveStyling) {
            for (c in findComponents(Label)) {
                c.addClass(":hover");
            }
            for (c in findComponents(Image)) {
                c.addClass(":hover");
            }
        }
    }

    private function _onItemMouseOut(event:MouseEvent) {
        removeClass(":hover", true, recursiveStyling);
        if (!recursiveStyling) {
            for (c in findComponents(Label)) {
                c.removeClass(":hover");
            }
            for (c in findComponents(Image)) {
                c.removeClass(":hover");
            }
        }
    }

    private function _onItemMouseDown(event:MouseEvent) {
        addClass(":down", true, recursiveStyling);
        if (!recursiveStyling) {
            for (c in findComponents(Label)) {
                c.addClass(":down");
            }
            for (c in findComponents(Image)) {
                c.addClass(":down");
            }
        }
    }

    private function _onItemMouseUp(event:MouseEvent) {
        removeClass(":down", true, recursiveStyling);
        if (!recursiveStyling) {
            for (c in findComponents(Label)) {
                c.removeClass(":down");
            }
            for (c in findComponents(Image)) {
                c.removeClass(":down");
            }
        }
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

        var components = [];
        var componentsToHide = [];
        updateValues(_data, _fieldList,componentsToHide, components );
        for (c in components) {
            if (componentsToHide.contains(c)) {
                c.hide();
            } else {
                c.show();
            }
        }

        if (autoRegisterInteractiveEvents) {
            var components = findComponents(InteractiveComponent);
            for (c in components) {
                if (c.hasEvent(MouseEvent.CLICK, onItemClick) == false) {
                    c.registerEvent(MouseEvent.CLICK, onItemClick);
                }
                if (c.hasEvent(UIEvent.CHANGE, onItemChange) == false) {
                    c.registerEvent(UIEvent.CHANGE, onItemChange);
                }
            }
        }
        
        onDataChanged(_data);
        var event = new ItemRendererEvent(ItemRendererEvent.DATA_CHANGED, this);
        dispatch(event);
    }

    private function onDataChanged(data:Dynamic) {
        _data = data;
    }
    
    private function onItemChange(event:UIEvent) {
        if (itemIndex < 0) {
            return; 
        }
        var v = event.target.value;
        if (_data != null && event.target.id != null) {
            var item:Dynamic = Reflect.getProperty(_data, event.target.id);
            switch (Type.typeof(item)) {
                case TObject:
                    item.value = v;
                case _:
                    Reflect.setProperty(_data, event.target.id, v);
            }
        }

        var e = new ItemEvent(ItemEvent.COMPONENT_EVENT);
        e.bubble = true;
        e.source = event.target;
        e.sourceEvent = event;
        e.itemIndex = itemIndex;
        e.data = _data;
        dispatch(e);

        var e2 = new ItemEvent(ItemEvent.COMPONENT_CHANGE_EVENT);
        e2.bubble = true;
        e2.source = event.target;
        e2.sourceEvent = event;
        e2.itemIndex = itemIndex;
        e2.data = _data;
        dispatch(e2);
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

        var e2 = new ItemEvent(ItemEvent.COMPONENT_CLICK_EVENT);
        e2.bubble = true;
        e2.source = event.target;
        e2.sourceEvent = event;
        e2.itemIndex = itemIndex;
        e2.data = _data;
        dispatch(e2);
    }

    private function updateValues(value:Dynamic, fieldList:Array<String> = null, componentsToHide:Array<Component> = null, components:Array<Component> = null) {
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

        if (componentsToHide == null) componentsToHide = [];
        if (components == null) components = [];
        for (f in fieldList) {
            var property:String = "value";
            var v = Reflect.getProperty(valueObject, f);
            var componentId = f;
            var n = f.indexOf(".");
            if (n != -1) {
                componentId = f.substring(0, n);
                property = f.substring(n + 1);
            }
            var c:Component = findComponent(componentId, null, true);
            if (c != null && v != null) {
                components.push(c);
                switch (Type.typeof(v)) {
                    case TObject:
                        for (valueField in Reflect.fields(v)) {
                            var valueFieldValue = Reflect.field(v, valueField);   
                            setComponentProperty(c, valueFieldValue, valueField);
                            if (valueField == "hidden" && valueFieldValue == true) {
                                componentsToHide.push(c);
                            }
                        }
                    case _:
                        setComponentProperty(c, v, property);
                        if (property == "hidden" && v == "true") {
                            componentsToHide.push(c);
                        }
                }
            } else if (f != "id" && f != "layout") {
                try {
                    Reflect.setProperty(this, f, v);
                } catch (e:Dynamic) {}
            } else if (Type.typeof(v) == TObject) {
                updateValues(v, componentsToHide, components);
            }
        }
    }

    private function setComponentProperty(c:Component, v:Any, property:String) {
        var typeInfo = TypeMap.getTypeInfo(c.className, property);
        var propValue = TypeConverter.convertTo(v, typeInfo);
        if (property == "value") {
            c.value = propValue;
        } else if (typeInfo == "variant") {
            Reflect.setProperty(c, property, Variant.fromDynamic(propValue));
        } else {
            Reflect.setProperty(c, property, propValue);
        }

        if (autoRegisterInteractiveEvents) {
            if ((c is InteractiveComponent) || (c is ItemRenderer)) {
                if (c.hasEvent(UIEvent.CHANGE, onItemChange) == false) {
                    c.registerEvent(UIEvent.CHANGE, onItemChange);
                }
                if (c.hasEvent(MouseEvent.CLICK, onItemClick) == false) {
                    c.registerEvent(MouseEvent.CLICK, onItemClick);
                }
            }
        }
    }
}
